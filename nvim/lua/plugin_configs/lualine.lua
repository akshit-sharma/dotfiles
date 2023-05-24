local ok, lualine = pcall(require, 'lualine')
if not ok then
  vim.notify('"lualine" not found', vim.log.levels.ERROR)
  return
end

lualine.setup {
  options = {
    theme = 'onedark',
    section_separators = '',
    component_separators = '|',
  },
  sections = {
    lualine_a = {
      'filename'
    },
    lualine_b = {
      {'branch', fmt = function(str) return (str ~= "main" and str or ' ') end },
      'diff',
    },
    lualine_c = {
      'navic'
    },

    lualine_x = { 'diagnostics' },
    lualine_y = {
      { 'encoding', fmt = function(str) return (str ~= "utf-8" and str or "") end },
      { 'filetype', icon_only = true, colored = true },
    },
    lualine_z = {
      'location',
      'progress',
      separator = nil,
    },
  }
}
