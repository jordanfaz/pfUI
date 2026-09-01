-- Cached item categorization for the bag category view.
setfenv(1, pfUI:GetEnvironment())

if pfUI.api.libitemdetect then return end

	local detector = {}
	pfUI.api.libitemdetect = detector
	local cache = {}
	local ItemClass = Enum.ItemClass
	local toolItems = {
		[2901] = true, -- Mining Pick
		[5956] = true, -- Blacksmith Hammer
		[6219] = true, -- Arclight Spanner
	}

	function detector:ClearCache()
	cache = {}
	end

	function detector:GetCategory(itemID)
	if not itemID then return "Empty" end
		local name, link, quality, _, _, itemType, itemSubtype, _, equipSlot = C_Item.GetItemInfo(itemID)
		local _, _, _, _, _, classID = C_Item.GetItemInfoInstant(itemID)
		local key = link or tostring(itemID)
		if cache[key] then return cache[key] end

			local category
			if itemID == HEARTHSTONE_ITEM_ID then
				category = "Home"
				elseif quality == 0 then
					-- Grey/Poor quality items are always Junk, regardless of their type
					-- (a grey sword is still Junk, not Weapon). Checked before the
					-- class-based branches below so it takes priority over them, and
					-- kept in sync with bags.lua's own quality-0 -> "Junk" assignment so
					-- both code paths agree no matter which one handles a given item.
					category = "Junk"
					elseif toolItems[itemID] then
						category = "Tools"
						elseif equipSlot == "INVTYPE_TRINKET" then
							category = "Trinket"
							elseif classID == ItemClass.Questitem or itemType == "Quest" then
								category = "Quest"
								elseif classID == ItemClass.Weapon or itemType == "Weapon" then
									category = "Weapon"
									elseif classID == ItemClass.Armor or itemType == "Armor" then
										category = "Armor"
										elseif classID == ItemClass.Consumable or itemType == "Consumable" then
											local subtype = string.lower(itemSubtype or "")
											category = string.find(subtype, "drink", 1, true) and "Drink"
											or string.find(subtype, "food", 1, true) and "Food"
											or "Consumable"
											elseif classID == ItemClass.Tradegoods or itemType == "Trade Goods" then
												category = "Trade Goods"
												elseif classID == ItemClass.Reagent or itemType == "Reagent" then
													category = "Reagent"
													elseif classID == ItemClass.Recipe or itemType == "Recipe" then
														category = "Recipe"
														elseif classID == ItemClass.Container or itemType == "Container" then
															category = "Container"
															elseif classID == ItemClass.Projectile or classID == ItemClass.Key or
																itemType == "Projectile" or itemType == "Key" then
																category = "Class Items"
																else
																	local lowerName = string.lower(name or "")
																	if string.find(lowerName, "fishing pole", 1, true) or
																		string.find(lowerName, "mining pick", 1, true) or
																		string.find(lowerName, "skinning knife", 1, true) then
																		category = "Tools"
																		else
																			category = "Miscellaneous"
																			end
																			end

																			cache[key] = category
																			return category
																			end
