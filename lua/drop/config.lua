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
  max = 75, -- maximum number of drops on the screen
  interval = 100, -- every 150ms we update the drops
  screensaver = 1000 * 60 * 5, -- show after 5 minutes. Set to false, to disable
  filetypes = { "dashboard", "alpha", "starter" }, -- will enable/disable automatically for the following filetypes
  winblend = 100, -- winblend for the drop window
}

M.ns = vim.api.nvim_create_namespace("drop")

---@type table<string,DropTheme>
M.themes = {
  stars = {
    symbols = { "★", "⭐", "✮", "✦", "✬", "✯", "🌟" },
    colors = {
      "#ffd27d",
      "#ffa371",
      "#a6a8ff",
      "#fffa86",
      "#a87bff",
    },
  },
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
  xmas = {
    symbols = {
      "🎄",
      "🎁",
      "🤶",
      "🎅",
      "🛷",
      "❄",
      "⛄",
      "🌟",
      "🦌",
      "🎶",
      "❄️ ",
      " ",
      "❅",
      "❇",
      "*",
    },
    colors = {
      "#146B3A",
      "#F8B229",
      "#EA4630",
      "#BB2528",
    },
  },
  spring = {
    symbols = {
      "🐑",
      "🐇",
      "🦔",
      "🐣",
      "🦢",
      "🐝",
      "🌻",
      "🌼",
      "🌷",
      "🌱",
      "🌳",
      "🌾",
      "🍀",
      "🍃",
      "🌈",
    },
    colors = {
      "#A36F58",
      "#FEDC78",
      "#F6F5AD",
      "#CFEEB7",
      "#ADE6B0",
    },
  },
  halloween = {
    symbols = { "👻", "🧛", "🧟", "🍬", "🍫" },
    colors = {
      "#3A3920",
      "#807622",
      "#EAA724",
      "#D25B01",
      "#5B1C02",
      "#740819",
    },
  },
  summer = {
    symbols = {
      "😎",
      "🏄",
      "🏊",
      "🌻",
      "🌴",
      "🍹",
      "🏝️",
      "☀️ ",
      "🌞",
      "🕶️",
      "👕",
      "⛵",
      "🥥",
      "🌊",
    },
    colors = {
      "#236e96",
      "#15b2d3",
      "#ffd700",
      "#f3872f",
      "#ff598f",
    },
  },
}

M.options = {}
---@type vim.loop.Timer
M.timer = nil

M.screensaver = false

function M.sleep()
  if M.screensaver then
    require("drop").hide()
  end
  if not M.timer then
    M.timer = vim.loop.new_timer()
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
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
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

local function _auto_theme(auto_theme)
  local current_month = os.date("*t").month
  local xmas = false
  local halloween = false
  for part in string.gmatch(auto_theme, "([^_]+)") do
    if part == "xmas" then
      xmas = true
    end
    if part == "halloween" then
      halloween = true
    end
  end
  local theme = ""
  if current_month <= 2 then
    theme = "snow"
  elseif current_month <= 5 then
    theme = "spring"
  elseif current_month <= 8 then
    theme = "summer"
  elseif current_month == 10 then
    theme = "leaves"
    if halloween then
      theme = "halloween"
    end
  elseif current_month <= 11 then
    theme = "leaves"
  elseif current_month == 12 then
    theme = "stars"
    if xmas then
      theme = "xmas"
    end
  end
  return theme
end

function M.get_theme()
  local theme = M.options.theme
  if type(theme) == "string" then
    if theme:sub(1, 4) == "auto" then
      theme = _auto_theme(theme)
    end
    theme = M.themes[theme]
  end
  return theme
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
