local M = {}

local function get_comment_prefix()
  local cs = vim.bo.commentstring ~= '' and vim.bo.commentstring or '# %s'
  return cs:match('^(%S+)') or '#'
end

local function get_repo_info()
  local remotes = vim.fn.systemlist('git remote 2>/dev/null')
  if #remotes == 0 then return '', '' end

  local selected
  if #remotes == 1 then
    selected = remotes[1]
  else
    table.insert(remotes, 1, 'Cancel')
    local idx = vim.fn.inputlist(remotes)
    if idx <= 1 then return '', '' end
    selected = remotes[idx]
  end

  local url = vim.fn.system('git remote get-url ' .. selected .. ' 2>/dev/null'):gsub('[\n\r]', '')
  local project = vim.fn.system('basename $(git rev-parse --show-toplevel 2>/dev/null)'):gsub('[\n\r]', '')
  return url, project
end

local function build_header(comment, opts)
  local sep = comment .. ' -----------------------------------------------------------------------------'
  return {
    comment .. ' INFO:',
    sep,
    comment .. ' Script: ' .. opts.filename,
    comment .. ' Version: ' .. opts.version,
    comment .. ' Author: RITHIK RATHAN C. <github.com/rithikrathan>',
    comment .. ' License: ' .. opts.license,
    comment .. ' Repository: ' .. opts.repository,
    comment .. ' Project: ' .. opts.project,
    comment .. ' Created: ' .. opts.created,
    comment .. ' Description: ' .. opts.description,
    sep,
    '',
  }
end

local function parse_header(comment)
  local lines = vim.fn.getline(1, math.min(vim.fn.line('$'), 30))
  local info_pattern = '^' .. vim.pesc(comment) .. ' INFO:$'
  local field_pattern = '^%s*' .. vim.pesc(comment) .. ' (%w+):%s*(.*)$'
  local in_header = false
  local parsed = {}

  for _, line in ipairs(lines) do
    if not in_header and line:match(info_pattern) then
      in_header = true
    elseif in_header and line:match('^' .. vim.pesc(comment) .. ' %-+$') then
      break
    elseif in_header then
      local _, _, key, val = line:find(field_pattern)
      if key then
        parsed[key:lower()] = val or ''
      end
    end
  end

  return parsed
end

local function insert_header(header_lines)
  local first = vim.fn.getline(1)
  local pos = first:match('^#!') and 1 or 0
  vim.fn.append(pos, header_lines)
end

function M.add()
  local comment = get_comment_prefix()
  local filename = vim.fn.expand('%:t')
  if filename == '' then filename = 'untitled' end

  local repo_url, project = get_repo_info()
  local version = vim.fn.input('Version: ')
  local desc = vim.fn.input('Description: ')

  local header = build_header(comment, {
    filename = filename,
    version = version,
    license = '',
    repository = repo_url,
    project = project,
    created = os.date('%Y-%m-%d'),
    description = desc,
  })

  insert_header(header)
  print('Header inserted.')
end

function M.update()
  local comment = get_comment_prefix()
  local filename = vim.fn.expand('%:t')
  if filename == '' then filename = 'untitled' end

  local parsed = parse_header(comment)
  local old_version = parsed.version or ''
  local old_desc = parsed.description or ''
  local old_license = parsed.license or ''

  local version = vim.fn.input('Version [' .. old_version .. ']: ', old_version)
  local desc = vim.fn.input('Description [' .. old_desc .. ']: ', old_desc)
  local license = vim.fn.input('License [' .. old_license .. ']: ', old_license)

  local repo_url, project = get_repo_info()
  if repo_url == '' then repo_url = parsed.repository or '' end
  if project == '' then project = parsed.project or '' end

  local header = build_header(comment, {
    filename = filename,
    version = version ~= '' and version or old_version,
    license = license ~= '' and license or old_license,
    repository = repo_url,
    project = project,
    created = os.date('%Y-%m-%d'),
    description = desc ~= '' and desc or old_desc,
  })

  insert_header(header)
  print('Header inserted.')
end

return M
