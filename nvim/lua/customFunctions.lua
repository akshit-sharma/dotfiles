local command = 'term://bash'
function TerminalOnce()
  if vim.fn.bufwinnr('$') == 1 then
    vim.cmd('botright 20new | terminal')
  else
    vim.cmd('terminal')
  end
end
