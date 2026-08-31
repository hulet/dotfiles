-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- no autoformatting, please
vim.g.autoformat = false

-- use absolute line numbers
vim.opt.relativenumber = false

-- no filler character for deleted lines in diff mode
vim.opt.fillchars:append({ diff = " " })

-- Disable the automatic sync with system clipboard
-- otherwise deleting text in neovim stomps the system clipboard
vim.opt.clipboard = ""

-- When launched in diff mode (`nvim -d`, e.g. `git difftool` / nvimdiff), don't
-- start any LSP servers. Avoids the terraformls "editing a single file" warning
-- and the slow startup when opening terraform files in a git diff.
if vim.tbl_contains(vim.v.argv, "-d") then
  vim.lsp.start = function() end
end
