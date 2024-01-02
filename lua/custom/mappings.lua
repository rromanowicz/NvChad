-- ---@type MappingsTable
-- local M = {}
--
-- M.general = {
--   n = {
--     [";"] = { ":", "enter command mode", opts = { nowait = true } },
--
--
--     ["<leader>Db"] = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Breakpoint" },
--     ["<leader>Dc"] = { "<cmd>lua require'custom.configs.dap'.continue()<cr>", "Continue (F5)" },
--     ["<leader>Di"] = { "<cmd>lua require'custom.configs.dap'.step_into()<cr>", "Into (F7)" },
--     ["<leader>Do"] = { "<cmd>lua require'custom.configs.dap'.step_over()<cr>", "Over (F8)" },
--     ["<leader>DO"] = { "<cmd>lua require'custom.configs.dap'.step_out()<cr>", "Out (S-F8)" },
--     ["<leader>Dr"] = { "<cmd>lua require'custom.configs.dap'.repl.toggle()<cr>", "Repl" },
--     ["<leader>Dl"] = { "<cmd>lua require'custom.configs.dap'.run_last()<cr>", "Last" },
--     ["<leader>Du"] = { "<cmd>lua require'dapui'.toggle()<cr>", "UI" },
--     ["<leader>Dx"] = { "<cmd>lua require'custom.configs.dap'.terminate()<cr>", "Exit" },
--     ["<leader>Da"] = { function() local dap = require('dap') dap.configurations.java = { { type = 'java'; request = 'attach'; name = "Java Debug (Attach) - Remote"; hostName = "127.0.0.1"; port = 5005; }, } dap.continue() end, "Attach debug session." },
--     ["<leader>Dv"] = { function() local dap = require('dap') dap.configurations.java = { { type = 'java'; request = 'attach'; name = "Java Vaadin Debug (Attach) - Remote"; hostName = "127.0.0.1"; port = 5987; }, } dap.continue() end, "Attach debug session." },
--   },
--   v = {
--     [">"] = { ">gv", "indent"},
--   },
-- }
--
-- -- more keybinds!
--
-- return M

local M = {}

M.opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

M.vopts = {
  mode = "v", -- VISUAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

M.mappings = {
  D = {
    name = "Debug",
    b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Breakpoint" },
    c = { "<cmd>lua require'dap'.continue()<cr>", "Continue (F5)" },
    i = { "<cmd>lua require'dap'.step_into()<cr>", "Into (F7)" },
    o = { "<cmd>lua require'dap'.step_over()<cr>", "Over (F8)" },
    O = { "<cmd>lua require'dap'.step_out()<cr>", "Out (S-F8)" },
    r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Repl" },
    l = { "<cmd>lua require'dap'.run_last()<cr>", "Last" },
    u = { "<cmd>lua require'dapui'.toggle()<cr>", "UI" },
    x = { "<cmd>lua require'dap'.terminate()<cr>", "Exit" },
    a = { function() local dap = require('dap') dap.configurations.java = { { type = 'java'; request = 'attach'; name = "Java Debug (Attach) - Remote"; hostName = "127.0.0.1"; port = 5005; }, } dap.continue() end, "Attach debug session." },
    v = { function() local dap = require('dap') dap.configurations.java = { { type = 'java'; request = 'attach'; name = "Java Vaadin Debug (Attach) - Remote"; hostName = "127.0.0.1"; port = 5987; }, } dap.continue() end, "Attach debug session." }
  },

  d = {
    name = "[D]efinitions",
    h = { vim.lsp.buf.hover, "Hover Documentation" },
    d = { vim.lsp.buf.definition, "[D]efinition" },
    D = { vim.lsp.buf.type_definition, "Type [D]efinition" },
    r = { vim.lsp.buf.references, "References" },
    S = { vim.lsp.buf.signature_help, "[S]ignature Documentation" },
    -- s = { require('telescope.builtin').lsp_document_symbols, "[D]ocument [S]ymbols" },
  },

  l = {
    name = "LSP",
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
    -- c = { "<cmd>lua require('user.lsp').server_capabilities()<cr>", "Get Capabilities" },
    d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
    w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
    R = { "<cmd>lua vim.lsp.buf.references()<cr>", "References" },
    f = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "Format" },
    i = { "<cmd>LspInfo<cr>", "Info" },
    h = { "<cmd>lua require('lsp-inlayhints').toggle()<cr>", "Toggle Hints" },
    j = { "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>", "Next Diagnostic", },
    k = { "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", "Prev Diagnostic", },
    l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    q = { "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", "Quickfix" },
    r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
    s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
    S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
    e = { "<cmd>Telescope quickfix<cr>", "Telescope Quickfix" },
  },

  t = {
    name = "Tab",
    n = { "<cmd>tabnew %<cr>", "New Tab" },
    c = { "<cmd>tabclose<cr>", "Close Tab" },
    o = { "<cmd>tabonly<cr>", "Only Tab" },
  },

  g = {
    name = "Git",
    g = { "<cmd>lua require('nvterm.terminal').toggle 'float' <cr> lazygit && exit <cr>", "Lazygit" },
    j = { "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", "Next Hunk" },
    k = { "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", "Prev Hunk" },
    l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
    p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
    r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
    R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
    s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
    u = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", "Undo Stage Hunk", },
    o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
    b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
    C = { "<cmd>Telescope git_bcommits<cr>", "Checkout commit(for current file)", },
    d = { "<cmd>Gitsigns diffthis HEAD<cr>", "Git Diff", },
  },
}

M.setup = function()
  local which_key = require("which-key")
  which_key.register(M.mappings, M.opts)
-- which_key.register(vmappings, vopts)
end

return M
