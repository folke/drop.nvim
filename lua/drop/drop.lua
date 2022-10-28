local config = require("drop.config")

local M = {}

---@type vim.loop.Timer?
M.timer = nil

---@class Drop
---@field id integer
---@field symbol string
---@field hl_group string
---@field row integer
---@field col integer
---@field win? integer
---@field buf? integer
local Drop = {}
Drop.__index = Drop

Drop._id = 1
---@type table<integer, Drop>
Drop.drops = {}

function Drop.new()
  local self = setmetatable({}, Drop)
  local theme = config.get_theme()
  local symbols = theme.symbols
  local colors = vim.tbl_keys(theme.colors)

  Drop._id = Drop._id + 1
  self.id = Drop._id
  self.symbol = symbols[math.random(1, #symbols)]
  self.hl_group = "Drop" .. math.random(1, #colors) .. (math.random(1, 3) == 1 and "Bold" or "")
  self.row = 0
  self.col = math.random(0, vim.go.columns)
  self.win = nil
  self.buf = nil
  self.speed = math.random(1, 2)
  Drop.drops[self.id] = self
  return self
end

function Drop:show()
  if not self.win then
    self.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[self.buf].filetype = "drop"
    vim.api.nvim_buf_set_name(self.buf, "")
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, { self.symbol })
    self.win = vim.api.nvim_open_win(self.buf, false, {
      relative = "editor",
      row = self.row,
      col = self.col,
      width = vim.fn.strwidth(self.symbol) + 1,
      height = 1,
      focusable = false,
      zindex = 1000,
      style = "minimal",
      noautocmd = true,
    })
    vim.wo[self.win].winhighlight = "NormalFloat:" .. self.hl_group
  elseif not vim.api.nvim_win_is_valid(self.win) then
    self:hide()
  else
    vim.api.nvim_win_set_config(self.win, {
      relative = "editor",
      row = self.row,
      col = self.col,
    })
  end
end

function Drop:hide()
  if self.win then
    pcall(vim.api.nvim_win_close, self.win, true)
    pcall(vim.api.nvim_buf_delete, self.buf, { force = true })
  end
  Drop.drops[self.id] = nil
end

function Drop:is_visible()
  return self.col >= 0 and self.col <= vim.go.columns and self.row < vim.go.lines
end

function Drop:update()
  local dx = math.random(0, 2) - 1
  self.row = self.row + self.speed
  self.col = self.col + dx

  if self:is_visible() then
    self:show()
  else
    self:hide()
  end
end

function M.show()
  if M.timer then
    return
  end
  local target = config.options.max
  local ticks = 0
  M.timer = vim.loop.new_timer()
  M.timer:start(
    0,
    config.options.interval,
    vim.schedule_wrap(function()
      if M.timer == nil then
        return
      end
      ticks = ticks + 1
      local count = vim.tbl_count(Drop.drops)
      local pct = math.min(vim.go.lines, ticks) / vim.go.lines
      local _target = pct * target
      while count < _target * math.random(80, 100) / 100 do
        count = count + 1
        Drop.new()
      end
      for _, drop in pairs(Drop.drops) do
        drop:update()
      end
    end)
  )
end

function M.hide()
  if not M.timer then
    return
  end
  M.timer:stop()
  M.timer = nil
  for _, drop in pairs(Drop.drops) do
    drop:hide()
  end
end

return M
