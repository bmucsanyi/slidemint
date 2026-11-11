module = "slidemint"

sourcefiledir = "tex/latex/slidemint"
sourcefiles = { "*.sty" }
installfiles = { "*.sty" }
unpackfiles = { }

-- Every deck compiles with lualatex.
local decks = {
  "basic-deck",
  "features-deck",
  "macromint-before-theme-deck",
  "citations-deck",
  "citef-deck",
  "palette-latte",
  "palette-frappe",
  "palette-macchiato",
  "palette-mocha",
  "palette-minimalist",
}

-- Each palette deck with the base color of its palette, which one background
-- pixel of its content frame must have.
local palettes = {
  { "palette-latte", { 0xef, 0xf1, 0xf5 } },
  { "palette-frappe", { 0x30, 0x34, 0x46 } },
  { "palette-macchiato", { 0x24, 0x27, 0x3a } },
  { "palette-mocha", { 0x1e, 0x1e, 0x2e } },
  { "palette-minimalist", { 0xff, 0xff, 0xff } },
}

-- An option the theme does not declare stops, as does an unknown palette.
local error_decks = {
  { "option-error-check", "Unknown option 'bogus'" },
  { "palette-error-check", "Package slidemint Error: Unknown palette 'lattewhite'" },
}

-- What the features deck writes to its log: the palette reaches figmint, the
-- deck is widescreen, figures get the ratio of the theme, and the caption font
-- is the size the figures are drawn at.
local feature_checks = {
  "SLIDEMINT_FIGMINT_THEME theme=mocha",
  "SLIDEMINT_ASPECT_RATIO width=455.24408pt;height=256.0748pt",
  "SLIDEMINT_FIGMINT_RATIO value=0.48",
  "SLIDEMINT_CAPTION_FONT size=10",
}

local function read_file(path)
  local handle = io.open(path, "rb")
  if not handle then
    return nil
  end
  local content = handle:read("*a")
  handle:close()
  return content
end

-- The color of a pixel of a PDF page rendered through pdftoppm.
local function render_pixel(harness, pdf, page, x, y)
  local prefix = "build/pixel"
  if harness.run("render " .. pdf, "pdftoppm -r 36 -f " .. page .. " -l " .. page
    .. " -singlefile " .. harness.quote(pdf) .. " " .. harness.quote(prefix)) ~= 0 then
    return nil
  end
  local data = read_file(prefix .. ".ppm")
  if not data then
    return nil
  end
  local width, offset = string.match(data, "^P6%s+(%d+)%s+%d+%s+%d+%s()")
  local index = offset + 3 * (y * tonumber(width) + x)
  return { string.byte(data, index, index + 2) }
end

local function palette_checks(harness)
  for _, palette in ipairs(palettes) do
    local name, expected = palette[1], palette[2]
    local color = render_pixel(harness, harness.output(name, "lualatex", "pdf"), 2, 2, 2)
    if not color then
      return 1
    end
    for channel = 1, 3 do
      if color[channel] ~= expected[channel] then
        print(name .. ": background " .. table.concat(color, ",")
          .. ", expected " .. table.concat(expected, ","))
        return 1
      end
    end
  end
  return 0
end

-- The top edges of the words of a page, through pdftotext, in order of
-- appearance on the page.
local function word_tops(harness, pdf, page, word)
  local path = "build/words.html"
  if harness.run("pdftotext " .. pdf, "pdftotext -f " .. page .. " -l " .. page
    .. " -bbox-layout " .. harness.quote(pdf) .. " " .. harness.quote(path)) ~= 0 then
    return nil
  end
  local tops = {}
  for top, found in string.gmatch(read_file(path),
    '<word xMin="[%d.]+" yMin="([%d.]+)" xMax="[%d.]+" yMax="[%d.]+">([^<]+)</word>') do
    if found == word then
      table.insert(tops, tonumber(top))
    end
  end
  return tops
end

-- The bodies of the three blocks of the features deck start at the same
-- distance below their titles, although only "Example Block" has a descender.
local function block_checks(harness)
  local pdf = harness.output("features-deck", "lualatex", "pdf")
  local titles = word_tops(harness, pdf, 3, "Block")
  local bodies = word_tops(harness, pdf, 3, "body.")
  if not titles or not bodies then
    return 1
  end
  if #titles ~= 3 or #bodies ~= 3 then
    print("features-deck: expected three block titles and three bodies, found "
      .. #titles .. " and " .. #bodies)
    return 1
  end
  local distances = {}
  for index = 1, 3 do
    distances[index] = bodies[index] - titles[index]
  end
  if math.max(table.unpack(distances)) - math.min(table.unpack(distances)) > 0.1 then
    print("features-deck: block bodies start " .. table.concat(distances, ", ")
      .. " below their titles")
    return 1
  end
  return 0
end

local function check(harness)
  local environment = {
    TEXINPUTS = harness.texinputs({
      "./tex/latex/slidemint",
      harness.require_sibling("macromint"),
      harness.require_sibling("figmint"),
      "./testfiles",
    }),
    BIBINPUTS = "./testfiles:",
    -- minted runs latexminted from the environment of this repository.
    PATH = "./.venv/bin:" .. os.getenv("PATH"),
  }

  for _, deck in ipairs(decks) do
    if harness.compile_test(environment, deck, "lualatex") ~= 0 then
      return 1
    end
  end

  for _, deck in ipairs(error_decks) do
    if harness.compile_error_test(environment, deck[1], "lualatex", deck[2]) ~= 0 then
      return 1
    end
  end

  local log = harness.output("features-deck", "lualatex", "log")
  for _, needle in ipairs(feature_checks) do
    if not harness.file_contains(log, needle) then
      print(log .. ": missing " .. needle)
      return 1
    end
  end

  if palette_checks(harness) ~= 0 or block_checks(harness) ~= 0 then
    return 1
  end

  for _, deck in ipairs(decks) do
    if harness.scan_log(harness.output(deck, "lualatex", "log")) ~= 0 then
      return 1
    end
  end

  return 0
end

target_list.check.func = function()
  local path = "../figmint/harness.lua"
  local harness = loadfile(path)
  if not harness then
    print(path .. " is missing: the tests need a checkout of figmint next to this repository")
    return 1
  end
  return check(harness())
end
