local status, jdtls = pcall(require, "jdtls")
if not status then
  return
end

local function find_root(items)
  return require("jdtls.setup").find_root { items }
end


-- -- Setup Workspace
local home = os.getenv "HOME"
local workspace_path = home .. "/.local/share/nvim/jdtls-workspace/"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = workspace_path .. project_name

-- Determine OS
local os_config = "linux"
if vim.fn.has "mac" == 1 then
  os_config = "mac"
end

-- Setup Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
local rootDir = find_root { ".git", "mvnw", "gradlew" }
local moduleRootDir = find_root { "pom.xml", "build.gradle" }

-- Setup Testing and Debugging
local bundles = {}
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "packages/java-test/extension/server/*.jar"), "\n"))
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n"))


local dap = require("custom.configs.dap")
dap.config.active = true

local config = {
  filetypes = { "java" },
  autostart = true,
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.lsrequire'lspconfig'.jdtls.setup{ cmd = { 'jdtls' } }.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
    "-jar", vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration", home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. os_config,
    "-data", workspace_dir,
  },
  root_dir = rootDir,
  module_root_dir = moduleRootDir,
  capabilities = capabilities,

  settings = {
    java = {
      eclipse = {
        downloadsources = true,
      },
      configuration = {
        updatebuildconfiguration = "interactive",
        runtimes = {
          {
            name = "javase-21",
            path = "~/.jdk/jdk-21",
          },
          -- {
          --   name = "javase-19",
          --   path = "~/.jdk/jdk-19.0.2",
          -- },
        },
      },
      maven = {
        downloadsources = true,
      },
      implementationscodelens = {
        enabled = true,
      },
      referencescodelens = {
        enabled = true,
      },
      references = {
        includedecompiledsources = true,
      },
      format = {
        enabled = false,
      },
    },
    signaturehelp = { enabled = true },
    extendedclientcapabilities = extendedClientCapabilities,
  },
  init_options = {
    bundles = bundles,
  },
}

config["on_attach"] = function(client, bufnr)
  local _, _ = pcall(vim.lsp.codelens.refresh)
	require("jdtls").setup_dap({ hotcodereplace = "auto" })
	require("lsp").on_attach(client, bufnr)
  local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
  if status_ok then
    jdtls_dap.setup_dap_main_class_configs()
  end
end

vim.api.nvim_create_autocmd({ "bufwritepost" }, {
  pattern = { "*.java" },
  callback = function()
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
})


local null_ls = require "null-ls"

null_ls.setup({
    sources = {
       null_ls.builtins.formatting.google_java_format
    },
})

require("jdtls").start_or_attach(config)


--------------------------------
---- maven runner functions ----
--------------------------------
local function get_working_directory()
  local working_dir = require("jdtls.setup").find_root { "pom.xml", "build.gradle" }
  if working_dir == nil then
    return ""
  else
    return "cd " .. working_dir .. " && "
  end
end

local function get_test_runner(test_name, debug)
  if debug then
    return 'mvn test -dmaven.surefire.debug -dtest="' .. test_name .. '"'
  end
  return 'mvn test -dtest="' .. test_name .. '"'
end

local function run_java_test_method(debug)
  local utils = require'utils'
  local method_name = utils.get_current_full_method_name("\\#")
  vim.cmd('term ' .. get_test_runner(method_name, debug))
end

local function run_java_test_class(debug)
  local utils = require'utils'
  local class_name = utils.get_current_full_class_name()
  vim.cmd('term ' .. get_test_runner(class_name, debug))
end

local function get_spring_boot_runner(profile, debug)
  local debug_param = ""
  if debug then
    debug_param = ' -Dspring-boot.run.jvmarguments="-xdebug -xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"'
  end

  local profile_param = ""
  if profile then
    profile_param = " -Dspring-boot.run.profiles=" .. profile
  end

  local env_vars = ""
  local f = io.open(config.root_dir .. "/.envvars", "rb")
  if f then
    env_vars = string.format(' -Dspring-boot.run.arguments="%s"', f:read "*a")
    f:close()
  end

  return get_working_directory() .. 'mvn spring-boot:run' .. env_vars .. profile_param .. debug_param
end

local function run_spring_boot(debug)
  vim.cmd('term ' ..  get_spring_boot_runner(nil, debug))
end

local function run_maven_cmd(mvn)
  vim.cmd('term mvn '  .. ' '.. mvn)
end


--------------------------------
--------- KEY MAPPINGS ---------
--------------------------------

local keymap = vim.keymap.set

keymap("n", "<F9>", "<cmd>lua require('nvterm.terminal').toggle 'vertical' <cr> " ..  get_spring_boot_runner(nil, false) .. "<cr>")
keymap("n", "<F10>", "<cmd>lua require('nvterm.terminal').toggle 'vertical' <cr> " ..  get_spring_boot_runner(nil, true) .. "<cr>")
keymap('n', '<F5>', ':lua require"dap".continue()<CR>')
keymap('n', '<F8>', ':lua require"dap".step_over()<CR>')
keymap('n', '<F7>', ':lua require"dap".step_into()<CR>')
keymap('n', '<S-F8>', ':lua require"dap".step_out()<CR>')
keymap('n', '<C-A-l>', ':lua vim.lsp.buf.format({ async = true })<CR>')
keymap('n', '<C-A-o>', ':lua require"jdtls".organize_imports()<CR>')

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local vopts = {
  mode = "v", -- VISUAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
  j = {
    name = "Java",
    o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
    v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
    c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
    t = { function() run_java_test_method() end, "(t)est Method" },
    T = { "<Cmd>run_java_test_class()<CR>", "(T)est Class" },
    d = { "<Cmd>run_java_test_method(true)<CR>", "(d)ebug Method" },
    D = { "<Cmd>run_java_test_class(true)<CR>", "(D)ebug Class" },
    u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
  },
  m ={
    name = "Maven",
    b = { "<cmd>lua require('nvterm.terminal').toggle 'float' <cr> mvn clean build <cr> exit <cr>", "Build"},
    c = { "<cmd>lua require('nvterm.terminal').toggle 'float' <cr> mvn clean compile <cr> exit <cr>", "Compile"},
    r = { function() run_spring_boot() end, "Run"},
    d = { function() run_spring_boot(true) end, "Debug"},
    i = { "<cmd>lua require('nvterm.terminal').toggle 'float' <cr> mvn clean install <cr> exit <cr>", "Install"},
    s = { function() run_maven_cmd("source:jar install") end, "Source install"},
  },
}

local vmappings = {
  j = {
    name = "Java",
    v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
    c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
    m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
  },
}

which_key.register(mappings, opts)
which_key.register(vmappings, vopts)


vim.cmd "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)"
vim.cmd "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_set_runtime JdtSetRuntime lua require('jdtls').set_runtime(<f-args>)"
vim.cmd "command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()"
vim.cmd "command! -buffer JdtBytecode lua require('jdtls').javap()"
