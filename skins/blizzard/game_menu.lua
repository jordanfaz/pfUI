pfUI:RegisterSkin("Game Menu", function ()
  StripTextures(GameMenuFrame)
  CreateBackdrop(GameMenuFrame, nil, true, .75)
  CreateBackdropShadow(GameMenuFrame)

  local menuWidth, menuHeight = GameMenuFrame:GetSize()
  GameMenuFrame:SetSize(menuWidth - 30, menuHeight + 6)

  local title = GetNoNameObject(GameMenuFrame, "FontString", "ARTWORK", MAIN_MENU)
  title:SetTextColor(1,1,1,1)
  title:ClearAllPoints()
  title:SetPoint("TOP", GameMenuFrame, "TOP", 0, 16)
  title:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")

  local pfUIButton = CreateFrame("Button", "GameMenuButtonPFUI", GameMenuFrame, "GameMenuButtonTemplate")
  pfUIButton:SetPoint("TOP", 0, -10)
  -- look the string up with its original key so localised builds still match,
  -- then recolour the accent in the result
  pfUIButton:SetText((string.gsub(T["|cff33ffccpf|cffffffffUI|cffcccccc Config"], "33ffcc", pfUI.chex or "33ffcc")))
  pfUIButton:SetScript("OnClick", function()
    pfUI.gui:Show()
    HideUIPanel(GameMenuFrame)
  end)
  SkinButton(pfUIButton)

  local point, relativeTo, relativePoint, xOffset, yOffset = GameMenuButtonOptions:GetPoint()
  GameMenuButtonOptions:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset - 22)

  local buttons = {
    GameMenuButtonOptions,
    GameMenuButtonSoundOptions,
    GameMenuButtonUIOptions,
    GameMenuButtonKeybindings,
    GameMenuButtonMacros,
    GameMenuButtonRatings,
    GameMenuButtonLogout,
    GameMenuButtonQuit,
    GameMenuButtonContinue,
  }

  for _, button in pairs(buttons) do
    if button then SkinButton(button) end
  end
end)
