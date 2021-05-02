local U = require("consolation/config")

local Wrapper = {
    buffers = vim.fn.getbufinfo(),
    windows = vim.fn.getwininfo()
}

function Wrapper:new()
    local state = {
        channel = nil,
        winid = nil,
        bufnr = nil,
        created = false
    }

    self.__index = self
    return setmetatable(state, self)
end

function Wrapper:setup(opts)
    self.config = U.create_config(opts)
end

-- local function get_new_terminal_bufnr(before_wininfo, after_wininfo)
function Wrapper.get_new_terminal_bufnr(before_wininfo, after_wininfo)
    local before_terminals = vim.tbl_filter(function(window) return window.terminal == 1 end, before_wininfo)
    local after_terminals = vim.tbl_filter(function(window) return window.terminal == 1 end, after_wininfo)

    local before_bufnrs = vim.tbl_map(function(window) return window.bufnr end, before_terminals)
    local after_bufnrs = vim.tbl_map(function(window) return window.bufnr end, after_terminals)

    local new_bufnrs = vim.tbl_filter(function(bufnr) return not vim.tbl_contains(before_bufnrs, bufnr) end, after_bufnrs)

    return new_bufnrs[1]
end

-- local function get_new_terminal_channel(before_bufinfo, after_bufinfo)
function Wrapper.get_new_terminal_channel(before_bufinfo, after_bufinfo)
    local before_variables = vim.tbl_map(function(buffer) return buffer.variables end, before_bufinfo)
    local after_variables = vim.tbl_map(function(buffer) return buffer.variables end, after_bufinfo)

    local before_channels = vim.tbl_map(function(variables) return variables.terminal_job_id end, before_variables)
    local after_channels = vim.tbl_map(function(variables) return variables.terminal_job_id end, after_variables)

    local new_channels = vim.tbl_filter(function(channel) return not vim.tbl_contains(before_channels, channel) end, after_channels)

    return new_channels[1]
end

-- local function get_new_terminal_winid(before_wininfo, after_wininfo)
function Wrapper.get_new_terminal_winid(before_wininfo, after_wininfo)
    local before_terminals = vim.tbl_filter(function(window) return window.terminal == 1 end, before_wininfo)
    local after_terminals = vim.tbl_filter(function(window) return window.terminal == 1 end, after_wininfo)

    local before_winids = vim.tbl_map(function(window) return window.winid end, before_terminals)
    local after_winids = vim.tbl_map(function(window) return window.winid end, after_terminals)

    local new_winids = vim.tbl_filter(function(winid) return not vim.tbl_contains(before_winids, winid) end, after_winids)

    return new_winids[1]
end

function Wrapper:update_values()
    local before_wininfo = self.windows
    local before_bufinfo = self.buffers

    local after_wininfo = vim.fn.getwininfo()
    local after_bufinfo = vim.fn.getbufinfo()

    local new_winid = Wrapper.get_new_terminal_winid(before_wininfo, after_wininfo)
    local new_channel = Wrapper.get_new_terminal_channel(before_bufinfo, after_bufinfo)
    local new_bufnr = Wrapper.get_new_terminal_bufnr(before_wininfo, after_wininfo)

    self.winid = new_winid or self.winid
    self.channel = new_channel or self.channel
    self.bufnr = new_bufnr or self.bufnr

    self.windows = vim.fn.getwininfo()
    self.buffers = vim.fn.getbufinfo()
end

function Wrapper:create()
    self.config.create()
    self:update_values()
    self.created = true
end

function Wrapper:open(args)
    local cmd
    local create = true
    if args then
        create = args.create
        cmd = args.cmd
    end

    if vim.fn.bufexists(self.bufnr) == 0 then
        if create == true then
            self:create()
        else
            print(string.format("Error: buffer does not exist: %s", self.bufnr))
            return
        end
    else
        self.config.open(self)
    end

    if cmd then
        self:send_command {cmd = cmd}
    end
end

function Wrapper:close()
    self.config.close(self)
    self.winid = nil
end

function Wrapper:kill()
    self.config.kill(self)
    self.channel = nil
    self.winid = nil
    self.bufnr = nil
end

function Wrapper:is_open()
    if self.created == false then
        return false
    end
    local winnr = vim.fn.bufwinnr(self.bufnr)
    return winnr ~= -1
end

function Wrapper:toggle(args)
    if self.created == false then
        self:create()
        return
    end

    local create = true
    if args then
        create = args.create
    end

    if self:is_open() then
        self:close()
    else
        self:open {create = create}
    end
end

function Wrapper:send_command(args)
    local cmd = assert(args.cmd, "No command to send!")
    local open = args.open
    local create = args.create

    if args.open == nil then
        open = true
    end
    if args.create == nil then
        create = true
    end

    if open and not self:is_open() then
        self:open {create = create}
    end

    vim.fn.chansend(self.channel, cmd.."\n")
end

return Wrapper
