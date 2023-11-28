local M = {}

-- Calculate the date of Easter on a given year via the computus method.
-- https://en.wikipedia.org/wiki/Date_of_Easter
function M.calculate_easter(year)
  -- Step 1: Calculate the Golden Number of the year, which is used to determine the date of the full moon.
  local golden_number = year % 19

  -- Step 2: Calculate century, year of the century, and number of years that have leap years.
  local century = math.floor(year / 100)
  local year_of_century = year % 100
  local leap_years = math.floor(century / 4)

  -- Step 3: Calculate skipped leap years.
  local skipped_leap_years = century % 4

  -- Step 4: Determine the leap year corrections.
  local leap_year_corrections = math.floor((century + 8) / 25)
  local additional_leap_year_correction = math.floor((century - leap_year_corrections + 1) / 3)

  -- Step 5: Calculate the "epact" which represents the age of the moon on January 1.
  local epact = (19 * golden_number + century - leap_years - additional_leap_year_correction + 15) % 30

  -- Step 6: Calculate the number of days from March 1 to the Paschal full moon.
  local days_to_full_moon = math.floor(year_of_century / 4)
  local correction_factor = year_of_century % 4
  local days_to_sunday = (32 + 2 * skipped_leap_years + 2 * days_to_full_moon - epact - correction_factor) % 7

  -- Step 7: Calculate the lunar month correction.
  local lunar_month_correction = math.floor((golden_number + 11 * epact + 22 * days_to_sunday) / 451)

  -- Step 8: Determine the month and day of Easter.
  local month = math.floor((epact + days_to_sunday - 7 * lunar_month_correction + 114) / 31)
  local day = ((epact + days_to_sunday - 7 * lunar_month_correction + 114) % 31) + 1

  return { month = month, day = day }
end

-- Calculate the date of US Thanksgiving on a given year.
function M.calculate_us_thanksgiving(year)
  -- Calculate the day of the week for November 1st of the given year
  local date = os.date("*t", os.time({ year = year, month = 11, day = 1 }))
  local first_thursday

  -- Determine the date of the first Thursday in November
  if date.wday == 5 then -- if November 1st is a Thursday
    first_thursday = 1
  else
    first_thursday = (5 - date.wday) % 7 + 1
  end

  -- Thanksgiving is the fourth Thursday, so we add 21 days to the first Thursday
  local thanksgiving_day = first_thursday + 21

  return { month = 11, day = thanksgiving_day }
end

local current_date = os.date("*t")
local year = current_date.year
local month = current_date.month
local day = current_date.day

---@class DropTheme
---@field symbols string[]
---@field colors string[]

---@class ActiveDropTheme: DropTheme
---@field hl string[]

---@class DropConfig
M.defaults = {
  ---@type DropTheme|string
  theme = "leaves", -- can be one of rhe default themes, or a custom theme
  holidays = { -- can be nil or {} to disable automatic holidays.
    new_year = { month = 1, day = 1 },
    valentines_day = { month = 2, day = 14 },
    st_patricks_day = { month = 3, day = 17 },
    easter = M.calculate_easter(year),
    april_fools = { month = 4, day = 1 },
    us_independence_day = { month = 7, day = 4 },
    halloween = { month = 10, day = 31 },
    us_thanksgiving = M.calculate_us_thanksgiving(year),
    xmas = { start_date = { month = 12, day = 24 }, end_date = { month = 12, day = 25 } },
  },
  max = 75, -- maximum number of drops on the screen
  interval = 100, -- every 150ms we update the drops
  screensaver = 1000 * 60 * 5, -- show after 5 minutes. Set to false, to disable
  filetypes = { "dashboard", "alpha", "starter" }, -- will enable/disable automatically for the following filetypes
  winblend = 100, -- winblend for the drop window
}

M.ns = vim.api.nvim_create_namespace("drop")

-- Convert current year to emoji equivalent for new_year theme.
local function number_to_emoji(number)
  local emojiMap = {
    ["0"] = "0️⃣",
    ["1"] = "1️⃣",
    ["2"] = "2️⃣",
    ["3"] = "3️⃣",
    ["4"] = "4️⃣",
    ["5"] = "5️⃣",
    ["6"] = "6️⃣",
    ["7"] = "7️⃣",
    ["8"] = "8️⃣",
    ["9"] = "9️⃣",
  }
  local result = ""
  for i = 1, #number do
    result = result .. emojiMap[number:sub(i, i)]
  end
  return result
end
local emojiYear = number_to_emoji(tostring(year))

---@type table<string,DropTheme>
M.themes = {
  april_fools = {
    symbols = { "🤡", "🎭", "🃏", "🎉", "😂", "🙃", "🎈", "🎁", "🤣", "😜" },
    colors = { "#FF4500", "#FFD700", "#ADFF2F", "#7FFF00", "#FF69B4" },
  },
  arcade = {
    symbols = { "🎮", "🕹️", "👾", "💾", "⚔️", "🛡️", "🏰" },
    colors = { "#FF4500", "#FFD700", "#ADFF2F", "#7FFF00", "#FF69B4" },
  },
  art = {
    symbols = { "🎨", "🖼️", "🖌️", "🎭", "🎶", "📚", "🖋️" },
    colors = { "#EE82EE", "#FF6347", "#20B2AA", "#FFD700", "#D8BFD8" },
  },
  bakery = {
    symbols = { "🍞", "🥖", "🥐", "🍩", "🍰", "🧁", "🍪" },
    colors = { "#FFE4B5", "#FFF8DC", "#DAA520", "#CD853F", "#F5DEB3" },
  },
  beach = {
    symbols = { "🌴", "🏖️", "🍹", "🌅", "🏄", "🐚", "🌞" },
    colors = { "#FFD700", "#FF6347", "#4682B4", "#87CEEB", "#FFA500" },
  },
  binary = {
    symbols = { "0", "1" },
    colors = { "#000000", "#FFFFFF", "#696969", "#A9A9A9", "#808080" },
  },
  bugs = {
    symbols = { "🐞", "🐜", "🪲", "🦗", "🕷️", "🕸️", "🐛" },
    colors = { "#556B2F", "#6B8E23", "#8FBC8F", "#20B2AA", "#3CB371" },
  },
  business = {
    symbols = { "💼", "🖊️", "📈", "📉", "💹", "💲", "🏢" },
    colors = { "#2E8B57", "#66CDAA", "#8FBC8F", "#20B2AA", "#008B8B" },
  },
  candy = {
    symbols = { "🍬", "🍭", "🍫", "🍩", "🍰", "🧁", "🍪" },
    colors = { "#FFC0CB", "#FF69B4", "#FFB6C1", "#FF4500", "#FFD700" },
  },
  cards = {
    symbols = { "♠️", "♥️", "♦️", "♣️", "🃏" },
    colors = { "#000000", "#FF0000", "#DAA520", "#008000", "#FF4500" },
  },
  carnival = {
    symbols = { "🎪", "🎭", "🍿", "🎠", "🎡", "🎈", "🤹" },
    colors = { "#FF6347", "#FFD700", "#FF4500", "#4B0082", "#32CD32" },
  },
  casino = {
    symbols = { "🎰", "♠️", "♦️", "♣️", "♥️", "🎲", "🃏" },
    colors = { "#DC143C", "#FFD700", "#228B22", "#A9A9A9", "#FF4500" },
  },
  cats = {
    symbols = { "🐱", "🦁", "🐯", "🐈", "🐅", "🐆" },
    colors = { "#FFA500", "#FF4500", "#D2691E", "#8B4513", "#A0522D" },
  },
  coffee = {
    symbols = { "☕", "🥐", "🍰", "🍪", "🍩", "🥛", "🍫" },
    colors = { "#8B4513", "#A0522D", "#D2B48C", "#F5DEB3", "#FFE4B5" },
  },
  cyberpunk = {
    symbols = { "🌃", "💿", "🕶️", "⚙️", "🖥️", "🎮", "🔌" },
    colors = { "#9400D3", "#4B0082", "#FF00FF", "#00FF00", "#FF4500" },
  },
  deepsea = {
    symbols = { "🐠", "🐙", "🦈", "🌊", "🦑", "🐡", "🐟" },
    colors = { "#1E90FF", "#20B2AA", "#4682B4", "#5F9EA0", "#B0E0E6" },
  },
  desert = {
    symbols = { "🌵", "🐪", "🏜️", "🌞", "🦂", "🪨", "💧" },
    colors = { "#DAA520", "#FFD700", "#CD853F", "#8B4513", "#FFDEAD" },
  },
  dice = {
    symbols = { "⚀", "⚁", "⚂", "⚃", "⚄", "⚅" },
    colors = { "#B5B5B5", "#7B7B7B", "#3B3B3B", "#EFEFEF", "#2F4F4F" },
  },
  diner = {
    symbols = { "🍔", "🍟", "🥤", "🍳", "🥞", "🥓", "🍦" },
    colors = { "#FF6347", "#FFD700", "#D2691E", "#FF4500", "#A9A9A9" },
  },
  easter = {
    symbols = {
      "🐣",
      "🐥",
      "🐤",
      "🥚",
      "🌸",
      "🍫",
      "🐇",
      "🌷",
      "🌼",
      "🍃",
      "🦋",
      "🍬",
      "🌈",
      "🎀",
      "💒",
    },
    colors = { "#FFC3A0", "#FFEBD3", "#A8D5BA", "#77CBB9", "#F7D6E6" },
  },
  emotional = {
    symbols = {
      "😀",
      "😃",
      "😄",
      "😁",
      "😆",
      "😅",
      "😂",
      "🤣",
      "😊",
      "😇",
      "🙂",
      "🙃",
      "😉",
      "😌",
      "😍",
      "😘",
      "😗",
      "😙",
      "😚",
      "😋",
      "😛",
      "😝",
      "😜",
      "🤪",
      "🤨",
      "🧐",
      "🤓",
      "😎",
      "🤩",
      "😏",
      "😒",
      "😞",
      "😔",
      "😟",
      "😕",
      "🙁",
      "☹️",
      "😣",
      "😖",
      "😫",
      "😩",
      "🥺",
      "😢",
      "😭",
      "😤",
      "😠",
      "😡",
      "🤬",
      "🤯",
      "😳",
      "🥵",
      "🥶",
      "😱",
      "😨",
      "😰",
      "😥",
      "😓",
      "😶",
      "😐",
      "😑",
      "😬",
      "😯",
      "😦",
      "😧",
      "😮",
      "😲",
      "🥱",
      "😴",
      "🤤",
      "😪",
      "😵",
      "🤐",
      "🥴",
      "🤢",
      "🤮",
      "🤕",
      "🤒",
      "😷",
      "🥰",
      "😸",
      "😺",
      "😻",
      "😼",
      "😽",
      "🙀",
      "😿",
      "😹",
    },
    colors = { "#FFD700", "#FF4500", "#2E8B57", "#8A2BE2", "#20B2AA" },
  },
  explorer = {
    symbols = { "🌍", "🌐", "🗺️", "🔍", "⛺", "🌄", "🧭" },
    colors = { "#BDB76B", "#DEB887", "#6B8E23", "#FF8C00", "#A0522D" },
  },
  fantasy = {
    symbols = { "🐉", "🏰", "🪄", "🧙", "🛡️", "🗡️", "🌌", "👑" },
    colors = { "#8A2BE2", "#D8BFD8", "#DDA0DD", "#EE82EE", "#DA70D6" },
  },
  farm = {
    symbols = { "🐄", "🐖", "🐓", "🌾", "🍎", "🍏", "🚜" },
    colors = { "#808000", "#8B4513", "#FFD700", "#FF6347", "#228B22" },
  },
  garden = {
    symbols = { "🌱", "🌸", "🌻", "🌿", "🍂", "🍃", "🌾" },
    colors = { "#32CD32", "#FFD700", "#FF4500", "#2E8B57", "#ADFF2F" },
  },
  halloween = {
    symbols = {
      "🎃",
      "👻",
      "🦇",
      "🕷️",
      "🕸️",
      "🦉",
      "🔮",
      "💀",
      "👽",
      "🌙",
      "🍬",
      "🍭",
      "🖤",
      "🔪",
      "🧛",
      "🪦",
      "😱",
      "🙀",
      "🌕",
      "⚰️",
    },
    colors = { "#FF6B6B", "#FFD166", "#06D6A0", "#118AB2", "#073B4C" },
  },
  jungle = {
    symbols = { "🦜", "🦍", "🌴", "🐅", "🐍", "🌺", "🦎" },
    colors = { "#228B22", "#006400", "#32CD32", "#8FBC8F", "#20B2AA" },
  },
  leaves = {
    symbols = { "🍂", "🍁", "🍀", "🌿", " ", " ", " " },
    colors = { "#3A3920", "#807622", "#EAA724", "#D25B01", "#5B1C02", "#740819" },
  },
  lunar = {
    symbols = { "🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘" },
    colors = { "#696969", "#808080", "#A9A9A9", "#C0C0C0", "#D3D3D3" },
  },
  magical = {
    symbols = { "🔮", "🌟", "🧹", "🎩", "🐇", "🪄", "💫" },
    colors = { "#8A2BE2", "#DA70D6", "#FF00FF", "#DDA0DD", "#EE82EE" },
  },
  mathematical = {
    symbols = { "➕", "➖", "✖️", "➗", "≠", "≈", "∞" },
    colors = { "#008080", "#20B2AA", "#2E8B57", "#3CB371", "#66CDAA" },
  },
  matrix = {
    symbols = { "0", "1", "⌘", "∑", "∆", "Λ", "ψ", "⊕", "⊖", "∴", "≡", "Ω", "µ", "∂", "Φ", "ν" },
    colors = { "#33FF33", "#009900", "#66FF66", "#003300", "#006600" },
  },
  medieval = {
    symbols = { "🏰", "🛡️", "⚔️", "🎠", "👑", "🏹", "🍺" },
    colors = { "#6A5ACD", "#8B4513", "#B8860B", "#556B2F", "#8B0000" },
  },
  musical = {
    symbols = { "🎵", "🎶", "🎤", "🎷", "🎸", "🎺", "🎻" },
    colors = { "#FFD700", "#FF4500", "#20B2AA", "#7FFF00", "#FF69B4" },
  },
  mystery = {
    symbols = { "🕵️", "🔎", "🔒", "🔑", "📜", "🖋️", "🗝️" },
    colors = { "#3B3B3B", "#7B7B7B", "#B5B5B5", "#EFEFEF", "#2F4F4F" },
  },
  mystical = {
    symbols = { "🔮", "🌕", "🌟", "📜", "✨", "🔥", "💫" },
    colors = { "#9932CC", "#9400D3", "#8B008B", "#BA55D3", "#9370DB" },
  },
  new_year = {
    symbols = {
      "🎆",
      "🎉",
      "🍾",
      "🥂",
      "⏰",
      "🕛",
      "🎈",
      "🌟",
      "✨",
      "🎊",
      "🥳",
      "💫",
      "📅",
      emojiYear,
    },
    colors = { "#FFD700", "#C0C0C0", "#8A2BE2", "#FF4500", "#7FFF00" },
  },
  nocturnal = {
    symbols = { "🦉", "🌙", "🦇", "🌌", "🌠", "🔭", "🌚" },
    colors = { "#2E2E3A", "#6A5ACD", "#483D8B", "#7B68EE", "#696969" },
  },
  ocean = {
    symbols = { "🌊", "🐠", "🐟", "🐡", "🐬", "🐳", "🦈", "🐚", "⛵" },
    colors = { "#1E90FF", "#20B2AA", "#00CED1", "#5F9EA0", "#B0E0E6" },
  },
  pirate = {
    symbols = { "☠️", "⚓", "🏴‍☠️", "🗺️", "🦜", "⚔️", "💰" },
    colors = { "#8B4513", "#FFD700", "#DAA520", "#A52A2A", "#2F4F4F" },
  },
  retro = {
    symbols = { "📻", "📺", "🎞️", "📼", "🎙️", "🕰️", "☎️" },
    colors = { "#FF69B4", "#FFD700", "#FF4500", "#00FF7F", "#D2691E" },
  },
  snow = {
    symbols = { "❄️ ", " ", "❅", "❇", "*", "." },
    colors = { "#c6fbff", "#abf0ff", "#99c4ce", "#73999a", "#628485" },
  },
  spa = {
    symbols = { "🕯️", "🛁", "🌸", "💆", "🍵", "🧘", "💅" },
    colors = { "#20B2AA", "#FFE4E1", "#F5F5DC", "#DDA0DD", "#778899" },
  },
  space = {
    symbols = { "🪐", "🌌", "⭐", "🌙", "🚀", "🛰️", "☄️", "🌠", "👩‍🚀" },
    colors = { "#483D8B", "#2E2B5F", "#696969", "#B0C4DE", "#8B008B" },
  },
  sports = {
    symbols = { "⚽", "🏀", "🏈", "⚾", "🎾", "🏓", "🏒" },
    colors = { "#FF6347", "#3CB371", "#1E90FF", "#FF4500", "#32CD32" },
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
    colors = { "#A36F58", "#FEDC78", "#F6F5AD", "#CFEEB7", "#ADE6B0" },
  },
  stars = {
    symbols = { "★", "⭐", "✮", "✦", "✬", "✯", "🌟" },
    colors = { "#ffd27d", "#ffa371", "#a6a8ff", "#fffa86", "#a87bff" },
  },
  steampunk = {
    symbols = { "⚙️", "🕰️", "🎩", "🚂", "🧭", "🔭", "🗝️" },
    colors = { "#B8860B", "#8B4513", "#2F4F4F", "#A0522D", "#5F9EA0" },
  },
  st_patricks_day = {
    symbols = {
      "🍀",
      "🌈",
      "💚",
      "🇮🇪",
      "🎩",
      "🥔",
      "🍺",
      "🍻",
      "🥃",
      "🍖",
      "💰",
      "🌟",
      "🍵",
      "🐍",
      "🪄",
    },
    colors = { "#009E60", "#FFD700", "#FF4500", "#FFFFFF", "#228B22" },
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
    colors = { "#236e96", "#15b2d3", "#ffd700", "#f3872f", "#ff598f" },
  },
  temporal = {
    symbols = { "🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚", "🕛" },
    colors = { "#8B0000", "#B22222", "#DC143C", "#FF4500", "#FF6347" },
  },
  us_thanksgiving = {
    symbols = {
      "🦃",
      "🍂",
      "🍁",
      "🌽",
      "🥧",
      "🍠",
      "🍎",
      "🍖",
      "🍗",
      "🥖",
      "🥔",
      "🍇",
      "🍷",
      "🌰",
      "🥕",
    },
    colors = { "#8B4513", "#D2691E", "#FF4500", "#228B22", "#A52A2A" },
  },
  travel = {
    symbols = { "✈️", "🌍", "🗺️", "🏨", "🧳", "🗽", "🚂" },
    colors = { "#FFD700", "#87CEEB", "#FF4500", "#2E8B57", "#20B2AA" },
  },
  tropical = {
    symbols = { "🌴", "🍍", "🍉", "🥥", "🌺", "🐢", "🌊" },
    colors = { "#20B2AA", "#FF6347", "#FFD700", "#FF4500", "#8A2BE2" },
  },
  urban = {
    symbols = { "🏢", "🚕", "🚇", "🍕", "🚦", "🛴", "🎧" },
    colors = { "#A9A9A9", "#2F4F4F", "#B22222", "#FF8C00", "#D3D3D3" },
  },
  us_independence_day = {
    symbols = {
      "🇺🇸",
      "🎆",
      "🗽",
      "🦅",
      "🌭",
      "🍔",
      "⭐",
      "🎉",
      "🥳",
      "🍻",
      "🥁",
      "🎵",
      "🎶",
      "🚀",
      "💥",
    },
    colors = { "#B22234", "#3C3B6E", "#FFFFFF", "#FFD700", "#FF6347" },
  },
  valentines_day = {
    symbols = {
      "❤️",
      "💖",
      "💘",
      "💝",
      "💕",
      "💓",
      "💞",
      "💟",
      "💌",
      "🌹",
      "🍫",
      "💐",
      "💍",
      "🍷",
      "🕯️",
    },
    colors = { "#FF6B8D", "#FFB6C1", "#DD2A7B", "#FFD1DC", "#8B0000" },
  },
  wilderness = {
    symbols = { "🌲", "🐺", "🦌", "🏞️", "🔥", "⛺", "🌌" },
    colors = { "#228B22", "#A52A2A", "#DEB887", "#696969", "#B0E0E6" },
  },
  wildwest = {
    symbols = { "🤠", "🐎", "🌵", "🔫", "⛏️", "🌄", "🚂" },
    colors = { "#8B4513", "#BDB76B", "#FFD700", "#D2691E", "#FFDEAD" },
  },
  winter_wonderland = {
    symbols = { "❄️", "⛄", "🌨️", "🎿", "🛷", "🏔️", "🧣" },
    colors = { "#ADD8E6", "#B0E0E6", "#87CEFA", "#1E90FF", "#6495ED" },
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
    colors = { "#146B3A", "#F8B229", "#EA4630", "#BB2528" },
  },
  zodiac = {
    symbols = { "♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓" },
    colors = { "#FF4500", "#FF6347", "#FFA07A", "#FFD700", "#FFFAF0" },
  },
  zoo = {
    symbols = { "🦁", "🐘", "🦓", "🦒", "🦅", "🦉", "🐆" },
    colors = { "#A0522D", "#8B4513", "#D2B48C", "#BDB76B", "#D2691E" },
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

function M.get_theme()
  local theme = M.options.theme
  local holidays = M.options.holidays
  if type(theme) == "string" then
    theme = M.themes[theme]
  end
  -- Check if today is a holiday or falls within a holiday range.
  if holidays ~= nil then
    for holiday, date in pairs(holidays) do
      if date ~= nil then
        local start_month, start_day = date.month or date.start_date.month, date.day or date.start_date.day
        local end_month, end_day = date.month or date.end_date.month, date.day or date.end_date.day
        local is_range = start_month ~= end_month or start_day ~= end_day
        if is_range then
          if month == start_month and month == end_month then
            if day >= start_day and day <= end_day then
              theme = M.themes[holiday]
            end
          elseif month == start_month then
            if day >= start_day then
              theme = M.themes[holiday]
            end
          elseif month == end_month then
            if day <= end_day then
              theme = M.themes[holiday]
            end
          elseif month > start_month and month < end_month then
            theme = M.themes[holiday]
          end
        end
      end
    end
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
