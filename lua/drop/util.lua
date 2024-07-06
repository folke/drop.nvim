local M = {}

local year = os.date("*t").year

-- Calculate the date of Easter on a given year via the computus method.
-- https://en.wikipedia.org/wiki/Date_of_Easter
---@return DropDate
function M.calculate_easter()
  local a = year % 19
  local b = math.floor(year / 100)
  local c = year % 100
  local d = math.floor(b / 4)
  local e = b % 4
  local f = math.floor((b + 8) / 25)
  local g = math.floor((b - f + 1) / 3)
  local h = (19 * a + b - d - g + 15) % 30
  local i = math.floor(c / 4)
  local k = c % 4
  local l = (32 + 2 * e + 2 * i - h - k) % 7
  local m = math.floor((a + 11 * h + 22 * l) / 451)
  return { month = math.floor((h + l - 7 * m + 114) / 31), day = ((h + l - 7 * m + 114) % 31) + 1 }
end

-- Calculate the date of US Thanksgiving on a given year.
---@return DropDate
function M.calculate_us_thanksgiving()
  local first_day_of_november = os.time({ year = year, month = 11, day = 1 })
  local first_weekday_of_november = os.date("*t", first_day_of_november).wday -- 1=Sunday, 2=Monday, ..., 7=Saturday
  -- Thanksgiving is the fourth Thursday, so we need to count the Thursdays
  local day_of_thanksgiving = 1 + (11 + (5 - first_weekday_of_november) % 7) + 21
  return { month = 11, day = day_of_thanksgiving }
end

return M
