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
  filetypes = { "dashboard", "alpha", "starter" }, -- will enable/disable automatically for the following filetypes
}

---@type table<string,DropTheme>
M.themes = {
  stars = {
    symbols = { "★", "⭐", "✮", "✦", "✬", "✯" },
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
  M.timer:start(M.options.screensaver, 0, function()
    M.screensaver = true
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

  if #M.options.filetypes > 0 then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = M.options.filetypes,
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
