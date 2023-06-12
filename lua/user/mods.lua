local M = {}

--- Shorten Function Names
local fn = vim.fn
function M.executable(name)
  if fn.executable(name) > 0 then
    return true
  end

  return false
end

--------------------------------------------------

--- Check whether a feature exists in Nvim
--- @feat: string
---   the feature name, like `nvim-0.7` or `unix`.
--- return: bool
M.has = function(feat)
  if fn.has(feat) == 1 then
    return true
  end

  return false
end


--------------------------------------------------


-- Format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
require("null-ls").setup({
  -- you can reuse a shared lspconfig on_attach callback here
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
          vim.lsp.buf.formatting_seq_sync()
        end,
      })
    end
  end,
})


--------------------------------------------------

---Determine if a value of any type is empty
---@param item any
---@return boolean?
function M.empty(item)
  if not item then return true end
  local item_type = type(item)
  if item_type == 'string' then return item == '' end
  if item_type == 'number' then return item <= 0 end
  if item_type == 'table' then return vim.tbl_isempty(item) end
  return item ~= nil
end

--------------------------------------------------

--- Create a dir if it does not exist
function M.may_create_dir(dir)
  local res = fn.isdirectory(dir)

  if res == 0 then
    fn.mkdir(dir, "p")
  end
end

--------------------------------------------------

--- Toggle cmp completion
vim.g.cmp_toggle_flag = false -- initialize
local normal_buftype = function()
  return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
end
M.toggle_completion = function()
  local ok, cmp = pcall(require, "cmp")
  if ok then
    local next_cmp_toggle_flag = not vim.g.cmp_toggle_flag
    if next_cmp_toggle_flag then
      print("completion on")
    else
      print("completion off")
    end
    cmp.setup({
      enabled = function()
        vim.g.cmp_toggle_flag = next_cmp_toggle_flag
        if next_cmp_toggle_flag then
          return normal_buftype
        else
          return next_cmp_toggle_flag
        end
      end,
    })
  else
    print("completion not available")
  end
end


--------------------------------------------------

--- Make sure using latest neovim version
function M.get_nvim_version()
  local actual_ver = vim.version()

  local nvim_ver_str = string.format("%d.%d.%d", actual_ver.major, actual_ver.minor, actual_ver.patch)
  return nvim_ver_str
end

function M.add_pack(name)
  local status, error = pcall(vim.cmd, "packadd " .. name)

  return status
end

--------------------------------------------------

--- Toggle autopairs on/off (requires "windwp/nvim-autopairs")
function M.Toggle_autopairs()
  local ok, autopairs = pcall(require, "nvim-autopairs")
  if ok then
    if autopairs.state.disabled then
      autopairs.enable()
      print("autopairs on")
    else
      autopairs.disable()
      print("autopairs off")
    end
  else
    print("autopairs not available")
  end
end

--------------------------------------------------

--- Make vim-rooter message disappear after making it's changes
--vim.cmd([[
--let timer = timer_start(1000, 'LogTrigger', {})
--func! LogTrigger(timer)
--  silent!
--endfunc
--]])
--
--vim.cmd([[
--function! ConfigureChDir()
--  echo ('')
--endfunction
--" Call after vim-rooter changes the root dir
--autocmd User RooterChDir :sleep! | call LogTrigger(timer) | call ConfigureChDir()
--]])


--------------------------------------------------

-- Set bare dotfiles repository git environment variables dynamically

-- Set git enviornment variables
--function M.Set_git_env_vars()
--  local git_dir_job = vim.fn.jobstart({ "git", "rev-parse", "--git-dir" })
--  local command_status = vim.fn.jobwait({ git_dir_job })[1]
--  if command_status > 0 then
--    vim.env.GIT_DIR = vim.fn.expand("$HOME/.cfg")
--    vim.env.GIT_WORK_TREE = vim.fn.expand("~")
--  else
--    vim.env.GIT_DIR = nil
--    vim.env.GIT_WORK_TREE = nil
--  end
--  -- Launch terminal emulator with Git environment variables set
--  --require("toggleterm").exec(string.format([[%s %s]], os.getenv("SHELL"), "-i"))
--end

------

local prev_cwd = ""

function M.Set_git_env_vars()
  local cwd = vim.fn.getcwd()
  if prev_cwd == "" then
    -- First buffer being opened, set prev_cwd to cwd
    prev_cwd = cwd
  elseif cwd ~= prev_cwd then
    -- Working directory has changed since last buffer was opened
    prev_cwd = cwd
    local git_dir_job = vim.fn.jobstart({ "git", "rev-parse", "--git-dir" })
    local command_status = vim.fn.jobwait({ git_dir_job })[1]
    if command_status > 0 then
      vim.env.GIT_DIR = vim.fn.expand("$HOME/.cfg")
      vim.env.GIT_WORK_TREE = vim.fn.expand("~")
    else
      vim.env.GIT_DIR = nil
      vim.env.GIT_WORK_TREE = nil
    end
  end
end

vim.cmd [[augroup my_git_env_vars]]
vim.cmd [[  autocmd!]]
vim.cmd [[  autocmd BufEnter * lua require('user.mods').Set_git_env_vars()]]
vim.cmd [[  autocmd VimEnter * lua require('user.mods').Set_git_env_vars()]]
vim.cmd [[augroup END]]

--------------------------------------------------

vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
--vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

--------------------------------------------------

--- Update Tmux Status Vi-mode
function M.update_tmux_status()
  local mode = vim.api.nvim_eval('mode()')
  -- Determine the mode name based on the mode value
  local mode_name
  if mode == 'n' then
    mode_name = '-- NORMAL --'
  elseif mode == 'i' or mode == 'ic' then
    mode_name = '-- INSERT --'
  else
    mode_name = '-- NORMAL --' --'-- COMMAND --'
  end

  -- Write the mode name to the file
  local file = io.open(os.getenv('HOME') .. '/.vi-mode', 'w')
  file:write(mode_name)
  file:close()
  if nvim_running then
    -- Neovim is running, update the mode file and refresh tmux
    VI_MODE = ""  -- Clear VI_MODE to show Neovim mode
    vim.cmd("silent !tmux refresh-client -S")
  end
  ---- Force tmux to update the status
  vim.cmd("silent !tmux refresh-client -S")
end

-- Add autocmd for <esc>
-- Add autocmd to check when tmux switches panes/windows
vim.cmd([[
  augroup TmuxStatus
    autocmd!
    autocmd InsertLeave,InsertEnter * lua require("user.mods").update_tmux_status()
    autocmd VimEnter * lua require("user.mods").update_tmux_status()
    autocmd BufEnter * lua require("user.mods").update_tmux_status()
    autocmd ModeChanged * lua require("user.mods").update_tmux_status()
  augroup END
]])

    --autocmd InsertLeave,InsertEnter * lua require("user.mods").update_tmux_status()
    --autocmd BufEnter * lua require("user.mods").update_tmux_status()

    --autocmd WinEnter,WinLeave * lua require("user.mods").update_tmux_status()
    --autocmd VimResized * lua require("user.mods").update_tmux_status()
    --autocmd FocusGained * lua require("user.mods").update_tmux_status()
    --autocmd FocusLost * lua require("user.mods").update_tmux_status()
    --autocmd CmdwinEnter,CmdwinLeave * lua require("user.mods").update_tmux_status()
--------------------------------------------------
return M
