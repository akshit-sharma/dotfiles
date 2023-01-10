local ok, chatGPT = pcall(require, 'chatgpt')
if not ok then
  vim.notify('ChatGPT not found')
  return
end

chatGPT.setup({
  -- optional configuration
})
