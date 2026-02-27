local addon, L = ...

local callbackFunction = nil
local name = ""
local icon = 0

L.ToyBoxEditFrame = CreateFrame("Frame", "ToyJunkie_ToyBoxEditFrame", UIParent, "ButtonFrameTemplate")
ButtonFrameTemplate_HidePortrait(L.ToyBoxEditFrame)
FrameTemplate_SetAtticHeight(L.ToyBoxEditFrame, 70)
L.ToyBoxEditFrame:SetTitle("Edit ToyBox")
L.ToyBoxEditFrame:SetFrameStrata("DIALOG")
L.ToyBoxEditFrame.CloseButton:Hide()
L.ToyBoxEditFrame:SetPoint("CENTER",0, 0)
L.ToyBoxEditFrame:SetSize(388,400)
L.ToyBoxEditFrame:SetScript("OnShow", function(self)
    L.ToyJunkie.noInteraction = true
end)
L.ToyBoxEditFrame:SetScript("OnHide", function(self)
    L.ToyJunkie.noInteraction = false
end)


local nameLabel = L.ToyBoxEditFrame:CreateFontString(nil, "OVERLAY", "GlueFontNormalExtraSmall")
nameLabel:SetPoint("TOPLEFT", 15, -30)
nameLabel:SetText("Enter ToyBox Name")


local nameInputBox = CreateFrame("EditBox", "$parent_NameInputBox", L.ToyBoxEditFrame, "InputBoxTemplate")
nameInputBox:SetPoint("TOPLEFT", 20, -38)
nameInputBox:SetSize(175,40)
nameInputBox:SetAutoFocus(false)

local iconLabel = L.ToyBoxEditFrame:CreateFontString(nil, "OVERLAY", "GlueFontNormalExtraSmall")
iconLabel:SetPoint("TOPRIGHT", -7, -30)
iconLabel:SetText("Currently Selected Icon")

local selectedIcon = CreateFrame("Frame", "$parent_SelectedIcon", L.ToyBoxEditFrame)
selectedIcon:SetSize(26,26)
selectedIcon:SetPoint("TOPRIGHT", -10, -42)
selectedIcon.texture = selectedIcon:CreateTexture()
selectedIcon.texture:SetAllPoints(selectedIcon)

L.ToyBoxEditFrame.IconSelectionFrame = Mixin(CreateFrame("Frame", "$parent_IconSelectionFrame", L.ToyBoxEditFrame), IconScrollTemplateMixin)
L.ToyBoxEditFrame.IconSelectionFrame:SetPoint("TOPLEFT", 5, -60)
L.ToyBoxEditFrame.IconSelectionFrame:SetPoint("BOTTOMRIGHT", -5, 0)
L.ToyBoxEditFrame.IconSelectionFrame:OnLoad()

local saveButton = CreateFrame("Button", "$parent_SaveButton", L.ToyBoxEditFrame, "UIPanelButtonTemplate")
saveButton:SetText("Save")
saveButton:SetPoint("BOTTOMLEFT", 12, 5)
saveButton:SetWidth(100)
saveButton:SetScript("OnClick", function(self)
    local newName = nameInputBox:GetText()
    if callbackFunction then
        callbackFunction(newName, icon)
        L.ToyboxFrame:RefreshToyBoxes()
        L.ToyBoxEditFrame:Hide()
    else
        L.ToyJunkie:Print("Callback function not set!")
    end
end)

local cancelButton = CreateFrame("Button", "$parent_CancelButton", L.ToyBoxEditFrame, "UIPanelButtonTemplate")
cancelButton:SetText("Cancel")
cancelButton:SetPoint("BOTTOMRIGHT", -10, 5)
cancelButton:SetWidth(100)
cancelButton:SetScript("OnClick", function(self)
    L.ToyBoxEditFrame:Hide()
end)
L.ToyBoxEditFrame:Hide()

if(JunkieDebug) then
    tjicons = L.ToyBoxEditFrame
end

function L.ToyBoxEditFrame:Open(initialName, initialIcon)
    name = initialName or ""
    icon = initialIcon or 454046

    nameInputBox:SetText(name)
    selectedIcon.texture:SetTexture(icon)
    self:Show()
end

function L.ToyBoxEditFrame:UpdateIcon(id)
    selectedIcon.texture:SetTexture(id)
    icon = id
end

function L.ToyBoxEditFrame:SetCallback(func)
    callbackFunction = func
end