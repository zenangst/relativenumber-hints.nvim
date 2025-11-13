# relativenumber-hints.nvim
Visual destination hints for relative line number navigation

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
