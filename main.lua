local api = require("api")

local tier_2_sextant_addon = {
	name = "Tier 2 Sextant",
	author = "Michaelqt",
	version = "1.0",
	desc = "A better version of the sextant."
}

local tier2SextantWindow
local treasureMapBtn

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
	--
    api.On("UPDATE", OnUpdate)
	api.SaveSettings()
end

local function OnUnload()
	api.On("UPDATE", function() return end)
	-- treasureMapBtn:Show(false)
	tier2SextantWindow:Show(false)
	treasureMapBtn = nil
end

tier_2_sextant_addon.OnLoad = OnLoad
tier_2_sextant_addon.OnUnload = OnUnload

return tier_2_sextant_addon
