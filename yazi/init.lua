pcall(function()
	require("relative-motions"):setup({
		show_numbers = "relative_absolute",
		show_motion = true,
	})
end)

function Linemode:size_and_mtime()
	local size = self._file:size()
	local size_text = size and ya.readable_size(size) or "-"

	local time = math.floor(self._file.cha.mtime or 0)
	local time_text = "-"
	if time > 0 then
		if os.date("%Y", time) == os.date("%Y") then
			time_text = os.date("%m-%d %H:%M", time)
		else
			time_text = os.date("%Y-%m-%d", time)
		end
	end

	return string.format("%8s  %s", size_text, time_text)
end
