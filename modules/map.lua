pfUI:RegisterModule("map", function ()
table.insert(UISpecialFrames, "WorldMapFrame")

local function UpdateTooltipScale()
local tooltipscale = tonumber(C.appearance.worldmap.tooltipsize)
local scale = WorldMapFrame:GetScale()

if tooltipscale > 0 then
  WorldMapTooltip:SetScale(tooltipscale/scale)
  else
    WorldMapTooltip:SetScale(1)
    end
    end

    ----------------------------------------------------------------------
    -- State & Forward Declarations
    ----------------------------------------------------------------------

    local mapZoom = 1
    local mapCenterX, mapCenterY
    local mapWidth, mapHeight
    local pinClipTicker
    local pfPlayerArrow

    local function GetValidChildren(frame)
    if not frame or not frame.GetChildren then return {} end
      local res = { pcall(frame.GetChildren, frame) }
      if not res[1] then return {} end

        local valid = {}
        for i = 2, table.getn(res) do
          local child = res[i]
          if child and type(child) == "table" and child.IsObjectType then
            table.insert(valid, child)
            end
            end
            return valid
            end

            local function UpdateHitRect()
            if not mapWidth or not WorldMapButton.zoomClip then return end
              local cl = WorldMapButton.zoomClip:GetLeft()
              local cr = WorldMapButton.zoomClip:GetRight()
              local ct = WorldMapButton.zoomClip:GetTop()
              local cb = WorldMapButton.zoomClip:GetBottom()

              local bl = WorldMapButton:GetLeft()
              local br = WorldMapButton:GetRight()
              local bt = WorldMapButton:GetTop()
              local bb = WorldMapButton:GetBottom()

              if not cl or not bl then return end

                local s = WorldMapButton:GetEffectiveScale()
                if not s or s == 0 then s = 1 end
                  local inL = (cl - bl) / s
                  local inR = (br - cr) / s
                  local inT = (bt - ct) / s
                  local inB = (cb - bb) / s

                  WorldMapButton:SetHitRectInsets(
                    math.max(0, inL),
                                                  math.max(0, inR),
                                                  math.max(0, inT),
                                                  math.max(0, inB)
                  )
                  end

                  local function ApplyMapPosition()
                  WorldMapButton:ClearAllPoints()
                  WorldMapButton:SetPoint("CENTER", WorldMapFrame, "CENTER", mapCenterX or 0, (mapCenterY or 0) - 15)

                  if WorldMapDetailFrame then
                    WorldMapDetailFrame:ClearAllPoints()
                    WorldMapDetailFrame:SetPoint("CENTER", WorldMapFrame, "CENTER", mapCenterX or 0, (mapCenterY or 0) - 15)
                    end

                    UpdateHitRect()
                    end

                    local function ApplyIconScale(child)
                    local natural = child.pfNaturalPoint
                    if not natural then return end
                      child.pfZoomCompensating = true
                      child:ClearAllPoints()
                      child:SetPoint(natural[1], natural[2], natural[3], natural[4]*mapZoom, natural[5]*mapZoom)
                      child.pfZoomCompensating = false
                      end

                      local function ResetMapZoom()
                      mapZoom = 1
                      mapCenterX = 0
                      mapCenterY = 0
                      WorldMapButton:SetScale(1)
                      if WorldMapDetailFrame then
                        WorldMapDetailFrame:SetScale(1)
                        end
                        ApplyMapPosition()

                        local children = GetValidChildren(WorldMapButton)
                        for i = 1, table.getn(children) do
                          local child = children[i]
                          if child ~= pfPlayerArrow and child ~= WorldMapPlayer and child.pfZoomHooked then
                            if child.SetScale then child:SetScale(1) end
                              if child.pfClipHidden then
                                child.pfClipHidden = false
                                if child.pfOrigSetAlpha then
                                  child:pfOrigSetAlpha(child.pfNaturalAlpha or 1)
                                  end
                                  if child.EnableMouse and child.pfWasMouseEnabled then
                                    child:EnableMouse(true)
                                    end
                                    end
                                    if child.pfNaturalPoint then
                                      ApplyIconScale(child)
                                      end
                                      end
                                      end
                                      end

                                      local pfOrigSetMapToCurrentZone = _G.SetMapToCurrentZone
                                      _G.SetMapToCurrentZone = function()
                                      ResetMapZoom()
                                      if C.appearance.worldmap.autozoneswitch == "0" and WorldMapFrame:IsShown() then return end
                                        pfOrigSetMapToCurrentZone()
                                        end

                                        local pfOrigWorldMapZoomOutButton_OnClick = WorldMapZoomOutButton_OnClick
                                        WorldMapZoomOutButton_OnClick = function()
                                        ResetMapZoom()
                                        pfOrigWorldMapZoomOutButton_OnClick()
                                        end

                                        local pfOrigSetMapZoom = _G.SetMapZoom
                                        _G.SetMapZoom = function(continent, zone)
                                        ResetMapZoom()
                                        pfOrigSetMapZoom(continent, zone)
                                        end

                                        pfUI.map = { UpdateConfig = UpdateTooltipScale }

                                        function _G.ToggleWorldMap()
                                        if WorldMapFrame:IsShown() then
                                          WorldMapFrame:Hide()
                                          else
                                            WorldMapFrame:Show()
                                            end
                                            end

                                            C.position["WorldMapFrame"] = C.position["WorldMapFrame"] or { alpha = 1.0, scale = 0.7 }
                                            C.position["WorldMapFrame"].parent = nil
                                            local alpha = C.position["WorldMapFrame"].alpha
                                            local scale = C.position["WorldMapFrame"].scale

                                            local function GetExtraMarkers()
                                            return { WorldMapPing, WorldMapDeathRelease }
                                            end

                                            local function GetCursorMapOffset()
                                            local bscale = WorldMapButton:GetEffectiveScale()
                                            local cx, cy = GetCursorPosition()
                                            local bx, by = WorldMapButton:GetCenter()
                                            if not bx then return nil end
                                              return (cx/bscale) - bx, (cy/bscale) - by
                                              end

                                              local function ClampMapPan()
                                              if not mapWidth then return end
                                                local maxOffsetX = mapWidth  * (mapZoom - 1) / (2 * mapZoom)
                                                local maxOffsetY = mapHeight * (mapZoom - 1) / (2 * mapZoom)
                                                mapCenterX = clamp(mapCenterX, -maxOffsetX, maxOffsetX)
                                                mapCenterY = clamp(mapCenterY, -maxOffsetY, maxOffsetY)
                                                end

                                                local function HookChildPosition(child)
                                                if not child or type(child) ~= "table" or not child.IsObjectType then return end
                                                  if child == pfPlayerArrow or child == WorldMapPlayer or child.pfZoomHooked then return end
                                                    child.pfZoomHooked = true

                                                    if not child.pfNaturalPoint then
                                                      local point, relTo, relPoint, x, y = child:GetPoint()
                                                      if point then
                                                        child.pfNaturalPoint = { point, relTo, relPoint, x or 0, y or 0 }
                                                        end
                                                        end

                                                        local origSetPoint = child.SetPoint
                                                        child.SetPoint = function(self, ...)
                                                        origSetPoint(self, ...)
                                                        if not self.pfZoomCompensating then
                                                          local a1, a2, a3, a4, a5 = ...
                                                          local point, relTo, relPoint, x, y
                                                          if a2 == nil or type(a2) == "number" then
                                                            point, x, y = a1, a2, a3
                                                            relTo, relPoint = self:GetParent(), point
                                                            else
                                                              point, relTo, relPoint, x, y = a1, a2, a3, a4, a5
                                                              end
                                                              self.pfNaturalPoint = { point, relTo, relPoint, x or 0, y or 0 }
                                                              ApplyIconScale(self)
                                                              end
                                                              end

                                                              child.pfOrigSetAlpha = child.SetAlpha
                                                              child.pfNaturalAlpha = child:GetAlpha()
                                                              child.SetAlpha = function(self, a)
                                                              self.pfNaturalAlpha = a
                                                              if not self.pfClipHidden then
                                                                self.pfOrigSetAlpha(self, a)
                                                                end
                                                                end
                                                                end

                                                                local function ClipPinsToZoomWindow()
                                                                local clip = WorldMapButton.zoomClip
                                                                if not clip then return end

                                                                  local clipLeft, clipRight = clip:GetLeft(), clip:GetRight()
                                                                  local clipTop, clipBottom = clip:GetTop(), clip:GetBottom()
                                                                  if not clipLeft then return end

                                                                    local children = GetValidChildren(WorldMapButton)
                                                                    local iconScale = 1 / mapZoom

                                                                    for i = 1, table.getn(children) do
                                                                      local child = children[i]
                                                                      if child and type(child) == "table" and child ~= pfPlayerArrow and child ~= WorldMapPlayer then
                                                                        if not child.pfZoomHooked then
                                                                          HookChildPosition(child)
                                                                          if child.SetScale then child:SetScale(iconScale) end
                                                                            ApplyIconScale(child)
                                                                            end

                                                                            if child.pfZoomHooked then
                                                                              if mapZoom <= 1 then
                                                                                if child.pfClipHidden then
                                                                                  child.pfClipHidden = false
                                                                                  if child.pfOrigSetAlpha then
                                                                                    child:pfOrigSetAlpha(child.pfNaturalAlpha or 1)
                                                                                    end
                                                                                    if child.EnableMouse and child.pfWasMouseEnabled then
                                                                                      child:EnableMouse(true)
                                                                                      end
                                                                                      end
                                                                                      elseif child:IsShown() then
                                                                                        local cl, cr = child:GetLeft(), child:GetRight()
                                                                                        local ct, cb = child:GetTop(), child:GetBottom()
                                                                                        if cl and cr and ct and cb then
                                                                                          local outside = cl < clipLeft or cr > clipRight or cb < clipBottom or ct > clipTop

                                                                                          if outside and not child.pfClipHidden then
                                                                                            child.pfClipHidden = true
                                                                                            if child.pfOrigSetAlpha then
                                                                                              child:pfOrigSetAlpha(0)
                                                                                              end
                                                                                              if child.EnableMouse then
                                                                                                child.pfWasMouseEnabled = child.IsMouseEnabled and child:IsMouseEnabled()
                                                                                                child:EnableMouse(false)
                                                                                                end
                                                                                                elseif not outside and child.pfClipHidden then
                                                                                                  child.pfClipHidden = false
                                                                                                  if child.pfOrigSetAlpha then
                                                                                                    child:pfOrigSetAlpha(child.pfNaturalAlpha or 1)
                                                                                                    end
                                                                                                    if child.EnableMouse and child.pfWasMouseEnabled then
                                                                                                      child:EnableMouse(true)
                                                                                                      end
                                                                                                      end
                                                                                                      end
                                                                                                      end
                                                                                                      end
                                                                                                      end
                                                                                                      end
                                                                                                      end

                                                                                                      local function SetMapZoom(amount, anchorX, anchorY)
                                                                                                      if not mapCenterX then
                                                                                                        local bx, by = WorldMapButton:GetCenter()
                                                                                                        local fx, fy = WorldMapFrame:GetCenter()
                                                                                                        if not bx or not fx then return end
                                                                                                          mapCenterX = bx - fx
                                                                                                          mapCenterY = by - fy
                                                                                                          end

                                                                                                          local oldZoom = mapZoom
                                                                                                          mapZoom = clamp(mapZoom + amount, 1, 2)

                                                                                                          if anchorX then
                                                                                                            mapCenterX = (mapCenterX*oldZoom + anchorX*(oldZoom - mapZoom)) / mapZoom
                                                                                                            mapCenterY = (mapCenterY*oldZoom + anchorY*(oldZoom - mapZoom)) / mapZoom
                                                                                                            end

                                                                                                            ClampMapPan()

                                                                                                            WorldMapButton:SetScale(mapZoom)
                                                                                                            if WorldMapDetailFrame then
                                                                                                              WorldMapDetailFrame:SetScale(mapZoom)
                                                                                                              end
                                                                                                              ApplyMapPosition()

                                                                                                              local iconScale = 1 / mapZoom
                                                                                                              local children = GetValidChildren(WorldMapButton)
                                                                                                              for i = 1, table.getn(children) do
                                                                                                                local child = children[i]
                                                                                                                if child ~= pfPlayerArrow and child ~= WorldMapPlayer then
                                                                                                                  HookChildPosition(child)
                                                                                                                  if child.SetScale then
                                                                                                                    child:SetScale(iconScale)
                                                                                                                    end
                                                                                                                    ApplyIconScale(child)
                                                                                                                    end
                                                                                                                    end

                                                                                                                    local extraMarkers = GetExtraMarkers()
                                                                                                                    for i = 1, table.getn(extraMarkers) do
                                                                                                                      local marker = extraMarkers[i]
                                                                                                                      if marker and type(marker) == "table" and marker.IsObjectType then
                                                                                                                        HookChildPosition(marker)
                                                                                                                        if marker.SetScale then
                                                                                                                          marker:SetScale(iconScale)
                                                                                                                          end
                                                                                                                          ApplyIconScale(marker)
                                                                                                                          end
                                                                                                                          end
                                                                                                                          end

                                                                                                                          pfPlayerArrow = CreateFrame("Frame", "pfWorldMapPlayerArrow", WorldMapButton)
                                                                                                                          pfPlayerArrow:SetSize(24, 24)
                                                                                                                          pfPlayerArrow:SetFrameStrata("FULLSCREEN_DIALOG")
                                                                                                                          pfPlayerArrow:SetFrameLevel(200)

                                                                                                                          local pfPlayerArrowTex = pfPlayerArrow:CreateTexture(nil, "OVERLAY")
                                                                                                                          pfPlayerArrowTex:SetAllPoints(pfPlayerArrow)
                                                                                                                          pfPlayerArrowTex:SetTexture("Interface\\Minimap\\MinimapArrow")

                                                                                                                          local pfArrowInvalidFrames = 0
                                                                                                                          local pfArrowGrace = 15 -- ~0.25s of tolerance for transient invalid reads after a zone switch

                                                                                                                          -- IMPORTANT: this logic must NOT live on pfPlayerArrow's own OnUpdate.
                                                                                                                          -- A frame's OnUpdate script stops firing entirely once the frame is
                                                                                                                          -- hidden -- so the moment we called pfPlayerArrow:Hide(), the only code
                                                                                                                          -- that could ever call :Show() again switched itself off for good. That
                                                                                                                          -- is exactly why the arrow vanished on the first zone switch and never
                                                                                                                          -- came back. Running the check on a separate frame that is never hidden
                                                                                                                          -- keeps it ticking regardless of the visual arrow's current state.
                                                                                                                          local pfPlayerArrowDriver = CreateFrame("Frame")

                                                                                                                          pfPlayerArrowDriver:SetScript("OnUpdate", function()
                                                                                                                          if not WorldMapFrame:IsShown() then
                                                                                                                            pfArrowInvalidFrames = 0
                                                                                                                            pfPlayerArrow:Hide()
                                                                                                                            return
                                                                                                                            end

                                                                                                                            local px, py = GetPlayerMapPosition("player")

                                                                                                                            -- GetPlayerMapPosition signals "not on this map" by returning (0,0) as
                                                                                                                            -- a *pair*. A single axis legitimately reading exactly 0 (e.g. standing
                                                                                                                            -- right on a zone's edge -- which is exactly where you tend to be when
                                                                                                                            -- hopping between adjacent zones) is still a valid position, so only
                                                                                                                            -- treat it as invalid when BOTH axes are 0 (or missing).
                                                                                                                          local invalid = (not px or not py) or (px == 0 and py == 0)

                                                                                                                          if invalid then
                                                                                                                            pfArrowInvalidFrames = pfArrowInvalidFrames + 1
                                                                                                                            -- Right after switching zones (dropdown click, SetMapToCurrentZone,
                                                                                                                                                        -- zoom out, etc) the client can take a frame or two to recompute the
                                                                                                                                                        -- player's position on the newly displayed map, so tolerate a short
                                                                                                                                                        -- burst of invalid reads before actually hiding the arrow.
                                                                                                                                                        if pfArrowInvalidFrames > pfArrowGrace then
                                                                                                                                                          pfPlayerArrow:Hide()
                                                                                                                                                          end
                                                                                                                                                          return
                                                                                                                                                          end

                                                                                                                                                          pfArrowInvalidFrames = 0
                                                                                                                                                          pfPlayerArrow:Show()

                                                                                                                                                          local currentZoom = mapZoom or 1
                                                                                                                                                          pfPlayerArrow:SetScale(1 / currentZoom)

                                                                                                                                                          local width = WorldMapButton:GetWidth()
                                                                                                                                                          local height = WorldMapButton:GetHeight()
                                                                                                                                                          if not width or width == 0 or not height or height == 0 then return end

                                                                                                                                                            local xOfs = px * width * currentZoom
                                                                                                                                                            local yOfs = -py * height * currentZoom

                                                                                                                                                            pfPlayerArrow:ClearAllPoints()
                                                                                                                                                            pfPlayerArrow:SetPoint("CENTER", WorldMapButton, "TOPLEFT", xOfs, yOfs)

                                                                                                                                                            if GetPlayerFacing then
                                                                                                                                                              local facing = GetPlayerFacing()
                                                                                                                                                              if facing and pfPlayerArrowTex.SetRotation then
                                                                                                                                                                pfPlayerArrowTex:SetRotation(facing)
                                                                                                                                                                end
                                                                                                                                                                end
                                                                                                                                                                end)

                                                                                                                          local pfMapLoader = CreateFrame("Frame")
                                                                                                                          pfMapLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
                                                                                                                          pfMapLoader:SetScript("OnEvent", function()
                                                                                                                          if Cartographer or METAMAP_TITLE then return end

                                                                                                                            UIPanelWindows["WorldMapFrame"] = { area = "center" }

                                                                                                                            WorldMapFrame:SetMovable(true)
                                                                                                                            WorldMapFrame:EnableMouse(true)
                                                                                                                            WorldMapFrame:RegisterForDrag("LeftButton")

                                                                                                                            if WorldMapPlayer then
                                                                                                                              WorldMapPlayer:Hide()
                                                                                                                              WorldMapPlayer.Show = function() end
                                                                                                                              end

                                                                                                                              if not pfMapLoader.hooked then
                                                                                                                                pfMapLoader.hooked = true

                                                                                                                                WorldMapFrame:HookScript("OnShow", function()
                                                                                                                                WorldMapFrame:EnableKeyboard(false)
                                                                                                                                WorldMapFrame:EnableMouseWheel(1)

                                                                                                                                WorldMapFrame:SetScale(scale or .85)
                                                                                                                                ResetMapZoom()

                                                                                                                                pfOrigSetMapToCurrentZone()
                                                                                                                                end)

                                                                                                                                WorldMapFrame:HookScript("OnMouseWheel", function()
                                                                                                                                if IsShiftKeyDown() then
                                                                                                                                  alpha = clamp(WorldMapFrame:GetAlpha() + (arg1 * 0.02), 0.1, 1.0)
                                                                                                                                  WorldMapFrame:SetAlpha(alpha)
                                                                                                                                  elseif IsControlKeyDown() then
                                                                                                                                    local oldscale = WorldMapFrame:GetScale()
                                                                                                                                    local newScale = clamp(oldscale + (arg1 * 0.02), 0.2, 2.0)

                                                                                                                                    if oldscale ~= newScale then
                                                                                                                                      local cursorX, cursorY = GetCursorPosition()
                                                                                                                                      local uiScale = UIParent:GetEffectiveScale()
                                                                                                                                      cursorX, cursorY = cursorX / uiScale, cursorY / uiScale

                                                                                                                                      local left, bottom = WorldMapFrame:GetLeft(), WorldMapFrame:GetBottom()
                                                                                                                                      if left and bottom then
                                                                                                                                        local relX = (cursorX - left) / oldscale
                                                                                                                                        local relY = (cursorY - bottom) / oldscale

                                                                                                                                        WorldMapFrame:SetScale(newScale)

                                                                                                                                        local newLeft = cursorX - (relX * newScale)
                                                                                                                                        local newBottom = cursorY - (relY * newScale)

                                                                                                                                        WorldMapFrame:ClearAllPoints()
                                                                                                                                        WorldMapFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", newLeft, newBottom)
                                                                                                                                        else
                                                                                                                                          WorldMapFrame:SetScale(newScale)
                                                                                                                                          end

                                                                                                                                          scale = newScale
                                                                                                                                          UpdateTooltipScale()
                                                                                                                                          end
                                                                                                                                          elseif MouseIsOver(WorldMapButton) then
                                                                                                                                            local ox, oy = GetCursorMapOffset()
                                                                                                                                            SetMapZoom(arg1 / 10, ox, oy)
                                                                                                                                            end

                                                                                                                                            SaveMovable(WorldMapFrame, true)
                                                                                                                                            end)

                                                                                                                                WorldMapFrame:HookScript("OnDragStart", function()
                                                                                                                                WorldMapFrame:StartMoving()
                                                                                                                                end)

                                                                                                                                WorldMapFrame:HookScript("OnDragStop", function()
                                                                                                                                WorldMapFrame:StopMovingOrSizing()
                                                                                                                                SaveMovable(WorldMapFrame, true)
                                                                                                                                end)

                                                                                                                                WorldMapButton:EnableMouse(true)
                                                                                                                                WorldMapButton:RegisterForDrag("LeftButton")

                                                                                                                                local panning = false
                                                                                                                                local pfMapDragged = false
                                                                                                                                local panStartCursorX, panStartCursorY
                                                                                                                                local panStartCenterX, panStartCenterY

                                                                                                                                WorldMapButton:HookScript("OnDragStart", function()
                                                                                                                                if mapZoom <= 1 then return end
                                                                                                                                  local clip = WorldMapButton.zoomClip or WorldMapFrame
                                                                                                                                  if not MouseIsOver(clip) then return end

                                                                                                                                    panning = true
                                                                                                                                    pfMapDragged = true
                                                                                                                                    panStartCursorX, panStartCursorY = GetCursorPosition()
                                                                                                                                    panStartCenterX, panStartCenterY = mapCenterX, mapCenterY
                                                                                                                                    end)

                                                                                                                                WorldMapButton:HookScript("OnDragStop", function()
                                                                                                                                panning = false
                                                                                                                                end)

                                                                                                                                WorldMapButton:HookScript("OnUpdate", function()
                                                                                                                                if not panning then return end
                                                                                                                                  local bscale = WorldMapButton:GetEffectiveScale()
                                                                                                                                  local cx, cy = GetCursorPosition()
                                                                                                                                  mapCenterX = panStartCenterX + (cx - panStartCursorX) / bscale
                                                                                                                                  mapCenterY = panStartCenterY + (cy - panStartCursorY) / bscale
                                                                                                                                  ClampMapPan()
                                                                                                                                  ApplyMapPosition()
                                                                                                                                  end)

                                                                                                                                if not pinClipTicker then
                                                                                                                                  pinClipTicker = C_Timer.NewTicker(0.05, function()
                                                                                                                                  if WorldMapFrame:IsShown() then
                                                                                                                                    ClipPinsToZoomWindow()
                                                                                                                                    UpdateHitRect()
                                                                                                                                    end
                                                                                                                                    end)
                                                                                                                                  end
                                                                                                                                  end

                                                                                                                                  WorldMapFrame:SetAlpha(alpha)
                                                                                                                                  WorldMapFrame:SetScale(scale)
                                                                                                                                  UpdateTooltipScale()

                                                                                                                                  WorldMapFrame:ClearAllPoints()
                                                                                                                                  WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                                                                                                                                  local wmWidth, wmHeight = WorldMapButton:GetWidth(), WorldMapButton:GetHeight()
                                                                                                                                  mapWidth, mapHeight = wmWidth, wmHeight

                                                                                                                                  WorldMapFrame:SetSize(wmWidth + 20, wmHeight + 65)
                                                                                                                                  LoadMovable(WorldMapFrame)
                                                                                                                                  if WorldMapButton.SetClipsChildren then WorldMapButton:SetClipsChildren(true) end

                                                                                                                                    if not WorldMapFrame.headerDragFrame then
                                                                                                                                      local headerDrag = CreateFrame("Frame", "pfWorldMapHeaderDrag", WorldMapFrame)
                                                                                                                                      headerDrag:SetHeight(50)
                                                                                                                                      headerDrag:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 0, 0)
                                                                                                                                      headerDrag:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 0, 0)
                                                                                                                                      headerDrag:EnableMouse(true)
                                                                                                                                      headerDrag:RegisterForDrag("LeftButton")

                                                                                                                                      headerDrag:SetScript("OnDragStart", function()
                                                                                                                                      WorldMapFrame:StartMoving()
                                                                                                                                      end)

                                                                                                                                      headerDrag:SetScript("OnDragStop", function()
                                                                                                                                      WorldMapFrame:StopMovingOrSizing()
                                                                                                                                      SaveMovable(WorldMapFrame, true)
                                                                                                                                      end)

                                                                                                                                      WorldMapFrame.headerDragFrame = headerDrag
                                                                                                                                      end

                                                                                                                                      if not WorldMapButton.zoomClip then
                                                                                                                                        local dx, dy
                                                                                                                                        if WorldMapDetailFrame then
                                                                                                                                          dx, dy = WorldMapDetailFrame:GetCenter()
                                                                                                                                          end
                                                                                                                                          local fx, fy = WorldMapFrame:GetCenter()

                                                                                                                                          local zoomClip = CreateFrame("ScrollFrame", "pfWorldMapZoomClip", WorldMapFrame)
                                                                                                                                          zoomClip:SetSize(wmWidth, wmHeight)
                                                                                                                                          zoomClip:SetPoint("BOTTOM", WorldMapFrame, "BOTTOM", 0, 10)

                                                                                                                                          local scrollChild = CreateFrame("Frame", "pfWorldMapZoomScrollChild", zoomClip)
                                                                                                                                          scrollChild:SetSize(wmWidth, wmHeight)
                                                                                                                                          scrollChild:SetPoint("TOPLEFT", zoomClip, "TOPLEFT", 0, 0)
                                                                                                                                          zoomClip:SetScrollChild(scrollChild)

                                                                                                                                          if WorldMapDetailFrame then
                                                                                                                                            WorldMapDetailFrame:SetParent(scrollChild)
                                                                                                                                            WorldMapDetailFrame:ClearAllPoints()
                                                                                                                                            WorldMapDetailFrame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
                                                                                                                                            end

                                                                                                                                            WorldMapButton.zoomClip = zoomClip
                                                                                                                                            end

                                                                                                                                            WorldMapButton:SetScript("OnMouseDown", nil)

                                                                                                                                            WorldMapButton:SetScript("OnMouseUp", function()
                                                                                                                                            if pfMapDragged then
                                                                                                                                              pfMapDragged = false
                                                                                                                                              return
                                                                                                                                              end

                                                                                                                                              local clip = WorldMapButton.zoomClip or WorldMapFrame
                                                                                                                                              if not MouseIsOver(clip) then
                                                                                                                                                return
                                                                                                                                                end

                                                                                                                                                if WorldMapButton_OnClick then
                                                                                                                                                  WorldMapButton_OnClick(arg1)
                                                                                                                                                  end
                                                                                                                                                  end)

                                                                                                                                            WorldMapContinentDropDown:ClearAllPoints()
                                                                                                                                            WorldMapContinentDropDown:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 160, -28)

                                                                                                                                            WorldMapZoneDropDown:ClearAllPoints()
                                                                                                                                            WorldMapZoneDropDown:SetPoint("LEFT", WorldMapContinentDropDown, "RIGHT", -10, 0)

                                                                                                                                            if WorldMapZoomOutButton then
                                                                                                                                              WorldMapZoomOutButton:ClearAllPoints()
                                                                                                                                              WorldMapZoomOutButton:SetPoint("LEFT", WorldMapZoneDropDown, "RIGHT", 10, 3)
                                                                                                                                              end

                                                                                                                                              if WorldMapFrameAreaFrame and not WorldMapFrameAreaFrame.pfReparented then
                                                                                                                                                WorldMapFrameAreaFrame.pfReparented = true
                                                                                                                                                WorldMapFrameAreaFrame:SetParent(WorldMapButton.zoomClip or WorldMapFrame)
                                                                                                                                                WorldMapFrameAreaFrame:SetFrameLevel((WorldMapButton.zoomClip and WorldMapButton.zoomClip:GetFrameLevel() or WorldMapFrame:GetFrameLevel()) + 20)
                                                                                                                                                WorldMapFrameAreaFrame:ClearAllPoints()
                                                                                                                                                WorldMapFrameAreaFrame:SetPoint("TOP", WorldMapButton.zoomClip or WorldMapFrame, "TOP", 0, -10)
                                                                                                                                                end

                                                                                                                                                WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -3, -3)
                                                                                                                                                CreateBackdrop(WorldMapFrame)
                                                                                                                                                CreateBackdropShadow(WorldMapFrame)

                                                                                                                                                BlackoutWorld:Hide()
                                                                                                                                                StripTextures(WorldMapFrame)

                                                                                                                                                SkinButton(WorldMapZoomOutButton)
                                                                                                                                                SkinCloseButton(WorldMapFrameCloseButton, WorldMapFrame, -3, -3)

                                                                                                                                                if not pfUI.map.autozoneswitch then
                                                                                                                                                  local btn = CreateFrame("CheckButton", "pfUI_map_autozoneswitch", WorldMapFrame, "UICheckButtonTemplate")
                                                                                                                                                  btn:SetNormalTexture("")
                                                                                                                                                  btn:SetPushedTexture("")
                                                                                                                                                  btn:SetHighlightTexture("")
                                                                                                                                                  btn.text = _G["pfUI_map_autozoneswitchText"]
                                                                                                                                                  CreateBackdrop(btn, nil, true)
                                                                                                                                                  btn:SetSize(14, 14)
                                                                                                                                                  btn:SetPoint("RIGHT", WorldMapContinentDropDown, "LEFT", -6, 3)
                                                                                                                                                  btn.text:ClearAllPoints()
                                                                                                                                                  btn.text:SetPoint("RIGHT", btn, "LEFT", -4, 0)
                                                                                                                                                  btn.text:SetJustifyH("RIGHT")
                                                                                                                                                  btn.text:SetText(T["Switch to current zone"])
                                                                                                                                                  btn:SetScript("OnShow", function()
                                                                                                                                                  btn:SetChecked(C.appearance.worldmap.autozoneswitch == "1")
                                                                                                                                                  end)
                                                                                                                                                  btn:SetScript("OnClick", function()
                                                                                                                                                  if btn:GetChecked() then
                                                                                                                                                    C.appearance.worldmap.autozoneswitch = "1"
                                                                                                                                                    pfOrigSetMapToCurrentZone()
                                                                                                                                                    else
                                                                                                                                                      C.appearance.worldmap.autozoneswitch = "0"
                                                                                                                                                      end
                                                                                                                                                      end)
                                                                                                                                                  pfUI.map.autozoneswitch = btn
                                                                                                                                                  end

                                                                                                                                                  SkinDropDown(WorldMapContinentDropDown)
                                                                                                                                                  SkinDropDown(WorldMapZoneDropDown)
                                                                                                                                                  if WorldMapZoneMinimapDropDown then
                                                                                                                                                    SkinDropDown(WorldMapZoneMinimapDropDown)
                                                                                                                                                    end

                                                                                                                                                    if not WorldMapButton.coords then
                                                                                                                                                      WorldMapButton.coords = CreateFrame("Frame", "pfWorldMapButtonCoords", WorldMapButton.zoomClip or WorldMapFrame)
                                                                                                                                                      WorldMapButton.coords.text = WorldMapButton.coords:CreateFontString(nil, "OVERLAY")
                                                                                                                                                      WorldMapButton.coords.text:SetPoint("BOTTOMRIGHT", WorldMapButton.zoomClip or WorldMapFrame, "BOTTOMRIGHT", -10, 10)
                                                                                                                                                      WorldMapButton.coords.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
                                                                                                                                                      WorldMapButton.coords.text:SetTextColor(1, 1, 1)
                                                                                                                                                      WorldMapButton.coords.text:SetJustifyH("RIGHT")

                                                                                                                                                      WorldMapButton.coords:SetScript("OnUpdate", function()
                                                                                                                                                      local width, height = WorldMapButton:GetWidth(), WorldMapButton:GetHeight()
                                                                                                                                                      local mx, my = WorldMapButton:GetCenter()
                                                                                                                                                      local wmbscale  = WorldMapButton:GetEffectiveScale()
                                                                                                                                                      local x, y   = GetCursorPosition()

                                                                                                                                                      if mx and my then
                                                                                                                                                        mx = (( x / wmbscale ) - ( mx - width / 2)) / width * 100
                                                                                                                                                        my = (( my + height / 2 ) - ( y / wmbscale )) / height * 100
                                                                                                                                                        end

                                                                                                                                                        if mx and my and MouseIsOver(WorldMapButton.zoomClip or WorldMapFrame) then
                                                                                                                                                          WorldMapButton.coords.text:SetFormattedText('%.1f / %.1f', mx, my)
                                                                                                                                                          else
                                                                                                                                                            WorldMapButton.coords.text:SetText("")
                                                                                                                                                            end
                                                                                                                                                            end)
                                                                                                                                                      end
                                                                                                                                                      end)

                                                                                                                          pfUI.map.loader = pfMapLoader
                                                                                                                          end)
