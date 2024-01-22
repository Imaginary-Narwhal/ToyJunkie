local addonName, L = ...

L.ToyJunkie.colorPickerOpened = false

function L.ToyJunkie:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ToyJunkieDB", L.defaults, true)
    L.ToyJunkie:ConfigurationInitialize(self)

    tjdb = L.ToyJunkie.db.profile --DELETE THIS LINE (BETA)
    tj = L --DELETE ME TOO (BETA)
    self:Print("REMOVE ALL BETA CODE (Search for (BETA) in your code)")

    local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
---@diagnostic disable-next-line: missing-fields
    local dataObj = ldb:NewDataObject(addonName, {
        type = "data source",
        icon = "454046",
        label = "Toy Junkie",
        OnClick = function(obj, button)
            if(button == "LeftButton") then
                L.ToyboxFrame:Toggle()
            elseif (button == "RightButton") then
               L:SettingsMenuDropdown()
            end
        end
    })
    L.ToyJunkie.Icon:Register(addonName, dataObj, self.db.profile.minimap)

    self:RegisterChatCommand("tj", "TJCommand")
    self:RegisterChatCommand("toyjunkie", "TJCommand")
end

function L.ToyJunkie:OnEnable()
    ----------------------------------
    -- Update old profile if needed --

    if(L.ToyJunkie.db.profile.boxes ~= nil) then
        for key, toybox in pairs(L.ToyJunkie.db.profile.boxes) do
            if(toybox.isCollapsed == nil) then
                toybox.isCollapsed = false
            end
            if(toybox.icon == nil) then
                toybox.icon = 454046
            end
            if(toybox.toyColor == nil) then
                toybox.toyColor = {
                    red = 0.0,
                    green = 0.0,
                    blue = 1.0,
                    alpha = 0.25
                }
            end
        end
    end
    ----------------------------------


    self:RegisterEvent("TOYS_UPDATED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    
    L.ToyJunkie:SecureHookScript(ColorPickerFrame, "OnHide", "ColorPickerFrame_OnHide_Hook")
    if(#L.ToyJunkie.db.profile.boxes < 1) then
        L.ToyJunkie.db.profile.selectedToybox = nil
        L.ToyJunkie.db.profile.toyboxShown = false
    end

    if(L.ToyJunkie.db.profile.addonCompartment) then
        L.ToyJunkie.Icon:AddButtonToCompartment(addonName)
    end
end

function L.ToyJunkie:TJCommand(msg)
    if(not msg or msg:trim() == "") then
        L.ToyboxFrame:Toggle()
    end
end

function L.ToyJunkie:TOYS_UPDATED()
    if(L.AttachedFrame ~= nil and ToyBox ~= nil) then
        if (not L.AttachedFrame.isAttached) then
            L.AttachedFrame:SetFrame()
        end
    end
    L.AttachedFrame.ScrollFrame.listView:Refresh()
    if(L.ToyJunkie.db.profile.toyboxShown) then
        L.ToyboxFrame:Toggle(true, "OPEN")
    end
end

function L.ToyJunkie:ColorPickerFrame_OnHide_Hook()
    if(L.ToyJunkie.colorPickerOpened) then
        ColorPickerFrame:ClearAllPoints()
        ColorPickerFrame:SetPoint("CENTER")
        L.ToyJunkie.colorPickerOpened = false
        L.ToyJunkie.noInteraction = false
    end
end

function L.ToyJunkie:PLAYER_REGEN_DISABLED()
    L.isInCombat = true
    L.ToyboxFrame:Toggle(true, "CLOSE")
end

function L.ToyJunkie:PLAYER_REGEN_ENABLED()
    L.isInCombat = false
    if(L.ToyJunkie.db.profile.toyboxShown) then
        L.ToyboxFrame:Toggle(true, "OPEN")
    end
end