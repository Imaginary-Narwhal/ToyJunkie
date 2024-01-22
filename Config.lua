local addonName, L = ...

L.ToyJunkie = LibStub("AceAddon-3.0"):NewAddon("ToyJunkie","AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
L.ToyJunkie.Icon = LibStub("LibDBIcon-1.0")

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

---------------------
-- Local variables --
---------------------

L.isInCombat = false

------------------------------
-- Default Profile Settings --
------------------------------

L.defaults = {
    profile = {
        isAttachedWindowHidden = true,
        compactDisplay = false,
        selectedToybox = nil,
        toyboxShown = false,
        toyboxLastSelectedPage = 1,
        showTooltips = true,
        minimap = {
            hide = false,
            lock = false
        },
        addonCompartment = true,
        boxes = {
            
        },
    }
}

function L.ToyJunkie:ConfigurationInitialize(self)
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    AC:RegisterOptionsTable("ToyJunkie_Profiles", profiles)
    self.profiles = ACD:AddToBlizOptions("ToyJunkie_Profiles", "ToyJunkie Profiles")
end

--[[ 
    settings: 
        displaySize = 1-Compact, 2-Normal, 3-Special?
        showTooltips = true/false
            (Possible option to hold shift to show tooltips)
        minimap button = hide - true/false, lock - true/false
            (Message to mention about LDB addon)
        addonCompartment = true/false
        profiles = button to open profiles in addonsettings

        134400 130724
]]