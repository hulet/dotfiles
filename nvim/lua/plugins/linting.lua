-- Centralized linter rule suppression across all languages.
-- Add entries to `suppressed` to silence specific rules without external
-- config files. Each key is an nvim-lint linter name; the value is a list
-- of rule code substrings to filter from its diagnostics.
local suppressed = {
  ["markdownlint-cli2"] = { "MD013" },
}

local function make_filtered_parser(linter_module, ignored)
  local orig = require(linter_module).parser
  return function(output, bufnr, linter_cwd)
    return vim.tbl_filter(function(d)
      for _, rule in ipairs(ignored) do
        if d.message:find(rule, 1, true) then return false end
      end
      return true
    end, orig(output, bufnr, linter_cwd))
  end
end

return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      for name, rules in pairs(suppressed) do
        opts.linters[name] = {
          parser = make_filtered_parser("lint.linters." .. name, rules),
        }
      end
      return opts
    end,
  },
}
