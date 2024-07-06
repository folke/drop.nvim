local M = {}

local uv = vim.uv or vim.loop

---@class DropTheme
---@field symbols (string|fun():string)[]
---@field colors string[]

---@class ActiveDropTheme: DropTheme
---@field hl string[]

---@alias DropDate {month: number, day: number, year?:number}

---@class DropConfig
M.defaults = {
  ---@type DropTheme|string
  theme = "auto", -- when auto, it will choose a theme based on the date
  ---@type ({theme: string}|DropDate|{from:DropDate, to:DropDate}|{holiday:"us_thanksgiving"|"easter"})[]
  themes = {
    { theme = "new_year", month = 1, day = 1 },
    { theme = "valentines_day", month = 2, day = 14 },
    { theme = "st_patricks_day", month = 3, day = 17 },
    { theme = "easter", holiday = "easter" },
    { theme = "april_fools", month = 4, day = 1 },
    { theme = "us_independence_day", month = 7, day = 4 },
    { theme = "halloween", month = 10, day = 31 },
    { theme = "us_thanksgiving", holiday = "us_thanksgiving" },
    { theme = "xmas", from = { month = 12, day = 24 }, to = { month = 12, day = 25 } },
    { theme = "leaves", from = { month = 9, day = 22 }, to = { month = 12, day = 20 } },
    { theme = "snow", from = { month = 12, day = 21 }, to = { month = 3, day = 19 } },
    { theme = "spring", from = { month = 3, day = 20 }, to = { month = 6, day = 20 } },
    { theme = "summer", from = { month = 6, day = 21 }, to = { month = 9, day = 21 } },
  },
  max = 75, -- maximum number of drops on the screen
  interval = 100, -- every 150ms we update the drops
  screensaver = 1000 * 60 * 5, -- show after 5 minutes. Set to false, to disable
  filetypes = { "dashboard", "alpha", "ministarter" }, -- will enable/disable automatically for the following filetypes
  winblend = 100, -- winblend for the drop window
}

M.ns = vim.api.nvim_create_namespace("drop")

---@type DropConfig
M.options = {}
---@type uv_timer_t
M.timer = nil

M.screensaver = false

function M.sleep()
  if M.screensaver then
    require("drop").hide()
  end
  if not M.timer then
    M.timer = uv.new_timer()
  end
  M.timer:start(
    M.options.screensaver,
    0,
    vim.schedule_wrap(function()
      M.screensaver = true
      require("drop").show()
    end)
  )
end

function M.setup(opts)
  math.randomseed(os.time())
  M.options = vim.tbl_extend("force", M.defaults, opts or {})
  M.colors()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = M.colors,
  })

  if #M.options.filetypes > 0 then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = M.options.filetypes,
      once = true,
      callback = function(event)
        M.auto(event.buf)
      end,
    })

    vim.defer_fn(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.tbl_contains(M.options.filetypes, vim.bo[buf].filetype) then
          M.auto(buf)
          break
        end
      end
    end, 100)
  end

  if M.options.screensaver ~= false then
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged", "InsertCharPre" }, {
      callback = function()
        M.sleep()
      end,
    })
  end
end

function M.auto(buf)
  require("drop").show()
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    callback = function()
      require("drop").hide()
    end,
  })
end

---@return DropTheme
function M.get_theme()
  local Util = require("drop.util")
  local themes = require("drop.themes")
  if M.options.theme ~= "auto" then
    return themes[M.options.theme]
  end

  local date = os.date("*t")
  local year = tonumber(date.year)
  local month = tonumber(date.month)
  local day = tonumber(date.day)

  for _, t in ipairs(M.options.themes) do
    if t.holiday == "easter" then
      local easter = Util.calculate_easter()
      t.month = easter.month
      t.day = easter.day
      t.holiday = nil
    elseif t.holiday == "us_thanksgiving" then
      local thanksgiving = Util.calculate_us_thanksgiving()
      t.month = thanksgiving.month
      t.day = thanksgiving.day
      t.holiday = nil
    end
    local from = t.from or t
    local to = t.to or t

    if month >= from.month then
      from.year = year
      to.year = to.month < from.month and year + 1 or year
    else -- month < from.month
      from.year = year - 1
      to.year = to.month < from.month and year or year - 1
    end

    local ff = from.year * 10000 + from.month * 100 + from.day
    local tt = to.year * 10000 + to.month * 100 + to.day
    local dd = year * 10000 + month * 100 + day
    if dd >= ff and dd <= tt then
      M.options.theme = t.theme
      return themes[t.theme]
    end
  end
  return themes.leaves
end

function M.colors()
  vim.api.nvim_set_hl(0, "Drop", { bg = "NONE", nocombine = true })
  local theme = M.get_theme()
  for i, color in ipairs(theme.colors) do
    local hl_group = "Drop" .. i
    vim.api.nvim_set_hl(0, hl_group, { fg = color, blend = 0 })
    vim.api.nvim_set_hl(0, hl_group .. "Bold", { fg = color, bold = true, blend = 0 })
  end
end

return M
