-- Save the files an LSP workspace edit touched, when it touched more than one.
--
-- Same rule as VS Code's `files.refactoring.autoSave`: a rename or code action
-- that spans several files gets written to disk right away, so tools that read
-- from disk (rust-analyzer's clippy check on save, cargo, tsc) see the whole
-- change. Single-file edits stay unsaved so they can be reviewed first.
--
-- Every path that applies LSP edits goes through
-- `vim.lsp.util.apply_workspace_edit` (rename handler, code actions,
-- actions-preview, rustaceanvim, `workspace/applyEdit`), so we wrap that.
--
-- Not under lua/config/lsp/ on purpose: plugins/lsp.lua loads every file there
-- as a server config.

local M = {}

local installed = false

--- Files the edit touches, keyed by path. `true` means save it after the
--- edit, `false` means it was deleted. A file rename counts as one file.
---@param workspace_edit lsp.WorkspaceEdit
---@return table<string, boolean>
local function touched_files(workspace_edit)
  local files = {} ---@type table<string, boolean>

  local function mark(uri, save)
    if type(uri) == 'string' then
      files[vim.uri_to_fname(uri)] = save
    end
  end

  -- Mirrors apply_workspace_edit: documentChanges wins over changes.
  if workspace_edit.documentChanges then
    for _, change in ipairs(workspace_edit.documentChanges) do
      if change.kind == 'rename' then
        files[vim.uri_to_fname(change.oldUri)] = nil
        mark(change.newUri, true)
      elseif change.kind == 'create' then
        mark(change.uri, true)
      elseif change.kind == 'delete' then
        mark(change.uri, false)
      elseif change.textDocument then
        mark(change.textDocument.uri, true)
      end
    end
  elseif workspace_edit.changes then
    for uri in pairs(workspace_edit.changes) do
      mark(uri, true)
    end
  end

  return files
end

---@param bufnr integer
---@return boolean
local function needs_write(bufnr)
  return vim.api.nvim_buf_is_loaded(bufnr)
      and vim.bo[bufnr].modified
      and vim.bo[bufnr].buftype == ''
end

---@param files table<string, boolean>
local function save(files)
  local failures = {} ---@type string[]

  for name, should_save in pairs(files) do
    -- bufexists() matches the name exactly; bufadd() then returns that buffer.
    if should_save and vim.fn.bufexists(name) == 1 then
      local bufnr = vim.fn.bufadd(name)
      if needs_write(bufnr) then
        local ok, err = pcall(vim.api.nvim_buf_call, bufnr, function()
          vim.cmd('silent update')
        end)
        if not ok then
          -- Keep just the Vim error, e.g. "E45: 'readonly' option is set ..."
          local first_line = tostring(err):match('[^\n]*')
          local reason = first_line:match('Vim%(%a+%):(.*)') or first_line
          table.insert(failures, vim.fn.fnamemodify(name, ':~:.') .. ': ' .. reason)
        end
      end
    end
  end

  if #failures > 0 then
    table.sort(failures)
    vim.notify(
      ('[LSP] Could not save %d file(s) after workspace edit:\n%s'):format(
        #failures,
        table.concat(failures, '\n')
      ),
      vim.log.levels.WARN
    )
  end
end

function M.setup()
  if installed then
    return
  end
  installed = true

  local util = vim.lsp.util
  local original = util.apply_workspace_edit

  -- Intentional override of the runtime function.
  ---@diagnostic disable-next-line: duplicate-set-field
  util.apply_workspace_edit = function(workspace_edit, position_encoding, ...)
    -- Without an encoding the original only warns and returns, so skip saving.
    local files = {} ---@type table<string, boolean>
    if position_encoding then
      files = touched_files(workspace_edit)
    end

    local result = vim.F.pack_len(original(workspace_edit, position_encoding, ...))

    if vim.tbl_count(files) > 1 then
      save(files)
    end

    return vim.F.unpack_len(result)
  end
end

return M
