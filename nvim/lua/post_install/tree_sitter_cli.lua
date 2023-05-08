local ok_job, Job = pcall(require, 'plenary.job')
local ok_notify, notify = pcall(require, 'notify')


if not ok_notify then
  notify = function(text, level, extra)
    vim.notify(text, level)
  end
end

local notificationOptions = {
  title = 'tree-sitter-cli',
  -- tree icon
  icon = '🌲',
  render = 'compact',
}

local record = nil

local reallyExist = function(output)
  local notfoundtest = 'not found'
  return (string.find(output, notfoundtest) ~= nil)
end

local checkTreeSitterCli = function(version, installFunc)
  local treeSitterCliStream = io.popen('tree-sitter --version 2>&1')
  if treeSitterCliStream == nil or reallyExist(treeSitterCliStream:read('*all')) then
    record = notify('not found, installing', vim.log.levels.WARN, notificationOptions)
    installFunc(version)
  end
end

if not ok_job then
  G_installTreeSitterCli = function(version)
    record = notify('installing', vim.log.levels.INFO,  { replace = record })
    local installStream = io.popen('npm install -g tree-sitter-cli@'..version)
    if installStream == nil then
      record = notify('Error installing', vim.log.levels.ERROR,  { replace = record })
    else
      installStream:close()
    end
  end
else
  G_installTreeSitterCli = function(version)
    record = notify('installing via async', vim.log.levels.INFO,  { replace = record })
    Job:new({
      command = 'npm',
      args = {'install', '-g', 'tree-sitter-cli@'..version},
      cwd = '~/faaltu',
      on_exit = function(output, returnVal)
        if returnVal ~= 0 then
          record = notify('Error installing '..returnVal, vim.log.levels.ERROR,  { replace = record })
        else
          record = notify('installed', vim.log.levels.INFO,  { replace = record })
        end
      end,
    }):start()
  end
end

local treesittercliVersion = '0.20.8'
checkTreeSitterCli(treesittercliVersion, G_installTreeSitterCli)

