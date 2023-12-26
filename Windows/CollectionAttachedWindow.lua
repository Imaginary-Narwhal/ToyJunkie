local addonName, L = ...

--------------------------------------------------
-- Create Attached Main frame and Toggle Button --
--------------------------------------------------

L.AttachedFrame = CreateFrame("Frame", "ToyJunkie_CollectionAttachedFrame", UIParent, "ButtonFrameTemplate")
ButtonFrameTemplate_HidePortrait(L.AttachedFrame)
ButtonFrameTemplate_HideButtonBar(L.AttachedFrame)
ButtonFrameTemplate_HideAttic(L.AttachedFrame)
L.AttachedFrame.CloseButton:Hide()
L.AttachedFrame:SetTitle("ToyJunkie")
L.AttachedFrame:SetSize(300, 500)
L.AttachedFrame.Inset:SetPoint("BOTTOMRIGHT", -18, 4)
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

L.AttachedFrame.ScrollFrame = Mixin(CreateFrame("Frame", "$parent_ScrollFrame", L.AttachedFrame.Inset), AttachedScrollTemplateMixin)

--L.AttachedFrame.ScrollFrame = CreateFrame("Frame", "$parent_ScrollFrame", L.AttachedFrame.Inset, "TJ_ScrollFrameTemplate")
L.AttachedFrame.ScrollFrame:SetPoint("TOPLEFT", 18, -7)
L.AttachedFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", 0, 5)
L.AttachedFrame.ScrollFrame:OnLoad()

-- Attached Main Frame Scrolling Frame --
--[[
L.AttachedFrame.ScrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", L.AttachedFrame.Inset, "ScrollFrameTemplate")
L.AttachedFrame.ScrollFrame:SetPoint("TOPLEFT", 15, -7)
L.AttachedFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", -23, 5)

L.AttachedFrame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", L.AttachedFrame.ScrollFrame, "TOPRIGHT", 6, -5)

L.AttachedFrame.ScrollFrame.Child = CreateFrame("Frame")
L.AttachedFrame.ScrollFrame.Child.Items = {}
local numButtons = 50
local buttonHeight = 22
for i=1, numButtons do
    local y = -(buttonHeight * (i - 1))
    local button = CreateFrame("Button", "Thing" .. i, L.AttachedFrame.ScrollFrame.Child, "UIPanelButtonTemplate")
    button:SetText("Thing " .. i)
    
    
    
    
    
    button:SetPoint("TOPLEFT", 0, y)
    button:SetPoint("TOPRIGHT", 0, y - 22)
end

L.AttachedFrame.ScrollFrame.Child:SetHeight(numButtons*buttonHeight)

L.AttachedFrame.ScrollFrame:SetScrollChild(L.AttachedFrame.ScrollFrame.Child)


-- For Testing --

local buttonPool = {}
local buttonNum = 0

local add = CreateFrame("Button", nil, L.AttachedFrame, "UIPanelButtonTemplate")
add:SetText("Add")
add:SetPoint("RIGHT", 40, 15)
add:SetScript("OnClick", function()
    buttonNum = buttonNum + 1
    table.insert(L.AttachedFrame.ScrollFrame.Child.Items, buttonNum)
    L.AttachedFrame.ScrollFrame.Child:Update()
end)


local del = CreateFrame("Button", nil, L.AttachedFrame, "UIPanelButtonTemplate")
del:SetText("Del")
del:SetPoint("RIGHT", 40, -15)
del:SetScript("OnClick", function()
    if(buttonNum > 0) then
        table.remove(L.AttachedFrame.ScrollFrame.Child.Items, buttonNum)
        buttonNum = buttonNum - 1
        L.AttachedFrame.ScrollFrame.Child:Update()
    end
end)


local function AddButton()
end


function L.AttachedFrame.ScrollFrame.Child:Update()
    if(#self.Items > 0) then
        for k,v in pairs(self.Items) do
            
        end
    end
end]]