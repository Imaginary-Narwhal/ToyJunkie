local addonName, L = ...

--[[L.HearthstoneIds = {
    54452,  -- Ethereal Portal
    64488,  -- The Innkeeper's Daughter
    93672,  -- Dark Portal
    142542, -- Tome of Town Portal
    162973, -- Greatfather Winter's Hearthstone
    163045, -- Headless Horseman's Hearthstone
    165669, -- Lunar Elder's Hearthstone
    165670, -- Peddlefeet's Lovely Hearthstone
    165802, -- Noble Gardener's Hearthstone
    166746, -- Fire Eater's Hearthstone
    166747, -- Brewfest Reveler's Hearthstone
    168907, -- Holographic Digitalization Hearthstone
    246565, -- Cosmic Hearthstone
    172179, -- Eternal Traveler's Hearthstone
    180290, -- Night Fae Hearthstone
    182773, -- Necrolord Hearthstone
    183716, -- Venthyr Sinstone
    184353, -- Kyrian Hearthstone
    188952, -- Dominated Hearthstone
    190196, -- Enlightened Hearthstone
    190237, -- Broker Translocation Matrix
    193588, -- Timewalker's Hearthstone
    200630, -- Ohn'ir Windsage's Hearthstone
    206195, -- Path of the Naaru
    208704, -- Deepdweller's Earthen Hearthstone
    209035, -- Hearthstone of the Flame
    210455, -- Draenic Hologem
    212337, -- Stone of the Hearth
    228940, -- Notorious Thread's Hearthstone
    236687, -- Explosive Hearthstone
    246565, -- Redeployment Module
    245970, -- P.O.S.T. Master's Express Hearthstone
}]]

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
        selectedToybox = nil,
        minimap = {
            hide = false,
            lock = false
        },
        toyBoxFrame = {
            locked = false,
            location = {
                point = "TOPLEFT",
                relativePoint = "TOPLEFT",
                offsetX = 21,
                offsetY = -18,
            },
            width = 194,
            height = 204,
            iconSize = 48,
            cooldownScale = .75,
            isSideBarShown = true,
            isShown = false
        },
        addonCompartment = true,
        boxes = {},
        hearthstoneFavoriteIds = {}
    }
}

local options = {
    name = "ToyJunkie",
    handler = L.ToyJunkie,
    type = "group",
    args = {
        minimap = {
            order = 2,
            type = "group",
            name = "Minimap Button",
            inline = true,
            args = {
                button = {
                    type = "toggle",
                    name = "Show Button",
                    desc = "Show/Hide minimap button",
                    order = 2,
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.minimap.hide = not val
                        if(L.ToyJunkie.db.profile.minimap.hide) then
                            L.ToyJunkie.Icon:Hide(addonName)
                        else
                            L.ToyJunkie.Icon:Show(addonName)
                        end
                    end),
                    get = (function(info)
                        return not L.ToyJunkie.db.profile.minimap.hide
                    end)
                },
                lock = {
                    type = "toggle",
                    name = "Lock Button",
                    desc = "Lock/unlock minimap button in place",
                    order = 3,
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.minimap.lock = val
                        if(L.ToyJunkie.db.profile.minimap.lock) then
                            L.ToyJunkie.Icon:Lock(addonName)
                        else
                            L.ToyJunkie.Icon:Unlock(addonName)
                        end
                    end),
                    get = (function(info)
                        return L.ToyJunkie.db.profile.minimap.lock
                    end)
                },
                compartment = {
                    type = "toggle",
                    name = "Addon Compartment",
                    desc = "Show ToyJunkie in addon compartment",
                    order = 4,
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.addonCompartment = val
                        if(L.ToyJunkie.db.profile.addonCompartment) then
                            L.ToyJunkie.Icon:AddButtonToCompartment(addonName)
                        else
                            L.ToyJunkie.Icon:RemoveButtonFromCompartment(addonName)
                        end
                    end),
                    get = (function(info)
                        return L.ToyJunkie.db.profile.addonCompartment
                    end)
                }
            }
        },
        toyboxSettings = {
            type = "group",
            name = "Toybox Settings",
            inline = true,
            order = 1,
            args = {
                iconSize = {
                    type = "range",
                    order = 1,
                    min = 16,
                    max = 48,
                    softMin = 16,
                    softMax = 48,
                    name = "Toy Icon Size",
                    step = 1,
                    get = (function(info) 
                        return L.ToyJunkie.db.profile.toyBoxFrame.iconSize
                    end),
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.toyBoxFrame.iconSize = val
                        L.ToyboxFrame:UpdateToyButtons()
                        L.ToyboxFrame:UpdateBounds()
                    end)
                },
                cooldownScale = {
                    type = "range",
                    order = 2,
                    min = .5,
                    max = 1.5,
                    softMin = .5,
                    softMax = 1.5,
                    name = "Cooldown Text Scale",
                    step = .05,
                    get = (function(info)
                        return L.ToyJunkie.db.profile.toyBoxFrame.cooldownScale
                    end),
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.toyBoxFrame.cooldownScale = val
                        L:CheckAllCooldowns()
                    end)
                }--[[,
                spacer = {
                    type = "header",
                    order = 2,
                    name = ""
                },
                frameOpacity = {
                    type = "range",
                    name = "Toybox Opacity",
                    order = 3,
                    min = 0,
                    max = 1,
                    softMin = 0,
                    softMax = 1,
                    isPercent = true,
                    step = .01,
                    get = (function(info) 
                        return L.ToyJunkie.db.profile.toyBoxFrame.opacity
                    end),
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.toyBoxFrame.opacity = val
                        L.ToyboxFrame:SetAlpha(val)
                    end)
                },
                mouseOverOpacity = {
                    type = "range",
                    name = "Toybox Mouseover Opacity",
                    order = 4,
                    min = 0,
                    max = 1,
                    softMin = 0,
                    softMax = 1,
                    isPercent = true,
                    step = .01,
                    get = (function(info) 
                        return L.ToyJunkie.db.profile.toyBoxFrame.mouseOverOpacity
                    end),
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.toyBoxFrame.mouseOverOpacity = val
                    end)
                }]]
            }
        }
    }
}

function L.ToyJunkie:ConfigurationInitialize(self)
    AC:RegisterOptionsTable("ToyJunkie_options", options)
    self.optionFrame, L.catID = ACD:AddToBlizOptions("ToyJunkie_options", "ToyJunkie")

    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    AC:RegisterOptionsTable("ToyJunkie", profiles)
    ACD:AddToBlizOptions("ToyJunkie", "Profiles", "ToyJunkie")
end