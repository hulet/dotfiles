return {
  {
    "folke/snacks.nvim",
    opts = {
      scroll = {
        -- don't animate page-up and page-down
        enabled = false,
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      on_highlights = function(hl, c)
        -- DiffChange: The background for the whole modified line (Subtle)
        hl.DiffChange = { bg = "#2e334d" }

        -- DiffText: The specific changed characters (High Contrast)
        -- We'll give it a brighter background and a bold font
        hl.DiffText = { bg = "#44508a", fg = "#ff9e64", bold = true }
      end,
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- Don't hide ``` lines in my markdown files
      enabled = false,
    },
  },
  {
    -- no automatic closing characters
    "nvim-mini/mini.pairs",
    enabled = false,
  },
  {
    -- from https://github.com/LazyVim/LazyVim/discussions/6353
    "saghen/blink.cmp",
    optional = true,
    opts = {
      completion = {
        list = {
          selection = {
            -- in insert mode enter should always insert \n
            -- if preselect is enabled, enter will instead often select the first blink.cmp suggestion
            -- e.g. without this `# Notes<CR>` in a .md file will replace `# Notes` with an unordered list
            preselect = false,
          },
        },
      },
    },
  },
}
