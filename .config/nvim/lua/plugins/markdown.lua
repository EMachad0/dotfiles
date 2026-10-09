-- Browser preview for Markdown, with Mermaid fences rendered by mermaid.js.
-- Terminal image protocols (image.nvim + diagram.nvim) are not an option here:
-- alacritty implements neither the kitty graphics protocol nor sixel.
return {
  {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
    -- The upstream prebuilt server binary has no macos-arm64 asset (404), so
    -- mkdp#util#install() leaves nothing behind. Install the node deps that the
    -- app/index.js fallback needs instead.
    build = 'cd app && npm install',
    keys = {
      {
        '<leader>mp',
        '<cmd>MarkdownPreviewToggle<cr>',
        ft = 'markdown',
        desc = 'Preview (browser)',
      },
    },
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
      -- The 'maid' table is spread into mermaid.initialize(). useMaxWidth
      -- defaults to true, which scales a wide diagram down to the 900px content
      -- column (a 5000px flowchart lands at ~800px, illegible). Rendering at
      -- natural size instead makes the page scroll horizontally.
      -- This dict must stay complete: mkdp replaces its defaults wholesale
      -- rather than merging.
      vim.g.mkdp_preview_options = {
        mkit = vim.empty_dict(),
        katex = vim.empty_dict(),
        uml = vim.empty_dict(),
        maid = {
          flowchart = { useMaxWidth = false },
          sequence = { useMaxWidth = false },
          gantt = { useMaxWidth = false },
        },
        disable_sync_scroll = 0,
        sync_scroll_type = 'middle',
        hide_yaml_meta = 1,
        sequence_diagrams = vim.empty_dict(),
        flowchart_diagrams = vim.empty_dict(),
        content_editable = false,
        disable_filename = 0,
        toc = vim.empty_dict(),
      }
      local wk_ok, wk = pcall(require, 'which-key')
      if wk_ok then
        wk.add({
          { '<leader>m', group = 'Markdown', mode = 'n' },
        })
      end
    end,
  },
  -- In-buffer rendering (headings, code blocks, tables, callouts...).
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    keys = {
      {
        '<leader>mr',
        '<cmd>RenderMarkdown buf_toggle<cr>',
        ft = 'markdown',
        desc = 'Render (in buffer) toggle',
      },
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      -- Checkbox/callout completions via an in-process LSP client, picked up
      -- by nvim-cmp through the existing 'nvim_lsp' source.
      completions = { lsp = { enabled = true } },
      -- Keep the cursor line rendered while navigating instead of flipping it
      -- to raw text (flickers on every j/k). Insert mode still shows raw text.
      anti_conceal = { enabled = false },
      win_options = {
        -- '' (default) reveals concealed markup (**, `, link urls) on the
        -- cursor line in all modes; keep it hidden in normal/command mode.
        concealcursor = { rendered = 'nc' },
      },
    },
  },
}
