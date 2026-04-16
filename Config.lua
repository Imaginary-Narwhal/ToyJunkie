local addonName, L = ...


L.ToyJunkie = LibStub("AceAddon-3.0"):NewAddon("ToyJunkie", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
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
        isAttachedWindowHidden = false,
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
        hearthstoneFavoriteIds = {},
        hearthstoneShowAll = false,
        quickToys = {},
        lastOpenVersion = "",
        tooltipsEnabled = true,
        useCompactTooltips = true,
        tutorial = false,
        createMacro = false
    }
}

local options = {
    name = "ToyJunkie",
    handler = L.ToyJunkie,
    type = "group",
    args = {
        minimap = {
            order = 3,
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
                        if (L.ToyJunkie.db.profile.minimap.hide) then
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
                        if (L.ToyJunkie.db.profile.minimap.lock) then
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
                        if (L.ToyJunkie.db.profile.addonCompartment) then
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
        tooltipSettings = {
            type = "group",
            name = "Tooltip Settings",
            inline = true,
            order = 2,
            args = {
                enableTooltips = {
                    type = "toggle",
                    name = "Enable tooltips",
                    desc = "Enable tooltips in toy box window",
                    order = 0,
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.tooltipEnabled = val
                    end),
                    get = (function(info)
                        return L.ToyJunkie.db.profile.tooltipEnabled
                    end)
                },
                compactTooltips = {
                    disabled = (function()
                        return not L.ToyJunkie.db.profile.tooltipEnabled
                    end),
                    type = "toggle",
                    name = "Use compact tooltips",
                    desc = "Compact tooltip is just the name",
                    order = 1,
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.useCompactTooltips = val
                    end),
                    get = (function(info)
                        return L.ToyJunkie.db.profile.useCompactTooltips
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
                }
            }
        },
        macroSettings = {
            type = "group",
            name = "Toybox Settings",
            inline = true,
            order = 1,
            args = {
                toggleMacro = {
                    type = "toggle",
                    name = "Random Toy Macro",
                    desc = "Creates a macro that casts a random hearthstone when clicked. Macro will be named 'TJ_RandomHearthstone' and will be placed in the general tab of your macros.",
                    order = 1,
                    set = (function(info, val)
                        L.ToyJunkie.db.profile.createMacro = val
                        if (val) then
                            L:CreateRandomHearthstoneMacro()
                            L:UpdateRandomHearthstoneMacro(L.ToyboxFrame:GetCurrentlySelectedHearthstoneId())
                        else
                            L:DeleteRandomHearthstoneMacro()
                        end
                    end),
                    get = (function(info)
                        return L.ToyJunkie.db.profile.createMacro
                    end)
                }
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
