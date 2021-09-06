local M = {
    width = 0.9, -- Width and height are percentages of the screen size
    height = 0.4,
    position = "bottom",
    name = "runner"
}

function M.create()
    vim.cmd("FloatermNew --name=" .. M.name
    .. " --width=" .. M.width
    .. " --height=" .. M.height
    .. " --position=" .. M.position)
end

function M.open()
    vim.cmd("FloatermShow " .. M.name)
end

function M.close()
    vim.cmd("FloatermHide " .. M.name)
end

function M.kill()
    vim.cmd("FloatermKill " .. M.name)
end

local runner_bufnr = -1
function M.toggle()
    -- Get a list of the bufnrs of all the terminals managed by floaterm.
    local bufnrs = vim.fn['floaterm#buflist#gather']()

    if vim.tbl_contains(bufnrs, runner_bufnr) then  -- If the runner is in that list
        vim.cmd("FloatermToggle " .. M.name)  -- Simply toggle it
    else
        -- Otherwise, create a new runner and set runner_bufnr to the bufnr of
        -- the new terminal buffer
        M.create()
        runner_bufnr = vim.fn['floaterm#buflist#curr']()
    end
end

vim.g.floaterm_autoclose = 1

return M
