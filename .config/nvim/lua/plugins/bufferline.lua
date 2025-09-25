return {return {return {

  {

    "akinsho/bufferline.nvim",  {  {

    opts = function(_, opts)

      -- Override LazyVim's catppuccin bufferline integration to prevent errors    "akinsho/bufferline.nvim",    "akinsho/bufferline.nvim",

      -- The old catppuccin.groups.integrations.bufferline module doesn't exist anymore

      opts.highlights = nil    opts = function(_, opts)    dependencies = { "catppuccin/nvim" },

      return opts

    end,      -- Check if catppuccin is available and loaded    opts = function()

  },

}      local has_catppuccin, catppuccin = pcall(require, "catppuccin.palettes")      return {

              options = {

      if has_catppuccin then          themable = true,

        -- Get the current palette        },

        local palette = catppuccin.get_palette()      }

            end,

        -- Use manual colors instead of the problematic integration    config = function(_, opts)

        opts.highlights = {      -- Load catppuccin first

          background = { bg = palette.mantle, fg = palette.text },      require("catppuccin").load()

          buffer_selected = { bg = palette.base, fg = palette.text, bold = true, italic = false },      

          buffer_visible = { bg = palette.surface0, fg = palette.subtext1 },      -- Then configure bufferline

          close_button = { bg = palette.mantle, fg = palette.overlay0 },      require("bufferline").setup(opts)

          close_button_visible = { bg = palette.surface0, fg = palette.overlay0 },    end,

          close_button_selected = { bg = palette.base, fg = palette.red },  }

          fill = { bg = palette.crust },}
          indicator_selected = { fg = palette.peach, bg = palette.base },
          indicator_visible = { fg = palette.surface2, bg = palette.surface0 },
          modified = { bg = palette.mantle, fg = palette.yellow },
          modified_visible = { bg = palette.surface0, fg = palette.yellow },
          modified_selected = { bg = palette.base, fg = palette.yellow },
          separator = { bg = palette.mantle, fg = palette.crust },
          separator_visible = { bg = palette.surface0, fg = palette.crust },
          separator_selected = { bg = palette.base, fg = palette.crust },
          tab_close = { bg = palette.red, fg = palette.base },
        }
      end
      
      return opts
    end,
  },
}