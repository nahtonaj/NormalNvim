local M = {}

local function find(l, value) -- find element v of l satisfying f(v)
  for _, v in ipairs(l) do
    if v == value then
      return v
    end
  end
  return nil
end
M.bemol = function ()
  local bemol_dir = vim.fs.find({ '.bemol' }, { upward = true, type = 'directory' })[1]
  local ws_folders_lsp = {}
  if bemol_dir then
    local file = io.open(bemol_dir .. '/ws_root_folders', 'r')
    if file then
      for line in file:lines() do
        table.insert(ws_folders_lsp, line)
      end
      file:close()
    end
  end
  local current_ws_folders = vim.lsp.buf.list_workspace_folders()

  for _, line in ipairs(ws_folders_lsp) do
    if not find(current_ws_folders, line) then
      vim.lsp.buf.add_workspace_folder(line)
    end
  end
end

local home = os.getenv("HOME")

local java_cmds = vim.api.nvim_create_augroup('java_cmds', { clear = true })
local cache_vars = {}

-- local root_files = {
--   '.git',
--   'mvnw',
--   'gradlew',
--   'pom.xml',
--   'build.gradle',
--   'build.xml',
--   'Config',
-- }

local features = {
  -- change this to `true` to enable codelens
  codelens = true,

  -- change this to `true` if you have `nvim-dap`,
  -- `java-test` and `java-debug-adapter` installed
  debugger = true,
}

local function get_jdtls_paths()
  if cache_vars.paths then
    return cache_vars.paths
  end

  local path = {}

  path.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'

  local jdtls_install = require('mason-registry')
      .get_package('jdtls')
      :get_install_path()
  -- local jdtls_install = '/local/home/jonatgao/.local/share/jdtls'
  path.jdtls_bin = jdtls_install .. '/bin/jdtls'

  path.java_agent = '/local/home/jonatgao/.local/share/lombok/lombok-edge.jar'
  -- path.java_agent = jdtls_install .. '/lombok.jar'
  -- path.java_agent = require('mason-registry')
  --     .get_package('lombok-nightly')
  --     :get_install_path() .. '/lombok.jar'

  path.launcher_jar = vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar')

  if vim.fn.has('mac') == 1 then
    path.platform_config = jdtls_install .. '/config_mac'
  elseif vim.fn.has('unix') == 1 then
    path.platform_config = jdtls_install .. '/config_linux'
  elseif vim.fn.has('win32') == 1 then
    path.platform_config = jdtls_install .. '/config_win'
  end

  path.bundles = {}

  ---
  -- Include java-test bundle if present
  ---
  local java_test_path = require('mason-registry')
      .get_package('java-test')
      :get_install_path()

  local java_test_bundle = vim.split(
    vim.fn.glob(java_test_path .. '/extension/server/*.jar'),
    '\n'
  )

  if java_test_bundle[1] ~= '' then
    vim.list_extend(path.bundles, java_test_bundle)
  end

  ---
  -- Include java-debug-adapter bundle if present
  ---
  local java_debug_path = require('mason-registry')
      .get_package('java-debug-adapter')
      :get_install_path()

  local java_debug_bundle = vim.split(
    vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'),
    '\n'
  )

  if java_debug_bundle[1] ~= '' then
    vim.list_extend(path.bundles, java_debug_bundle)
  end

  ---
  -- Useful if you're starting jdtls with a Java version that's
  -- different from the one the project uses.
  ---
  path.runtimes = {
    -- Note: the field `name` must be a valid `ExecutionEnvironment`,
    -- you can find the list here:
    -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    --
    -- This example assume you are using sdkman: https://sdkman.io
    -- {
    --   name = 'JavaSE-17',
    --   path = vim.fn.expand('~/.sdkman/candidates/java/17.0.6-tem'),
    -- },
    -- {
    --   name = 'JavaSE-17',
    --   path = vim.fn.expand('~/.sdkman/candidates/java/current'),
    -- },
  }

  cache_vars.paths = path

  return path
end

local function enable_codelens(bufnr)
  pcall(vim.lsp.codelens.refresh)

  vim.api.nvim_create_autocmd('BufWritePost', {
    buffer = bufnr,
    group = java_cmds,
    desc = 'refresh codelens',
    callback = function()
      pcall(vim.lsp.codelens.refresh)
    end,
  })
end

local function enable_debugger(bufnr)
  require('jdtls').setup_dap({ hotcodereplace = 'auto' })
  require('jdtls.dap').setup_dap_main_class_configs()
  local opts = {
    config_overrides = {
      shortenCommandLine = "argfile",
      vmArgs = "-DmixMode=MMM --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.nio.channels=ALL-UNNAMED --add-opens=java.base/java.time=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.locks=ALL-UNNAMED --add-opens=java.base/jdk.internal.access=ALL-UNNAMED --add-opens=java.base/jdk.internal.misc=ALL-UNNAMED --add-opens=java.base/jdk.internal.ref=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.net.dns=ALL-UNNAMED --add-opens=java.base/sun.security.x509=ALL-UNNAMED --add-opens=java.base/sun.security.util=ALL-UNNAMED --add-opens=java.base/sun.security.ssl=ALL-UNNAMED"
    }
  }

  local dap_mappings = require("base.4-mappings").dap_jdtls_mappings(opts)
  require('base.utils').set_mappings(dap_mappings, { buffer = bufnr })
end

local function jdtls_on_attach(client, bufnr)
  M.bemol()

  if features.debugger then
    enable_debugger(bufnr)
  end

  if features.codelens then
    enable_codelens(bufnr)
  end

  -- Apply lsp_mappings to the buffer
  local lsp_mappings = require("base.4-mappings").lsp_mappings(client, bufnr)
  if not vim.tbl_isempty(lsp_mappings.v) then
    lsp_mappings.v["<leader>l"] = { desc = require('base.utils').get_icon("ActiveLSP", 1, true) .. "LSP" }
  end
  require('base.utils').set_mappings(lsp_mappings, { buffer = bufnr })

  -- The following mappings are based on the suggested usage of nvim-jdtls
  -- https://github.com/mfussenegger/nvim-jdtls#usage
  -- local opts = { buffer = bufnr }
  -- vim.keymap.set('n', '<A-o>', "<cmd>lua require('jdtls').organize_imports()<cr>", opts)
  -- vim.keymap.set('n', 'crv', "<cmd>lua require('jdtls').extract_variable()<cr>", opts)
  -- vim.keymap.set('x', 'crv', "<esc><cmd>lua require('jdtls').extract_variable(true)<cr>", opts)
  -- vim.keymap.set('n', 'crc', "<cmd>lua require('jdtls').extract_constant()<cr>", opts)
  -- vim.keymap.set('x', 'crc', "<esc><cmd>lua require('jdtls').extract_constant(true)<cr>", opts)
  -- vim.keymap.set('x', 'crm', "<esc><Cmd>lua require('jdtls').extract_method(true)<cr>", opts)
end

M.jdtls_setup = function(event)
  local jdtls = require('jdtls')

  local path = get_jdtls_paths()
  local data_dir = path.data_dir .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p')

  if cache_vars.capabilities == nil then
    jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    cache_vars.capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      ok_cmp and cmp_lsp.default_capabilities() or {}
    )
  end

  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  local cmd = {
    -- 💀
    path.jdtls_bin,
    -- 'java',

    '-XX:+UseParallelGC', -- Better performance for multi-core systems
		'-XX:GCTimeRatio=4', -- Spend less time on GC
		'-XX:AdaptiveSizePolicyWeight=90', -- Optimize for throughput
		'-Dsun.zip.disableMemoryMapping=true', -- Reduce memory pressure
		'-Xms1g', -- Initial heap size
		'-Xmx8g', -- Maximum heap size
		'-XX:+UseStringDeduplication', -- Reduce memory usage for string storage
		'-XX:+OptimizeStringConcat', -- Optimize string concatenation

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-javaagent:' .. path.java_agent,
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '--add-opens',
    -- 'java.base/java.lang.reflect=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/java.io=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/java.nio=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/java.nio.channels=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/java.time=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/java.util.concurrent.locks=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/jdk.internal.access=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/jdk.internal.misc=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/jdk.internal.ref=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/sun.nio.ch=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/sun.net.dns=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/sun.security.x509=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/sun.security.util=ALL-UNNAMED',
    -- '--add-opens',
    -- 'java.base/sun.security.ssl=ALL-UNNAMED',

    -- 💀
    '-jar',
    path.launcher_jar,

    -- 💀
    '-configuration',
    path.platform_config,

    -- 💀
    '-data',
    data_dir,
  }

  local lsp_settings = {
    java = {
      -- jdt = {
      --   ls = {
      --     vmargs = "-DmixMode=MMM --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.nio.channels=ALL-UNNAMED --add-opens=java.base/java.time=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.locks=ALL-UNNAMED --add-opens=java.base/jdk.internal.access=ALL-UNNAMED --add-opens=java.base/jdk.internal.misc=ALL-UNNAMED --add-opens=java.base/jdk.internal.ref=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.net.dns=ALL-UNNAMED --add-opens=java.base/sun.security.x509=ALL-UNNAMED --add-opens=java.base/sun.security.util=ALL-UNNAMED --add-opens=java.base/sun.security.ssl=ALL-UNNAMED"
      --   }
      -- },
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = 'automatic',
        runtimes = path.runtimes,
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
				includeDecompiledSources = true,
				includeAccessors = true,
				includeDeclaration = true,
			},
			quickfix = {
				enabled = true,
			},
			inlayHints = {
				parameterNames = {
					enabled = "all",
				},
			},
      format = {
        enabled = true,
        settings = {
          profile = 'DdbLogService',
          url = '/local/home/jonatgao/workplace/dotfiles/DdbLogService.xml'
        }
      },
    },
    signatureHelp = {
      enabled = true,
    },
    completion = {
      favoriteStaticMembers = {
        'org.hamcrest.MatcherAssert.assertThat',
        'org.hamcrest.Matchers.*',
        'org.hamcrest.CoreMatchers.*',
        'org.junit.jupiter.api.Assertions.*',
        'java.util.Objects.requireNonNull',
        'java.util.Objects.requireNonNullElse',
        'org.mockito.Mockito.*',
      },
      filteredTypes = {
        "com.sun.*",
        "io.micrometer.shaded.*",
        "java.awt.*",
        "jdk.*",
        "sun.*",
      },
    },
    contentProvider = {
      preferred = 'fernflower',
    },
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      }
    },
    codeGeneration = {
      toString = {
        template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
      },
      useBlocks = true,
    },
  }

  local ws_folders_jdtls = {}
  local root_dir = jdtls.setup.find_root({ "packageInfo" }, "Config")
  -- if root_dir then
  --   local file = io.open(root_dir .. "/.bemol/ws_root_folders")
  --   if file then
  --     for line in file:lines() do
  --       table.insert(ws_folders_jdtls, "file://" .. line)
  --     end
  --     file:close()
  --   end
  -- end

  -- This starts a new client & server,
  -- or attaches to an existing client & server depending on the `root_dir`.
  jdtls.start_or_attach({
    cmd = cmd,
    settings = lsp_settings,
    on_attach = jdtls_on_attach,
    capabilities = cache_vars.capabilities,
    root_dir = jdtls.setup.find_root({ "packageInfo" }, "Config"),
    flags = {
      allow_incremental_sync = true,
    },
    init_options = {
      bundles = path.bundles,
      -- workspaceFolders = ws_folders_jdtls,
    },
  })
end

vim.api.nvim_create_autocmd('FileType', {
  group = java_cmds,
  pattern = {'java'},
  desc = 'Setup jdtls',
  callback = function()
    M.jdtls_setup()
  end,
})

return M
