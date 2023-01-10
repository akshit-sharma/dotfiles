local ok, notify = pcall(require, 'notify')
if not ok then
  print("Error loading notify")
  return
end

notify.setup({
  stages = 'fade_in_slide_out',
  timeout = 5000,
  background_colour = '#000000',
  icons = {
    ERROR = ' ',
    WARN = ' ',
    INFO = ' ',
    DEBUG = ' ',
    TRACE = ' ',
  },
})

local banned_message =  { "warning: multiple different client offset_encodings detected for buffer, this is not supported yet" }

vim.notify = function(msg, ...)
  print("message is msg"..msg)
  for _, banned in ipairs(banned_message) do
    if msg == banned then
      print(msg)
      return
    end
  end
  notify(msg, ...)
end
