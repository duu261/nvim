local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup("HighlightYank", {})

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

local DuuGroup = augroup("Duu", {})

-- auto remove trailing white space (keep cursor/view in place)
autocmd({ "BufWritePre" }, {
	group = DuuGroup,
	pattern = "*",
	callback = function()
		local view = vim.fn.winsaveview()
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})
-- Filetype association for Hyprland config files
vim.filetype.add({
	pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})
-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime", {}),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})
-- resize splits if window got resized
autocmd({ "VimResized" }, {
	group = augroup("resize_splits", {}),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc", {}),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
			return
		end
		vim.b[buf].lazyvim_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
autocmd("FileType", {
	group = augroup("close_with_q", {}),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

-- make it easier to close man-files when opened inline
autocmd("FileType", {
	group = augroup("man_unlisted", {}),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir", {}),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Auto-template for pom.xml
autocmd("BufNewFile", {
	group = augroup("auto_templates", { clear = true }),
	pattern = "pom.xml",
	callback = function(args)
		local java_version = "JAVA_VERSION"
		if vim.fn.executable("java") == 1 then
			local ok, result = pcall(function()
				return vim.system({ "java", "-version" }, { text = true }):wait()
			end)
			if ok and result.code == 0 then
				local output = (result.stdout or "") .. "\n" .. (result.stderr or "")
				local raw = output:match('version%s+"([^"]+)"')
				java_version = raw and (raw:match("^1%.(%d+)") or raw:match("^(%d+)")) or java_version
			end
		end
		local content = [[
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>${1:group}</groupId>
  <artifactId>${2:artifact}</artifactId>
  <version>${3:0.1.0}</version>
  <packaging>${4:jar}</packaging>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.release>${5:__JAVA_VERSION__}</maven.compiler.release>
  </properties>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.15.0</version>
      </plugin>
    </plugins>
  </build>

  <dependencies>
  </dependencies>
</project>
]]
		content = content:gsub("__JAVA_VERSION__", java_version)
		if vim.snippet then
			vim.snippet.expand(content)
		else
			vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, vim.split(content, "\n"))
		end
	end,
})
