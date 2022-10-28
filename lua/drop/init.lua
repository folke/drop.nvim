local M = {}

---@param opts? DropConfig
function M.setup(opts)
	require("drop.config").setup(opts)
end

function M.show()
	require("drop.drop").show()
end

function M.hide()
	require("drop.drop").hide()
end

return M
