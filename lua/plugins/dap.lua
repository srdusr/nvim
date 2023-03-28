local dap = require('dap')
--local home_path = vim.fn.expand('$HOME')

-- Unsafe Defaults
--local mi_mode = ""
--local mi_debugger_path = ""
--
---- Unix
--if vim.loop.os_uname().sysname == 'Linux' then
--    mi_mode = "gdb"
--    mi_debugger_path = vim.trim(vim.fn.system('which gdb'))
---- MacOS
--elseif vim.loop.os_uname().sysname == 'Darwin' then
--    mi_mode = "lldb"
--    mi_debugger_path = vim.trim(vim.fn.system('which lldb-mi'))
--else
--    error("Unsupported OS")
--end

--local mason_registry = require("mason-registry")
--local codelldb_root = mason_registry.get_package("codelldb"):get_install_path() .. "/extension/"

dap.adapters.lldb = {
  type = 'executable',
  --command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
  --command = '/usr/bin/vscode-lldb', -- adjust as needed, must be absolute path
  command = 'codelldb',
  --command = 'lldb',
  --command = codelldb_root,
  name = 'lldb'
}

-- cpp

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    --program = function()
    --  return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --end,
    terminal = 'integrated',
    console = 'integratedTerminal',
    program = function()
        return vim.fn.input('program: ', vim.loop.cwd() .. '/', 'file')
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
 },
}


--dap.configurations.cpp = {
--    {
--        name = "Launch file",
--        type = "cppdbg",
--        request = "launch",
--        program = function()
--            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--        end,
--        cwd = '${workspaceFolder}',
--        --stopAtEntry = true,
--        --MIMode = mi_mode,
--        --miDebuggerPath = mi_debugger_path
--    }
--}

-- If you want to use this for Rust and C, add something like this:
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- javascript
dap.adapters.node2 = {
  type = 'executable',
  command = 'node-debug2-adapter',
  args = {},
}

dap.configurations.javascript = {
  {
    name = 'Launch',
    type = 'node2',
    request = 'attach',
    program = '${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
}

dap.adapters.python = {
    type = 'executable';
    command = vim.trim(vim.fn.system('which python'));
    args = { '-m', 'debugpy.adapter' };
}

dap.configurations.python = {
    {
        -- The first three options are required by nvim-dap
        type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch';
        name = "Launch file";
        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        program = "${file}"; -- This configuration will launch the current file if used.
        stopOnEntry = true,
    },
}

local dapui = require('dapui')

    -- setup statusline

    -- setup repl
    dap.repl.commands = vim.tbl_extend('force', dap.repl.commands, {
        exit = { 'q', 'exit' },
        custom_commands = {
            ['.run_to_cursor'] = dap.run_to_cursor,
            ['.restart'] = dap.run_last
        }
    })

    -- vim.api.nvim_create_augroup('DAPConfig', { clear = true })
    -- vim.api.nvim_create_autocmd('FileType', {
    --     group = 'DAPConfig',
    --     pattern = 'dap-repl',
    --     callback = require('dap.ext.autocompl').attach
    -- })

    -- setup dapui
    dapui.setup({
        mappings = {
            expand = "<CR>",
            open = "o",
            remove = "D",
            edit = "e",
            repl = "r",
            toggle = "t",
        },
        layouts = {
            { elements = { "scopes", "breakpoints", "stacks" }, size = 0.33, position = "right" },
            { elements = { "repl", "watches" },                 size = 0.27, position = "bottom" },
        },
        icons = { expanded = "-", collapsed = "$" },
        controls = { enabled = false },
        floating = { border = "rounded", mappings = { close = { "q", "<esc>", "<c-o>" } } },
    })

    -- signs
    vim.fn.sign_define("DapStopped", { text = '=>', texthl = 'DiagnosticWarn', numhl = 'DiagnosticWarn' })
    vim.fn.sign_define("DapBreakpoint", { text = '<>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })
    vim.fn.sign_define("DapBreakpointRejected", { text = '!>', texthl = 'DiagnosticError', numhl = 'DiagnosticError' })
    vim.fn.sign_define("DapBreakpointCondition", { text = '?>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })
    vim.fn.sign_define("DapLogPoint", { text = '.>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })

    -- options
    dap.defaults.fallback.focus_terminal = false
    dap.defaults.fallback.terminal_win_cmd = '10split new'

    -- virtual text setup
    --require('nvim-dap-virtual-text').setup({})



--local debugging = {}
--
--function debugging.setup()
--  local dap = require("dap")
--
--  local sign = vim.fn.sign_define
--
--  -- These are to override the default highlight groups for catppuccin (see https://github.com/catppuccin/nvim/#special-integrations)
--  sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
--  sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
--  sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
--
--  local mason_registry = require("mason-registry")
--  local cpp_dap_executable = mason_registry.get_package("cpptools"):get_install_path()
--    .. "/extension/debugAdapters/bin/OpenDebugAD7"
--
--  dap.adapters.cpp = {
--    id = "cppdbg",
--    type = "executable",
--    command = cpp_dap_executable,
--  }
--
--  local codelldb_root = mason_registry.get_package("codelldb"):get_install_path() .. "/extension/"
--  local codelldb_path = codelldb_root .. "adapter/codelldb"
--  local liblldb_path = codelldb_root .. "lldb/lib/liblldb.so"
--
--  dap.adapters.rust = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
--
--  -- To use the venv for debugpy that is installed with mason, obtain the path and pass it to `setup` as shown below.
--  -- I don't think this is the best idea right now, because it requires that the user installs the packages into a venv that they didn't create and may not know of.
--
--  -- local debugpy_root =   mason_registry.get_package("debugpy"):get_install_path()
--  require("dap-python").setup(--[[ debugpy_root.. "/venv/bin/python" --]])
--  require('dap-python').test_runner = 'pytest'
--
--  dap.configurations.lua = {
--    {
--      type = "nlua",
--      request = "attach",
--      name = "Attach to running Neovim instance",
--    },
--  }
--
--  dap.adapters.nlua = function(callback, config)
--    callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
--  end
--
--  require("nvim-dap-virtual-text").setup({
--    enabled = true,
--    enabled_commands = true,
--    highlight_changed_variables = true,
--    highlight_new_as_changed = true,
--    show_stop_reason = true,
--    commented = true,
--    only_first_definition = true,
--    all_references = true,
--    display_callback = function(variable, _buf, _stackframe, _node)
--      return " " .. variable.name .. " = " .. variable.value .. " "
--    end,
--    -- experimental features:
--    virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
--    all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
--    virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
--    virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
--  })
--
--  local dapui = require("dapui")
--  dapui.setup({
--    icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
--    mappings = {
--      -- Use a table to apply multiple mappings
--      expand = { "<CR>", "<2-LeftMouse>" },
--      open = "o",
--      remove = "d",
--      edit = "e",
--      repl = "r",
--      toggle = "t",
--    },
--    -- Expand lines larger than the window
--    -- Requires >= 0.7
--    expand_lines = vim.fn.has("nvim-0.7") == 1,
--    -- Layouts define sections of the screen to place windows.
--    -- The position can be "left", "right", "top" or "bottom".
--    -- The size specifies the height/width depending on position. It can be an Int
--    -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
--    -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
--    -- Elements are the elements shown in the layout (in order).
--    -- Layouts are opened in order so that earlier layouts take priority in window sizing.
--    layouts = {
--      {
--        elements = {
--          -- Elements can be strings or table with id and size keys.
--          "breakpoints",
--          "stacks",
--          "watches",
--          { id = "scopes", size = 0.25 },
--        },
--        size = 40, -- 40 columns
--        position = "left",
--      },
--      {
--        elements = {
--          "repl",
--          "console",
--        },
--        size = 0.25, -- 25% of total lines
--        position = "bottom",
--      },
--    },
--    controls = {
--      -- Requires Neovim nightly (or 0.8 when released)
--      enabled = true,
--      -- Display controls in this element
--      element = "repl",
--      icons = {
--        pause = "",
--        play = "",
--        step_into = "",
--        step_over = "",
--        step_out = "",
--        step_back = "",
--        run_last = "↻",
--        terminate = "□",
--      },
--    },
--    floating = {
--      max_height = nil, -- These can be integers or a float between 0 and 1.
--      max_width = nil, -- Floats will be treated as percentage of your screen.
--      border = "single", -- Border style. Can be "single", "double" or "rounded"
--      mappings = {
--        close = { "q", "<Esc>" },
--      },
--    },
--    windows = { indent = 1 },
--    render = {
--      max_type_length = nil, -- Can be integer or nil.
--      max_value_lines = 100, -- Can be integer or nil.
--    },
--  })
--
--  dap.listeners.after.event_initialized["dapui_config"] = function()
--    dapui.open()
--  end
--  -- dap.listeners.before.event_terminated["dapui_config"] = function()
--  --   dapui.close()
--  -- end
--  -- dap.listeners.before.event_exited["dapui_config"] = function()
--  --   dapui.close()
--  -- end
--end
--
--return debugging