# 🍁 Drop

Fun little plugin that can be used as a screensaver and on your dashboard.

https://user-images.githubusercontent.com/292349/198695517-c834a9c5-8acc-4a47-9f1d-277085169754.mp4

## Features

- automatically enables/disables on dashboard plugins:
  - [mini.starter](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-starter.md)
  - [alpha-nvim](https://github.com/goolord/alpha-nvim)
  - [dashboard-nvim](https://github.com/glepnir/dashboard-nvim)
- runs as a screen saver when no there is no activity for a specified amount of time
- currently, two themes available: `"leaves"` & `"snow"`

## ⚡️ Requirements

- Neovim >= 0.8.0
- a [Nerd Font](https://www.nerdfonts.com/)

## 📦 Installation

Install the plugin with your preferred package manager:

```lua
-- Packer
use({
  "folke/drop.nvim",
  event = "VimEnter",
  config = function()
    require("drop").setup()
  end,
})
```

## ⚙️ Configuration

**noice.nvim** comes with the following defaults:

```lua
{
  ---@type DropTheme|string
  theme = "leaves", -- can be one of rhe default themes, or a custom theme
  max = 40, -- maximum number of drops on the screen
  interval = 150, -- every 150ms we update the drops
  screensaver = 1000 * 60 * 5, -- show after 5 minutes. Set to false, to disable
  filetypes = { "dashboard", "alpha", "starter" }, -- will enable/disable automatically for the following filetypes
}
```
