local cmp = require "cmp"
local snip_status_ok, luasnip = pcall(require, "luasnip")
local lspkind_status_ok, lspkind = pcall(require, "lspkind")
if not snip_status_ok then return end
local setup = cmp.setup
local border_opts =
{ border = "single", winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None" }
local has_copilot, copilot_cmp = pcall(require, "copilot_cmp.comparators")


local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

setup(astronvim.user_plugin_opts("plugins.cmp", {
  enabled = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
    return vim.g.cmp_enabled
  end,
  preselect = cmp.PreselectMode.None,
  formatting = {
    fields = { "abbr", "menu", "kind" },
    format = lspkind_status_ok and lspkind.cmp_format(astronvim.lspkind) or nil,
  },
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  duplicates = {
    copilot = 1,
    nvim_lsp = 1,
    luasnip = 1,
    cmp_tabnine = 1,
    buffer = 1,
    path = 1,
  },
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  window = {
    completion = cmp.config.window.bordered(border_opts),
    documentation = cmp.config.window.bordered(border_opts),
  },
  mapping = {
    ["<Up>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
    ["<Down>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
    ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-k>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-j>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable,
    ["<C-e>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    ["<CR>"] = cmp.mapping.confirm { select = false },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  },
  sources = {
    { name = "copilot", group_index = 2 },
    { name = "nvim_lsp", group_index = 2 },
    { name = "luasnip", group_index = 2 },
    { name = "path", group_index = 2 },
    { name = "buffer", group_index = 2 },
  },
  sorting = {
    --keep priority weight at 2 for much closer matches to appear above copilot
    --set to 1 to make copilot always appear on top
    priority_weight = 1,
    comparators = {
      -- order matters here
      cmp.config.compare.exact,
      has_copilot and copilot_cmp.prioritize or nil,
      has_copilot and copilot_cmp.score or nil,
      cmp.config.compare.offset,
      -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
      -- personal settings:
      -- cmp.config.compare.recently_used,
      -- cmp.config.compare.offset,
      -- cmp.config.compare.score,
      -- cmp.config.compare.sort_text,
      -- cmp.config.compare.length,
      -- cmp.config.compare.order,
    },
  },
}))
for setup_opt, setup_table in pairs(astronvim.user_plugin_opts("cmp.setup", {})) do
  for pattern, options in pairs(setup_table) do
    setup[setup_opt](pattern, options)
  end
end
