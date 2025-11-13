local M = {}

local pending = ""

local SIGN_GROUP = "RelativeNumberHints"
local SIGN_NAME = "RelativeNumberHintSign"
local HLGROUP = "RelativeNumberHint"

vim.api.nvim_set_hl(0, HLGROUP, { fg = "#ff0000", bold = true })
vim.fn.sign_define(SIGN_NAME, {
	numhl = HLGROUP,
})

local function clear()
	pending = ""
	local buf = vim.api.nvim_get_current_buf()
	vim.fn.sign_unplace(SIGN_GROUP, { buffer = buf })
end

local function highlight_line(buf, row0)
	vim.fn.sign_place(0, SIGN_GROUP, SIGN_NAME, buf, { lnum = row0 + 1, priority = 10000 })
end

local function apply()
	if pending == "" then
		return
	end

	local count = tonumber(pending)
	if not count then
		return
	end

	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_win_get_buf(win)

	local cursor = vim.api.nvim_win_get_cursor(win)
	local cur_1 = cursor[1]
	local max_1 = vim.api.nvim_buf_line_count(buf)

	local up_1 = math.max(1, cur_1 - count)
	local down_1 = math.min(max_1, cur_1 + count)

	vim.fn.sign_unplace(SIGN_GROUP, { buffer = buf })

	highlight_line(buf, up_1 - 1)

	if down_1 ~= up_1 then
		highlight_line(buf, down_1 - 1)
	end
end

local function on_digit(d)
	if vim.fn.mode() ~= "n" then
		return d
	end

	pending = pending .. d

	apply()

	return "<Ignore>"
end

local function on_motion(m)
	if pending == "" then
		return m
	end

	local count = tonumber(pending) or 0
	clear()

	local keys = string.format("%d%s", count, m)

	vim.api.nvim_feedkeys(keys, "n", false)

	return "<Ignore>"
end

function M.setup(opts)
	opts = opts or {}

	if opts.highlight then
		vim.api.nvim_set_hl(0, HLGROUP, opts.highlight)
	end

	local digits = "0123456789"
	for d in digits:gmatch(".") do
		vim.keymap.set("n", d, function()
			return on_digit(d)
		end, { expr = true, noremap = true })
	end

	local motions = opts.motions or { "j", "k" }
	for _, m in ipairs(motions) do
		vim.keymap.set("n", m, function()
			return on_motion(m)
		end, { expr = true, noremap = true, replace_keycodes = true })
	end

	vim.keymap.set("n", "<Esc>", function()
		clear()
		return "<Esc>"
	end, { expr = true })
end

return M
