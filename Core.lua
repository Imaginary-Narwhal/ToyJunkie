local addonName, L = ...

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
                --[[if(L.ToyboxFrame:IsShown()) then
                    L.ToyboxFrame:Hide()
                else
                    if(not L.isInCombat) then
                        L.ToyboxFrame:Show()
                    end
                end
            elseif (button == "RightButton") then
                InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)]]
            end
        end
    })
    L.ToyJunkie.Icon:Register(addonName, dataObj, self.db.profile.minimap)

    self:RegisterChatCommand("tj", "TJCommand")
    self:RegisterChatCommand("toyjunkie", "TJCommand")
end

function L.ToyJunkie:OnEnable()
    L.AttachedFrame.ScrollFrame.listView:Refresh()
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
        end
    end
    ----------------------------------


    self:RegisterEvent("TOYS_UPDATED")
    --self:RegisterEvent("PLAYER_REGEN_DISABLED")
    --self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function L.ToyJunkie:TJCommand(msg)
    if(not msg or msg:trim() == "") then
        --[[if(L.ToyboxFrame:IsShown()) then
            L.ToyboxFrame:Hide()
        else
            if(not L.isInCombat) then
                L.ToyboxFrame:Show()
            end
        end
    elseif(string.lower(msg) == "config" or string.lower(msg) == "options") then
        --InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        print("Open options frame")]]
    end
end

function L.ToyJunkie:TOYS_UPDATED()
    if(L.AttachedFrame ~= nil and ToyBox ~= nil) then
        if (not L.AttachedFrame.isAttached) then
            L.AttachedFrame:SetFrame()
        end
    end

    --[[if(L.ToyJunkie.db.profile.selectedToybox == nil) then
        if(#L.ToyJunkie.db.profile.boxes > 0) then
            L:ToyJunkieToyboxSelectedChange(1)
        else
            L.ToyboxFrame:Hide()
        end
    else
        L:ToyJunkieToyboxSelectedChange(L.ToyJunkie.db.profile.selectedToybox)
    end
    L:CheckCooldowns()]]
end