return {
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
    "folke/snacks.nvim",
    opts = {
      scroll = {
        enabled = false,
      },
    },
  },
}
