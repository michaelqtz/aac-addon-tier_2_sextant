local api = require("api")

local appsettings = {}

local settings = nil
local addonSettingsName = "tier_2_sextant"
local defaultSettings = {
    territory_goods = true,
    leviathan = true,
    sunfish = true,
    mysterious_crate = true,
    delphinad_ghost_ship = true,
    perdita = true,
    territory_warehouse = true,
}

function appsettings.Get(key)
    if(settings == nil) then
        settings = appsettings.LoadSettings()
    end
    if(settings == nil) then -- if for some reason loading settings failed, return default settings
        settings = defaultSettings 
    end
    if(settings[key] == nil) then
        return defaultSettings[key]
    end
    return settings[key]
end

function appsettings.Set(key, value)
    if(settings == nil) then
        settings = appsettings.LoadSettings() -- how did we get to updating settings, without ever calling get...
    end
    local oldvalue = settings[key]
    settings[key] = value
    if oldvalue ~= value then 
        api.SaveSettings(addonSettingsName, settings)
    end
end

function appsettings.LoadSettings()
    local settings = api.GetSettings(addonSettingsName)
    -- loop for set default settings if not exists
    local needsSave = false
    for k, v in pairs(defaultSettings) do
        if settings[k] == nil then 
            settings[k] = v 
            needsSave = true
        end
    end
    if needsSave then
        api.SaveSettings(addonSettingsName, settings)
    end
    return settings
end

return appsettings