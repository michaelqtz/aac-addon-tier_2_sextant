local api = require("api")

local tier_2_sextant_addon = {
	name = "Tier 2 Sextant",
	author = "Michaelqt",
	version = "1.1.0",
	desc = "A better version of the sextant."
}

local tier2SextantWindow
local treasureMapBtn
local coordinatePromptWindow
local coordinatePromptLabel

local clockTimer = 0
local clockResetTime = 1000
local function OnUpdate(dt)
    if clockTimer + dt > clockResetTime then

		clockTimer = 0
    end 
    clockTimer = clockTimer + dt
end 


local function latitudeSextantToDegrees(direction, degrees, minutes, seconds)
	local coordCoef = 0.00097657363894522145695357130138029 
	local yCoords = 0
	yCoords = seconds / 60
	yCoords = (yCoords + minutes) / 60
	yCoords = degrees + yCoords
	if direction == "S" then yCoords = yCoords * -1 end
	return (yCoords + 28) / coordCoef

end
local function longitudeSextantToDegrees(direction, degrees, minutes, seconds) 
	local coordCoef = 0.00097657363894522145695357130138029 
	local xCoords = 0
	xCoords = seconds / 60
	xCoords = (xCoords + minutes) / 60
	xCoords = degrees + xCoords
	if direction == "W" then xCoords = xCoords * -1 end
	return (xCoords + 21) / coordCoef
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
		local latitude = latitudeSextantToDegrees(latDir, latDeg, latMin, latSec)
		local lonDir = sextants.longitude
		local lonDeg = sextants.deg_long
		local lonMin = sextants.min_long
		local lonSec = sextants.sec_long
		local longitude = longitudeSextantToDegrees(lonDir, lonDeg, lonMin, lonSec)

		local coordinateString = lonDir .. " " .. lonDeg .. " " .. lonMin .. " " .. lonSec .. " " .. latDir .. " " .. latDeg .. " " .. latMin .. " " .. latSec

		-- Adjust the prompt window based on type of coordinates
		if string.find(msg, "swarm of Sunfish") then 
			coordinatePromptWindow:SetTitle("Sunfish Found")
			local coordinatePromptText = "A swarm of Sunfish has been found! \n \n  Would you like to find it on your map?"
			api.Log:Info("[Tier 2 Sextant] Swarm of Sunfish found at " .. tostring(coordinateString))
		elseif string.find(msg, "Perdita Statue Torso") then 
			coordinatePromptWindow:SetTitle("Perdita Found")
			local coordinatePromptText = "A Perdita Statue Torso pack has been found! \n \n  Would you like to find it on your map?"
			api.Log:Info("[Tier 2 Sextant] Perdita Statue Torso pack found at " .. tostring(coordinateString))
		elseif string.find(msg, "Leviathan carcass") then 
			coordinatePromptWindow:SetTitle("Leviathan Dead")
			local coordinatePromptText = "Leviathan is super dead! \n \n  Would you like to find it on your map?"
			api.Log:Info("[Tier 2 Sextant] Leviathan's dead corpse is at " .. tostring(coordinateString))
		elseif string.find(msg, "are being unlocked") then 
			coordinatePromptWindow:SetTitle("Stolen Goods Unlocking")
			local coordinatePromptText = "Territory goods are being unlocked. \n \n  Would you like to find it on your map?"
			api.Log:Info("[Tier 2 Sextant] Territory goods are being unlocked at " .. tostring(coordinateString))
		elseif string.find(msg, "Territory Warehouse") then 
			coordinatePromptWindow:SetTitle("Warehouse Looted")
			local coordinatePromptText = "A territory warehouse has been looted! \n \n  Would you like to find it on your map?"
			api.Log:Info("[Tier 2 Sextant] A Territory Warehouse was looted at " .. tostring(coordinateString))
		elseif string.find(msg, "mysterious crate") then 
			coordinatePromptWindow:SetTitle("Mysterious Crate Found")
			local coordinatePromptText = "Someone found a mysterious crate. \n \n  Would you like to find it on your map?"
			api.Log:Info("[Tier 2 Sextant] A Mysterious Crate was found at " .. tostring(coordinateString))
		end 
		function coordinatePromptWindow.coordinatePromptYesBtn:OnClick()
			api.Map:ToggleMapWithPortal(323, longitude, latitude, 100)
			coordinatePromptWindow:Show(false)
		end
		coordinatePromptWindow.coordinatePromptYesBtn:SetHandler("OnClick", coordinatePromptWindow.coordinatePromptYesBtn.OnClick)
		
	end 
	api.Log:Info("[Tier 2 Sextant] " .. tostring(msg))
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
				local latitude = latitudeSextantToDegrees(latDir, latDeg, latMin, latSec)
				local lonDir = currentItemInfo.longitudeDir
				local lonDeg = currentItemInfo.longitudeDeg
				local lonMin = currentItemInfo.longitudeMin
				local lonSec = currentItemInfo.longitudeSec
				local longitude = longitudeSextantToDegrees(lonDir, lonDeg, lonMin, lonSec)
				-- Zone for the window to be opened to: (323 is an instance)
				local zoneId = 323 --> TODO: fill this based on map position
				-- Let's draw that map!
				api.Map:ToggleMapWithPortal(323, longitude, latitude, 100)
			end
		end 
    end 
    clickOverlay:SetHandler("OnClick", clickOverlay.OnClick)
	
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
