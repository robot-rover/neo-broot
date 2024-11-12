local broot_conf_path = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h") .. "/assets/broot_conf.toml"

function open_broot_in(path)
	local win_height = math.ceil(vim.api.nvim_get_option("lines") * 0.90 - 4)
    local win_width = math.ceil(vim.api.nvim_get_option("columns") * 0.90 - 2)
    local col = math.ceil((vim.api.nvim_get_option("columns") - win_width) * 0.5)
    local row = math.ceil((vim.api.nvim_get_option("lines") - win_height) * 0.5 - 1)

	local tmp_file = os.tmpname()
	local cmd = "broot --conf " .. broot_conf_path .. " --verb-output " .. tmp_file .. " " .. path
	local buffer = vim.api.nvim_create_buf(false, true)
	local window = vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
		style = "minimal"
	})
  vim.api.nvim_buf_set_keymap(buffer, "t", "<Esc>", "<Esc>", {silent = true})

	vim.fn.termopen(cmd, { on_exit = function()
	  vim.api.nvim_win_close(window, true)
    vim.api.nvim_buf_delete(buffer, {force = true})
	  local file = io.open(tmp_file, "r")
	  if not file then return end
	  local content = file:read("*a")
	  file:close()
	  os.remove(tmp_file)
	  for command, file in string.gmatch(content, "(%w+) ([^\r\n]+)") do
      print("broot " .. command .. " " .. file)
      if command == "edit" then
        vim.cmd.edit(file)
      elseif command == "cd" then
        vim.cmd.cd(file)
      elseif command == "tabedit" then
        vim.cmd.tabedit(file)
      elseif command == "split" then
        vim.cmd.split(file)
      elseif command == "vsplit" then
        vim.cmd.vsplit(file)
      elseif command == "echo" then
      else
        error("Unknown command " .. command)
      end
    end
  end })
  vim.api.nvim_command("startinsert")
end

vim.api.nvim_create_user_command('Broot', function() open_broot_in('.') end, {})
vim.api.nvim_create_user_command('BrootFile', function() open_broot_in(vim.fn.expand("%:h")) end, {})
