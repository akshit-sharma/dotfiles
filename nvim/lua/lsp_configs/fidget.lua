-- https://github.com/j-hui/fidget.nvim
local ok, fidget = pcall(require, "fidget")
if not ok then
  vim.notify('fidget not found','error')
  return
end
fidget.setup({
  task = function (task_name, message, percentage)
    if task_name == 'Checking document' then return nil end
    --vim.notify('taskname: '..task_name..' message: '..message..' percentage: '..percentage)
    return string.format(
      "%s%s [%s]",
      message,
      percentage and string.format(" (%s%%)", percentage) or "",
      task_name
    )
  end,
})
