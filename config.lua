-- Functions:
-- winnr: get winnr of current window
-- bufnr: get bufnr of current buffer or specified buffer
-- win_getid: get winid given winnr
-- win_id2win: get winnr given winid

local U = {}

local O = {
    create = function() vim.cmd("vnew | term") end,
    open = function(self)
        -- vim.cmd("vnew")
        -- vim.cmd("b"..self.bufnr)
        local winnr = vim.fn.bufwinnr(self.bufnr)
        if winnr == -1 then
            vim.cmd("vnew")
            vim.cmd("b"..self.bufnr)
        else
            vim.cmd(winnr.."wincmd w")
        end
    end,
    close = function(self)
        local winnr = vim.fn.win_id2win(self.winid)
        vim.cmd(winnr.."wincmd c")
    end,
    kill = function(self) vim.cmd("bd! "..self.bufnr) end,
}

function U.create_config(opts)
    if not opts then
        return O
    end

    return {
        create = opts.create or O.create,
        open = opts.open or O.open,
        close = opts.close or O.close,
        kill = opts.kill or O.kill
    }
end

return U
