local vim = vim
local nvim = require'mdmath.nvim'
local uv = vim.loop
local marks = require'mdmath.marks'
local util = require'mdmath.util'
local Processor = require'mdmath.Processor'
local Image = require'mdmath.Image'
local hl = require'mdmath.highlight-colors'
local tracker = require'mdmath.tracker'
local terminfo = require'mdmath.terminfo'
local config = require'mdmath.config'.opts

local Equation = util.class 'Equation'
local inline_dynamic_scale = 0.80
local inline_internal_scale = 0.90
local block_dynamic_scale = 0.88
local block_internal_scale = 0.92

local function is_inline_equation(text)
    if text:find('\n') then
        return false
    end

    if text:match('^%$%$.*%$%$$') or text:match('^\\%[.*\\%]$') then
        return false
    end

    if text:match('^%$.*%$$') or text:match('^\\%(.+\\%)$') then
        return true
    end

    return false
end

local function trim(text)
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function is_single_symbol_equation(equation)
    local eq = trim(equation)
    if eq:find("%s") then
        return false
    end

    return eq:match("^\\[%a]+$") ~= nil or eq:match("^[%a%d]$") ~= nil
end

local function is_fraction_equation(equation)
    local eq = trim(equation)
    return eq:match("\\frac") ~= nil
        or eq:match("\\dfrac") ~= nil
        or eq:match("\\tfrac") ~= nil
        or eq:match("\\cfrac") ~= nil
end

local function fraction_unit_height(equation)
    local eq = trim(equation)
    if eq:match("\\dfrac") ~= nil then
        return 3
    end

    if is_fraction_equation(eq) then
        return 2
    end

    return nil
end

function Equation:__tostring()
    return '<Equation>'
end

function Equation:_create(res, err)
    if not res then
        local text = ' ' .. err
        local color = 'Error'
        vim.schedule(function()
            if self.valid then
                self.mark_id = marks.add(self.bufnr, self.pos[1], self.pos[2], {
                    text = { text, self.text:len() },
                    color = color,
                    text_pos = 'eol',
                })
                self.created = true
            end
        end)
        return
    end

    local filename = res.data

    local width = res.width
    local height = res.height

    if self.is_inline then
        vim.schedule(function()
            if not self.valid then
                return
            end

            local image = Image.new(height, width, filename)
            local text = image:text()[1]
            local color = hl[image:color()]

            self.mark_id = marks.add(self.bufnr, self.pos[1], self.pos[2], {
                text = { text, self.text:len() },
                color = color,
                text_pos = "inline",
                inline_compact = true,
            })
            self.image = image
            self.created = true
        end)
        return
    end

    -- Multiline equations
    if self.lines then
        local image = Image.new(height, width, filename)
        local texts = image:text()
        local color = image:color()

        local nlines = #self.lines

        local lines = {}
        for i, text in ipairs(texts) do
            if i <= nlines then
                -- Increase text width to match the original width.
                local padding = self.lines_width[i] - width
                local rtext = padding > 0
                    and text .. (' '):rep(padding)
                    or text

                lines[i] = { rtext, self.lines[i]:len() }
            else
                -- add virtual lines
                lines[i] = { text, -1 }
            end
        end

        for i = #texts + 1, nlines do
            local padding = self.lines_width[i]
            lines[i] = { (' '):rep(padding), self.lines[i]:len() }
        end

        vim.schedule(function()
            if self.valid then
                self.mark_id = marks.add(self.bufnr, self.pos[1], self.pos[2], {
                    lines = lines,
                    color = color,
                    text_pos = 'overlay',
                })
                self.image = image
                self.created = true
            else -- free resources
                image:close()
            end
        end)
    else
        local image = Image.new(height, width, filename)
        local text = image:text()[1]
        local color = image:color()

        vim.schedule(function()
            if self.valid then
                self.mark_id = marks.add(self.bufnr, self.pos[1], self.pos[2], {
                    text = { text, self.text:len() },
                    color = color,
                    text_pos = 'overlay',
                })
                self.image = image
                self.created = true
            else -- free resources
                image:close()
            end
        end)
    end
end

function Equation:_init(bufnr, row, col, text, opts)
    local color = opts and opts.color or config.foreground
    if not color:match("^#%x%x%x%x%x%x$") then
        color = util.hl_as_hex(color)
    end

    if opts and type(opts.inline) == 'boolean' then
        self.is_inline = opts.inline
    else
        self.is_inline = is_inline_equation(text)
    end

    if text:find('\n') then
        local lines = vim.split(text, '\n')
        -- Only support rectangular equations
        if util.linewidth(bufnr, row) ~= lines[1]:len() or util.linewidth(bufnr, row + #lines - 1) ~= lines[#lines]:len() then
            return false
        end

        local width = 0
        local lines_width = {}
        for i, line in ipairs(lines) do
            local w = util.strwidth(line)
            width = math.max(width, w)
            lines_width[i] = w
        end
        self.lines = lines
        self.lines_width = lines_width
        self.width = width
    elseif not self.is_inline and util.linewidth(bufnr, row) == text:len() then
        -- Treat single line equations as a special case
        self.width = util.strwidth(text)
        self.lines = { text }
        self.lines_width = { self.width }
    end

    self.bufnr = bufnr
    -- TODO: pos should be shared with the mark
    self.pos = tracker.add(bufnr, row, col, text:len())
    self.pos.on_finish = function()
        self:invalidate()
    end

    self.text = text
    if not self.lines then
        self.width = util.strwidth(text)
    end
    self.created = false
    self.valid = true
    self.color = color

    -- remove trailing '$'
    self.equation = text:gsub('^%$*(.-)%$*$', '%1')

    local cell_width, cell_height = terminfo.cell_size()

    local flags, height, request_width
    local dynamic_scale = block_dynamic_scale
    local internal_scale = block_internal_scale
    if self.is_inline then
        flags = 3 -- dynamic + centered
        height = 1
        request_width = 1
        dynamic_scale = inline_dynamic_scale
        internal_scale = inline_internal_scale
    elseif self.lines then
        if is_single_symbol_equation(self.equation) then
            height = 1
            dynamic_scale = inline_dynamic_scale
            internal_scale = inline_internal_scale
        elseif is_fraction_equation(self.equation) then
            height = fraction_unit_height(self.equation) or 2
        else
            height = math.max(1, #self.lines)
        end

        flags = 1 -- dynamic
        request_width = 1
    else
        height = 1
        flags = 2 -- centered
        request_width = self.width
    end

    local processor = Processor.from_bufnr(bufnr)
    processor:setDynamicScale(dynamic_scale)
    processor:setInternalScale(internal_scale)
    processor:request(self.equation, cell_width, cell_height, request_width, height, flags, color, function(res, err)
        if self.valid then
            self:_create(res, err)
        end
    end)
end

-- TODO: should we call invalidate() on '__gc'?
function Equation:invalidate()
    if not self.valid then
        return
    end
    self.valid = false
    if not self.created then
        return
    end

    self.pos:cancel()
    if self.mark_id then
        marks.remove(self.bufnr, self.mark_id)
    end
    if self.image then
        self.image:close()
    end
    self.mark_id = nil
end

return Equation
