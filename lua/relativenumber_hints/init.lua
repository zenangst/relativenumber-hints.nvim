local M = {}

local defaults = {
	highlight = nil,
	motions = { "j", "k", "h", "l", "g" },
	center_motion_threshold = 15,
}

local pending = ""

local SIGN_GROUP = "RelativeNumberHints"
local SIGN_NAME = "RelativeNumberHintSign"
local HLGROUP = "RelativeNumberHint"

vim.api.nvim_set_hl(0, HLGROUP, { fg = "#ff0000", bold = true })
vim.fn.sign_define(SIGN_NAME, {
	text = "",
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
	local mode = vim.fn.mode()
	if
		mode ~= "n"
		and mode ~= "v"
		and mode ~= "V"
		and mode ~= "\22"
		and mode ~= "no"
		and mode ~= "noV"
		and mode ~= "no\22"
	then
		return d
	end

	pending = pending .. d
	apply()

	return "<Ignore>"
end

local function on_motion(opts, m)
	if pending == "" then
		return m
	end

	local count = tonumber(pending) or 0
	clear()

	local keys = string.format("%d%s", count, m)

	vim.api.nvim_feedkeys(keys, "n", false)
	if count >= opts.center_motion_threshold then
		vim.schedule(function()
			vim.cmd("normal! zz")
		end)
	end

	return "<Ignore>"
end

local function on_motion_visual(m)
	if pending == "" then
		return m
	end

	local count = tonumber(pending) or 0
	clear()

	local keys = string.format("%d%s", count, m)
	vim.api.nvim_feedkeys(keys, "n", false)

	return "<Ignore>"
end

local function on_motion_operator(m)
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
	opts = vim.tbl_deep_extend("force", defaults, opts or {})

	if opts.highlight then
		vim.api.nvim_set_hl(0, HLGROUP, opts.highlight)
	end

	local digits = "0123456789"
	for d in digits:gmatch(".") do
		vim.keymap.set("n", d, function()
			return on_digit(d)
		end, { expr = true, noremap = true })
		vim.keymap.set("v", d, function()
			return on_digit(d)
		end, { expr = true, noremap = true })
		vim.keymap.set("o", d, function()
			return on_digit(d)
		end, { expr = true, noremap = true })
	end

	vim.keymap.set("n", "gg", function()
		if pending ~= "" then
			local count = tonumber(pending)
			clear()
			return tostring(count) .. "gg"
		end
		return "gg"
	end, { expr = true, noremap = true })

	local motions = opts.motions or { "j", "k", "h", "l", "g" }
	for _, m in ipairs(motions) do
		vim.keymap.set("n", m, function()
			return on_motion(opts, m)
		end, { expr = true, noremap = true, replace_keycodes = true })

		vim.keymap.set("v", m, function()
			return on_motion_visual(m)
		end, { expr = true, noremap = true })

		vim.keymap.set("o", m, function()
			return on_motion_operator(m)
		end, { expr = true, noremap = true })
	end

	local existing = vim.fn.maparg("<C-c>", "n")
	if existing == "" then
		vim.keymap.set({ "n", "v" }, "<C-c>", function()
			clear()
			return "<C-c>"
		end, { expr = true })
	end

	vim.keymap.set({ "n", "v" }, "<Esc>", function()
		if pending ~= "" then
			clear()
			return ""
		end
		if _G._original_esc_handler then
			_G._original_esc_handler()
			return ""
		end
		return "<Esc>"
	end, { expr = true })
end

return M
