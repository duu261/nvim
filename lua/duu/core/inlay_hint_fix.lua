-- Hack to fix Neovim core inlay hint out of bounds column error while typing asynchronously
local original_set_extmark = vim.api.nvim_buf_set_extmark
vim.api.nvim_buf_set_extmark = function(buffer, ns_id, line, col, opts)
	-- only intercept inlay hints namespace
	local is_inlay_ns = false
	if ns_id then
		for ns_name, id in pairs(vim.api.nvim_get_namespaces()) do
			if id == ns_id and ns_name == "nvim.lsp.inlayhint" then
				is_inlay_ns = true
				break
			end
		end
	end

	if is_inlay_ns then
		local line_length = 0
		local success, lines = pcall(vim.api.nvim_buf_get_lines, buffer, line, line + 1, false)
		if success and lines and lines[1] then
			line_length = #lines[1]
		end
		-- Check if the column is out of range to prevent the crash
		if col > line_length then
			-- clamp to end of line or ignore
			col = line_length
		end
	end

	return original_set_extmark(buffer, ns_id, line, col, opts)
end
