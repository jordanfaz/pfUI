pfUI:RegisterModule("pixelperfect", function ()
  -- pre-calculated min values
  local statics = {
    [4] = 1.4222222222222,
    [5] = 1.1377777777778,
    [6] = 0.94814814814815,
    [7] = 0.81269841269841,
    [8] = 0.71111111111111,
  }

  -- pixel perfect
  local function pixelperfect()
    local conf = tonumber(C.global.pixelperfect)
    if conf < 4 then
      -- restore gamesettings
      local scale = GetCVar("uiScale")
      local use = GetCVar("useUiScale")

      -- GetCVar returns strings: `use == 1` could never be true, so leaving a
      -- preset always fell through to the hardcoded 0.9 fallback -- and the
      -- branch would then have restored the wrong variable (the flag, not the
      -- scale).
      if use == "1" then
        UIParent:SetScale(tonumber(scale) or 1)
      else
        UIParent:SetScale(.9)
      end
    else
      local scale = conf and statics[conf] or 1

      SetCVar("uiScale", scale)
      SetCVar("useUiScale", 1)

      UIParent:SetScale(scale)
    end
  end

  -- pixelperfect: native UIScale listener
  if tonumber(C.global.pixelperfect) > 0 then
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", pixelperfect)
    pixelperfect()
  end

  pfUI.pixelperfect = {
    UpdateConfig = pixelperfect
  }
end)
