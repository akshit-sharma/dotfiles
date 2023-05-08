--[[

local ok, notifier = pcall(require, "notifier")
if not ok then
  print("Error loading notifier")
  return
end

notifier.setup({
  ignore_messages = {}, -- Ignore message from LSP servers with this name
  -- status_width = something, -- COmputed using 'columns' and 'textwidth'
  components = {  -- Order of the components to draw from top to bottom (first nvim notifications, then lsp)
    "nvim",  -- Nvim notifications (vim.notify and such)
    "lsp"  -- LSP status updates
  },
  notify = {
    clear_time = 5000, -- Time in milliseconds before removing a vim.notify notification, 0 to make them sticky
    min_level = vim.log.levels.INFO, -- Minimum log level to print the notification
  },
  component_name_recall = false, -- Whether to prefix the title of the notification by the component name
  zindex = 50, -- The zindex to use for the floating window. Note that changing this value may cause visual bugs with other windows overlapping the notifier window.
})

local banned_message =  { "warning: multiple different client offset_encodings detected for buffer, this is not supported yet" }

vim.notify = function(msg, ...)
  print("message is msg : "..msg)
  for _, banned in ipairs(banned_message) do
    if msg == banned then
      print(msg)
      return
    end
  end
  notifier(msg, ...)
end

]]--
