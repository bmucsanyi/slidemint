module = "slidemint"

sourcefiledir = "tex/latex/slidemint"
sourcefiles = { "*.sty" }
installfiles = { "*.sty" }
unpackfiles = { }
testfiledir = "testfiles"
checkengines = { "luatex" }

local tests = {
  "basic-deck",
  "features-deck",
  "macromint-before-theme-deck",
  "citations-deck",
  "palette-frappe",
  "palette-macchiato",
}

local log_needles = {
  "Missing character",
  "Fatal error",
  "Undefined control sequence",
  "LaTeX Error",
  "Emergency stop",
  "LaTeX Warning:",
  "LaTeX Font Warning:",
  "Overfull \\hbox",
  "Overfull \\vbox",
  "Underfull \\hbox",
  "Underfull \\vbox",
  "Could not resolve font",
}

-- Noto Sans Math stores bold math alphabets in the regular OTF. fontspec still
-- probes a separate NFSS bold face name while building math families.
local log_allowed = {
  "Could not resolve font \"Noto Sans Math/B\"",
}

local function quote(value)
  return "'" .. string.gsub(value, "'", "'\\''") .. "'"
end

local function run(label, command)
  print(label)
  local result = os.execute(command)
  if result == true or result == 0 then
    return 0
  end
  return 1
end

local function file_contains(path, needle)
  local handle = io.open(path, "r")
  if not handle then
    return false
  end
  local content = handle:read("*a")
  handle:close()
  return string.find(content, needle, 1, true) ~= nil
end

local function line_has_log_problem(line)
  for _, allowed in ipairs(log_allowed) do
    if string.match(line, "^%(fontspec%)%s+")
        and string.find(line, allowed, 1, true) then
      return false
    end
  end

  if string.sub(line, 1, 1) == "!" then
    return true
  end
  if string.match(line, "^Package .+ Error") then
    return true
  end
  if string.match(line, "^Package .+ Warning:") then
    return true
  end
  if string.match(line, "^Class .+ Error") then
    return true
  end
  if string.match(line, "^Class .+ Warning:") then
    return true
  end
  for _, needle in ipairs(log_needles) do
    if string.find(line, needle, 1, true) then
      return true
    end
  end
  return false
end

local function scan_log(path)
  for line in io.lines(path) do
    if line_has_log_problem(line) then
      print(path .. ": " .. line)
      return 1
    end
  end
  return 0
end

local function compile_test(name)
  local texinputs = table.concat({
    "./tex/latex/slidemint",
    "../macromint/tex/latex/macromint",
    "../figmint/tex/latex/figmint",
    "",
  }, ":")
  local path = "./.venv/bin:" .. os.getenv("PATH")
  local environment = "env TEXINPUTS=" .. quote(texinputs)
    .. " TEXMFVAR=" .. quote("build/texmf-var")
    .. " TEXMFCACHE=" .. quote("build/texmf-var")
    .. " PATH=" .. quote(path)
  local tex = environment
    .. " lualatex -halt-on-error -interaction=nonstopmode -output-directory=build "
    .. quote("testfiles/" .. name .. ".tex")

  if run("lualatex " .. name, tex) ~= 0 then
    return 1
  end
  if file_contains("build/" .. name .. ".aux", "\\bibdata{") then
    if run("bibtex " .. name, "bibtex " .. quote("build/" .. name)) ~= 0 then
      return 1
    end
  end
  if run("lualatex " .. name, tex) ~= 0 then
    return 1
  end
  return run("lualatex " .. name, tex)
end

local function slidemint_check()
  if run("create build directory", "mkdir -p build/texmf-var") ~= 0 then
    return 1
  end
  for _, name in ipairs(tests) do
    if compile_test(name) ~= 0 then
      return 1
    end
  end
  if not file_contains("build/features-deck.log", "SLIDEMINT_FIGMINT_THEME theme=mocha") then
    print("build/features-deck.log: missing figmint theme check")
    return 1
  end
  if not file_contains("build/features-deck.log", "SLIDEMINT_ASPECT_RATIO width=455.24408pt;height=256.0748pt") then
    print("build/features-deck.log: missing widescreen aspect ratio check")
    return 1
  end
  if not file_contains("build/features-deck.log", "SLIDEMINT_FIGMINT_RATIO value=0.5625") then
    print("build/features-deck.log: missing figmint slide ratio check")
    return 1
  end
  if not file_contains("build/features-deck.log", "SLIDEMINT_FIGMINT_FONT name=caption;size=10") then
    print("build/features-deck.log: missing figmint caption font check")
    return 1
  end
  if not file_contains("build/features-deck.log", "SLIDEMINT_FIGMINT_FONT name=primary;size=10") then
    print("build/features-deck.log: missing figmint primary font check")
    return 1
  end
  if not file_contains("build/features-deck.log", "SLIDEMINT_FIGMINT_FONT name=secondary;size=10") then
    print("build/features-deck.log: missing figmint secondary font check")
    return 1
  end
  for _, name in ipairs(tests) do
    if scan_log("build/" .. name .. ".log") ~= 0 then
      return 1
    end
  end
  return 0
end

target_list.check.func = function()
  return slidemint_check()
end
