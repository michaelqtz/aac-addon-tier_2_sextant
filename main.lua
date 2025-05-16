local api = require("api")

local tier_2_sextant_addon = {
	name = "Tier 2 Sextant",
	author = "Michaelqt",
	version = "1.3.1",
	desc = "A better version of the sextant."
}

local tier2SextantWindow
local treasureMapBtn
local coordinatePromptWindow
local coordinatePromptLabel

local clockTimer = 0
local clockResetTime = 10000
local function OnUpdate(dt)
    if clockTimer + dt > clockResetTime then
		-- Only show the map button window if there is a treasure map in the bag.
		local bagFrame = ADDON:GetContent(UIC.BAG)
		clockTimer = 0
		local mapFound = false
		for key, value in pairs(bagFrame.slots.btns) do
			local bagItemInfo = bagFrame.slots.btns[key]:GetInfo()
			if bagItemInfo ~= nil then 
				if bagItemInfo.name == "Treasure Map with Coordinates" or bagItemInfo.name == "Cleaned Map" then 
					mapFound = true
				end 
			end 
		end 
		tier2SextantWindow:Show(mapFound)
    end 
    clockTimer = clockTimer + dt
end 


function tier_2_sextant_addon.latitudeSextantToDegrees(direction, degrees, minutes, seconds)
	local coordCoef = 0.00097657363894522145695357130138029 
	local yCoords = 0
	yCoords = seconds / 60
	yCoords = (yCoords + minutes) / 60
	yCoords = degrees + yCoords
	if direction == "S" then yCoords = yCoords * -1 end
	return (yCoords + 28) / coordCoef

end
function tier_2_sextant_addon.longitudeSextantToDegrees(direction, degrees, minutes, seconds)
	local coordCoef = 0.00097657363894522145695357130138029 
	local xCoords = 0
	xCoords = seconds / 60
	xCoords = (xCoords + minutes) / 60
	xCoords = degrees + xCoords
	if direction == "W" then xCoords = xCoords * -1 end
	return (xCoords + 21) / coordCoef
end 

local function getCleanedMapCoordsByItemId(itemId)
	local x = nil
	local y = nil
	cleanedMapCoords = {
		["26705"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 6, 24, 6),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 5, 59, 19)
		},
		["26706"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 6, 34, 40),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 5, 25, 17)
		},
		["26707"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 6, 9, 37),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 6, 7, 29)
		},
		["26723"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 5, 58, 34),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 6, 25, 10)
		},
		["26724"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 5, 10, 52),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 5, 3, 8)
		},
		["26725"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 4, 28, 36),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 12, 3, 58)
		},
		["26726"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 4, 34, 29),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 12, 21, 12)
		},
		["26727"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 0, 26, 36),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 8, 36, 32)
		},
		["28622"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 2, 27, 31),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 4, 11, 33)
		},
		["28623"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 2, 6, 57),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 3, 28, 36)
		},
		["28624"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 1, 1, 15),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 3, 4, 38)
		},
		["28625"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 0, 34, 32),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 2, 50, 54)
		},
		["28626"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 0, 26, 30),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 2, 41, 46)
		},
		["28627"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 0, 32, 32),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 2, 27, 58)
		},
		["28628"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("E", 0, 8, 51),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 1, 30, 31)
		},
		["28629"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("E", 0, 21, 26),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 1, 20, 18)
		},
		["28630"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("E", 0, 47, 10),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 4, 44, 39)
		},
		["28631"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 4, 24, 28),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 8, 39, 30)
		},
		["28632"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 4, 10, 42),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 8, 49, 35)
		},
		["28633"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 7, 9, 38),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 9, 7, 40)
		},
		["28634"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("E", 0, 38, 2),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 5, 12, 52)
		},
		["28635"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 2, 41, 16),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 17, 52, 39)
		},
		["28636"] = {
			tier_2_sextant_addon.longitudeSextantToDegrees("W", 7, 21, 54),
			tier_2_sextant_addon.latitudeSextantToDegrees("S", 19, 30, 2)
		},
	}
	x = cleanedMapCoords[tostring(itemId)][1]
	y = cleanedMapCoords[tostring(itemId)][2]
	return {longitude=x, latitude=y}
end 

local function openCoordsPromptFromWorldMessage(msg, iconKey, sextants, info) 
	keyWord = "@coordinates"
    isCoordsFound = string.find(msg, keyWord)
	if isCoordsFound then 
		-- Latitude/Longitude
		local latDir = sextants.latitude
		local latDeg = sextants.deg_lat
		local latMin = sextants.min_lat
		local latSec = sextants.sec_lat
		local latitude = tier_2_sextant_addon.latitudeSextantToDegrees(latDir, latDeg, latMin, latSec)
		local lonDir = sextants.longitude
		local lonDeg = sextants.deg_long
		local lonMin = sextants.min_long
		local lonSec = sextants.sec_long
		local longitude = tier_2_sextant_addon.longitudeSextantToDegrees(lonDir, lonDeg, lonMin, lonSec)

		local coordinateString = lonDir .. " " .. lonDeg .. " " .. lonMin .. " " .. lonSec .. " " .. latDir .. " " .. latDeg .. " " .. latMin .. " " .. latSec

		-- Adjust the prompt window based on type of coordinates
		if string.find(msg, "swarm of Sunfish") then 
			coordinatePromptWindow:SetTitle("Sunfish Found")
			local coordinatePromptText = "A swarm of Sunfish has been found! \n \n  Would you like to find it on your map?"
			coordinatePromptLabel:SetText(coordinatePromptText)
			api.Log:Info("[Tier 2 Sextant] Swarm of Sunfish found at " .. tostring(coordinateString))
		elseif string.find(msg, "Perdita Statue Torso") then 
			coordinatePromptWindow:SetTitle("Perdita Found")
			local coordinatePromptText = "A Perdita Statue Torso pack has been found! \n \n  Would you like to find it on your map?"
			coordinatePromptLabel:SetText(coordinatePromptText)
			api.Log:Info("[Tier 2 Sextant] Perdita Statue Torso pack found at " .. tostring(coordinateString))
		elseif string.find(msg, "Leviathan carcass") then 
			coordinatePromptWindow:SetTitle("Leviathan Dead")
			local coordinatePromptText = "Leviathan is super dead! \n \n  Would you like to find it on your map?"
			coordinatePromptLabel:SetText(coordinatePromptText)
			api.Log:Info("[Tier 2 Sextant] Leviathan's dead corpse is at " .. tostring(coordinateString))
		elseif string.find(msg, "are being unlocked") then 
			coordinatePromptWindow:SetTitle("Stolen Goods Unlocking")
			local coordinatePromptText = "Territory goods are being unlocked. \n \n  Would you like to find it on your map?"
			coordinatePromptLabel:SetText(coordinatePromptText)
			api.Log:Info("[Tier 2 Sextant] Territory goods are being unlocked at " .. tostring(coordinateString))
		elseif string.find(msg, "Territory Warehouse") then 
			coordinatePromptWindow:SetTitle("Warehouse Looted")
			local coordinatePromptText = "A territory warehouse has been looted! \n \n  Would you like to find it on your map?"
			coordinatePromptLabel:SetText(coordinatePromptText)
			api.Log:Info("[Tier 2 Sextant] A Territory Warehouse was looted at " .. tostring(coordinateString))
		elseif string.find(msg, "mysterious crate") then 
			coordinatePromptWindow:SetTitle("Mysterious Crate Found")
			local coordinatePromptText = "Someone found a mysterious crate. \n \n  Would you like to find it on your map?"
			coordinatePromptLabel:SetText(coordinatePromptText)
			api.Log:Info("[Tier 2 Sextant] A Mysterious Crate was found at " .. tostring(coordinateString))
		end 
		function coordinatePromptWindow.coordinatePromptYesBtn:OnClick()
			api.Map:ToggleMapWithPortal(323, longitude, latitude, 100)
			coordinatePromptWindow:Show(false)
		end
		coordinatePromptWindow.coordinatePromptYesBtn:SetHandler("OnClick", coordinatePromptWindow.coordinatePromptYesBtn.OnClick)
		coordinatePromptWindow:Show(true)
	end 
	-- api.Log:Info("[Tier 2 Sextant] " .. tostring(msg))
	-- api.Log:Info("[Tier 2 Sextant] " .. tostring(iconKey))
	-- api.Log:Info(sextants)
	-- api.Log:Info(info)
end 

local function OnLoad()
	local settings = api.GetSettings("tier_2_sextant_addon")
	--
	local bagFrame = ADDON:GetContent(UIC.BAG)
	tier2SextantWindow = bagFrame:CreateChildWidget("label", "tier2SextantWindow", 0, true)
	tier2SextantWindow:AddAnchor("BOTTOMLEFT", bagFrame, -80, -5)
	tier2SextantWindow:SetExtent(80, 90)
	-- Main Window Background Styling
	tier2SextantWindow.bg = tier2SextantWindow:CreateNinePartDrawable("ui/common/tab_list.dds", "background")
	tier2SextantWindow.bg:SetTextureInfo("bg_quest")
	tier2SextantWindow.bg:SetColor(0, 0, 0, 0.5)
	tier2SextantWindow.bg:AddAnchor("TOPLEFT", tier2SextantWindow, 0, 0)
	tier2SextantWindow.bg:AddAnchor("BOTTOMRIGHT", tier2SextantWindow, 0, 0)

	local textbox = tier2SextantWindow:CreateChildWidget("textbox", "textbox", 0, true)
    textbox:AddAnchor("TOPLEFT", tier2SextantWindow, 0, -10)
    textbox:AddAnchor("BOTTOMRIGHT", tier2SextantWindow, 0, -40)
    textbox.style:SetAlign(ALIGN.CENTER)
    ApplyTextColor(textbox, FONT_COLOR.WHITE)
    tier2SextantWindow.textbox = textbox
	textbox:SetText("Drag and click map")

	local treasureMapBtn = CreateItemIconButton("treasureMapBtn", tier2SextantWindow)
    treasureMapBtn:Show(true)
    F_SLOT.ApplySlotSkin(treasureMapBtn, treasureMapBtn.back, SLOT_STYLE.BUFF)
    F_SLOT.SetIconBackGround(treasureMapBtn, "game/ui/icon/icon_item_0002.dds")
    treasureMapBtn:AddAnchor("BOTTOMLEFT", tier2SextantWindow, 20, -10)

	local clickOverlay = tier2SextantWindow:CreateChildWidget("button", "clickOverlay", 0, true)
    clickOverlay:AddAnchor("TOPLEFT", tier2SextantWindow, 0, 0)
    clickOverlay:AddAnchor("BOTTOMRIGHT", tier2SextantWindow, 0, 0)
    function clickOverlay:OnClick()
		-- api.Log:Info("hello")
		local currentCursorItemIndex = api.Cursor:GetCursorPickedBagItemIndex()
		if currentCursorItemIndex > 0 then 
			local currentItemInfo = api.Bag:GetBagItemInfo(1, currentCursorItemIndex)
			local currentCursorItemName = currentItemInfo.name or nil
			if currentCursorItemName == "Treasure Map with Coordinates" then 
				-- Latitude/Longitude
				local latDir = currentItemInfo.latitudeDir
				local latDeg = currentItemInfo.latitudeDeg
				local latMin = currentItemInfo.latitudeMin
				local latSec = currentItemInfo.latitudeSec
				local latitude = tier_2_sextant_addon.latitudeSextantToDegrees(latDir, latDeg, latMin, latSec)
				local lonDir = currentItemInfo.longitudeDir
				local lonDeg = currentItemInfo.longitudeDeg
				local lonMin = currentItemInfo.longitudeMin
				local lonSec = currentItemInfo.longitudeSec
				local longitude = tier_2_sextant_addon.longitudeSextantToDegrees(lonDir, lonDeg, lonMin, lonSec)
				-- Zone for the window to be opened to: (323 is an instance)
				local zoneId = 323 --> TODO: fill this based on map position
				-- Let's draw that map!
				api.Map:ToggleMapWithPortal(323, longitude, latitude, 100)
			elseif currentCursorItemName == "Cleaned Map" then 
				local currentItemId = currentItemInfo.itemType
				local cleanedMapCoords = getCleanedMapCoordsByItemId(currentItemId)
				api.Map:ToggleMapWithPortal(323, cleanedMapCoords.longitude, cleanedMapCoords.latitude, 100)
			end 
		end 
    end 
    clickOverlay:SetHandler("OnClick", clickOverlay.OnClick)
	
	-- api.Log:Info(tier_2_sextant_addon.latitudeSextantToDegrees)

	--- Coordinate Prompt for various pop-ups
	-- Actual window
	coordinatePromptWindow = api.Interface:CreateWindow("coordinatePromptWindow", "Coordinates Found", 0, 0)
	coordinatePromptWindow:AddAnchor("CENTER", "UIParent", 0, -150)
	coordinatePromptWindow:SetExtent(300, 150)
	-- Prompt label and buttons
	local coordinatePromptText = "Aguru is a frog. \n \n  Would you like to know his true identity?"
	-- local coordinatePromptText = "A Perdita Statue Torso has been found! \n \n  Would you like to find it on your map?"
	coordinatePromptLabel = coordinatePromptWindow:CreateChildWidget("textbox", "coordinatePromptLabel", 0, true)
	coordinatePromptLabel:SetText(coordinatePromptText)
	coordinatePromptLabel:SetExtent(240, FONT_SIZE.LARGE * 2.5)
	coordinatePromptLabel.style:SetAlign(ALIGN.CENTER)
	ApplyTextColor(coordinatePromptLabel, FONT_COLOR.DEFAULT)
	coordinatePromptLabel:AddAnchor("CENTER", coordinatePromptWindow, 0, 0)
	coordinatePromptYesBtn = coordinatePromptWindow:CreateChildWidget("button", "coordinatePromptYesBtn", 0, true)
	api.Interface:ApplyButtonSkin(coordinatePromptYesBtn, BUTTON_BASIC.DEFAULT)
	coordinatePromptYesBtn:AddAnchor("BOTTOMLEFT", coordinatePromptWindow, 10, -10)
	coordinatePromptYesBtn:SetText("Yes")
	coordinatePromptNoBtn = coordinatePromptWindow:CreateChildWidget("button", "coordinatePromptNoBtn", 0, true)
	api.Interface:ApplyButtonSkin(coordinatePromptNoBtn, BUTTON_BASIC.DEFAULT)
	coordinatePromptNoBtn:AddAnchor("BOTTOMRIGHT", coordinatePromptWindow, -10, -10)
	coordinatePromptNoBtn:SetText("No")
	-- Starts off hidden (Hide the damn thing)
	coordinatePromptWindow:Show(false)
	-- Button clicky for no. (yes has its callback set when coordinates detected)
	function coordinatePromptWindow.coordinatePromptNoBtn:OnClick()
		coordinatePromptWindow:Show(false)
	end
	coordinatePromptWindow.coordinatePromptNoBtn:SetHandler("OnClick", coordinatePromptWindow.coordinatePromptNoBtn.OnClick)
	--- "Unit Testing"
	-- local msg = "A swarm of Sunfish has appeared at @coordinates!"
	-- local iconKey = nil
	-- local sextants = {}
	-- sextants.longitude = "W"
	-- sextants.deg_long = 5
	-- sextants.min_long = 13
	-- sextants.sec_long = 21
	-- sextants.latitude = "S"
	-- sextants.deg_lat = 5
	-- sextants.min_lat = 57
	-- sextants.sec_lat = 1
	-- local info = nil
	-- openCoordsPromptFromWorldMessage(msg, iconKey, sextants, info) 

	function tier2SextantWindow:OnEvent(event, ...)
        if event == "WORLD_MESSAGE" then
            openCoordsPromptFromWorldMessage(unpack(arg))
        end
    end
	tier2SextantWindow:SetHandler("OnEvent", tier2SextantWindow.OnEvent)
    tier2SextantWindow:RegisterEvent("WORLD_MESSAGE")

    api.On("UPDATE", OnUpdate)
	api.SaveSettings()
end

local function OnUnload()
	api.On("UPDATE", function() return end)
	-- tier2SextantWindow = api.Interface:Free(tier2SextantWindow)
	if tier2SextantWindow ~= nil then 
		tier2SextantWindow:Show(false)
		tier2SextantWindow:ReleaseHandler("OnEvent")
		tier2SextantWindow = nil
	end 
	if treasureMapBtn ~= nil then 
		-- treasureMapBtn:Show(false)
		treasureMapBtn = nil
	end 
end

tier_2_sextant_addon.OnLoad = OnLoad
tier_2_sextant_addon.OnUnload = OnUnload

return tier_2_sextant_addon
