local addonName, L = ...

--------------------------------------------------
-- Create Attached Main frame and Toggle Button --
--------------------------------------------------

L.AttachedFrame = CreateFrame("Frame", "ToyJunkie_CollectionAttachedFrame", UIParent, "ButtonFrameTemplate")
ButtonFrameTemplate_HidePortrait(L.AttachedFrame)
ButtonFrameTemplate_HideAttic(L.AttachedFrame)

L.AttachedFrame.CloseButton:Hide()
L.AttachedFrame:SetTitle("ToyJunkie")
L.AttachedFrame:SetSize(300, 500)
L.AttachedFrame.Inset:SetPoint("BOTTOMRIGHT", -18, 27)
L.AttachedFrame:Hide()
L.AttachedFrame.isAttached = false

L.AttachedFrame.ToggleButton = CreateFrame("Button", "$parent_ToggleButton", L.AttachedFrame)
L.AttachedFrame.ToggleButton:SetNormalTexture("Interface\\RaidFrame\\RaidPanel-Toggle")
L.AttachedFrame.ToggleButton:SetSize(18, 60)
L.AttachedFrame.ToggleButton:SetPoint("RIGHT", L.AttachedFrame, -3, 0)

L.AttachedFrame.ToggleButton:SetScript("OnClick", function(self)
    L.AttachedFrame:Toggle()
end)

-- Attached Main Frame Functions --

function L.AttachedFrame:SetFrame()
    self:SetParent(ToyBox)
    self:SetFrameStrata("MEDIUM")
    self:ClearAllPoints()
    local tex = self.ToggleButton:GetNormalTexture()
    if(L.ToyJunkie.db.profile.isAttachedWindowHidden) then
        self:SetPoint("LEFT", ToyBox, "RIGHT", -(self:GetWidth() - 17), 0)
        tex:SetTexCoord(0, 0.5, 0, 1)
        self.ToggleButton:ClearAllPoints()
        self.ToggleButton:SetPoint("RIGHT", self, -2, 0)
    else
        self:SetPoint("LEFT", ToyBox, "RIGHT", -20, 0)
        tex:SetTexCoord(0.5, 1, 0, 1)
        self.ToggleButton:ClearAllPoints()
        self.ToggleButton:SetPoint("RIGHT", self, -3, 0)
    end
    self.isAttached = true
    --self.ScrollFrame.Child:SetWidth(self.Inset:GetWidth() - 37)
    self:Show()
end

function L.AttachedFrame:Toggle()
    self:ClearAllPoints()
    local tex = self.ToggleButton:GetNormalTexture()
    if(L.ToyJunkie.db.profile.isAttachedWindowHidden) then --closed, open it
        self:SetPoint("LEFT", ToyBox, "RIGHT", -20, 0)
        L.ToyJunkie.db.profile.isAttachedWindowHidden = false
        tex:SetTexCoord(0.5, 1, 0, 1)
        self.ToggleButton:ClearAllPoints()
        self.ToggleButton:SetPoint("RIGHT", self, -3, 0)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
    else --opened, close it
        self:SetPoint("LEFT", ToyBox, "RIGHT", -(self:GetWidth() - 17), 0)
        L.ToyJunkie.db.profile.isAttachedWindowHidden = true
        tex:SetTexCoord(0, 0.5, 0, 1)
        self.ToggleButton:ClearAllPoints()
        self.ToggleButton:SetPoint("RIGHT", self, -2, 0)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
    end
end

-----------------------------------
-- Toy box and toys scroll frame --
-----------------------------------

L.AttachedFrame.ScrollFrame = Mixin(CreateFrame("Frame", "$parent_ScrollFrame", L.AttachedFrame), AttachedScrollTemplateMixin)
L.AttachedFrame.ScrollFrame:SetPoint("TOPLEFT", L.AttachedFrame.Inset, "TOPLEFT", 18, -7)
L.AttachedFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", L.AttachedFrame.Inset, "BOTTOMRIGHT", 0, 5)
L.AttachedFrame.ScrollFrame:OnLoad()

L.AttachedFrame.AddToyboxButton = CreateFrame("Button", "$parent_AddToyboxButton", L.AttachedFrame, "UIPanelButtonTemplate")
L.AttachedFrame.AddToyboxButton:SetText("Add Toy Box")
L.AttachedFrame.AddToyboxButton:SetWidth(100)
L.AttachedFrame.AddToyboxButton:SetPoint("BOTTOMRIGHT", -5, 4)
L.AttachedFrame.AddToyboxButton:SetScript("OnClick", function()
    L.AttachedFrame.ScrollFrame:AddToybox()
end)