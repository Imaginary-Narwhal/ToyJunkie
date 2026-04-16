local addon, L = ...

local callbackFunction = nil
local name = ""
local icon = 0
local id = 0

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

local saveButton = CreateFrame("Button", "$parent_SaveButton", L.ToyBoxEditFrame, "UIMenuButtonStretchTemplate")
saveButton:SetText("Okay")
saveButton:SetPoint("BOTTOMRIGHT", -110, 3)
saveButton:SetSize(100, 23)
saveButton:SetScript("OnClick", function(self)
    if(nameInputBox:GetText() == "" or nameInputBox:GetText():match("^%s*$")) then
        L.ModalContainer:Open(IN_MODAL.Okay, "Toy box name", "Toy box must have a name.")
        return
    end

    if(L:IsToyboxNameDuplicate(nameInputBox:GetText(), false, name)) then
        L.ModalContainer:Open(IN_MODAL.Okay, "Toy box name", "Toy box name already exists, please try another.")
        return
    end

    if callbackFunction then
        callbackFunction(id, nameInputBox:GetText(), icon, false)
        L.ToyBoxEditFrame:Hide()
    else
        L.ToyJunkie:Print("Callback function not set!")
    end
end)

local cancelButton = CreateFrame("Button", "$parent_CancelButton", L.ToyBoxEditFrame, "UIMenuButtonStretchTemplate")
cancelButton:SetText("Cancel")
cancelButton:SetPoint("BOTTOMRIGHT", -10, 3)
cancelButton:SetSize(100, 23)
cancelButton:SetScript("OnClick", function(self)
    L.ToyBoxEditFrame:Hide()
end)
L.ToyBoxEditFrame:Hide()

local deleteButton = CreateFrame("Button", "$parent_DeleteButton", L.ToyBoxEditFrame, "UIPanelButtonTemplate")
deleteButton:SetText("Delete")
deleteButton:SetPoint("BOTTOMLEFT", 10, 4)
deleteButton:SetWidth(100)
deleteButton:SetScript("OnClick", function(self)
    L.ModalContainer:Open(IN_MODAL.YesNo, 
        "Delete toy box [" .. name .. "]", 
        "Are you sure you want to delete this toy box? This cannot be undone.",
        function(result)
            if(result == IN_MODAL_RESULT.Yes) then
                callbackFunction(id, name, icon, true)
                L.ToyBoxEditFrame:Hide()
            end
        end
    )
end)

if(JunkieDebug) then
    tjicons = L.ToyBoxEditFrame
end

function L.ToyBoxEditFrame:Open(toyBoxId)
    id = toyBoxId
    name = L.ToyJunkie.db.profile.boxes[toyBoxId].name
    icon = L.ToyJunkie.db.profile.boxes[toyBoxId].icon

    nameInputBox:SetText(name)
    selectedIcon.texture:SetTexture(icon)
    self:Show()
    nameInputBox:SetFocus()
    deleteButton:Show()
end

function L.ToyBoxEditFrame:New()
    id = 0
    name = ""
    icon = 454046

    nameInputBox:SetText("")
    selectedIcon.texture:SetTexture(icon)
    self:Show()
    nameInputBox:SetFocus()
    deleteButton:Hide()
end


function L.ToyBoxEditFrame:UpdateIcon(id)
    selectedIcon.texture:SetTexture(id)
    icon = id
end

function L.ToyBoxEditFrame:SetCallback(func)
    callbackFunction = func
end
