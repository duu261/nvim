local api = vim.api

-- :Del - Delete buffer and file on disk
api.nvim_create_user_command("Del", function(args)
	local bufnr = api.nvim_get_current_buf()
	local fname = api.nvim_buf_get_name(bufnr)
	if vim.bo[bufnr].buftype == "" then
		local ok, err = os.remove(fname)
		assert(args.bang or ok, err)
	end
	api.nvim_buf_delete(bufnr, { force = args.bang })
end, { bang = true, desc = "Delete buffer and file on disk" })

-- :GV - Git Visual log for selected lines
api.nvim_create_user_command("GV", function(args)
	local fname = api.nvim_buf_get_name(0)
	local cmd = {
		'G log --date=short --format="%cd %h%d %s (%an)"',
		string.format("-L%d,%d:%s", args.line1, args.line2, fname),
	}
	vim.cmd(table.concat(cmd, " "))
end, { range = "%", desc = "Git visual log for selected lines" })

-- :C - Smart close buffer without closing split
api.nvim_create_user_command("C", function(args)
	local curbuf = api.nvim_get_current_buf()
	local altbuf = nil
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if buf ~= curbuf and api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
			altbuf = buf
			break
		end
	end
	if not altbuf then
		altbuf = api.nvim_create_buf(true, true)
	end
	for _, win in ipairs(api.nvim_list_wins()) do
		if api.nvim_win_get_buf(win) == curbuf then
			api.nvim_win_set_buf(win, altbuf)
		end
	end
	local force = (args.bang or vim.bo[curbuf].buftype == "prompt" or api.nvim_buf_get_name(0) == "")
	api.nvim_buf_delete(curbuf, { force = force })
end, { bang = true, desc = "Smart close buffer" })

-- :JdtCleanWorkspaces[!] [days] - Preview or remove stale JDTLS workspaces
api.nvim_create_user_command("JdtCleanWorkspaces", function(args)
	local days = args.args == "" and 14 or tonumber(args.args)
	if not days or days < 1 or days % 1 ~= 0 then
		vim.notify("JdtCleanWorkspaces expects a positive whole number of days", vim.log.levels.ERROR)
		return
	end

	local workspace_root = vim.fn.expand("~/code/workspace")
	local root_stat = vim.uv.fs_stat(workspace_root)
	if not root_stat or root_stat.type ~= "directory" then
		vim.notify("No JDTLS workspace directory: " .. workspace_root, vim.log.levels.WARN)
		return
	end

	local active = {}
	for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
		local cmd = (client.config or {}).cmd or {}
		for index, argument in ipairs(cmd) do
			if argument == "-data" and cmd[index + 1] then
				active[vim.fs.normalize(cmd[index + 1])] = true
				break
			end
		end
	end

	local cutoff = os.time() - (days * 24 * 60 * 60)
	local candidates = {}
	for name, entry_type in vim.fs.dir(workspace_root) do
		if entry_type == "directory" then
			local path = vim.fs.joinpath(workspace_root, name)
			local stat = vim.uv.fs_stat(path)
			local activity_stat = vim.uv.fs_stat(vim.fs.joinpath(path, ".metadata", ".log")) or stat
			if activity_stat and activity_stat.mtime.sec < cutoff and not active[vim.fs.normalize(path)] then
				table.insert(candidates, path)
			end
		end
	end
	table.sort(candidates)

	if #candidates == 0 then
		vim.notify(string.format("No inactive JDTLS workspaces older than %d days", days))
		return
	end

	local names = vim.tbl_map(vim.fs.basename, candidates)
	if not args.bang then
		vim.notify(
			string.format(
				"Inactive JDTLS workspaces older than %d days:\n%s\nRun :JdtCleanWorkspaces! %d to remove",
				days,
				table.concat(names, "\n"),
				days
			)
		)
		return
	end

	local failures = {}
	for _, path in ipairs(candidates) do
		local ok, remove_error = pcall(vim.fs.rm, path, { recursive = true })
		if not ok then
			table.insert(failures, vim.fs.basename(path) .. ": " .. tostring(remove_error))
		end
	end

	if #failures > 0 then
		vim.notify("JDTLS cleanup failures:\n" .. table.concat(failures, "\n"), vim.log.levels.ERROR)
		return
	end
	vim.notify(string.format("Removed %d stale JDTLS workspace(s)", #candidates))
end, { bang = true, nargs = "?", desc = "Preview or remove stale JDTLS workspaces" })

-- :Term - Run visual selection in terminal split
api.nvim_create_user_command("Term", function(args)
	local srcbuf = api.nvim_get_current_buf()
	local lines
	if args.range ~= 0 then
		lines = api.nvim_buf_get_lines(srcbuf, args.line1 - 1, args.line2, true)
		local indent = math.huge
		for _, line in ipairs(lines) do
			indent = math.min(line:find("[^ ]") or math.huge, indent)
		end
		if indent ~= math.huge and indent > 0 then
			for i, line in ipairs(lines) do
				lines[i] = line:sub(indent)
			end
		end
	end
	vim.cmd("belowright split")
	local win = api.nvim_get_current_win()
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	local bufnr = api.nvim_create_buf(true, true)
	api.nvim_win_set_buf(win, bufnr)
	local jobid
	local chan = api.nvim_open_term(bufnr, {
		on_input = function(_, _, _, data)
			pcall(api.nvim_chan_send, jobid, data)
		end,
	})
	local opts = {
		height = api.nvim_win_get_height(win),
		width = api.nvim_win_get_width(win),
		pty = true,
		on_stdout = function(_, data)
			local count = #data
			for idx, line in ipairs(data) do
				local islast = idx == count
				local msg = islast and line or (line .. "\n")
				local send_ok = pcall(api.nvim_chan_send, chan, msg)
				if not send_ok then
					return
				end
			end
		end,
		on_exit = function(_, exit_code)
			pcall(api.nvim_chan_send, chan, "\r\n[Process exited " .. tostring(exit_code) .. "]")
			pcall(api.nvim_buf_set_keymap, bufnr, "t", "<CR>", "<cmd>bd!<CR>", { noremap = true, silent = true })
		end,
	}
	local cmd = args.args == "" and vim.o.shell or args.args
	if lines then
		local inputs = vim.fn.tempname()
		vim.fn.system(string.format('mkfifo "%s"', inputs))
		jobid = vim.fn.jobstart(string.format('cat "%s" | %s', inputs, cmd), opts)
		local f = io.open(inputs, "a")
		if f then
			for _, line in ipairs(lines) do
				f:write(line)
				f:write("\n")
			end
			f:flush()
			f:close()
		end
	else
		jobid = vim.fn.jobstart(cmd, opts)
	end
end, { nargs = "*", range = "%", desc = "Like :term but supporting range" })
