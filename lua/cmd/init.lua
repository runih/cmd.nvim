local M = {}
local function expand_cmd(cmd)
  for index, value in ipairs(cmd) do
    cmd[index] = vim.fn.expand(value)
  end
  return cmd
end

local shellbuffers = {}

M.setup = function (opts)
  M.opts = opts
  -- Set commands
  if M.opts.debug then
    print("CMD opts " .. vim.inspect(M.opts))
  end

  if M.opts.set_command or M.opts.set_command == nil then
    vim.cmd("command! CMD lua require'cmd'.execute_current_line()")
  end
end

M.execute = function (command, opts)
  print("Executing command...")
  local cmd = {}
  local result = ""
  for str in string.gmatch(command, "%S+") do
    table.insert(cmd, str)
  end
  cmd = expand_cmd(cmd)
  if opts.debug then
    print(vim.inspect(cmd))
  end
  local handle = io.popen(table.concat(cmd, " ") .. " 2>&1")
  if handle then
    result = handle:read("*a")
    handle:close()
    print("Executing done!")
  else
    print("Executing Failed!")
  end
  return result
end

-- Execute the current line, and send the output to an other buffer
M.execute_current_line = function ()
  -- Get current buffer
  local bufnr = vim.api.nvim_get_current_buf()

  -- create a output buffer for the buffer
  if not shellbuffers[bufnr] then
    shellbuffers[bufnr] = {
      output = vim.api.nvim_create_buf(true, true)
    }
    vim.api.nvim_buf_set_name(shellbuffers[bufnr].output, 'CMD OUTPUT')
  end

  if shellbuffers[bufnr].output then
    -- If now window is visable create a new window
    shellbuffers[bufnr].scriptwin = vim.api.nvim_get_current_win()
    local window_exists, _ = pcall(vim.api.nvim_win_get_config, shellbuffers[bufnr].outputwin)
    if not window_exists then
      vim.cmd('split')
      shellbuffers[bufnr].outputwin = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(shellbuffers[bufnr].outputwin, shellbuffers[bufnr].output)
      vim.api.nvim_set_current_win(shellbuffers[bufnr].scriptwin)
    end

    -- Get the current line
    local lineNum = vim.api.nvim_win_get_cursor(0)[1]
    -- Get the content for the current line
    local content = vim.api.nvim_buf_get_lines(bufnr, lineNum - 1, lineNum, false)
    -- the content is a table of rows, only pass the first one

    local lines = M.execute(content[1], {debug = M.opts.debug})

    local linenr = 1
    -- Clear the buffer
    vim.api.nvim_buf_set_lines(shellbuffers[bufnr].output, 0, -1, false, { "" })
    for line in lines:gmatch("([^\n]*)\n?") do
      if line and string.len(line) > 0 then
        if linenr == 1 then
          vim.api.nvim_buf_set_lines(shellbuffers[bufnr].output, 0, -1, false, { line })
        else
          vim.api.nvim_buf_set_lines(shellbuffers[bufnr].output, -1, -1, false, { line })
        end
        linenr = linenr + 1
      end
    end
  end
end

return M
