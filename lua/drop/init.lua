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

function M.calculate_easter(year)
  return require("drop.config").calculate_easter(year)
end

function M.calculate_us_thanksgiving(year)
  return require("drop.config").calculate_us_thanksgiving(year)
end

return M
