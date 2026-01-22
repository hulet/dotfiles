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
-- otherwise deleting text in neovim stops the system clipboard
vim.opt.clipboard = ""
