local addonName, L = ...

local isMoving = false

------------------------------
-- Create main toybox frame --
------------------------------

L.ToyboxFrame = CreateFrame("Frame", "ToyJunkie_ToyboxFrame", UIParent, "BackdropTemplate")
L.ToyboxFrame.Bg = CreateFrame("Frame", "$parent_Bg", L.ToyboxFrame, "FlatPanelBackgroundTemplate")
L.ToyboxFrame.Bg:SetFrameLevel(0)
L.ToyboxFrame.Bg:SetPoint("TOPLEFT", 2, -2)
L.ToyboxFrame.Bg:SetPoint("BOTTOMRIGHT", -2, 2)
L.ToyboxFrame:SetBackdrop({
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
L.ToyboxFrame:SetBackdropBorderColor(.5, .5, .5, 1)
L.ToyboxFrame:SetSize(194, 235)
L.ToyboxFrame:SetPoint("TOPLEFT", 20, -20)

L.ToyboxFrame:RegisterForDrag("LeftButton")
L.ToyboxFrame:SetClampedToScreen(true)
L.ToyboxFrame:SetMovable(true)
L.ToyboxFrame:EnableMouse(true)

L.ToyboxFrame:SetScript("OnDragStart", function(self, button)
    if (not isMoving) then
        L.ToyboxFrame:StartMoving()
        isMoving = true
    end
end)
L.ToyboxFrame:SetScript("OnDragStop", function(self, button)
    if (isMoving) then
        L.ToyboxFrame:StopMovingOrSizing()
        isMoving = false
    end
end)
L.ToyboxFrame:SetScript("OnHide", function(self)
    if (isMoving) then
        L.ToyboxFrame:StopMovingOrSizing()
        isMoving = false
    end
end)

L.ToyboxFrame.CloseButton = CreateFrame("Button", "$parent_CloseButton", L.ToyboxFrame, "UIPanelCloseButton")
L.ToyboxFrame.CloseButton:SetSize(18, 18)
L.ToyboxFrame.CloseButton:SetPoint("TOPRIGHT", 0, 0)
L.ToyboxFrame.CloseButton:SetScript("OnClick", function(self, button)
    if (button == "LeftButton") then
        L.ToyboxFrame:Toggle()
    end
end)

L.ToyboxFrame.Icon = L.ToyboxFrame:CreateTexture()
L.ToyboxFrame.Icon:SetSize(16, 16)
L.ToyboxFrame.Icon:SetPoint("TOPLEFT", 7, -7)
L.ToyboxFrame.Icon:SetTexture(454046)

L.ToyboxFrame.Title = L.ToyboxFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
L.ToyboxFrame.Title:SetPoint("TOPLEFT", L.ToyboxFrame, 25, -9)
L.ToyboxFrame.Title:SetPoint("TOPRIGHT", L.ToyboxFrame, -40, -24)
L.ToyboxFrame.Title:SetWordWrap(false)

L.ToyboxFrame.ToyButtonHolderFrame = CreateFrame("Frame", "$parent_ToyButtonHolderFrame", L.ToyboxFrame)
L.ToyboxFrame.ToyButtonHolderFrame:SetScale(1)
L.ToyboxFrame.ToyButtonHolderFrame:SetPoint("TOPLEFT", 15, -30)
L.ToyboxFrame.ToyButtonHolderFrame:SetSize(164, 164)
----------------------
-- Toybox Functions --
----------------------
function L.ToyboxFrame:UpdateToyboxDisplay()
    local idx = 1
    for id, box in pairs(L.ToyJunkie.db.profile.boxes) do
        if(box.name == L.ToyJunkie.db.profile.selectedToybox) then
            idx = id
            break
        end
    end
    self.Title:SetText(L.ToyJunkie.db.profile.boxes[idx].name)
    self.Icon:SetTexture(L.ToyJunkie.db.profile.boxes[idx].icon)
    self:UpdateToyButtons()
end

function L.ToyboxFrame:CreateToyButtons()
    
end

function L.ToyboxFrame:UpdateToyButtons()

end

function L.ToyboxFrame:Toggle(auto, force)
    if (force == nil) then
        if (self:IsShown()) then
            force = "CLOSE"
        else
            force = "OPEN"
        end
    end
    if (force ~= "OPEN" and force ~= "CLOSE") then
        L.ToyJunkie:Print("Error in ToyboxFrame toggle. (force) must be OPEN or CLOSE")
        return
    end
    if (#L.ToyJunkie.db.profile.boxes > 0) then
        if(not L.ToyJunkie.db.profile.selectedToybox) then
            L.ToyJunkie.db.profile.selectedToybox = L.ToyJunkie.db.profile.boxes[1].name
        end
    else
        self:Hide()
        return
    end

    if (auto) then
        if (force == "CLOSE") then
            self:Hide()
        else
            self:UpdateToyboxDisplay()
            self:Show()
        end
    else
        if (force == "CLOSE") then
            self:Hide()
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
            L.ToyJunkie.db.profile.toyboxShown = false
        else
            if (not L.isInCombat) then
                self:UpdateToyboxDisplay()
                self:Show()
                PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
                L.ToyJunkie.db.profile.toyboxShown = true
            end
        end
    end
end

L.ToyboxFrame:Hide()
