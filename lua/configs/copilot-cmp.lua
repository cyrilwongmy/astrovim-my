local copilot_status_ok, copilot_cmp = pcall(require, "copilot_cmp")
if not copilot_status_ok then
  vim.notify("copilot_cmp not work")
  return
end
if copilot_status_ok then
  vim.notify("copilot_cmp ok")
end

copilot_cmp.setup {
  method = "getCompletionsCycling",
  formatters = {
    label = require("copilot_cmp.format").format_label_text,
    insert_text = require("copilot_cmp.format").format_insert_text,
    preview = require("copilot_cmp.format").deindent,
  },
}
