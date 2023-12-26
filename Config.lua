local addonName, L = ...

L.ToyJunkie = LibStub("AceAddon-3.0"):NewAddon("ToyJunkie","AceConsole-3.0", "AceEvent-3.0")
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
        displaySize = 2,
        selectedToybox = nil,
        toyboxShown = true,
        toyboxLastSelectedPage = 1,
        minimap = {
            hide = false,
            lock = false
        },
        addonCompartment = true,
        boxes = {
            
        }
    }
}

function L.ToyJunkie:ConfigurationInitialize(self)
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    AC:RegisterOptionsTable("ToyJunkie_Profiles", profiles)
    ACD:AddToBlizOptions("ToyJunkie_Profiles", "ToyJunkie Profiles")
end