local ok, notify = pcall(require, 'notify')
if not ok then
  print("Error loading notify")
  return
end

notify.setup()

local banned_message =  { "warning: multiple different client offset_encodings detected for buffer, this is not supported yet" }

vim.notify = function(msg, ...)
  print("message is msg "..msg)
  for _, banned in ipairs(banned_message) do
    if msg == banned then
      print(msg)
      return
    end
  end
  notify(msg, ...)
end
