pfUI:RegisterModule("bags", function ()
local rawborder, default_border = GetBorderSize("bags")

local extractSpells = {
  [13262] = {frame="disenchant"},
  [1804] = {frame="picklock"},
}

local scanner = libtipscan:GetScanner("input_search")

local function GetItemSearchText(bag, slot)
scanner:SetBagItem(bag, slot)
local text = scanner:Text()
local result = ""
for _, line in pairs(text) do
  result = result .. (line[1] or "") .. (line[2] or "")
  end
  return strlower(result)
  end

  -- the keyring only has slots to iterate/show while the player has toggled it on
  local function GetBagSize(bag)
  if bag == -2 then
    return pfUI.bag.showKeyring == true and GetKeyRingSize() or 0
    end
    return GetContainerNumSlots(bag)
    end

  local function BagSortOpts()
  return {
    reverse     = C.appearance.bags.sortreverse == "1",
    reversePrio = C.appearance.bags.sortprioreverse == "1",
  }
  end

  local function Crisp(value)
  return math.floor((value or 0) + .5)
  end

  local function IsBankFrame(frame)
  return frame == pfUI.bag.left
  end

  local function CategoryViewKey(frame)
  return IsBankFrame(frame) and "bankcategoryview" or "bagcategoryview"
  end

  local function CategoryColumnsKey(frame)
  return IsBankFrame(frame) and "bankcategorycolumns" or "bagcategorycolumns"
  end

  local function IconSizeKey(frame)
  return IsBankFrame(frame) and "bankiconsize" or "bagiconsize"
  end

  -- seed the new independent bag/bank settings from the old shared ones
  -- (or sane defaults) so they're never nil before a slider is touched
  if C.appearance.bags.bagcategoryview == nil then
    C.appearance.bags.bagcategoryview = C.appearance.bags.categoryview or "0"
    end
    if C.appearance.bags.bankcategoryview == nil then
      C.appearance.bags.bankcategoryview = C.appearance.bags.categoryview or "0"
      end
      if C.appearance.bags.bagcategorycolumns == nil then
        C.appearance.bags.bagcategorycolumns = C.appearance.bags.categorycolumns or "6"
        end
        if C.appearance.bags.bankcategorycolumns == nil then
          C.appearance.bags.bankcategorycolumns = C.appearance.bags.categorycolumns or "6"
          end
          if C.appearance.bags.bagiconsize == nil then
            C.appearance.bags.bagiconsize = C.appearance.bags.icon_size or "-1"
            end
            if C.appearance.bags.bankiconsize == nil then
              C.appearance.bags.bankiconsize = C.appearance.bags.icon_size or "-1"
              end

              local RefreshCategoryLayouts
              local CreateCategoryEditor

              local function CreateBagOptions(frame)
              if frame.options then return frame.options end

                local options = CreateFrame("Frame", nil, UIParent)
                options:SetFrameStrata("DIALOG")
                options:SetSize(190, 94)
                options:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, default_border * 2)
                CreateBackdrop(options, default_border)
                options:SetBackdropColor(0, 0, 0, .85)
                options:Hide()

                local function AddSlider(key, label, minimum, maximum, step, y)
                local function SettingKey()
                if key == "categorycolumns" then
                  if C.appearance.bags[CategoryViewKey(frame)] ~= "1" then
                    return frame == pfUI.bag.left and "bankrowlength" or "bagrowlength"
                    end
                    return CategoryColumnsKey(frame)
                    end
                    if key == "icon_size" then
                      return IconSizeKey(frame)
                      end
                      return key
                      end

                      local text = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                      text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                      text:SetPoint("TOPLEFT", options, "TOPLEFT", 4, y)
                      text:SetTextColor(pfUI.cr, pfUI.cg, pfUI.cb, 1)

                      local slider = CreateFrame("Slider", nil, options)
                      slider:SetPoint("LEFT", options, "TOPLEFT", 56, y + 1)
                      slider:SetWidth(100)
                      slider:SetHeight(14)
                      slider:SetMinMaxValues(minimum, maximum)
                      slider:SetValueStep(step)
                      if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
                        local configured = tonumber(C.appearance.bags[SettingKey()])
                        local value = configured and configured >= minimum and configured or 22
                        options.updating = true
                        slider:SetValue(value)
                        options.updating = nil
                        slider:SetOrientation("HORIZONTAL")
                        slider:SetBackdrop({
                          bgFile = "Interface\\Buttons\\WHITE8X8",
                          edgeFile = "Interface\\Buttons\\WHITE8X8",
                          edgeSize = 1,
                          insets = { left = 0, right = 0, top = 4, bottom = 4 },
                        })
                        slider:SetBackdropColor(.15, .15, .15, 1)
                        slider:SetBackdropBorderColor(.45, .45, .45, 1)
                        slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
                        local thumb = slider:GetThumbTexture()
                        if thumb then thumb:SetWidth(20); thumb:SetHeight(24) end

                          local input = CreateFrame("EditBox", nil, options)
                          input:SetWidth(25)
                          input:SetHeight(14)
                          input:SetPoint("LEFT", slider, "RIGHT", 4, 0)
                          input:SetAutoFocus(false)
                          input:SetJustifyH("CENTER")
                          input:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                          CreateBackdrop(input, nil, true)
                          input:SetTextColor(1, 1, 1, 1)

                          local function SetValue(value)
                          value = math.max(minimum, math.min(maximum, math.floor(tonumber(value) or minimum)))
                          options.updating = true
                          slider:SetValue(value)
                          options.updating = nil
                          C.appearance.bags[SettingKey()] = tostring(value)
                          input:SetText(tostring(value))
                          text:SetText(label)
                          if key == "icon_size" then
                            frame.category_button_size = nil
                            end
                            pfUI.bag:CreateBags()
                            pfUI.bag:CreateBags("bank")
                            end

                            input:SetScript("OnEnterPressed", function()
                            SetValue(this:GetText())
                            this:ClearFocus()
                            end)
                            input:SetScript("OnEscapePressed", function() this:ClearFocus() end)
                            slider:SetScript("OnValueChanged", function()
                            local snapped = math.max(minimum, math.min(maximum, math.floor(this:GetValue() / step + .5) * step))
                            if math.abs(this:GetValue() - snapped) > .001 then
                              options.updating = true
                              this:SetValue(snapped)
                              options.updating = nil
                              end
                              local value = tostring(snapped)
                              if not options.updating then C.appearance.bags[SettingKey()] = value end
                                text:SetText(label)
                                input:SetText(value)
                                if not options.updating then
                                  options.updating = true
                                  if key == "icon_size" then
                                    frame.category_button_size = nil
                                    end
                                    pfUI.bag:CreateBags()
                                    pfUI.bag:CreateBags("bank")
                                    options.updating = nil
                                    end
                                    end)
                            text:SetText(label)
                            input:SetText(value)
                            return slider
                            end

                            AddSlider("categorycolumns", "Columns", 1, 20, 1, -14)
                            AddSlider("icon_size", "Icon Size", 12, 48, 1, -42)
                            local categories = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
                            categories:SetPoint("BOTTOMLEFT", options, "BOTTOMLEFT", 5, 5)
                            categories:SetSize(180, 18)
                            categories:SetText("Edit Categories")
                            categories:SetScript("OnClick", function()
                            CreateCategoryEditor():Show()
                            end)
                            SkinButton(categories)
                            frame.options = options
                            return options
                            end

                            local function SetBagContentsShown(shown)
                            for bag = -2, 11 do
                              local slots = pfUI.bags[bag] and pfUI.bags[bag].slots
                              if slots then
                                for _, entry in pairs(slots) do
                                  if entry.frame then
                                    if shown then entry.frame:Show() else entry.frame:Hide() end
                                      end
                                      end
                                      end
                                      end
                                      end

                                      local function SetBagDragVisual(frame, dragging)
                                      SetBagContentsShown(not dragging)
                                      if frame.backdrop then
                                        if dragging then frame.backdrop:Hide() else frame.backdrop:Show() end
                                          end
                                          if frame.backdrop_shadow then
                                            if dragging then frame.backdrop_shadow:Hide() else frame.backdrop_shadow:Show() end
                                              end
                                              end

                                              local function ArrangeHeader(frame)
                                              if not frame.header then return end
                                                local function Anchor(button, anchor, relative, offset)
                                                if button then
                                                  button.noBorder = true
                                                  if button.backdrop then button.backdrop:SetBackdropBorderColor(0, 0, 0, 0) end
                                                    button:ClearAllPoints()
                                                    button:SetPoint(anchor, relative, anchor, offset or 0, 0)
                                                    end
                                                    end

                                                    if frame == pfUI.bag.right then
                                                      local leftAnchor = frame.header
                                                      if frame.emptyGroup then
                                                        Anchor(frame.emptyGroup, "LEFT", leftAnchor, 2)
                                                        leftAnchor = frame.emptyGroup
                                                        end
                                                        if frame.optionsButton then
                                                          Anchor(frame.optionsButton, "LEFT", leftAnchor, leftAnchor == frame.header and 2 or 15)
                                                          leftAnchor = frame.optionsButton
                                                          end
                                                          if frame.keys then
                                                            Anchor(frame.keys, "LEFT", leftAnchor, leftAnchor == frame.header and 2 or 15)
                                                            end
                                                            Anchor(frame.close, "RIGHT", frame.header, -2)
                                                            Anchor(frame.sort, "RIGHT", frame.close, -15)
                                                            Anchor(frame.bags, "RIGHT", frame.sort, -15)
                                                            else
                                                              local leftAnchor = frame.header
                                                              if frame.emptyGroup then
                                                                Anchor(frame.emptyGroup, "LEFT", leftAnchor, 2)
                                                                leftAnchor = frame.emptyGroup
                                                                end
                                                                if frame.optionsButton then
                                                                  Anchor(frame.optionsButton, "LEFT", leftAnchor, leftAnchor == frame.header and 2 or 15)
                                                                  leftAnchor = frame.optionsButton
                                                                  end
                                                                  if frame.bags then
                                                                    Anchor(frame.bags, "LEFT", leftAnchor, leftAnchor == frame.header and 2 or 15)
                                                                    end
                                                                    Anchor(frame.close, "RIGHT", frame.header, -2)
                                                                    Anchor(frame.sort, "RIGHT", frame.close, -15)
                                                                    end
                                                                    end

                                                                    local function CreateBagHeader(frame, name, title)
                                                                    if frame.header then return end
                                                                      frame.header = CreateFrame("Frame", name, frame)
                                                                      frame.header:SetPoint("TOPLEFT", frame, "TOPLEFT", default_border, 0)
                                                                      frame.header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -default_border, 0)
                                                                      frame.header:SetHeight(20)
                                                                      frame.header:SetFrameLevel(math.max(0, frame:GetFrameLevel() - 1))
                                                                      frame.header.noBorder = true
                                                                      frame.header.title = frame.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                                      frame.header.title:SetFont(pfUI.font_default, C.global.font_size * 1.5, "OUTLINE")
                                                                      frame.header.title:SetTextColor(pfUI.cr, pfUI.cg, pfUI.cb, 1)
                                                                      frame.header.title:SetPoint("CENTER", frame.header, "CENTER", 0, 0)
                                                                      frame.header.title:SetText(title or "")
                                                                      frame.header:EnableMouse(1)
                                                                      frame.header:SetScript("OnMouseDown", function()
                                                                      if arg1 == "LeftButton" and C.appearance.bags.movable == "1" then
                                                                        pfUI.bag.dragging = true
                                                                        local cursorX, cursorY = GetCursorPosition()
                                                                        local scale = UIParent:GetEffectiveScale()
                                                                        frame.dragOffsetX = frame:GetLeft() - cursorX / scale
                                                                        frame.dragOffsetY = frame:GetBottom() - cursorY / scale
                                                                        SetBagDragVisual(frame, true)
                                                                        if not frame.dragGhost then
                                                                          frame.dragGhost = CreateFrame("Frame", nil, UIParent)
                                                                          frame.dragGhost:SetFrameStrata("TOOLTIP")
                                                                          CreateBackdrop(frame.dragGhost, default_border)
                                                                          frame.dragGhost:SetBackdropColor(pfUI.cr, pfUI.cg, pfUI.cb, .25)
                                                                          frame.dragGhost:SetBackdropBorderColor(pfUI.cr, pfUI.cg, pfUI.cb, .8)
                                                                          end
                                                                          frame.dragGhost:SetSize(frame:GetWidth(), frame:GetHeight())
                                                                          frame.dragGhost:ClearAllPoints()
                                                                          frame.dragGhost:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", frame:GetLeft(), frame:GetBottom())
                                                                          frame.dragGhost:Show()
                                                                          frame.header:SetScript("OnUpdate", function(_, elapsed)
                                                                          frame.dragElapsed = (frame.dragElapsed or 0) + elapsed
                                                                          if frame.dragElapsed < .05 then return end
                                                                            frame.dragElapsed = 0
                                                                            local x, y = GetCursorPosition()
                                                                            local currentScale = UIParent:GetEffectiveScale()
                                                                            frame.dragGhost:ClearAllPoints()
                                                                            frame.dragGhost:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
                                                                                                     Crisp(frame.dragOffsetX + x / currentScale),
                                                                                                     Crisp(frame.dragOffsetY + y / currentScale))
                                                                            end)
                                                                          end
                                                                          end)
                                                                      frame.header:SetScript("OnMouseUp", function()
                                                                      if arg1 == "LeftButton" and C.appearance.bags.movable == "1" then
                                                                        frame.header:SetScript("OnUpdate", nil)
                                                                        frame.dragElapsed = nil
                                                                        if frame.dragGhost then
                                                                          local ghostLeft, ghostBottom = frame.dragGhost:GetLeft(), frame.dragGhost:GetBottom()
                                                                          frame.dragGhost:Hide()
                                                                          frame:ClearAllPoints()
                                                                          frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", ghostLeft, ghostBottom)
                                                                          end
                                                                          pfUI.bag.dragging = nil
                                                                          SetBagDragVisual(frame, false)
                                                                          SaveMovable(frame)
                                                                          if C.appearance.bags[CategoryViewKey(frame)] == "1" then
                                                                            pfUI.bag.delay.CategoryLayout = nil
                                                                            RefreshCategoryLayouts()
                                                                            end
                                                                            end
                                                                            end)
                                                                      end

                                                                      local function CreateEmptyOptionsButton(frame)
                                                                      if frame.optionsButton then return end
                                                                        frame.optionsButton = CreateFrame("Button", nil, frame)
                                                                        frame.optionsButton:SetSize(12, 12)
                                                                        frame.optionsButton:SetText("E")
                                                                        frame.optionsButton:SetFont(pfUI.font_default, 9, "OUTLINE")
                                                                        frame.optionsButton:SetScript("OnClick", function()
                                                                        local options = CreateBagOptions(frame)
                                                                        options:SetShown(not options:IsShown())
                                                                        end)
                                                                        frame.optionsButton:SetScript("OnEnter", function()
                                                                        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                                                        GameTooltip:SetText(T["Bag Options"] or "Bag Options")
                                                                        GameTooltip:Show()
                                                                        end)
                                                                        frame.optionsButton:SetScript("OnLeave", function()
                                                                        if GameTooltip:IsOwned(this) then GameTooltip:Hide() end
                                                                          end)
                                                                        CreateBackdrop(frame.optionsButton, default_border)
                                                                        end

                                                                        local defaultCategories = {
                                                                          { name = "Weapon", rules = "Weapon" },
                                                                          { name = "Armor", rules = "Armor" },
                                                                          { name = "Trinket", rules = "Trinket" },
                                                                          { name = "Consumable", rules = "Consumable" },
                                                                          { name = "Food", rules = "Food" },
                                                                          { name = "Drink", rules = "Drink" },
                                                                          { name = "Trade Goods", rules = "Trade Goods" },
                                                                          { name = "Reagent", rules = "Reagent" },
                                                                          { name = "Recipe", rules = "Recipe" },
                                                                          { name = "Quiver", rules = "Quiver" },
                                                                          { name = "Keyring", rules = "Keyring" },
                                                                          { name = "Container", rules = "Container" },
                                                                          { name = "Quest", rules = "Quest" },
                                                                          { name = "Class Items", rules = "Class Items" },
                                                                          { name = "Home", rules = "Home" },
                                                                          { name = "Tools", rules = "Tools" },
                                                                          { name = "Junk", rules = "Junk" },
                                                                          { name = "Miscellaneous", rules = "Miscellaneous" },
                                                                          { name = "Empty", rules = "Empty" },
                                                                        }
                                                                        local defaultCategoryNames = {}
                                                                        for _, category in ipairs(defaultCategories) do
                                                                          defaultCategoryNames[category.name] = true
                                                                          end

                                                                          local function IsCustomCategory(category, index)
                                                                          return category.custom or (category.custom == nil
                                                                          and (index > #defaultCategories or not defaultCategoryNames[category.name]))
                                                                          end

                                                                          local function GetCategories()
                                                                          local categories = C.appearance.bags.categories
                                                                          if categories and #categories == 5 and categories[1].name == "Equipment" and
                                                                            categories[2].name == "Consumables" and categories[3].name == "Crafting" and
                                                                            categories[4].name == "Bags & Tools" and categories[5].name == "Other" then
                                                                            C.appearance.bags.categories = nil
                                                                            categories = nil
                                                                            end
                                                                            if not categories then
                                                                              categories = {}
                                                                              for index, category in ipairs(defaultCategories) do
                                                                                categories[index] = { name = category.name, rules = category.rules, custom = false }
                                                                                end
                                                                                C.appearance.bags.categories = categories
                                                                                return categories
                                                                                end
                                                                                -- A saved profile only gets initialized from defaultCategories once
                                                                                -- (above), so a category added to defaultCategories later (like
                                                                                -- "Junk") would otherwise never actually exist in an existing
                                                                                -- profile. Reconcile any missing default categories back in,
                    -- grouped with the other defaults and ahead of custom entries,
                    -- without disturbing custom categories or edits to existing ones.
                    local present = {}
                    for _, category in ipairs(categories) do present[category.name] = true end
                      for _, category in ipairs(defaultCategories) do
                        if not present[category.name] then
                          local insertAt = #categories + 1
                          for index, existing in ipairs(categories) do
                            local isCustom = existing.custom or (existing.custom == nil
                            and (index > #defaultCategories or not defaultCategoryNames[existing.name]))
                            if isCustom then
                              insertAt = index
                              break
                              end
                              end
                              table.insert(categories, insertAt, { name = category.name, rules = category.rules, custom = false })
                              present[category.name] = true
                              end
                              end
                              return categories
                              end

                              local function ResolveCategory(itemText, baseCategory)
                              local categories = GetCategories()
                              local normalizedCategory = strlower(strtrim(baseCategory or ""))
                              local function Matches(rule)
                              rule = strlower(strtrim(rule))
                              return rule ~= "" and strfind(itemText, rule, 1, true)
                              end
                              for index = #categories, 1, -1 do
                                local category = categories[index]
                                local isCustom = category.custom or (category.custom == nil
                                and (index > #defaultCategories or not defaultCategoryNames[category.name]))
                                if isCustom then
                                  for rule in string.gmatch(category.rules or "", "[^,]+") do
                                    if Matches(rule) then return category.name end
                                      end
                                      end
                                      end
                                      for index, category in ipairs(categories) do
                                        local isCustom = category.custom or (category.custom == nil
                                        and (index > #defaultCategories or not defaultCategoryNames[category.name]))
                                        if not isCustom then
                                          for rule in string.gmatch(category.rules or "", "[^,]+") do
                                            if strlower(strtrim(rule)) == normalizedCategory then return category.name end
                                              end
                                              end
                                              end
                                              -- Nothing matched. "Empty" is reserved for actual empty slots (that
                                              -- case is already handled by the exact-match loop above via the
                                              -- "Empty" baseCategory) -- never fall back to it here just because it
                                              -- happens to be last in the category list.
                                              for _, category in ipairs(categories) do
                                                if strlower(category.name) == "miscellaneous" then return category.name end
                                                  end
                                                  for _, category in ipairs(categories) do
                                                    if strlower(category.name) ~= "empty" then return category.name end
                                                      end
                                                      return categories[#categories].name
                                                      end

                                                      CreateCategoryEditor = function()
                                                      if pfUI.bag.categoryEditor then return pfUI.bag.categoryEditor end

                                                        local editor = CreateFrame("Frame", "pfBagCategoryEditor", UIParent)
                                                        editor:SetFrameStrata("DIALOG")
                                                        editor:SetSize(430, 300)
                                                        editor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                                                        CreateBackdrop(editor, default_border)
                                                        editor:SetBackdropColor(0, 0, 0, .9)
                                                        editor:Hide()

                                                        local title = editor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                        title:SetPoint("TOPLEFT", editor, "TOPLEFT", 8, -8)
                                                        title:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
                                                        title:SetTextColor(pfUI.cr, pfUI.cg, pfUI.cb, 1)
                                                        title:SetText("Bag Categories")

                                                        local close = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
                                                        close:SetPoint("TOPRIGHT", editor, "TOPRIGHT", -6, -6)
                                                        close:SetSize(18, 18)
                                                        close:SetText("X")
                                                        close:SetScript("OnClick", function() editor:Hide() end)
                                                        SkinButton(close)
                                                        tinsert(UISpecialFrames, "pfBagCategoryEditor")

                                                        local function CreateButton(text, width, point, relative, relativePoint, x, y)
                                                        local button = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
                                                        button:SetSize(width, 18)
                                                        button:SetPoint(point, relative, relativePoint, x, y)
                                                        button:SetText(text)
                                                        SkinButton(button)
                                                        return button
                                                        end

                                                        local function CreateInput(point, relative, relativePoint, x, y)
                                                        local input = CreateFrame("EditBox", nil, editor)
                                                        input:SetSize(238, 18)
                                                        input:SetPoint(point, relative, relativePoint, x, y)
                                                        input:SetAutoFocus(false)
                                                        input:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                        input:SetTextInsets(4, 4, 0, 0)
                                                        input:SetTextColor(1, 1, 1, 1)
                                                        CreateBackdrop(input, nil, true)
                                                        return input
                                                        end

                                                        local list = CreateFrame("ScrollFrame", nil, editor)
                                                        list:SetPoint("TOPLEFT", editor, "TOPLEFT", 8, -32)
                                                        list:SetSize(150, 224)
                                                        CreateBackdrop(list, default_border)
                                                        list:EnableMouseWheel(true)

                                                        local listContent = CreateFrame("Frame", nil, list)
                                                        listContent:SetSize(150, 224)
                                                        list:SetScrollChild(listContent)
                                                        list:SetScript("OnMouseWheel", function()
                                                        local offset = this:GetVerticalScroll() - arg1 * 18
                                                        local maximum = math.max(0, listContent:GetHeight() - this:GetHeight())
                                                        this:SetVerticalScroll(math.max(0, math.min(offset, maximum)))
                                                        end)

                                                        local nameLabel = editor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                        nameLabel:SetPoint("TOPLEFT", list, "TOPRIGHT", 10, -2)
                                                        nameLabel:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                        nameLabel:SetText("Name")
                                                        local nameInput = CreateInput("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -3)

                                                        local rulesLabel = editor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                        rulesLabel:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT", 0, -12)
                                                        rulesLabel:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                        rulesLabel:SetText("Rules")
                                                        local rulesInput = CreateInput("TOPLEFT", rulesLabel, "BOTTOMLEFT", 0, -3)

                                                        local hint = editor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                        hint:SetPoint("TOPLEFT", rulesInput, "BOTTOMLEFT", 0, -6)
                                                        hint:SetPoint("RIGHT", editor, "RIGHT", -8, 0)
                                                        hint:SetJustifyH("LEFT")
                                                        hint:SetFont(pfUI.font_default, C.global.font_size - 2, "OUTLINE")
                                                        hint:SetTextColor(.6, .6, .6, 1)
                                                        hint:SetText("Comma-separated text matches, using the same item tooltip text as bag search. Unmatched items use the final category.")

                                                        editor.rows = {}
                                                        editor.selected = 1
                                                        local delete
                                                        local function Apply()
                                                        if pfUI.api and pfUI.api.libitemdetect then pfUI.api.libitemdetect:ClearCache() end
                                                          pfUI.bag:CreateBags()
                                                          pfUI.bag:CreateBags("bank")
                                                          end

                                                          local function Refresh()
                                                          local categories = GetCategories()
                                                          if editor.selected > #categories then editor.selected = #categories end
                                                            for index, category in ipairs(categories) do
                                                              local row = editor.rows[index]
                                                              if not row then
                                                                row = CreateFrame("Button", nil, listContent)
                                                                row:SetPoint("TOPLEFT", listContent, "TOPLEFT", 3, -5 - (index - 1) * 18)
                                                                row:SetSize(144, 17)
                                                                row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                                row.text:SetAllPoints()
                                                                row.text:SetJustifyH("LEFT")
                                                                row.text:SetFont(pfUI.font_default, C.global.font_size - 1, "OUTLINE")
                                                                row:SetScript("OnClick", function()
                                                                editor.selected = this.index
                                                                Refresh()
                                                                end)
                                                                row:SetScript("OnEnter", function()
                                                                if row.builtin then
                                                                  GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                                                  GameTooltip:SetText(T["Built-in category"] or "Built-in category")
                                                                  GameTooltip:AddLine(T["This category cannot be deleted."] or "This category cannot be deleted.", 1, 1, 1, true)
                                                                  GameTooltip:Show()
                                                                  end
                                                                  end)
                                                                row:SetScript("OnLeave", function()
                                                                if GameTooltip:IsOwned(this) then GameTooltip:Hide() end
                                                                  end)
                                                                editor.rows[index] = row
                                                                end
                                                                row.index = index
                                                                local builtin = not IsCustomCategory(category, index)
                                                                row.builtin = builtin
                                                                row.text:SetText(category.name .. (builtin and " (default)" or ""))
                                                                row.text:SetTextColor(index == editor.selected and pfUI.cr or (builtin and .65 or 1),
                                                                                      index == editor.selected and pfUI.cg or (builtin and .65 or 1),
                                                                                      index == editor.selected and pfUI.cb or (builtin and .65 or 1), 1)
                                                                row:Show()
                                                                end
                                                                for index = #categories + 1, #editor.rows do editor.rows[index]:Hide() end
                                                                  listContent:SetHeight(math.max(224, #categories * 18 + 10))
                                                                  list:SetVerticalScroll(math.min(list:GetVerticalScroll(), listContent:GetHeight() - list:GetHeight()))
                                                                  local selected = categories[editor.selected]
                                                                  nameInput:SetText(selected and selected.name or "")
                                                                  rulesInput:SetText(selected and selected.rules or "")
                                                                  if delete then
                                                                    if selected and not IsCustomCategory(selected, editor.selected) then
                                                                      delete:Disable()
                                                                      else
                                                                        delete:Enable()
                                                                        end
                                                                        end
                                                                        end

                                                                        local save = CreateButton("Save", 72, "BOTTOMRIGHT", editor, "BOTTOMRIGHT", -8, 8)
                                                                        save:SetScript("OnClick", function()
                                                                        local category = GetCategories()[editor.selected]
                                                                        if not category then return end
                                                                          category.name = strtrim(nameInput:GetText())
                                                                          if category.name == "" then category.name = "Category " .. editor.selected end
                                                                            category.rules = rulesInput:GetText()
                                                                            Apply()
                                                                            Refresh()
                                                                            end)

                                                                        local up = CreateButton("Up", 45, "BOTTOMLEFT", editor, "BOTTOMLEFT", 8, 8)
                                                                        up:SetScript("OnClick", function()
                                                                        local categories = GetCategories()
                                                                        if editor.selected <= 1 then return end
                                                                          categories[editor.selected], categories[editor.selected - 1] = categories[editor.selected - 1], categories[editor.selected]
                                                                          editor.selected = editor.selected - 1
                                                                          Apply()
                                                                          Refresh()
                                                                          end)

                                                                        local down = CreateButton("Down", 45, "LEFT", up, "RIGHT", 4, 0)
                                                                        down:SetScript("OnClick", function()
                                                                        local categories = GetCategories()
                                                                        if editor.selected >= #categories then return end
                                                                          categories[editor.selected], categories[editor.selected + 1] = categories[editor.selected + 1], categories[editor.selected]
                                                                          editor.selected = editor.selected + 1
                                                                          Apply()
                                                                          Refresh()
                                                                          end)

                                                                        local new = CreateButton("New", 45, "LEFT", down, "RIGHT", 4, 0)
                                                                        new:SetScript("OnClick", function()
                                                                        local categories = GetCategories()
                                                                        table.insert(categories, { name = "New Category", rules = "", custom = true })
                                                                        editor.selected = #categories
                                                                        Apply()
                                                                        Refresh()
                                                                        end)

                                                                        delete = CreateButton("Delete", 52, "LEFT", new, "RIGHT", 4, 0)
                                                                        delete:SetScript("OnClick", function()
                                                                        local categories = GetCategories()
                                                                        if #categories <= 1 then return end
                                                                          local category = categories[editor.selected]
                                                                          if not category or not IsCustomCategory(category, editor.selected) then return end
                                                                            table.remove(categories, editor.selected)
                                                                            Apply()
                                                                            Refresh()
                                                                            end)

                                                                        editor:SetScript("OnShow", Refresh)
                                                                        pfUI.bag.categoryEditor = editor
                                                                        return editor
                                                                        end

                                                                        local function LayoutCategories(frame, iterate, topspace, rowlength, categorySidePadding)
                                                                        categorySidePadding = categorySidePadding or 0
                                                                        local columns = tonumber(C.appearance.bags[CategoryColumnsKey(frame)]) or 6
                                                                        columns = math.max(1, math.min(20, math.floor(columns)))
                                                                        local categories = GetCategories()
                                                                        local groups = {}
                                                                        for _, category in ipairs(categories) do groups[category.name] = {} end
                                                                          for _, bag in ipairs(iterate) do
                                                                            local size = GetBagSize(bag)
                                                                              for slot = 1, size do
                                                                                local entry = pfUI.bags[bag] and pfUI.bags[bag].slots[slot]
                                                                                if entry and entry.frame then
                                                                                  local category = entry.frame.category or "Miscellaneous"
                                                                                  if category == "Empty" and GetBagFamily(bag) == "QUIVER" then
                                                                                    entry.frame:Hide()
                                                                                    elseif groups[category] then
                                                                                      table.insert(groups[category], entry.frame)
                                                                                      elseif groups["Miscellaneous"] then
                                                                                        table.insert(groups["Miscellaneous"], entry.frame)
                                                                                        else
                                                                                          entry.frame:Hide()
                                                                                          end
                                                                                          end
                                                                                          end
                                                                                          end

                                                                                          frame.categoryHeaders = frame.categoryHeaders or {}
                                                                                          local row, step = 0, frame.button_size + default_border * 3
                                                                                          local titleOffset = .45
                                                                                          local categoryGap = .5
                                                                                          local rowHeight, column = 0, 0
                                                                                          frame.categoryAreas = frame.categoryAreas or {}
                                                                                          for _, definition in ipairs(categories) do
                                                                                            local category = definition.name
                                                                                            local items = groups[category]
                                                                                            if table.getn(items) > 0 then
                                                                                              local itemCount = table.getn(items)
                                                                                              local displayCount = itemCount
                                                                                              if category == "Empty" and C.appearance.bags.groupempty == "1" then
                                                                                                for index = 2, itemCount do items[index]:Hide() end
                                                                                                  displayCount = 1
                                                                                                  end
                                                                                                  local itemWidth = math.min(columns, displayCount)
                                                                                                  local rows = math.ceil(displayCount / columns)

                                                                                                  local header = frame.categoryHeaders[category]
                                                                                                  if not header then
                                                                                                    header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                                                                    header:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                                                                    header:SetTextColor(pfUI.cr, pfUI.cg, pfUI.cb, 1)
                                                                                                    header.line = frame:CreateTexture(nil, "ARTWORK")
                                                                                                    header.line:SetTexture(.35, .35, .35, .55)
                                                                                                    frame.categoryHeaders[category] = header
                                                                                                    end
                                                                                                    -- Measure the header text before laying anything out, so a long
                                                                                                    -- category name can claim extra column width instead of
                                                                                                    -- overflowing into whatever comes next.
                                                                                                    header:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                                                                    header:SetText(category .. " (" .. itemCount .. ")")
                                                                                                    local headerPadding = .3
                                                                                                    local headerWidth = math.min(columns, header:GetStringWidth() / step + headerPadding)
                                                                                                    local width = math.max(itemWidth, headerWidth)

                                                                                                    local gap = column > 0 and categoryGap or 0
                                                                                                    if column > 0 and column + gap + width > columns then
                                                                                                      row = row + rowHeight + .15
                                                                                                      rowHeight, column, gap = 0, 0, 0
                                                                                                      end
                                                                                                      column = column + gap
                                                                                                      header:ClearAllPoints()
                                                                                                      header:SetPoint("TOPLEFT", frame, "TOPLEFT", default_border + categorySidePadding + column * step,
                                                                                                                      Crisp(-default_border - row * step - topspace))
                                                                                                      header:SetWidth(math.max(1.5, width) * step)
                                                                                                      header:SetJustifyH("LEFT")
                                                                                                      header.line:ClearAllPoints()
                                                                                                      header.line:SetPoint("LEFT", header, "LEFT", header:GetStringWidth() + step * .25, 0)
                                                                                                      header.line:SetPoint("RIGHT", header, "RIGHT", -step * .25, 0)
                                                                                                      header.line:SetHeight(1)
                                                                                                      if header:GetStringWidth() + step * .5 < width * step then
                                                                                                        header.line:Show()
                                                                                                        else
                                                                                                          header.line:Hide()
                                                                                                          end
                                                                                                          header:Show()

                                                                                                          for index = 1, displayCount do
                                                                                                            local button = items[index]
                                                                                                            local x = column + math.mod(index - 1, columns)
                                                                                                            local y = row + titleOffset + math.floor((index - 1) / columns)
                                                                                                            button:ClearAllPoints()
                                                                                                            button:SetPoint("TOPLEFT", frame, "TOPLEFT", Crisp(default_border + categorySidePadding + x * step),
                                                                                                                            Crisp(-default_border * 2 - y * step - topspace))
                                                                                                            button:SetSize(frame.button_size, frame.button_size)
                                                                                                            button:Show()
                                                                                                            if category == "Empty" and C.appearance.bags.groupempty == "1" then
                                                                                                              if not button.emptyCount then
                                                                                                                button.emptyCount = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                                                                                button.emptyCount:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
                                                                                                                button.emptyCount:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
                                                                                                                button.emptyCount:SetTextColor(1, 1, 1, 1)
                                                                                                                end
                                                                                                                button.emptyCount:SetText(itemCount)
                                                                                                                button.emptyCount:Show()
                                                                                                                elseif button.emptyCount then
                                                                                                                  button.emptyCount:Hide()
                                                                                                                  end
                                                                                                                  end
                                                                                                                  column = column + width
                                                                                                                  rowHeight = math.max(rowHeight, titleOffset + rows)
                                                                                                                  end
                                                                                                                  end

                                                                                                                  row = row + rowHeight + .15

                                                                                                                  for category, header in pairs(frame.categoryHeaders) do
                                                                                                                    local active = false
                                                                                                                    if groups[category] and table.getn(groups[category]) > 0 then
                                                                                                                      active = true
                                                                                                                      end
                                                                                                                      if not active then
                                                                                                                        header:Hide()
                                                                                                                        if header.line then header.line:Hide() end
                                                                                                                          end
                                                                                                                          end
                                                                                                                          return row
                                                                                                                          end

                                                                                                                          local function ClearCategoryLayout(frame, iterate)
                                                                                                                          if frame.categoryHeaders then
                                                                                                                            for _, header in pairs(frame.categoryHeaders) do
                                                                                                                              header:Hide()
                                                                                                                              if header.line then header.line:Hide() end
                                                                                                                                end
                                                                                                                                end
                                                                                                                                if frame.categoryAreas then
                                                                                                                                  for _, header in pairs(frame.categoryAreas) do
                                                                                                                                    header:Hide()
                                                                                                                                    if header.line then header.line:Hide() end
                                                                                                                                      end
                                                                                                                                      end
                                                                                                                                      for _, bag in ipairs(iterate) do
                                                                                                                                        local slots = pfUI.bags[bag] and pfUI.bags[bag].slots
                                                                                                                                        local bagsize = GetBagSize(bag)
                                                                                                                                        if slots then
                                                                                                                                          for slotIndex, entry in pairs(slots) do
                                                                                                                                            if entry.frame then
                                                                                                                                              -- keyring slots stay hidden here too, otherwise this undoes the toggle
                                                                                                                                              if slotIndex <= bagsize then
                                                                                                                                                entry.frame:Show()
                                                                                                                                              else
                                                                                                                                                entry.frame:Hide()
                                                                                                                                              end
                                                                                                                                              if entry.frame.emptyCount then entry.frame.emptyCount:Hide() end
                                                                                                                                                end
                                                                                                                                                end
                                                                                                                                                end
                                                                                                                                                end
                                                                                                                                                end

                                                                                                                                                RefreshCategoryLayouts = function()
                                                                                                                                                for _, entry in ipairs({
                                                                                                                                                  { frame = pfUI.bag.right, bags = pfUI.BACKPACK,
                                                                                                                                                    rowlength = tonumber(C.appearance.bags.bagrowlength) },
                                                                                                                                                                       { frame = pfUI.bag.left, bags = pfUI.BANK,
                                                                                                                                                                         rowlength = tonumber(C.appearance.bags.bankrowlength) },
                                                                                                                                                }) do
                                                                                                                                                if entry.frame and C.appearance.bags[CategoryViewKey(entry.frame)] == "1" and entry.frame:IsShown() and entry.frame.button_size then
                                                                                                                                                  local top = entry.frame.close:GetHeight() + default_border * 2 + entry.frame.header:GetHeight()
                                                                                                                                                  local rows = LayoutCategories(entry.frame, entry.bags, top, entry.rowlength,
                                                                                                                                                                                entry.frame.category_button_size and (entry.frame.category_button_size + default_border * 3) / 2 or 0)
                                                                                                                                                  local bottom = pfUI.panel and pfUI.panel.right:IsShown()
                                                                                                                                                  and pfUI.panel.right:GetHeight() + default_border or 16 + default_border
                                                                                                                                                  entry.frame:SetHeight(default_border * 2
                                                                                                                                                  + rows * (entry.frame.button_size + default_border * 3) + top + bottom)
                                                                                                                                                  end
                                                                                                                                                  end
                                                                                                                                                  end

                                                                                                                                                  -- prevent from being placed offscreen
                                                                                                                                                  _G.StackSplitFrame:SetClampedToScreen(true)

                                                                                                                                                  -- overwrite some bag functions
                                                                                                                                                  function _G.OpenAllBags()
                                                                                                                                                  if pfUI.bag.right:IsShown() then
                                                                                                                                                    pfUI.bag.right:Hide()
                                                                                                                                                    else
                                                                                                                                                      pfUI.bag.right:Show()
                                                                                                                                                      end
                                                                                                                                                      end

                                                                                                                                                      function _G.CloseAllBags()
                                                                                                                                                      pfUI.bag.right:Hide()
                                                                                                                                                      end

                                                                                                                                                      function _G.ToggleBackpack()
                                                                                                                                                      if pfUI.bag.right:IsShown() then
                                                                                                                                                        pfUI.bag.right:Hide()
                                                                                                                                                        else
                                                                                                                                                          pfUI.bag.right:Show()
                                                                                                                                                          end
                                                                                                                                                          end

                                                                                                                                                          function _G.OpenBackpack()
                                                                                                                                                          if ( pfUI.bag.right:IsShown() ) then
                                                                                                                                                            ContainerFrame1.backpackWasOpen = 1
                                                                                                                                                            return
                                                                                                                                                            else
                                                                                                                                                              ContainerFrame1.backpackWasOpen = nil
                                                                                                                                                              end

                                                                                                                                                              if ( not ContainerFrame1.backpackWasOpen ) then
                                                                                                                                                                ToggleBackpack()
                                                                                                                                                                end
                                                                                                                                                                end

                                                                                                                                                                function _G.ToggleBag()
                                                                                                                                                                return
                                                                                                                                                                end

                                                                                                                                                                -- hide blizzard's bankframe
                                                                                                                                                                BankFrame:SetScale(0.001)
                                                                                                                                                                BankFrame:SetPoint("TOPLEFT", 0,0)
                                                                                                                                                                BankFrame:SetAlpha(0)

                                                                                                                                                                pfUI.bag = CreateFrame("Frame", "pfUIBag")
                                                                                                                                                                pfUI.bag:RegisterEvent("PLAYER_ENTERING_WORLD")
                                                                                                                                                                pfUI.bag:RegisterEvent("BAG_UPDATE")
                                                                                                                                                                pfUI.bag:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
                                                                                                                                                                pfUI.bag:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
                                                                                                                                                                pfUI.bag:RegisterEvent("BAG_UPDATE_COOLDOWN")
                                                                                                                                                                pfUI.bag:RegisterEvent("BAG_CLOSED")
                                                                                                                                                                pfUI.bag:RegisterEvent("BANKFRAME_CLOSED")
                                                                                                                                                                pfUI.bag:RegisterEvent("BANKFRAME_OPENED")
                                                                                                                                                                pfUI.bag:RegisterEvent("ITEM_LOCK_CHANGED")
                                                                                                                                                                pfUI.bag:RegisterEvent("SPELLS_CHANGED")
                                                                                                                                                                pfUI.bag:RegisterEvent("MERCHANT_CLOSED")

                                                                                                                                                                pfUI.bag.delay = { UpdateBag = {} }

                                                                                                                                                                pfUI.bag:SetScript("OnUpdate", function()
                                                                                                                                                                -- update delayed ones every 0.1s
                                                                                                                                                                if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .1 end

                                                                                                                                                                  if this.delay.RefreshSpells then
                                                                                                                                                                    this.delay.RefreshSpells = nil
                                                                                                                                                                    pfUI.bag:RefreshSpells()
                                                                                                                                                                    end

                                                                                                                                                                    if this.delay.CheckFullUpdate then
                                                                                                                                                                      this.delay.CheckFullUpdate = nil
                                                                                                                                                                      pfUI.bag:CheckFullUpdate()
                                                                                                                                                                      end

                                                                                                                                                                      if this.delay.UpdateCooldowns then
                                                                                                                                                                        this.delay.UpdateCooldowns = nil
                                                                                                                                                                        pfUI.bag:UpdateCooldowns()
                                                                                                                                                                        end

                                                                                                                                                                        if this.delay.UpdateItemLock then
                                                                                                                                                                          this.delay.UpdateItemLock = nil
                                                                                                                                                                          pfUI.bag:UpdateItemLock()
                                                                                                                                                                          end

                                                                                                                                                                          for bag in pairs(this.delay.UpdateBag) do
                                                                                                                                                                            this.delay.UpdateBag[bag] = nil
                                                                                                                                                                            pfUI.bag:UpdateBag(bag)
                                                                                                                                                                            end

                                                                                                                                                                            if this.delay.CategoryLayout and not this.dragging then
                                                                                                                                                                              this.delay.CategoryLayout = nil
                                                                                                                                                                              RefreshCategoryLayouts()
                                                                                                                                                                              end
                                                                                                                                                                              end)

                                                                                                                                                                pfUI.bag:SetScript("OnEvent", function()
                                                                                                                                                                if event == "PLAYER_ENTERING_WORLD" then
                                                                                                                                                                  pfUI.bag:CreateBags()
                                                                                                                                                                  pfUI.bag.right:Hide()

                                                                                                                                                                  pfUI.bag:CreateBags("bank")
                                                                                                                                                                  pfUI.bag.left:Hide()

                                                                                                                                                                  pfUI.bag:CreateBagSlots(pfUI.bag.right)
                                                                                                                                                                  pfUI.bag:CreateBagSlots(pfUI.bag.left)
                                                                                                                                                                  pfUI.bag:RefreshSpells()
                                                                                                                                                                  end

                                                                                                                                                                  if event == "SPELLS_CHANGED" then
                                                                                                                                                                    this.delay.RefreshSpells = true
                                                                                                                                                                    end

                                                                                                                                                                    if event == "BAG_CLOSED" or event == "PLAYERBANKSLOTS_CHANGED" or
                                                                                                                                                                      event == "PLAYERBANKBAGSLOTS_CHANGED" or event == "BAG_UPDATE" or
                                                                                                                                                                      event == "BANKFRAME_OPENED" or event == "BANKFRAME_CLOSED" then
                                                                                                                                                                      this.delay.CheckFullUpdate = true
                                                                                                                                                                      end

                                                                                                                                                                      if event == "BAG_UPDATE_COOLDOWN" then
                                                                                                                                                                        this.delay.UpdateCooldowns = true
                                                                                                                                                                        end

                                                                                                                                                                        if event == "ITEM_LOCK_CHANGED" then
                                                                                                                                                                          this.delay.UpdateItemLock = true
                                                                                                                                                                          end

                                                                                                                                                                          if event == "PLAYERBANKSLOTS_CHANGED" then
                                                                                                                                                                            this.delay.UpdateBag[-1] = true
                                                                                                                                                                            end

                                                                                                                                                                            if event == "BAG_UPDATE" then
                                                                                                                                                                              this.delay.UpdateBag[arg1] = true
                                                                                                                                                                              this.delay.CategoryLayout = true
                                                                                                                                                                              end

                                                                                                                                                                              if event == "PLAYERBANKBAGSLOTS_CHANGED" then
                                                                                                                                                                                pfUI.bag:CreateBagSlots(pfUI.bag.left)
                                                                                                                                                                                end

                                                                                                                                                                                if event == "BANKFRAME_OPENED" then
                                                                                                                                                                                  pfUI.bag.left:Show()
                                                                                                                                                                                  OpenBackpack()
                                                                                                                                                                                  end

                                                                                                                                                                                  if event == "BANKFRAME_CLOSED" then
                                                                                                                                                                                    pfUI.bag.left:Hide()
                                                                                                                                                                                    end

                                                                                                                                                                                    if event == "MERCHANT_CLOSED" then
                                                                                                                                                                                      if not ContainerFrame1.backpackWasOpen then
                                                                                                                                                                                        pfUI.bag.right:Hide()
                                                                                                                                                                                        end
                                                                                                                                                                                        end
                                                                                                                                                                                        end)

                                                                                                                                                                tinsert(UISpecialFrames,"pfBag")

                                                                                                                                                                pfUI.BACKPACK = { -2, 0, 1, 2, 3, 4 }
                                                                                                                                                                pfUI.BANK = { -1, 5, 6, 7, 8, 9, 10, 11 }

                                                                                                                                                                pfUI.bags = {}
                                                                                                                                                                pfUI.slots = {}

                                                                                                                                                                function pfUI.bag:CheckFullUpdate()
                                                                                                                                                                local maxslots = 0

                                                                                                                                                                for bag = -2,11 do
                                                                                                                                                                  local bagsize = GetBagSize(bag)

                                                                                                                                                                    maxslots = maxslots + bagsize
                                                                                                                                                                    end

                                                                                                                                                                    if maxslots ~= pfUI.bag.maxslots then
                                                                                                                                                                      for bag = -2,11 do
                                                                                                                                                                        if pfUI.bags[bag] then
                                                                                                                                                                          for slot, f in ipairs(pfUI.bags[bag].slots) do
                                                                                                                                                                            local bagsize = GetBagSize(bag)

                                                                                                                                                                              if slot > bagsize then
                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame:Hide()
                                                                                                                                                                                end
                                                                                                                                                                                end
                                                                                                                                                                                end
                                                                                                                                                                                end

                                                                                                                                                                                pfUI.bag:CreateBags()
                                                                                                                                                                                pfUI.bag:CreateBags("bank")
                                                                                                                                                                                pfUI.bag.maxslots = maxslots
                                                                                                                                                                                end
                                                                                                                                                                                end

                                                                                                                                                                                function pfUI.bag:CreateBags(object)
                                                                                                                                                                                local x = 0
                                                                                                                                                                                local y = 0
                                                                                                                                                                                local frame = {}
                                                                                                                                                                                local iterate = {}
                                                                                                                                                                                local anchor, rowlength, cwidth
                                                                                                                                                                                local categorySidePadding = 0
                                                                                                                                                                                local contentSidePadding = 0
                                                                                                                                                                                local normalButtonSize

                                                                                                                                                                                if object == "bank" then
                                                                                                                                                                                  if not pfUI.bag.left then pfUI.bag.left = CreateFrame("Frame", "pfBank", UIParent) end
                                                                                                                                                                                    anchor = { "BOTTOMLEFT", (pfUI.chat and pfUI.chat.left or nil), "BOTTOMRIGHT", "TOPLEFT", "TOPRIGHT" }
                                                                                                                                                                                    rowlength = tonumber(C.appearance.bags.bankrowlength)
                                                                                                                                                                                    cwidth = C.chat.left.width
                                                                                                                                                                                    iterate = pfUI.BANK
                                                                                                                                                                                    frame = pfUI.bag.left
                                                                                                                                                                                    else
                                                                                                                                                                                      if not pfUI.bag.right then pfUI.bag.right = CreateFrame("Frame", "pfBag", UIParent) end
                                                                                                                                                                                        rowlength = tonumber(C.appearance.bags.bagrowlength)
                                                                                                                                                                                        anchor = { "BOTTOMRIGHT", (pfUI.chat and pfUI.chat.right or nil), "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT" }
                                                                                                                                                                                        cwidth = C.chat.right.width
                                                                                                                                                                                        iterate = pfUI.BACKPACK
                                                                                                                                                                                        frame = pfUI.bag.right
                                                                                                                                                                                        end

                                                                                                                                                                                        if not frame.init then
                                                                                                                                                                                          local title = UnitName("player") .. "'s " .. (object == "bank" and "Bank" or "Bag")
                                                                                                                                                                                          CreateBagHeader(frame, object == "bank" and "pfBankHeader" or "pfBagHeader", title)
                                                                                                                                                                                          pfUI.bag:CreateAdditions(frame)
                                                                                                                                                                                          ArrangeHeader(frame)
                                                                                                                                                                                          frame:SetFrameStrata("HIGH")
                                                                                                                                                                                          CreateBackdrop(frame, default_border)
                                                                                                                                                                                          CreateBackdropShadow(frame)
                                                                                                                                                                                          frame.init = true
                                                                                                                                                                                          end

                                                                                                                                                                                          if pfUI.chat and C.appearance.bags[IconSizeKey(frame)] == "-1" then
                                                                                                                                                                                            frame:SetWidth(cwidth * anchor[2]:GetScale())
                                                                                                                                                                                            elseif C.appearance.bags[IconSizeKey(frame)] ~= "-1" then
                                                                                                                                                                                              frame:SetWidth((C.appearance.bags[IconSizeKey(frame)] + default_border*3) * rowlength - default_border)
                                                                                                                                                                                              else
                                                                                                                                                                                                frame:SetWidth((22 + default_border*3) * rowlength - default_border)
                                                                                                                                                                                                end

                                                                                                                                                                                                if pfUI.chat and C.appearance.bags[IconSizeKey(frame)] ~= "-1" then
                                                                                                                                                                                                  frame:SetPoint(anchor[1], anchor[2], anchor[1], 0, 0)
                                                                                                                                                                                                  elseif pfUI.chat then
                                                                                                                                                                                                    if C.appearance.bags.abovechat == "0" then
                                                                                                                                                                                                      frame:SetPoint(anchor[1], anchor[2], anchor[1], 0, 0)
                                                                                                                                                                                                      frame:SetPoint(anchor[3], anchor[2], anchor[3], 0, 0)
                                                                                                                                                                                                      else
                                                                                                                                                                                                        frame:SetPoint(anchor[3], anchor[2], anchor[5], 0, 3*default_border)
                                                                                                                                                                                                        frame:SetPoint(anchor[1], anchor[2], anchor[4], 0, 3*default_border)
                                                                                                                                                                                                        end
                                                                                                                                                                                                        else
                                                                                                                                                                                                          frame:SetPoint(anchor[1], UIParent, anchor[1], 5, 5)
                                                                                                                                                                                                          end

                                                                                                                                                                                                          if C.appearance.bags[CategoryViewKey(frame)] == "1" then
                                                                                                                                                                                                            local categoryColumns = tonumber(C.appearance.bags[CategoryColumnsKey(frame)]) or 6
                                                                                                                                                                                                            categoryColumns = math.max(1, math.min(20, math.floor(categoryColumns)))
                                                                                                                                                                                                            if not frame.category_button_size then
                                                                                                                                                                                                              frame.category_button_size = Crisp((frame:GetWidth() - 2*default_border
                                                                                                                                                                                                              - (rowlength-1)*default_border*3) / rowlength)
                                                                                                                                                                                                              end
                                                                                                                                                                                                              categorySidePadding = (frame.category_button_size + default_border*3) / 2
                                                                                                                                                                                                              contentSidePadding = categorySidePadding
                                                                                                                                                                                                              frame:SetWidth(Crisp((frame.category_button_size + default_border*3)
                                                                                                                                                                                                              * categoryColumns - default_border + categorySidePadding * 2))
                                                                                                                                                                                                              else
                                                                                                                                                                                                                frame.category_button_size = nil
                                                                                                                                                                                                                if C.appearance.bags.movable == "1" and C.appearance.bags[IconSizeKey(frame)] ~= "-1" then
                                                                                                                                                                                                                  normalButtonSize = Crisp(C.appearance.bags[IconSizeKey(frame)])
                                                                                                                                                                                                                  else
                                                                                                                                                                                                                    normalButtonSize = Crisp((frame:GetWidth() - 2*default_border
                                                                                                                                                                                                                    - (rowlength-1)*default_border*3) / rowlength)
                                                                                                                                                                                                                    end
                                                                                                                                                                                                                    contentSidePadding = (normalButtonSize + default_border*3) / 2
                                                                                                                                                                                                                    frame:SetWidth(Crisp(frame:GetWidth() + contentSidePadding * 2))
                                                                                                                                                                                                                    end

                                                                                                                                                                                                                    if C.appearance.bags.movable == "1" then
                                                                                                                                                                                                                      LoadMovable(frame)
                                                                                                                                                                                                                      frame:EnableMouse(1)
                                                                                                                                                                                                                      frame:SetMovable(1)
                                                                                                                                                                                                                      frame:RegisterForDrag("LeftButton")
                                                                                                                                                                                                                      frame:SetScript("OnDragStart", function()
                                                                                                                                                                                                                      this:StartMoving()
                                                                                                                                                                                                                      end)

                                                                                                                                                                                                                      frame:SetScript("OnDragStop",  function()
                                                                                                                                                                                                                      this:StopMovingOrSizing()
                                                                                                                                                                                                                      SaveMovable(this)
                                                                                                                                                                                                                      end)
                                                                                                                                                                                                                      end

                                                                                                                                                                                                                      frame:EnableMouse(1)

                                                                                                                                                                                                                      if C.appearance.bags[CategoryViewKey(frame)] == "1" then
                                                                                                                                                                                                                        frame.button_size = Crisp(frame.category_button_size)
                                                                                                                                                                                                                        elseif C.appearance.bags.movable == "1" and C.appearance.bags[IconSizeKey(frame)] ~= "-1" then
                                                                                                                                                                                                                          frame.button_size = Crisp(C.appearance.bags[IconSizeKey(frame)])
                                                                                                                                                                                                                          else
                                                                                                                                                                                                                            frame.button_size = normalButtonSize
                                                                                                                                                                                                                            end

                                                                                                                                                                                                                            local topspace = pfUI.bag.right.close:GetHeight() + default_border * 2 + frame.header:GetHeight()
                                                                                                                                                                                                                            if C.appearance.bags[CategoryViewKey(frame)] == "1" then
                                                                                                                                                                                                                              topspace = topspace + Crisp(frame.button_size / 4)
                                                                                                                                                                                                                              else
                                                                                                                                                                                                                                topspace = topspace + 8
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                local bottomspace = pfUI.panel and pfUI.panel.right:IsShown() and pfUI.panel.right:GetHeight() + default_border or 16 + default_border

                                                                                                                                                                                                                                if C.appearance.bags[CategoryViewKey(frame)] ~= "1" then
                                                                                                                                                                                                                                  ClearCategoryLayout(frame, iterate)
                                                                                                                                                                                                                                  end

                                                                                                                                                                                                                                  for id, bag in pairs(iterate) do
                                                                                                                                                                                                                                    if not pfUI.bags[bag] then
                                                                                                                                                                                                                                      pfUI.bags[bag] = CreateFrame("Frame", "pfBag" .. bag,  frame)
                                                                                                                                                                                                                                      pfUI.bags[bag]:SetAllPoints(frame)
                                                                                                                                                                                                                                      pfUI.bags[bag].slots = {}
                                                                                                                                                                                                                                      end
                                                                                                                                                                                                                                      pfUI.bags[bag]:SetID(bag)
                                                                                                                                                                                                                                      local bagsize = GetBagSize(bag)
                                                                                                                                                                                                                                        for slot=1, bagsize do
                                                                                                                                                                                                                                          pfUI.bag:UpdateSlot(bag, slot)

                                                                                                                                                                                                                                          if C.appearance.bags[CategoryViewKey(frame)] ~= "1" then
                                                                                                                                                                                                                                            pfUI.bags[bag].slots[slot].frame:ClearAllPoints()
                                                                                                                                                                                                                                            pfUI.bags[bag].slots[slot].frame:SetPoint("TOPLEFT",
                                                                                                                                                                                                                                                                Crisp(default_border + contentSidePadding + x*(frame.button_size+default_border*3)),
                                                                                                                                                                                                                                                                Crisp(-default_border*2 - y*(frame.button_size+default_border*3) - topspace))

                                                                                                                                                                                                                                            pfUI.bags[bag].slots[slot].frame:SetSize(frame.button_size, frame.button_size)
                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                            if x >= rowlength - 1 then
                                                                                                                                                                                                                                              y = y + 1
                                                                                                                                                                                                                                              x = 0
                                                                                                                                                                                                                                              else
                                                                                                                                                                                                                                                x = x + 1
                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                if C.appearance.bags[CategoryViewKey(frame)] == "1" then
                                                                                                                                                                                                                                                  local success, categoryRows = pcall(LayoutCategories, frame, iterate, topspace, rowlength, categorySidePadding)
                                                                                                                                                                                                                                                  if success then
                                                                                                                                                                                                                                                    y = categoryRows
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                      C.appearance.bags[CategoryViewKey(frame)] = "0"
                                                                                                                                                                                                                                                      return pfUI.bag:CreateBags(object)
                                                                                                                                                                                                                                                      end
                                                                                                                                                                                                                                                      elseif x > 0 then
                                                                                                                                                                                                                                                        y = y + 1
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        frame:SetHeight( default_border*2 + y*(frame.button_size+default_border*3) + topspace + bottomspace)

                                                                                                                                                                                                                                                        local chat = pfUI.chat and ( object == "bank" and pfUI.chat.left or pfUI.chat.right) or nil

                                                                                                                                                                                                                                                        frame:SetScript("OnShow", function()
                                                                                                                                                                                                                                                        frame.opened = true
                                                                                                                                                                                                                                                        if C.appearance.bags.hidechat == "1" and chat and chat:IsVisible() then
                                                                                                                                                                                                                                                          frame.chatWasOpen = true
                                                                                                                                                                                                                                                          chat:Hide()
                                                                                                                                                                                                                                                          end
                                                                                                                                                                                                                                                          if C.appearance.bags.autoSortOnOpen == "1" then
                                                                                                                                                                                                                                                            libbagsort:Sort({0, 1, 2, 3, 4}, BagSortOpts())
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                            PlaySound("INTERFACESOUND_BACKPACKOPEN")
                                                                                                                                                                                                                                                            end)

                                                                                                                                                                                                                                                        frame:SetScript("OnHide", function()
                                                                                                                                                                                                                                                        if frame.options then frame.options:Hide() end
                                                                                                                                                                                                                                                          if C.appearance.bags.hidechat == "1" and chat and frame.chatWasOpen then
                                                                                                                                                                                                                                                            chat:Show()
                                                                                                                                                                                                                                                            frame.chatWasOpen = false
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                            pfUI.bag:CreateBags(object)
                                                                                                                                                                                                                                                            PlaySound("INTERFACESOUND_BACKPACKCLOSE")
                                                                                                                                                                                                                                                            if frame.opened then
                                                                                                                                                                                                                                                              frame.opened = nil
                                                                                                                                                                                                                                                              pfUI.events:TriggerEvent("bag:closed", object)
                                                                                                                                                                                                                                                              end
                                                                                                                                                                                                                                                              end)
                                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                                        function pfUI.bag:UpdateBag(bag)
                                                                                                                                                                        local bagsize = GetBagSize(bag)
                                                                                                                                                                          for slot=1, bagsize do
                                                                                                                                                                            pfUI.bag:UpdateSlot(bag, slot)
                                                                                                                                                                            end
                                                                                                                                                                            end

                                                                                                                                                                            function pfUI.bag:UpdateSlot(bag, slot)
                                                                                                                                                                                                                                                            if not pfUI.bags[bag] then return end

                                                                                                                                                                                                                                                              if not pfUI.bags[bag].slots[slot] then
                                                                                                                                                                                                                                                                local tpl = "ContainerFrameItemButtonTemplate"
                                                                                                                                                                                                                                                                if bag == -1 then tpl = "BankItemButtonGenericTemplate" end
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot] = {}
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame = CreateFrame("Button", "pfBag" .. bag .. "item" .. slot,  pfUI.bags[bag], tpl)
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.qtext = pfUI.bags[bag].slots[slot].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.boetext = pfUI.bags[bag].slots[slot].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.itemLevelText = pfUI.bags[bag].slots[slot].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame:SetNormalTexture("")
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].bag = bag
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].slot = slot
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame:SetID(slot)

                                                                                                                                                                                                                                                                if tpl == "BankItemButtonGenericTemplate" then
                                                                                                                                                                                                                                                                local bankslot = pfUI.bags[bag].slots[slot].frame
                                                                                                                                                                                                                                                                local name = "pfBag" .. bag .. "item" .. slot .. "Cooldown"
                                                                                                                                                                                                                                                                bankslot.cd = CreateFrame(COOLDOWN_FRAME_TYPE, name, bankslot, "CooldownFrameTemplate")
                                                                                                                                                                                                                                                                bankslot.cd:SetAllPoints(bankslot)
                                                                                                                                                                                                                                                                bankslot.cd.pfCooldownStyleAnimation = 1
                                                                                                                                                                                                                                                                bankslot.cd.pfCooldownType = "ALL"
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                local bagslot = pfUI.bags[bag].slots[slot].frame
                                                                                                                                                                                                                                                                bagslot.cd = _G[bagslot:GetName().."Cooldown"]
                                                                                                                                                                                                                                                                bagslot.cd.pfCooldownType = "ALL"
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if not pfUI.bags[bag].slots[slot].frame.backdrop then
                                                                                                                                                                                                                                                                CreateBackdrop(pfUI.bags[bag].slots[slot].frame, default_border)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local glow = CreateFrame("Frame", nil, pfUI.bags[bag].slots[slot].frame)
                                                                                                                                                                                                                                                                glow:SetFrameLevel(pfUI.bags[bag].slots[slot].frame:GetFrameLevel() + 5)
                                                                                                                                                                                                                                                                glow:SetPoint("TOPLEFT", -3, 3)
                                                                                                                                                                                                                                                                glow:SetPoint("BOTTOMRIGHT", 3, -3)
                                                                                                                                                                                                                                                                glow:SetBackdrop({ edgeFile = pfUI.media["img:glow"], edgeSize = 6 })
                                                                                                                                                                                                                                                                glow:Hide()
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.rarityGlow = glow

                                                                                                                                                                                                                                                                local highlight = pfUI.bags[bag].slots[slot].frame:GetHighlightTexture()
                                                                                                                                                                                                                                                                highlight:SetTexture(.5, .5, .5, .5)

                                                                                                                                                                                                                                                                local pushed = pfUI.bags[bag].slots[slot].frame:GetPushedTexture()
                                                                                                                                                                                                                                                                pushed:SetTexture(.5, .5, .5, .5)

                                                                                                                                                                                                                                                                local questText = pfUI.bags[bag].slots[slot].frame.qtext
                                                                                                                                                                                                                                                                questText:SetFont(pfUI.font_default, 13, "THICKOUTLINE")
                                                                                                                                                                                                                                                                questText:SetPoint("TOPLEFT", 0, 0)
                                                                                                                                                                                                                                                                questText:SetTextColor(1, .8, .2, 1)

                                                                                                                                                                                                                                                                local boeText = pfUI.bags[bag].slots[slot].frame.boetext
                                                                                                                                                                                                                                                                boeText:SetFont(pfUI.font_default, 9, "THICKOUTLINE")
                                                                                                                                                                                                                                                                boeText:SetPoint("BOTTOMLEFT", 1, 1)
                                                                                                                                                                                                                                                                boeText:SetTextColor(.4, .8, 1, 1)

                                                                                                                                                                                                                                                                local itemLevelText = pfUI.bags[bag].slots[slot].frame.itemLevelText
                                                                                                                                                                                                                                                                itemLevelText:SetFont(pfUI.font_unit, math.max(8, C.global.font_unit_size - 1), "OUTLINE")
                                                                                                                                                                                                                                                                itemLevelText:SetPoint("TOPLEFT", 1, -1)
                                                                                                                                                                                                                                                                itemLevelText:SetJustifyH("LEFT")
                                                                                                                                                                                                                                                                itemLevelText:SetTextColor(1, 1, 1, 1)

                                                                                                                                                                                                                                                                local countFrame = _G[pfUI.bags[bag].slots[slot].frame:GetName() .. "Count"]
                                                                                                                                                                                                                                                                countFrame:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
                                                                                                                                                                                                                                                                countFrame:SetAllPoints()
                                                                                                                                                                                                                                                                countFrame:SetJustifyH("RIGHT")
                                                                                                                                                                                                                                                                countFrame:SetJustifyV("BOTTOM")

                                                                                                                                                                                                                                                                local icon = _G[pfUI.bags[bag].slots[slot].frame:GetName() .. "IconTexture"]
                                                                                                                                                                                                                                                                icon:SetTexCoord(.08, .92, .08, .92)
                                                                                                                                                                                                                                                                icon:ClearAllPoints()
                                                                                                                                                                                                                                                                icon:SetPoint("TOPLEFT", 1, -1)
                                                                                                                                                                                                                                                                icon:SetPoint("BOTTOMRIGHT", -1, 1)

                                                                                                                                                                                                                                                                local border = _G[pfUI.bags[bag].slots[slot].frame:GetName() .. "NormalTexture"]
                                                                                                                                                                                                                                                                border:SetTexture("")

                                                                                                                                                                                                                                                                if ShaguScore then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.scoreText = pfUI.bags[bag].slots[slot].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.scoreText:SetFont(pfUI.font_default, 12, "OUTLINE")
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.scoreText:SetPoint("TOPRIGHT", 0, 0)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local itemID = C_Container.GetContainerItemID(bag, slot)
                                                                                                                                                                                                                                                                local texture, count, locked, quality = GetContainerItemInfo(bag, slot)

                                                                                                                                                                                                                                                                if not itemID and texture then
                                                                                                                                                                                                                                                                local containerLink = GetContainerItemLink(bag, slot)
                                                                                                                                                                                                                                                                if containerLink then
                                                                                                                                                                                                                                                                itemID = tonumber(string.match(containerLink, "item:(%d+)"))
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if count == 1 then
                                                                                                                                                                                                                                                                local charges = C_Container.GetContainerItemCharges(bag, slot)
                                                                                                                                                                                                                                                                if charges > 1 then
                                                                                                                                                                                                                                                                count = charges
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local name, link, q, itemLevel, _, itype, subtype, _, equipSlot, _, _, _, _, bindType = C_Item.GetItemInfo(itemID)
                                                                                                                                                                                                                                                                -- Note: C_Item.GetItemInfoInstant does not return an item level (its
                                                                                                                                                                                                                                                                -- 4th return value is itemEquipLoc), so there is no "instant" level to
                                                                                                                                                                                                                                                                -- fall back to here. itemLevel simply stays nil until the item is
                                                                                                                                                                                                                                                                -- cached by GetItemInfo, at which point this refreshes on its own.
                                                                                                                                                                                                                                                                local detector = pfUI.api and pfUI.api.libitemdetect
                                                                                                                                                                                                                                                                local baseCategory
                                                                                                                                                                                                                                                                if not itemID then
                                                                                                                                                                                                                                                                baseCategory = "Empty"
                                                                                                                                                                                                                                                                elseif bag == -2 then
                                                                                                                                                                                                                                                                baseCategory = "Keyring"
                                                                                                                                                                                                                                                                elseif q == 0 then
                                                                                                                                                                                                                                                                baseCategory = "Junk"
                                                                                                                                                                                                                                                                elseif detector then
                                                                                                                                                                                                                                                                local success, detected = pcall(detector.GetCategory, detector, itemID)
                                                                                                                                                                                                                                                                baseCategory = success and detected or itype or "Miscellaneous"
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                baseCategory = itype or "Miscellaneous"
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                local bindCategory
                                                                                                                                                                                                                                                                if texture and (bindType == 2 or bindType == 3) and not C_Item.IsBound({ bagID = bag, slotIndex = slot }) then
                                                                                                                                                                                                                                                                bindCategory = (bindType == 2 and "BoE") or "BoU"
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                local itemText = GetItemSearchText(bag, slot) .. strlower(baseCategory or "")
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.baseCategory = baseCategory
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.category = ResolveCategory(itemText, baseCategory)
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.itemName = name or ""
                                                                                                                                                                                                                                                                local itemLevelText = pfUI.bags[bag].slots[slot].frame.itemLevelText
                                                                                                                                                                                                                                                                if itemLevelText then
                                                                                                                                                                                                                                                                local category = pfUI.bags[bag].slots[slot].frame.baseCategory
                                                                                                                                                                                                                                                                if itemID and itemLevel and (category == "Weapon" or category == "Armor" or category == "Trinket") then
                                                                                                                                                                                                                                                                itemLevelText:SetText(itemLevel)
                                                                                                                                                                                                                                                                local r, g, b = GetItemQualityColor(quality or q or 1)
                                                                                                                                                                                                                                                                itemLevelText:SetTextColor(r, g, b, 1)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                itemLevelText:SetText("")
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if C.appearance.bags.borderonlygear == "0" and texture and quality and quality < 1 then
                                                                                                                                                                                                                                                                if quality then quality = q end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                SetItemButtonTexture(pfUI.bags[bag].slots[slot].frame, texture)
                                                                                                                                                                                                                                                                SetItemButtonCount(pfUI.bags[bag].slots[slot].frame, count)
                                                                                                                                                                                                                                                                SetItemButtonDesaturated(pfUI.bags[bag].slots[slot].frame, locked, 0.5, 0.5, 0.5)

                                                                                                                                                                                                                                                                local hasItem = texture and 1 or nil
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.hasItem = hasItem
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.qtext:SetText("")

                                                                                                                                                                                                                                                                local rarityGlow = pfUI.bags[bag].slots[slot].frame.rarityGlow
                                                                                                                                                                                                                                                                if rarityGlow and C.appearance.bags.rarityglow == "1" and texture and quality and quality > 1 then
                                                                                                                                                                                                                                                                rarityGlow:SetBackdropBorderColor(GetItemQualityColor(quality))
                                                                                                                                                                                                                                                                rarityGlow:Show()
                                                                                                                                                                                                                                                                elseif rarityGlow then
                                                                                                                                                                                                                                                                rarityGlow:Hide()
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local bindLabel = ""
                                                                                                                                                                                                                                                                if texture and C.appearance.bags.showbind ~= "0" and (bindType == 2 or bindType == 3) then
                                                                                                                                                                                                                                                                bindLabel = bindCategory or ""
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.boetext:SetText(bindLabel)
                                                                                                                                                                                                                                                                if bindLabel ~= "" then
                                                                                                                                                                                                                                                                local qr, qg, qb = GetItemQualityColor(quality or 1)
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.boetext:SetTextColor(qr, qg, qb, 1)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                ContainerFrame_UpdateCooldown(bag, pfUI.bags[bag].slots[slot].frame)

                                                                                                                                                                                                                                                                if texture and itype == "Quest" then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(1, .8, .2, .8)
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.qtext:SetText("?")
                                                                                                                                                                                                                                                                elseif texture and quality and quality > tonumber(C.appearance.bags.borderlimit) then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
                                                                                                                                                                                                                                                                elseif texture and quality then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(.5,.5,.5,1)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                local bagtype = GetBagFamily(bag)

                                                                                                                                                                                                                                                                if bagtype == "QUIVER" then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(1,1,.5,.5)
                                                                                                                                                                                                                                                                elseif bagtype == "SOULBAG" then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(1,.5,.5,.5)
                                                                                                                                                                                                                                                                elseif bagtype == "SPECIAL" then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(.5,.5,1,.5)
                                                                                                                                                                                                                                                                elseif bagtype == "KEYRING" then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(.5,1,1,.5)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(1,1,1,.2)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if ShaguScore and pfUI.bags[bag].slots[slot].frame.scoreText then
                                                                                                                                                                                                                                                                if quality and quality > 0 then
                                                                                                                                                                                                                                                                local item = Item:CreateFromBagAndSlot(bag, slot)
                                                                                                                                                                                                                                                                local r,g,b = item:GetItemQualityColorRGB()
                                                                                                                                                                                                                                                                local itemID = item:GetItemID()
                                                                                                                                                                                                                                                                local itemLevel = ShaguScore.Database[itemID] or 0
                                                                                                                                                                                                                                                                local score = ShaguScore:Calculate(vslot, quality, itemLevel)
                                                                                                                                                                                                                                                                if score and score > 0 and count and count == 1 then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.scoreText:SetText(score)
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.scoreText:SetTextColor(r, g, b)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.scoreText:SetText("")
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame.scoreText:SetText("")
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if q == 0 then
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame:SetAlpha(0.5)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame:SetAlpha(1)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].frame:Show()
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function pfUI.bag:CreateBagSlots(frame)
                                                                                                                                                                                                                                                                if not frame.bagslots then
                                                                                                                                                                                                                                                                frame.bagslots = CreateFrame("Frame", "pfBagSlots", frame)
                                                                                                                                                                                                                                                                frame.bagslots.slots = {}
                                                                                                                                                                                                                                                                frame.bagslots:Hide()
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local min, max = 0, 3
                                                                                                                                                                                                                                                                local tpl = "BagSlotButtonTemplate"
                                                                                                                                                                                                                                                                local name, append = "pfUIBagsBBag", "Slot"
                                                                                                                                                                                                                                                                local position = "RIGHT"

                                                                                                                                                                                                                                                                if frame == pfUI.bag.left then
                                                                                                                                                                                                                                                                min, max = 1, math.min(NUM_BANKBAGSLOTS, (GetNumBankSlots() or 0))
                                                                                                                                                                                                                                                                tpl = "BankItemButtonBagTemplate"
                                                                                                                                                                                                                                                                name, append = "pfUIBankBBag", ""
                                                                                                                                                                                                                                                                position = "LEFT"
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                frame.bagslots:SetPoint("BOTTOM"..position, frame, "TOP"..position, 0, default_border*3)
                                                                                                                                                                                                                                                                CreateBackdrop(frame.bagslots, default_border)
                                                                                                                                                                                                                                                                CreateBackdropShadow(frame.bagslots)

                                                                                                                                                                                                                                                                local extra = frame == pfUI.bag.left and GetNumBankSlots() < NUM_BANKBAGSLOTS and 1 or 0
                                                                                                                                                                                                                                                                local width = (frame.button_size/5*4 + default_border*2) * (max-min+1+extra)
                                                                                                                                                                                                                                                                local height = default_border + (frame.button_size/5*4 + default_border)

                                                                                                                                                                                                                                                                frame.bagslots:SetSize(width, height)
                                                                                                                                                                                                                                                                for slot=min, max do
                                                                                                                                                                                                                                                                if not frame.bagslots.slots[slot] then
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot] = {}
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame = CreateFrame("CheckButton", name .. slot .. append, frame.bagslots, tpl)

                                                                                                                                                                                                                                                                local icon = _G[frame.bagslots.slots[slot].frame:GetName() .. "IconTexture"]
                                                                                                                                                                                                                                                                local border = _G[frame.bagslots.slots[slot].frame:GetName() .. "NormalTexture"]
                                                                                                                                                                                                                                                                icon:SetTexCoord(.08, .92, .08, .92)
                                                                                                                                                                                                                                                                icon:ClearAllPoints()
                                                                                                                                                                                                                                                                icon:SetPoint("TOPLEFT", 1, -1)
                                                                                                                                                                                                                                                                icon:SetPoint("BOTTOMRIGHT", -1, 1)
                                                                                                                                                                                                                                                                border:SetTexture("")

                                                                                                                                                                                                                                                                local highlight = frame.bagslots.slots[slot].frame:GetHighlightTexture()
                                                                                                                                                                                                                                                                highlight:SetTexture(.5, .5, .5, .5)

                                                                                                                                                                                                                                                                local pushed = frame.bagslots.slots[slot].frame:GetPushedTexture()
                                                                                                                                                                                                                                                                pushed:SetTexture(.5, .5, .5, .5)

                                                                                                                                                                                                                                                                if frame == pfUI.bag.left then
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame:SetID(slot + 4)
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame.slot = slot + 3
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame.slot = slot
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].slot = slot
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local SlotEnter = frame.bagslots.slots[slot].frame:GetScript("OnEnter")
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame:SetScript("OnEnter", function()
                                                                                                                                                                                                                                                                for slot, f in ipairs(pfUI.bags[this.slot + 1].slots) do
                                                                                                                                                                                                                                                                CreateBackdrop(f.frame, default_border)
                                                                                                                                                                                                                                                                f.frame.backdrop:SetBackdropBorderColor(pfUI.cr, pfUI.cg, pfUI.cb,1)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                SlotEnter(this)
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                local SlotLeave = frame.bagslots.slots[slot].frame:GetScript("OnLeave")
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame:SetScript("OnLeave", function()
                                                                                                                                                                                                                                                                pfUI.bag:UpdateBag(this.slot + 1)
                                                                                                                                                                                                                                                                SlotLeave()
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                if frame == pfUI.bag.left and BankFrameItemButton_Update then
                                                                                                                                                                                                                                                                local SlotUpdate = frame.bagslots.slots[slot].frame:GetScript("OnUpdate")
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame:SetScript("OnUpdate", function()
                                                                                                                                                                                                                                                                if SlotUpdate then SlotUpdate(this) end
                                                                                                                                                                                                                                                                BankFrameItemButton_Update(this)
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local left = (slot-min)*(frame.button_size/5*4+default_border*2) + default_border
                                                                                                                                                                                                                                                                local top = -default_border

                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame:ClearAllPoints()
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame:SetPoint("TOPLEFT", frame.bagslots, "TOPLEFT", left, top)
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame:SetSize(frame.button_size/5*4, frame.button_size/5*4)

                                                                                                                                                                                                                                                                CreateBackdrop(frame.bagslots.slots[slot].frame, default_border)
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame:Show()

                                                                                                                                                                                                                                                                if ( slot <= GetNumBankSlots() ) then
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame.tooltipText = BANK_BAG
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                frame.bagslots.slots[slot].frame.tooltipText = BANK_BAG_PURCHASE
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if frame == pfUI.bag.left then
                                                                                                                                                                                                                                                                if GetNumBankSlots() < NUM_BANKBAGSLOTS then
                                                                                                                                                                                                                                                                if not frame.bagslots.buy then
                                                                                                                                                                                                                                                                frame.bagslots.buy = CreateFrame("Button", "pfBagSlotBuy", frame.bagslots)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetPoint("RIGHT", frame.bagslots, "RIGHT", -default_border, 0)
                                                                                                                                                                                                                                                                CreateBackdrop(frame.bagslots.buy, default_border)
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetSize(frame.button_size/5*4, frame.button_size/5*4)
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetText("+")
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetTextColor(.5,.5,1,1)
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetScript("OnEnter", function ()
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetTextColor(1,1,1,1)
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetScript("OnLeave", function ()
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetTextColor(.5,.5,1,1)
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                frame.bagslots.buy:SetScript("OnClick", function()
                                                                                                                                                                                                                                                                StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                if frame.bagslots.buy then frame.bagslots.buy:Hide() end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function pfUI.bag:ReanchorAdditions()
                                                                                                                                                                                                                                                                local frame = pfUI.bag.right
                                                                                                                                                                                                                                                                if not frame then return end
                                                                                                                                                                                                                                                                local show_disenchant = frame.disenchant and (frame.disenchant:GetID() > 0)
                                                                                                                                                                                                                                                                local show_picklock = frame.picklock and (frame.picklock:GetID() > 0)

                                                                                                                                                                                                                                                                if frame.disenchant then
                                                                                                                                                                                                                                                                if not show_disenchant then
                                                                                                                                                                                                                                                                frame.disenchant:Hide()
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                frame.disenchant:Show()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if frame.picklock then
                                                                                                                                                                                                                                                                if not show_picklock then
                                                                                                                                                                                                                                                                frame.picklock:Hide()
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                frame.picklock:Show()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                ArrangeHeader(frame)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function pfUI.bag:UpdateGoldVisibility()
                                                                                                                                                                                                                                                                local hide = C.appearance.bags.hidegold == "1"
                                                                                                                                                                                                                                                                for _, frame in pairs({ pfUI.bag.left, pfUI.bag.right }) do
                                                                                                                                                                                                                                                                if frame and frame.gold then
                                                                                                                                                                                                                                                                if hide then frame.gold:Hide() else frame.gold:Show() end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function pfUI.bag:UpdateCooldowns()
                                                                                                                                                                                                                                                                local frame
                                                                                                                                                                                                                                                                for bag=-2, 11 do
                                                                                                                                                                                                                                                                local bagsize = GetBagSize(bag)
                                                                                                                                                                                                                                                                for slot=1, bagsize do
                                                                                                                                                                                                                                                                frame = pfUI.bags[bag] and pfUI.bags[bag].slots[slot] and pfUI.bags[bag].slots[slot].frame
                                                                                                                                                                                                                                                                if frame and frame.hasItem and _G[frame:GetName() .. "Cooldown"] then
                                                                                                                                                                                                                                                                ContainerFrame_UpdateCooldown(bag, frame)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function pfUI.bag:UpdateItemLock()
                                                                                                                                                                                                                                                                for bag=-2, 11 do
                                                                                                                                                                                                                                                                local bagsize = GetBagSize(bag)
                                                                                                                                                                                                                                                                for slot=1, bagsize do
                                                                                                                                                                                                                                                                if pfUI.bags[bag] and pfUI.bags[bag].slots[slot] and pfUI.bags[bag].slots[slot].frame:IsShown() then
                                                                                                                                                                                                                                                                local _, _, locked, _ = GetContainerItemInfo(bag, slot)
                                                                                                                                                                                                                                                                if pfUI.bags[bag].slots[slot].locked ~= locked then
                                                                                                                                                                                                                                                                SetItemButtonDesaturated(pfUI.bags[bag].slots[slot].frame, locked, 0.5, 0.5, 0.5)
                                                                                                                                                                                                                                                                if pfUI.unusable then pfUI.unusable:UpdateSlot(bag, slot) end
                                                                                                                                                                                                                                                                pfUI.bags[bag].slots[slot].locked = locked
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function pfUI.bag:RefreshSpells()
                                                                                                                                                                                                                                                                if not (pfUI.bag and pfUI.bag.right) then return end
                                                                                                                                                                                                                                                                for spellID, widget in pairs(extractSpells) do
                                                                                                                                                                                                                                                                if IsSpellKnown(spellID) and pfUI.bag.right[widget.frame] then
                                                                                                                                                                                                                                                                pfUI.bag.right[widget.frame]:SetID(spellID)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                pfUI.bag:ReanchorAdditions()
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function pfUI.bag:CreateAdditions(frame)
                                                                                                                                                                                                                                                                local bankframe = (frame == pfUI.bag.left)
                                                                                                                                                                                                                                                                if frame == pfUI.bag.right or frame == pfUI.bag.left then
                                                                                                                                                                                                                                                                -- bag close button
                                                                                                                                                                                                                                                                if not frame.close then
                                                                                                                                                                                                                                                                frame.close = CreateFrame("Button", bankframe and "pfBankClose" or "pfBagClose", frame)
                                                                                                                                                                                                                                                                frame.close:SetPoint("TOPRIGHT", -default_border*1, -default_border)
                                                                                                                                                                                                                                                                CreateBackdrop(frame.close, default_border)
                                                                                                                                                                                                                                                                frame.close:SetSize(12, 12)
                                                                                                                                                                                                                                                                frame.close.texture = frame.close:CreateTexture(bankframe and "pfBankClose" or "pfBagClose")
                                                                                                                                                                                                                                                                frame.close.texture:SetTexture(pfUI.media["img:close"])
                                                                                                                                                                                                                                                                frame.close.texture:ClearAllPoints()
                                                                                                                                                                                                                                                                frame.close.texture:SetPoint("TOPLEFT", frame.close, "TOPLEFT", 2, -2)
                                                                                                                                                                                                                                                                frame.close.texture:SetPoint("BOTTOMRIGHT", frame.close, "BOTTOMRIGHT", -2, 2)
                                                                                                                                                                                                                                                                frame.close.texture:SetVertexColor(1,.25,.25,1)
                                                                                                                                                                                                                                                                frame.close:SetScript("OnEnter", function ()
                                                                                                                                                                                                                                                                frame.close.backdrop:SetBackdropBorderColor(1,.25,.25,1)
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.close:SetScript("OnLeave", function ()
                                                                                                                                                                                                                                                                CreateBackdrop(frame.close, default_border)
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.close:SetScript("OnClick", function()
                                                                                                                                                                                                                                                                if bankframe then
                                                                                                                                                                                                                                                                CloseBankFrame()
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                CloseAllBags()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- bags button
                                                                                                                                                                                                                                                                if not frame.bags then
                                                                                                                                                                                                                                                                frame.bags = CreateFrame("Button", bankframe and "pfBankSlotShow" or "pfBagSlotShow", frame)
                                                                                                                                                                                                                                                                frame.bags:SetPoint("TOPRIGHT", frame.close, "TOPLEFT", -default_border*3, 0)
                                                                                                                                                                                                                                                                CreateBackdrop(frame.bags, default_border)
                                                                                                                                                                                                                                                                frame.bags:SetSize(12, 12)
                                                                                                                                                                                                                                                                frame.bags:SetTextColor(1,1,.25,1)
                                                                                                                                                                                                                                                                frame.bags:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                                                                                                                                                                                                                                frame.bags.texture = frame.bags:CreateTexture(bankframe and "pfBankArrowUp" or "pfBagArrowUp")
                                                                                                                                                                                                                                                                frame.bags.texture:SetTexture(pfUI.media["img:up"])
                                                                                                                                                                                                                                                                frame.bags.texture:ClearAllPoints()
                                                                                                                                                                                                                                                                frame.bags.texture:SetPoint("TOPLEFT", frame.bags, "TOPLEFT", 3, -1)
                                                                                                                                                                                                                                                                frame.bags.texture:SetPoint("BOTTOMRIGHT", frame.bags, "BOTTOMRIGHT", -3, 1)
                                                                                                                                                                                                                                                                frame.bags.texture:SetVertexColor(.25,.25,.25,1)

                                                                                                                                                                                                                                                                frame.bags:SetScript("OnEnter", function ()
                                                                                                                                                                                                                                                                frame.bags.backdrop:SetBackdropBorderColor(1,1,.25,1)
                                                                                                                                                                                                                                                                frame.bags.texture:SetVertexColor(1,1,.25,1)
                                                                                                                                                                                                                                                                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                                                                                                                                                                                                                                                GameTooltip:SetText(_G.TUTORIAL_TITLE10)
                                                                                                                                                                                                                                                                GameTooltip:Show()
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.bags:SetScript("OnLeave", function ()
                                                                                                                                                                                                                                                                CreateBackdrop(frame.bags, default_border)
                                                                                                                                                                                                                                                                frame.bags.texture:SetVertexColor(.25,.25,.25,1)
                                                                                                                                                                                                                                                                if GameTooltip:IsOwned(this) then
                                                                                                                                                                                                                                                                GameTooltip:Hide()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.bags:SetScript("OnClick", function()
                                                                                                                                                                                                                                                                if frame.bagslots then frame.bagslots:SetShown(not frame.bagslots:IsShown()) end
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if frame == pfUI.bag.right then
                                                                                                                                                                                                                                                                -- disenchant button
                                                                                                                                                                                                                                                                if not frame.disenchant then
                                                                                                                                                                                                                                                                frame.disenchant = CreateFrame("Button", "pfBagSlotDisenchant", frame)
                                                                                                                                                                                                                                                                frame.disenchant:SetPoint("TOPRIGHT", frame.bags, "TOPLEFT", -default_border*3, 0)
                                                                                                                                                                                                                                                                CreateBackdrop(frame.disenchant, default_border)
                                                                                                                                                                                                                                                                frame.disenchant:SetSize(12, 12)
                                                                                                                                                                                                                                                                frame.disenchant:SetTextColor(1,1,.25,1)
                                                                                                                                                                                                                                                                frame.disenchant:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                                                                                                                                                                                                                                frame.disenchant.texture = frame.disenchant:CreateTexture("pfBagDisenchant")
                                                                                                                                                                                                                                                                frame.disenchant.texture:SetTexture(pfUI.media["img:disenchant"])
                                                                                                                                                                                                                                                                frame.disenchant.texture:ClearAllPoints()
                                                                                                                                                                                                                                                                frame.disenchant.texture:SetPoint("TOPLEFT", frame.disenchant, "TOPLEFT", 3, -1)
                                                                                                                                                                                                                                                                frame.disenchant.texture:SetPoint("BOTTOMRIGHT", frame.disenchant, "BOTTOMRIGHT", -3, 1)
                                                                                                                                                                                                                                                                frame.disenchant.texture:SetVertexColor(.25,.25,.25,1)

                                                                                                                                                                                                                                                                frame.disenchant:SetScript("OnEnter", function ()
                                                                                                                                                                                                                                                                frame.disenchant.backdrop:SetBackdropBorderColor(1,1,.25,1)
                                                                                                                                                                                                                                                                frame.disenchant.texture:SetVertexColor(1,1,.25,1)
                                                                                                                                                                                                                                                                local id = this:GetID()
                                                                                                                                                                                                                                                                if id and id > 0 then
                                                                                                                                                                                                                                                                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                                                                                                                                                                                                                                                GameTooltip:SetSpellByID(id)
                                                                                                                                                                                                                                                                GameTooltip:Show()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.disenchant:SetScript("OnLeave", function ()
                                                                                                                                                                                                                                                                CreateBackdrop(frame.disenchant, default_border)
                                                                                                                                                                                                                                                                frame.disenchant.texture:SetVertexColor(.25,.25,.25,1)
                                                                                                                                                                                                                                                                if GameTooltip:IsOwned(this) then
                                                                                                                                                                                                                                                                GameTooltip:Hide()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.disenchant:SetScript("OnClick", function()
                                                                                                                                                                                                                                                                local id = this:GetID()
                                                                                                                                                                                                                                                                if id and id > 0 then
                                                                                                                                                                                                                                                                CastSpellByName(id)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- pick lock button
                                                                                                                                                                                                                                                                if not frame.picklock then
                                                                                                                                                                                                                                                                frame.picklock = CreateFrame("Button", "pfBagSlotPicklock", frame)
                                                                                                                                                                                                                                                                frame.picklock:SetPoint("TOPRIGHT", frame.disenchant, "TOPLEFT", -default_border*3, 0)
                                                                                                                                                                                                                                                                CreateBackdrop(frame.picklock, default_border)
                                                                                                                                                                                                                                                                frame.picklock:SetSize(12, 12)
                                                                                                                                                                                                                                                                frame.picklock:SetTextColor(1,1,.25,1)
                                                                                                                                                                                                                                                                frame.picklock:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                                                                                                                                                                                                                                frame.picklock.texture = frame.picklock:CreateTexture("pfBagPicklock")
                                                                                                                                                                                                                                                                frame.picklock.texture:SetTexture(pfUI.media["img:picklock"])
                                                                                                                                                                                                                                                                frame.picklock.texture:ClearAllPoints()
                                                                                                                                                                                                                                                                frame.picklock.texture:SetPoint("TOPLEFT", frame.picklock, "TOPLEFT", 3, -1)
                                                                                                                                                                                                                                                                frame.picklock.texture:SetPoint("BOTTOMRIGHT", frame.picklock, "BOTTOMRIGHT", -3, 1)
                                                                                                                                                                                                                                                                frame.picklock.texture:SetVertexColor(.25,.25,.25,1)

                                                                                                                                                                                                                                                                frame.picklock:SetScript("OnEnter", function ()
                                                                                                                                                                                                                                                                frame.picklock.backdrop:SetBackdropBorderColor(1,1,.25,1)
                                                                                                                                                                                                                                                                frame.picklock.texture:SetVertexColor(1,1,.25,1)
                                                                                                                                                                                                                                                                local id = this:GetID()
                                                                                                                                                                                                                                                                if id and id > 0 then
                                                                                                                                                                                                                                                                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                                                                                                                                                                                                                                                GameTooltip:SetSpellByID(id)
                                                                                                                                                                                                                                                                GameTooltip:Show()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.picklock:SetScript("OnLeave", function ()
                                                                                                                                                                                                                                                                CreateBackdrop(frame.picklock, default_border)
                                                                                                                                                                                                                                                                frame.picklock.texture:SetVertexColor(.25,.25,.25,1)
                                                                                                                                                                                                                                                                if GameTooltip:IsOwned(this) then
                                                                                                                                                                                                                                                                GameTooltip:Hide()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.picklock:SetScript("OnClick", function()
                                                                                                                                                                                                                                                                local id = this:GetID()
                                                                                                                                                                                                                                                                if id and id > 0 then
                                                                                                                                                                                                                                                                CastSpellByName(id)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- key button
                                                                                                                                                                                                                                                                if not frame.keys then
                                                                                                                                                                                                                                                                frame.keys = CreateFrame("Button", "pfBagSlotShow", frame)
                                                                                                                                                                                                                                                                frame.keys:SetPoint("TOPRIGHT", frame.picklock, "TOPLEFT", -default_border*3, 0)
                                                                                                                                                                                                                                                                CreateBackdrop(frame.keys, default_border)
                                                                                                                                                                                                                                                                frame.keys:SetSize(12, 12)
                                                                                                                                                                                                                                                                frame.keys:SetTextColor(1,1,.25,1)
                                                                                                                                                                                                                                                                frame.keys:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                                                                                                                                                                                                                                frame.keys.texture = frame.keys:CreateTexture("pfBagArrowUp")
                                                                                                                                                                                                                                                                frame.keys.texture:SetTexture(pfUI.media["img:key"])
                                                                                                                                                                                                                                                                frame.keys.texture:ClearAllPoints()
                                                                                                                                                                                                                                                                frame.keys.texture:SetPoint("TOPLEFT", frame.keys, "TOPLEFT", 3, -1)
                                                                                                                                                                                                                                                                frame.keys.texture:SetPoint("BOTTOMRIGHT", frame.keys, "BOTTOMRIGHT", -3, 1)
                                                                                                                                                                                                                                                                frame.keys.texture:SetVertexColor(.25,.25,.25,1)

                                                                                                                                                                                                                                                                frame.keys:SetScript("OnEnter", function ()
                                                                                                                                                                                                                                                                frame.keys.backdrop:SetBackdropBorderColor(1,1,.25,1)
                                                                                                                                                                                                                                                                frame.keys.texture:SetVertexColor(1,1,.25,1)
                                                                                                                                                                                                                                                                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                                                                                                                                                                                                                                                GameTooltip:SetText(_G.KEYRING)
                                                                                                                                                                                                                                                                GameTooltip:Show()
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.keys:SetScript("OnLeave", function ()
                                                                                                                                                                                                                                                                CreateBackdrop(frame.keys, default_border)
                                                                                                                                                                                                                                                                frame.keys.texture:SetVertexColor(.25,.25,.25,1)
                                                                                                                                                                                                                                                                if GameTooltip:IsOwned(this) then
                                                                                                                                                                                                                                                                GameTooltip:Hide()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.keys:SetScript("OnClick", function()
                                                                                                                                                                                                                                                                if not pfUI.bag.showKeyring then
                                                                                                                                                                                                                                                                pfUI.bag.showKeyring = true
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                pfUI.bag.showKeyring = nil
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                pfUI.bag:CheckFullUpdate()
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- sort button
                                                                                                                                                                                                                                                                if not frame.sort then
                                                                                                                                                                                                                                                                frame.sort = CreateFrame("Button", "pfBagSort", frame)
                                                                                                                                                                                                                                                                frame.sort:SetPoint("TOPRIGHT", frame.keys, "TOPLEFT", -default_border*3, 0)
                                                                                                                                                                                                                                                                CreateBackdrop(frame.sort, default_border)
                                                                                                                                                                                                                                                                frame.sort:SetSize(12, 12)
                                                                                                                                                                                                                                                                frame.sort.texture = frame.sort:CreateTexture("pfBagSortIcon")
                                                                                                                                                                                                                                                                frame.sort.texture:SetTexture(pfUI.media["img:sort"])
                                                                                                                                                                                                                                                                frame.sort.texture:ClearAllPoints()
                                                                                                                                                                                                                                                                frame.sort.texture:SetPoint("TOPLEFT", frame.sort, "TOPLEFT", 2, -2)
                                                                                                                                                                                                                                                                frame.sort.texture:SetPoint("BOTTOMRIGHT", frame.sort, "BOTTOMRIGHT", -2, 2)
                                                                                                                                                                                                                                                                frame.sort.texture:SetVertexColor(.25,.25,.25,1)

                                                                                                                                                                                                                                                                frame.sort:SetScript("OnEnter", function ()
                                                                                                                                                                                                                                                                frame.sort.backdrop:SetBackdropBorderColor(1,1,.25,1)
                                                                                                                                                                                                                                                                frame.sort.texture:SetVertexColor(1,1,.25,1)
                                                                                                                                                                                                                                                                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                                                                                                                                                                                                                                                GameTooltip:SetText(C.appearance.bags[CategoryViewKey(frame)] == "1"
                                                                                                                                                                                                                                                                and (T["Group Empty Slots"] or "Group Empty Slots")
                                                                                                                                                                                                                                                                or T["Sort Bags"])
                                                                                                                                                                                                                                                                GameTooltip:Show()
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.sort:SetScript("OnLeave", function ()
                                                                                                                                                                                                                                                                CreateBackdrop(frame.sort, default_border)
                                                                                                                                                                                                                                                                frame.sort.texture:SetVertexColor(.25,.25,.25,1)
                                                                                                                                                                                                                                                                if GameTooltip:IsOwned(this) then
                                                                                                                                                                                                                                                                GameTooltip:Hide()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.sort:SetScript("OnClick", function()
                                                                                                                                                                                                                                                                if C.appearance.bags[CategoryViewKey(frame)] == "1" then
                                                                                                                                                                                                                                                                C.appearance.bags.groupempty = C.appearance.bags.groupempty == "1" and "0" or "1"
                                                                                                                                                                                                                                                                pfUI.bag:CreateBags()
                                                                                                                                                                                                                                                                pfUI.bag:CreateBags("bank")
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                libbagsort:Sort({0, 1, 2, 3, 4}, BagSortOpts())
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if frame == pfUI.bag.right or frame == pfUI.bag.left then
                                                                                                                                                                                                                                                                -- category view button
                                                                                                                                                                                                                                                                if not frame.emptyGroup then
                                                                                                                                                                                                                                                                frame.emptyGroup = CreateFrame("Button", bankframe and "pfBankEmptyGroup" or "pfBagEmptyGroup", frame)
                                                                                                                                                                                                                                                                frame.emptyGroup:SetPoint("TOPRIGHT", frame.sort or frame.bags, "TOPLEFT", -default_border*3, 0)
                                                                                                                                                                                                                                                                CreateBackdrop(frame.emptyGroup, default_border)
                                                                                                                                                                                                                                                                frame.emptyGroup:SetSize(12, 12)
                                                                                                                                                                                                                                                                frame.emptyGroup:SetText("C")
                                                                                                                                                                                                                                                                frame.emptyGroup:SetFont(pfUI.font_default, 9, "OUTLINE")
                                                                                                                                                                                                                                                                frame.emptyGroup:SetScript("OnClick", function()
                                                                                                                                                                                                                                                                C.appearance.bags[CategoryViewKey(frame)] = C.appearance.bags[CategoryViewKey(frame)] == "1" and "0" or "1"
                                                                                                                                                                                                                                                                pfUI.bag:CreateBags()
                                                                                                                                                                                                                                                                pfUI.bag:CreateBags("bank")
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                frame.emptyGroup:SetScript("OnEnter", function()
                                                                                                                                                                                                                                                                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                                                                                                                                                                                                                                                                GameTooltip:SetText(T["Category View"] or "Category View")
                                                                                                                                                                                                                                                                GameTooltip:Show()
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                frame.emptyGroup:SetScript("OnLeave", function()
                                                                                                                                                                                                                                                                if GameTooltip:IsOwned(this) then GameTooltip:Hide() end
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                CreateEmptyOptionsButton(frame)

                                                                                                                                                                                                                                                                -- gold string
                                                                                                                                                                                                                                                                if not frame.gold and (C.appearance.bags.movable == "1" or not pfUI.panel) then
                                                                                                                                                                                                                                                                frame.gold = CreateFrame("Frame", "pfBagGoldString", frame)
                                                                                                                                                                                                                                                                frame.gold:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 1)
                                                                                                                                                                                                                                                                frame.gold:SetSize(200, 18)
                                                                                                                                                                                                                                                                frame.gold:RegisterEvent("PLAYER_ENTERING_WORLD")
                                                                                                                                                                                                                                                                frame.gold:RegisterEvent("PLAYER_MONEY")
                                                                                                                                                                                                                                                                frame.gold:SetScript("OnEvent", function()
                                                                                                                                                                                                                                                                frame.gold.text:SetText(CreateGoldString(GetMoney()))
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.gold.text = frame.gold.text or frame.gold:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                                                                                                                                                                                                                                                frame.gold.text:SetFontObject(GameFontWhite)
                                                                                                                                                                                                                                                                frame.gold.text:SetJustifyH("RIGHT")
                                                                                                                                                                                                                                                                frame.gold.text:SetAllPoints()
                                                                                                                                                                                                                                                                pfUI.bag:UpdateGoldVisibility()
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- bag search
                                                                                                                                                                                                                                                                if not frame.search then
                                                                                                                                                                                                                                                                frame.search = CreateFrame("Frame", bankframe and "pfBankSearch" or "pfBagSearch", frame)
                                                                                                                                                                                                                                                                frame.search.db = {}
                                                                                                                                                                                                                                                                frame.search:SetHeight(18)
                                                                                                                                                                                                                                                                frame.search:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", default_border*2, -default_border)
                                                                                                                                                                                                                                                                frame.search:SetPoint("TOPRIGHT", frame.header, "BOTTOMRIGHT", -default_border*2, -default_border)
                                                                                                                                                                                                                                                                frame.search.noBorder = true
                                                                                                                                                                                                                                                                CreateBackdrop(frame.search, default_border)

                                                                                                                                                                                                                                                                frame:HookScript("OnMouseDown", function()
                                                                                                                                                                                                                                                                frame.search.edit:ClearFocus()
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.search:RegisterEvent("GLOBAL_MOUSE_DOWN")
                                                                                                                                                                                                                                                                frame.search:SetScript("OnEvent", function()
                                                                                                                                                                                                                                                                local focus = GetMouseFocus()
                                                                                                                                                                                                                                                                while focus do
                                                                                                                                                                                                                                                                if focus == frame then return end
                                                                                                                                                                                                                                                                focus = focus:GetParent()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                frame.search.edit:ClearFocus()
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                local searchEditName = bankframe and "pfUIBankSearch" or "pfUIBagSearch"
                                                                                                                                                                                                                                                                frame.search.edit = CreateFrame("EditBox", searchEditName, frame.search, "InputBoxTemplate")
                                                                                                                                                                                                                                                                _G[searchEditName.."Left"]:SetTexture(nil)
                                                                                                                                                                                                                                                                _G[searchEditName.."Middle"]:SetTexture(nil)
                                                                                                                                                                                                                                                                _G[searchEditName.."Right"]:SetTexture(nil)
                                                                                                                                                                                                                                                                frame.search.edit:ClearAllPoints()
                                                                                                                                                                                                                                                                frame.search.edit:SetPoint("TOPLEFT", frame.search, "TOPLEFT", default_border*2, 0)
                                                                                                                                                                                                                                                                frame.search.edit:SetPoint("BOTTOMRIGHT", frame.search, "BOTTOMRIGHT", -default_border*2, 0)

                                                                                                                                                                                                                                                                frame.search.edit:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                                                                                                                                                                                                                                frame.search.edit:SetAutoFocus(false)
                                                                                                                                                                                                                                                                frame.search.edit:SetText(T["Search"])
                                                                                                                                                                                                                                                                frame.search.edit:SetTextColor(.5,.5,.5,1)

                                                                                                                                                                                                                                                                frame.search.edit:SetScript("OnTextChanged", function()
                                                                                                                                                                                                                                                                local text = strlower(this:GetText() or "")
                                                                                                                                                                                                                                                                if text == "" or text == strlower(T["Search"]) then
                                                                                                                                                                                                                                                                for bag = -2, 11 do
                                                                                                                                                                                                                                                                if pfUI.bags[bag] then
                                                                                                                                                                                                                                                                for slot, entry in pairs(pfUI.bags[bag].slots) do
                                                                                                                                                                                                                                                                if entry.frame then
                                                                                                                                                                                                                                                                entry.frame:SetAlpha(1)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                for bag = -2, 11 do
                                                                                                                                                                                                                                                                if pfUI.bags[bag] then
                                                                                                                                                                                                                                                                for slot, entry in pairs(pfUI.bags[bag].slots) do
                                                                                                                                                                                                                                                                if entry.frame then
                                                                                                                                                                                                                                                                local itemText = GetItemSearchText(bag, slot)
                                                                                                                                                                                                                                                                if strfind(itemText, text, 1, true) then
                                                                                                                                                                                                                                                                entry.frame:SetAlpha(1)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                entry.frame:SetAlpha(0.2)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.search.edit:SetScript("OnEditFocusGained", function()
                                                                                                                                                                                                                                                                if this:GetText() == T["Search"] then
                                                                                                                                                                                                                                                                this:SetText("")
                                                                                                                                                                                                                                                                this:SetTextColor(1, 1, 1, 1)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.search.edit:SetScript("OnEditFocusLost", function()
                                                                                                                                                                                                                                                                if this:GetText() == "" then
                                                                                                                                                                                                                                                                this:SetText(T["Search"])
                                                                                                                                                                                                                                                                this:SetTextColor(.5, .5, .5, 1)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.search.edit:SetScript("OnEscapePressed", function()
                                                                                                                                                                                                                                                                this:ClearFocus()
                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                frame.search.edit:SetScript("OnEnterPressed", function()
                                                                                                                                                                                                                                                                this:ClearFocus()
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)
