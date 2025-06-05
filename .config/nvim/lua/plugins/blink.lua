return {
  {
    "saghen/blink.compat",
    version = "*",
    lazy = true, -- Automatically loads when required by blink.cmp
    opts = {},
  },
  {
    "saghen/blink.cmp",
    dependencies = { "allaman/emoji.nvim", "rafamadriz/friendly-snippets" }, -- Optional snippet support
    version = "*", -- Use a release tag to get pre-built binaries
    opts = {
      keymap = { preset = "default" },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "html-css", "emoji" },
        providers = {
          ["html-css"] = {
            name = "html-css",
            module = "blink.compat.source",
          },
          emoji = {
            name = "emoji",
            module = "blink.compat.source",
            transform_items = function(ctx, items)
              local kind = require("blink.cmp.types").CompletionItemKind.Text
              for i = 1, #items do
                items[i].kind = kind
              end
              return items
            end,
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
