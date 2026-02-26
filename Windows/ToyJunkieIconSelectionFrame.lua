local addon, L = ...

local callbackFunction = nil
local name = ""
local icon = 0
local color = {red = 0, green = 0, blue = 1, alpha = 0.25}

L.ToyBoxEditFrame = CreateFrame("Frame", "ToyJunkie_ToyBoxEditFrame", UIParent, "ButtonFrameBaseTemplate")
ButtonFrameTemplate_HidePortrait(L.ToyBoxEditFrame)
L.ToyBoxEditFrame:SetTitle("Edit ToyBox")
L.ToyBoxEditFrame:SetFrameStrata("DIALOG")
L.ToyBoxEditFrame.CloseButton:Hide()
L.ToyBoxEditFrame:SetPoint("CENTER")
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
nameInputBox:SetPoint("TOPLEFT", 15, -34)
nameInputBox:SetSize(250,40)
nameInputBox:SetAutoFocus(false)

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
        callbackFunction(newName, icon, color)
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

function L.ToyBoxEditFrame:Open(initialName, initialIcon, initialColor)
    name = initialName or ""
    icon = initialIcon or 454046
    color = initialColor or {red = 0, green= 0, blue = 1, alpha = 0.25}
    self:Show()
end

function L.ToyBoxEditFrame:SetCallback(func)
    callbackFunction = func
end

L.ToyBoxEditFrame:SetCallback(function(savedName, savedIcon, savedColor)
    print("Saved values:", savedName, savedIcon)
    print("Color:", savedColor.red, savedColor.green, savedColor.blue, savedColor.alpha)
    L.ToyBoxEditFrame:Hide()
end)

L.ToyBoxEditFrame:Open("Test", 454046, {red = 1, green=0,blue=0.5,alpha=0.25})