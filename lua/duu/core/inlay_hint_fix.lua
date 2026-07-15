-- Compatibility guard for JDTLS inlay hints that reach Neovim with out-of-range coordinates.
-- Keep until normal Java editing on the current Neovim version proves the upstream fix stable.
local inlay_ns = vim.api.nvim_create_namespace("nvim.lsp.inlayhint")
local original_set_extmark = vim.api.nvim_buf_set_extmark
vim.api.nvim_buf_set_extmark = function(buffer, ns_id, line, col, opts)
	if ns_id == inlay_ns then
		-- clamp line to buffer end (lines deleted since hint was computed)
		local line_count = vim.api.nvim_buf_line_count(buffer)
		if line >= line_count then
			line = math.max(line_count - 1, 0)
		end
		-- clamp col to end of line
		local success, lines = pcall(vim.api.nvim_buf_get_lines, buffer, line, line + 1, false)
		local line_length = (success and lines and lines[1]) and #lines[1] or 0
		if col > line_length then
			col = line_length
		end
	end

	return original_set_extmark(buffer, ns_id, line, col, opts)
end
