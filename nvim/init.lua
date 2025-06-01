require "core"

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

dofile(vim.g.base46_cache .. "defaults")
vim.opt.rtp:prepend(lazypath)
vim.opt.makeprg = "cmake --build build"

-- Set tab width to 4 spaces
vim.opt.tabstop = 4       -- Number of spaces a <Tab> in the file counts for
vim.opt.shiftwidth = 4    -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true  -- Use spaces instead of tabs

-- Enable relative line numbers
vim.opt.relativenumber = true
vim.opt.number = true     -- Show the absolute line number for the current line

vim.opt.scrolloff = 5
-- vim.cmd [[
--   highlight Normal guibg=none
--   highlight NonText guibg=none
--   highlight Normal ctermbg=none
--   highlight NonText ctermbg=none
-- ]]
require "plugins"
