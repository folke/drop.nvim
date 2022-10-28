local M = {}

---@class DropTheme
---@field symbols string[]
---@field colors string[]

---@class ActiveDropTheme: DropTheme
---@field hl string[]

---@class DropConfig
M.defaults = {
	---@type DropTheme|string
	theme = "leaves", -- can be one of rhe default themes, or a custom theme
	max = 40, -- maximum number of drops on the screen
	interval = 150, -- every 150ms we update the drops
	screensaver = 1000 * 60 * 5, -- show after 5 minutes. Set to false, to disable
}

---@type table<string,DropTheme>
M.themes = {
	leaves = {
		symbols = { "🍂", "🍁", "🍀", "🌿", " ", " ", " " },
		colors = {
			"#3A3920",
			"#807622",
			"#EAA724",
			"#D25B01",
			"#5B1C02",
			"#740819",
		},
	},
	snow = {
		symbols = { "❄️ ", " ", "❅", "❇", "*", "." },
		colors = {
			"#c6fbff",
			"#abf0ff",
			"#99c4ce",
			"#73999a",
			"#628485",
		},
	},
}

M.options = {}
---@type vim.loop.Timer
M.timer = nil

function M.sleep()
	require("drop").hide()
	if not M.timer then
		M.timer = vim.loop.new_timer()
	end
	M.timer:start(M.options.screensaver, 0, function()
		require("drop").show()
	end)
end

function M.setup(opts)
	math.randomseed(os.time())
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
	M.colors()
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = M.colors,
	})

	if M.options.screensaver ~= false then
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged", "InsertCharPre" }, {
			callback = function()
				M.sleep()
			end,
		})
	end
end

function M.get_theme()
	local theme = M.options.theme
	if type(theme) == "string" then
		theme = M.themes[theme]
	end
	return theme
end

function M.colors()
	local theme = M.get_theme()
	for i, color in ipairs(theme.colors) do
		local hl_group = "Drop" .. i
		vim.api.nvim_set_hl(0, hl_group, { fg = color })
		vim.api.nvim_set_hl(0, hl_group .. "Bold", { fg = color, bold = true })
	end
end

return M
