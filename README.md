# relativenumber-hints.nvim
Visual destination hints for relative line number navigation

<img src="https://github.com/zenangst/relativenumber-hints.nvim/blob/main/screenshot.png?raw=true" style="border-radius: 8px;" alt="relativenumber-hints.nvim - screenshot" />

## Why???

Relative numbers are helpful, but it’s still easy to misjudge a long jump.
This plugin highlights the two lines you’ll land on, making things clearer and helping you avoid overshooting.

### Installation

```lua
{
  "zenangst/relativenumber-hints.nvim",
  config = function()
    require("relativenumber_hints").setup({ })
  end
}
```

### Configuration

```lua
require("relativenumber_hints").setup({
  highlight = { fg = "#ffcc00", bold = true }
})
```
