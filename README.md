# Consolation.nvim

A general-perpose terminal wrapper and management plugin for neovim, written in lua

## About

I know what you're thinking: "There are already dozens of terminal wrapper plugins for vim/neovim out there! Why yet another?" Well, Consolation isn't actually a new way to interact with your terminal - in fact, it was created because if the author's frustration with configuring all the other wrappers out there. The thing is, the configuration and usage for all of these plugins is so different, you have to practically re-write your config if you ever see the need to switch to a different one. The point of this plugin is to unify the interfaces for all the wrappers out there to simplify the configuration process, no matter what terminal wrapper you are using.

The idea is quite simple: you provide four functions (one each to create, open, close, and kill the terminal) and Consolation figures out the rest.

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
