P = function(v)
    print(vim.inspect(v))
    return v
end

local ok, plenary_reload = pcall(require, "plenary.reload")
if not ok then
    reloader = require
else
    reloader = plenary_reload.reload_module
end

RELOAD = function(...)
    return reloader(...)
end

R = function(name)
    RELOAD(name)
    return require(name)
end

-- vim.g.python3_host_prog = vim.fn.stdpath('data')..'/venv/bin/python'

VIM_KEYMAP_SET = vim.keymap.set
NOREMAP = { noremap = true }
NOREMAP_SILENT = { noremap = true, silent = true }
PLUGIN_MISSING_NOTIFY = false

