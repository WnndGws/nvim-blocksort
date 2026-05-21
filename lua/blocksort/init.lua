-- Vibed my way to an answer
local M = {}

-- Map characters to sort keys: A-Z < a-z < 0-9 < everything else
local function char_sort_key(c)
	local byte = string.byte(c)
	if byte >= 65 and byte <= 90 then
		return byte
	elseif byte >= 97 and byte <= 122 then
		return byte + 256
	elseif byte >= 48 and byte <= 57 then
		return byte + 512
	else
		return byte + 1024
	end
end

-- Compare two strings character-by-character using the custom sort order
local function compare_strings(a, b)
	local min_len = math.min(#a, #b)
	for i = 1, min_len do
		local ka = char_sort_key(a:sub(i, i))
		local kb = char_sort_key(b:sub(i, i))
		if ka ~= kb then
			return ka < kb
		end
	end
	return #a < #b
end

function M.block_sort(regex_str, opts)
	local ok, re = pcall(vim.regex, regex_str)
	if not ok then
		vim.notify("Invalid regex: " .. regex_str, vim.log.levels.ERROR)
		return
	end

	-- Determine range: visual selection or cursor-to-EOF
	-- opts.range is 0 if no range, or a table {start, end} if range is provided
	local start_line, end_line
	if opts.range ~= 0 and type(opts.range) == "table" then
		start_line = opts.range[1]
		end_line = opts.range[2]
	else
		start_line = vim.fn.line(".")
		end_line = vim.fn.line("$")
	end

	-- Find all lines matching the regex within the range
	local match_lines = {}
	for i = start_line, end_line do
		local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
		if re:match_str(line) then
			table.insert(match_lines, i)
		end
	end

	if #match_lines == 0 then
		vim.notify("No matches found for regex: " .. regex_str, vim.log.levels.WARN)
		return
	end

	-- Build blocks: each block starts at a match line and ends before the next match
	local blocks = {}
	for idx, match_line in ipairs(match_lines) do
		local block_start = match_line
		local block_end
		if idx < #match_lines then
			block_end = match_lines[idx + 1] - 1
		else
			block_end = end_line
		end

		local header = vim.api.nvim_buf_get_lines(0, block_start - 1, block_start, false)[1]
		local body = vim.api.nvim_buf_get_lines(0, block_start, block_end, false)

		table.insert(blocks, { header = header, body = body })
	end

	-- Sort blocks by header using the custom A-Z a-z 0-9 order
	table.sort(blocks, function(a, b)
		return compare_strings(a.header, b.header)
	end)

	-- Replace text from first match to end of range with sorted blocks
	local first_match = match_lines[1]
	local new_lines = {}
	for _, block in ipairs(blocks) do
		table.insert(new_lines, block.header)
		for _, line in ipairs(block.body) do
			table.insert(new_lines, line)
		end
	end

	vim.api.nvim_buf_set_lines(0, first_match - 1, end_line, false, new_lines)
end

-- Register the command
vim.api.nvim_create_user_command("BlockSort", function(opts)
	M.block_sort(opts.args, opts)
end, {
	nargs = 1,
	range = true,
})

return M
