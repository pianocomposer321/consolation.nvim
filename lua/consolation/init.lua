local M = {
    current_terminal = nil
}

M.Wrapper = require("consolation/wrapper")

function M.set_current_terminal(term)
    M.current_terminal = term
end

function M.setup(opts)
    local term = M.Wrapper:new()
    term:setup(opts)

    M.set_current_terminal(term)
end

function M.create()
    M.current_terminal:create()
end

function M.open(args)
    M.current_terminal:open(args)
end

function M.close()
    M.current_terminal:close()
end

function M.kill()
    M.current_terminal:kill()
end

function M.is_open()
    return M.current_terminal:is_open()
end

function M.get_winnr()
    return M.current_terminal:get_winnr()
end

function M.toggle(args)
    M.current_terminal:toggle(args)
end

function M.send_command(args)
    M.current_terminal:send_command(args)
end

return M
