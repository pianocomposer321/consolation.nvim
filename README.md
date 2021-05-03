# Consolation.nvim

A general-perpose terminal wrapper and management plugin for neovim, written in lua

## About

I know what you're thinking: "There are already dozens of terminal wrapper plugins for vim/neovim out there! Why yet another?" And you'd be partially right - the default configuration of consolation.nvim is basically the same as [all](https://github.com/akinsho/nvim-toggleterm.lua) [the](https://github.com/oberblastmeister/termwrapper.nvim) [other](https://github.com/s1n7ax/nvim-terminal) [terminal](https://github.com/jlesquembre/nterm.nvim) [wrapper](https://github.com/itmecho/bufterm.nvim) [plugins](https://github.com/anott03/termight.nvim) [out](https://github.com/haorenW1025/term-nvim) [there](https://github.com/mortepau/terminal.nvim). But, as is the case with many vim and neovim plugins, consolation.nvim is much more than its default configuration.

The main reason that [the author](https://github.com/pianocomposer321) created this plugin is because while there is no shortage of either terminal management plugins (e.g. [Neoterm](https://github.com/kassio/neoterm)) or floating terminal plugins (e.g. [Floaterm](https://github.com/voldikss/vim-floaterm)), trying to get either the terminal management plugin to work with floating windows or the floating terminal plugin to accept input programmatically is a major pain. The idea of this plugin is to take absolutely *any* asthetically enhancing terminal plugin and make it easy to use programmatically as well. What this means practically speaking is that you can have a floating terminal (like with [Floaterm](https://github.com/voldikss/vim-floaterm) or [FTerm](https://github.com/numToStr/FTerm.nvim)) that can be controlled with lua functions similarly to [Neoterm](https://github.com/kassio/neoterm).

## Usage
The way you interact with Consolation is through its `Wrapper` object.

### `Wrapper:new()`
Returns a new `Wrapper` object

### `Wrapper:setup(opts)`
Setup the `Wrapper` using the provided configuration options

##### Arguments

- `create` (function): The function used to create the terminal
- `open` (function): The function used to open the terminal.
- `close` (function): The function used to close the terminal.
- `kill` (function): The function used to kill the terminal.

Except for `create`, all of these functions accept one argument, which is a reference to the `Wrapper` object iself. This way all of its variables like `bufnr`, `winid`, etc. are avaliable to the functions.

### `Wrapper:create()`
Creates a new terminal buffer, using the `create` function specified in the `Wrapper:setup(opts)` function, and updates values for the terminal's `bufnr`, `winid`, etc.

### `Wrapper:open(args)`
Opens the terminal using the `open` function specified in the `Wrapper:setup(opts)` function.

##### Arguments (optional)

- `cmd` (string, default `nil`): Command to run upon opening the terminal
- `create` (bool, default `true`): Whether to create the terminal if it does not already exist

### `Wrapper:close()`
Closes the terminal using the `close` function specified in the `Wrapper:setup(opts)` function.

### `Wrapper:kill()`
Kills the terminal using the `kill` function specified in the `Wrapper:setup(opts)` function, and resets the `Wrapper` object's `channel`, `winid`, and `bufnr` variables to `nil`.

### `Wrapper:toggle(args)`
Toggles the terminal using either the `open` or the `close` function specified in the `Wrapper:setup()` opts function.

##### Arguments (optional)
- `create` (bool, default `true`): Whether to create the terminal when opening it if it does not already exist

### `Wrapper:send_command(args)`
Sends a command to the terminal.

##### Arguments

- `cmd` (string, REQUIRED): The command to send
- `open` (bool, default `true`): Whether to open the terminal before running the command
- `create` (bool, default `true`): Whether to create the terminal if it does not already exist

### `Wrapper:is_open()`
Utility function that returns whether the terminal buffer is currently displayed in a window (IOW, open).

##### Returns: `bool`

## Examples

### Using neovim's builtin `:term` command in a vsplit
```lua 
local Wrapper = require("consolation").Wrapper

BuiltinTerminalWrapper = Wrapper:new()
BuiltinTerminalWraper:setup {
    create = function() vim.cmd("vnew | term") end,
    open = function(self)
        if self:is_open() then
            local winnr = vim.fn.bufwinnr(self.bufnr)
            vim.cmd(winnr.."wincmd w")
        else
            vim.cmd("vnew")
            vim.cmd("b"..self.bufnr)
        end
    end,
    close = function(self)
        local winnr = vim.fn.bufwinnr(self.bufnr)
        vim.cmd(winnr.."wincmd c")
    end,
    kill = function(self)
        vim.cmd("bd! "..self.bufnr)
    end
}


-- Try:

-- BuiltinTerminalWraper:open {cmd = "echo hi"}
-- BuiltinTerminalWraper:send_command {cmd = "echo hi again"}
-- BuiltinTerminalWraper:close()
-- BuiltinTerminalWraper:toggle()
-- BuiltinTerminalWraper:kill()
```

### Using FTerm.nvim
```lua
local term = require("Fterm.terminal")
Runner = term:new():setup()

FtermWrapper = Wrapper:new()
FtermWrapper:setup {
    create = function() Runner:open() end,
    open = function(_) Runner:open() end,
    close = function(_) Runner:close() end,
    kill = function(_) Runner:close(true) end
}
```
