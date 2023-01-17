# cmd.nvim

Execute a shell command and return the result in to a new buffer.

![cmd](cmd.gif)

## Installation

**Lazy**
```lua
require("lazy").setup({
  {
    'runih/cmd.nvim',
    config = function ()
      local ok, cmd = pcall(require, "cmd")
      if not ok then
        return
      end
      cmd.setup({
        set_command=true
      })
    end
  },
})
```

By default the plugin will introduce a command called `CMD`. It can be avoided by setting the
option `set_command` to `false`.

## Keymapping

```lua
local cmd_loaded, cmd = pcall(require, "cmd")
if cmd_loaded then
  keymap.set(
    "n",
    "<leader>!",
    cmd.execute_current_line,
    {
      desc = "Execute current line in to a buffer"
    })
end
```
