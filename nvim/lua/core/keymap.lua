-- 将方向键下映射为向下滚动一行
vim.keymap.set({ "n", "v" }, "<Down>", "<C-e>", { desc = "Scroll down" })
-- 将方向键上映射为向上滚动一行
vim.keymap.set({ "n", "v" }, "<Up>", "<C-y>", { desc = "Scroll up" })
vim.g.mapleader = " "
vim.g.maplocalleader = ","
