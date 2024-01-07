local addonName, L = ...

local searchText = ""
local colorPickerToyBoxId = nil
local iconToyBoxId = nil
L.ToyJunkie.noInteraction = false

local function ValidateName(newName, oldName)
    local changes = 0 -- 0 = invalid, 1 = duplicate, 2 = valid
    if (newName ~= "") then
        if (newName ~= oldName) then
            if (L:IsToyboxNameDuplicate(newName, false, oldName)) then
                changes = 1
            else
                changes = 2
            end
        end
    end
    return changes
end

local invalidFrame = CreateFrame("Frame", "ToyJunkie_InvalidNameFrame", UIParent, "BackdropTemplate")
invalidFrame:SetBackdrop({
    bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileEdge = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 5, top = 3, bottom = 5 },
})
invalidFrame:ApplyBackdrop()
invalidFrame:SetSize(220, 30)
invalidFrame:SetFrameStrata("TOOLTIP")
invalidFrame.Text = invalidFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
invalidFrame.Text:SetAllPoints()
invalidFrame.Text:SetText("That toy box name already exists")
invalidFrame.Text:SetTextColor(1, 0, 0, 1)
invalidFrame:Hide()

local function toyColorCallback(restore)
    local newR, newG, newB, newA
    if(restore) then
        newR, newG, newB, newA = unpack(restore)
    else
        newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
    end
    L.ToyJunkie.db.profile.boxes[colorPickerToyBoxId].toyColor.red = newR
    L.ToyJunkie.db.profile.boxes[colorPickerToyBoxId].toyColor.green = newG
    L.ToyJunkie.db.profile.boxes[colorPickerToyBoxId].toyColor.blue = newB
    L.ToyJunkie.db.profile.boxes[colorPickerToyBoxId].toyColor.alpha = newA
    L.AttachedFrame.ScrollFrame.listView:Refresh()
end

local function ShowColorPicker(r, g, b, a, changedCallBack)
    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a
    ColorPickerFrame.previousValues = {r,g,b,a}
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallBack, changedCallBack, changedCallBack
    ColorPickerFrame:SetColorRGB(r,g,b)
    ColorPickerFrame:Hide()
    L.ToyJunkie.colorPickerOpened = true
    L.ToyJunkie.noInteraction = true
    ColorPickerFrame:ClearAllPoints()
    ColorPickerFrame:SetPoint("TOPLEFT", L.AttachedFrame, "TOPRIGHT", 5, 0)
    ColorPickerFrame:Show()
end
---------------
-- Backdrops --
---------------

TJ_TOYLISTBACKDROP = {
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
    tile = true,
    tileEdge = true,
    tileSize = 12,
    edgeSize = 12,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
};


AttachedScrollTemplateMixin = {}

local ItemListMixin = CreateFromMixins(CallbackRegistryMixin)
ItemListMixin:GenerateCallbackEvents(
    {
        "OnMouseDown",
        "OnEditCancelMouseDown",
        "OnEditSubmitMouseDown",
        "OnEditTextChanged"
    }
)

function ItemListMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self:SetScript("OnMouseDown", self.OnClick)
    if (self.RenameBox ~= nil) then
        self.RenameBox.Cancel:SetScript("OnMouseDown", self.EditCancelOnClick)
        self.RenameBox.Submit:SetScript("OnMouseDown", self.EditSubmitOnClick)
        self.RenameBox:SetScript("OnEscapePressed", self.EditEscapePressed)
        self.RenameBox:SetScript("OnEnterPressed", self.EditEnterPressed)
        self.RenameBox:SetScript("OnTextChanged", self.EditTextChanged)
    end
end

function ItemListMixin:OnClick(button)
    self:TriggerEvent("OnMouseDown", self, button)
end

function ItemListMixin:EditCancelOnClick(button)
    self:GetParent():GetParent():TriggerEvent("OnEditCancelMouseDown", self, button)
end

function ItemListMixin:EditSubmitOnClick(button)
    self:GetParent():GetParent():TriggerEvent("OnEditSubmitMouseDown", self, button)
end

function ItemListMixin:EditTextChanged(human)
    self:GetParent():TriggerEvent("OnEditTextChanged", self, human)
end

function ItemListMixin:EditEscapePressed()
    self:GetParent():TriggerEvent("OnEditCancelMouseDown", self.Cancel, "LeftButton")
end

function ItemListMixin:EditEnterPressed()
    self:GetParent():TriggerEvent("OnEditSubmitMouseDown", self.Submit, "LeftButton")
end

function ItemListMixin:Init(elementData)
    if (elementData.isHeader) then
        self.Text:SetText(elementData.name)
        self.icon:SetTexture(elementData.icon)
        if (elementData.isCollapsed) then
            self.expandIcon:SetTexture(130838)
        else
            self.expandIcon:SetTexture(130821)
        end
    else
        self.toyCard.Text:SetText(elementData.name)
        self.icon.texture:SetTexture(elementData.icon)
        self.toyCard:SetBackdrop(TJ_TOYLISTBACKDROP)
        self.toyCard:SetBackdropColor(L:GetBackdropColorByToyboxId(elementData.toyBoxId))
    end
end

local ListMixin = {}
function ListMixin:OnLoad()
    CallbackRegistryMixin:OnLoad(self)

    self.scrollView = CreateScrollBoxListLinearView()
    self.scrollView:SetElementFactory(function(factory, data)
        if (data.isHeader) then
            factory("TJ_ToyBoxHeaderTemplate", function(button, data)
                self:OnElementInitialize(button, data)
            end)
        else
            factory("TJ_ToyTemplate", function(button, data)
                self:OnElementInitialize(button, data)
            end)
        end
    end)
    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self))

    self.scrollBox = CreateFrame("Frame", "$parent_ScrollBox", self, "WowScrollBoxList")
    self.scrollBox:SetPoint("TOPLEFT")
    self.scrollBox:SetPoint("BOTTOMRIGHT", -24, 0)

    self.scrollBar = CreateFrame("EventFrame", "$parent_ScrollBar", self, "MinimalScrollBar")
    self.scrollBar:SetPoint("TOPLEFT", self.scrollBox, "TOPRIGHT", 8, 0)
    self.scrollBar:SetPoint("BOTTOMLEFT", self.scrollBox, "BOTTOMRIGHT", 8, 0)

    self.searchBar = CreateFrame("EditBox", "$parent_SearchBar", self, "InputBoxTemplate")
    self.searchBar:SetPoint("BOTTOMLEFT", 5, -38)
    self.searchBar:SetSize(150,40)
    self.searchBar:SetAutoFocus(false)
    self.searchBar:SetScript("OnTextChanged", function(self)
        if(self:GetText() == "") then
            self.Placeholder:Show()
        else
            self.Placeholder:Hide()
        end
        searchText = self:GetText()
        self:GetParent():Refresh()
    end)
    self.searchBar.Placeholder = self.searchBar:CreateFontString("SearchPlaceholder", "OVERLAY", "GameFontDisable")
    self.searchBar.Placeholder:SetText("Search toy boxes")
    self.searchBar.Placeholder:SetPoint("LEFT", 0, 0)
    self.searchBar.Placeholder:SetAlpha(.5)
    self.searchBar.ClearButton = CreateFrame("Button", "$parent_ClearButton", self.searchBar)
    self.searchBar.ClearButton:SetSize(14,14)
    self.searchBar.ClearButton:SetNormalAtlas("Radial_Wheel_Icon_Close")
    self.searchBar.ClearButton:SetPoint("RIGHT", -4, 0)
    self.searchBar.ClearButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Clear search bar")
        GameTooltip:Show()
    end)
    self.searchBar.ClearButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    self.searchBar.ClearButton:SetScript("OnClick", function(self, button)
        self:GetParent():SetText("")
    end)

    ScrollUtil.InitScrollBoxWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView)
end

function ListMixin:OnElementInitialize(element, elementData)
    if (not element.OnLoad) then
        Mixin(element, ItemListMixin)
        element:OnLoad()
    end
    element:Init(elementData)
    element:RegisterCallback("OnMouseDown", self.OnElementClicked, self)
    element:RegisterCallback("OnEditCancelMouseDown", self.OnEditCancelMouseDown, self)
    element:RegisterCallback("OnEditSubmitMouseDown", self.OnEditSubmitMouseDown, self)
    element:RegisterCallback("OnEditTextChanged", self.OnEditTextChanged, self)
end

function ListMixin:OnElementReset(element)
    element:UnregisterCallback("OnMouseDown", self)
    element:UnregisterCallback("OnEditCancelMouseDown", self)
    element:UnregisterCallback("OnEditTextChanged", self)
    element:UnregisterCallback("OnEditSubmitMouseDown", self)
end

function ListMixin:OnEditCancelMouseDown(element)
    element:GetParent():Hide()
    element:GetParent():GetParent().Text:Show()
    L.ToyJunkie.noInteraction = false
    invalidFrame:ClearAllPoints()
    invalidFrame:Hide()
end

function ListMixin:OnEditSubmitMouseDown(element)
    L.ToyJunkie.db.profile.boxes[element:GetParent():GetParent():GetData().id].name = element:GetParent():GetText()
    element:GetParent():Hide()
    element:GetParent():GetParent().Text:Show()
    L.ToyJunkie.noInteraction = false
    self:Refresh()
end

function ListMixin:OnEditTextChanged(renameBox, human)
    if (human) then
        local validate = ValidateName(renameBox:GetText(), renameBox:GetParent().Text:GetText())
        if (validate == 0) then
            renameBox.Submit:Disable()
            invalidFrame:ClearAllPoints()
            invalidFrame:Hide()
        elseif (validate == 1) then
            renameBox.Submit:Disable()
            invalidFrame:SetPoint("BOTTOM", renameBox, "TOP", 0, 0)
            invalidFrame:Show()
        else
            renameBox.Submit:Enable()
            invalidFrame:ClearAllPoints()
            invalidFrame:Hide()
        end
    end
end

function ListMixin:OnElementClicked(element, button)
    if (not L.ToyJunkie.noInteraction) then
        local data = element.GetData()
        if (data.isHeader) then
            if (button == "LeftButton") then
                for key, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
                    if (key == data.id) then
                        L.ToyJunkie.db.profile.boxes[key].isCollapsed = not data.isCollapsed
                    else
                        if (not L.ToyJunkie.db.profile.allowMultipleBoxesOpen) then
                            L.ToyJunkie.db.profile.boxes[key].isCollapsed = true
                        end
                    end
                end
                self:Refresh()
            elseif (button == "RightButton") then
                local headerContext = L:CreateContextMenu(
                    {
                        name = "headerContextMenu",
                        parent = element,
                        title = "Toy box Options",
                        items = {
                            {
                                text = "Rename",
                                tooltipTitle="Rename",
                                tooltipText="Rename the toy box",
                                func = function()
                                    element.Text:Hide()
                                    element.RenameBox:SetText(data.name)
                                    element.RenameBox:Show()
                                    element.RenameBox:SetFocus()
                                    element.RenameBox.Submit:Disable()
                                    L.ToyJunkie.noInteraction = true
                                end
                            },
                            {
                                text = "Change Icon",
                                tooltipTitle = "Change Icon",
                                tooltipText = "Change the toy box icon",
                                func = function()
                                    iconToyBoxId = data.id
                                    L.AttachedFrame.IconSelectionFrame:Show()
                                    L.ToyJunkie.noInteraction = true
                                end
                            },
                            {
                                text = "Change Toy Colors",
                                tooltipTitle = "Change toy color",
                                tooltipText = "Change the background color of the toys in this toy box",
                                func = function()
                                    local colors = L.ToyJunkie.db.profile.boxes[data.id].toyColor
                                    colorPickerToyBoxId = data.id
                                    ShowColorPicker(colors.red, colors.green, colors.blue, colors.alpha, toyColorCallback)
                                end
                            },
                            {
                                separator = true
                            },
                            {
                                text = "Delete Toy box",
                                color = "|cffff0000",
                                tooltipTitle = "Delete toy box",
                                tooltipWarning = "Hold SHIFT to delete this toy box",
                                func = function()
                                    if (IsShiftKeyDown()) then
                                        table.remove(L.ToyJunkie.db.profile.boxes, data.id)
                                        self:Refresh()
                                    end
                                end
                            },
                            {
                                separator = true
                            },
                            {
                                text = "Close"
                            }
                        }
                    }
                )
                ToggleDropDownMenu(1, nil, headerContext, "cursor", 10, 5)
            end
        else

        end
    end
end

function ListMixin:Refresh()
    if (L.ToyJunkie.db.profile.boxes ~= nil) then
        local data = CreateDataProvider()
        for id, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
            local excludeToybox = false
            if (searchText ~= "") then
                if(not L:strContains(toyBox.name, searchText)) then
                    excludeToybox = true
                end
            end
            if (not excludeToybox) then
                data:InsertTable({
                    {
                        id = id,
                        name = toyBox.name,
                        isHeader = true,
                        isCollapsed = toyBox.isCollapsed,
                        icon = toyBox.icon
                    }
                })
                if (not toyBox.isCollapsed) then
                    for _, toyId in pairs(toyBox.toys) do
                        local _, toyName, toyIcon = C_ToyBox.GetToyInfo(toyId)
                        data:InsertTable({
                            { name = toyName, isHeader = false, icon = toyIcon, toyBoxId = id }
                        })
                    end
                end
            end
        end
        self.scrollView:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
    end
end

function ListMixin:GetDataProvider()
    if (self ~= nil) then
        return self.scrollView:GetDataProvider()
    end
end

function ListMixin:SetDataProvider(dataProvider)
    self.scrollView:SetDataProvider(dataProvider)
end

function AttachedScrollTemplateMixin:OnLoad()
    self.dataProvider = CreateDataProvider()

    self.listView = Mixin(CreateFrame("Frame", nil, self), ListMixin)
    self.listView:OnLoad()
    self.listView:SetDataProvider(self.dataProvider)
    self.listView:SetPoint("TOPLEFT")
    self.listView:SetPoint("BOTTOMRIGHT")
end

function AttachedScrollTemplateMixin:AddToybox()
    local newName = ""
    local numList = {}
    for id, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
        toyBox.isCollapsed = true
        if (L:strStart(toyBox.name, "New Toy box")) then
            local num = toyBox.name:match("%((%d+)%)")
            if (num ~= nil) then
                table.insert(numList, num)
            end
        end
    end
    if (#numList > 0) then
        table.sort(numList)
        table.insert(L.ToyJunkie.db.profile.boxes, 1, {
            name = "New Toy box (" .. numList[#numList] + 1 .. ")",
            isCollapsed = true,
            icon = 454046,
            toyColor = {
                red = 0,
                blue = 1,
                green = 0,
                alpha = 0.25
            },
            toys = {}
        })
    else
        table.insert(L.ToyJunkie.db.profile.boxes, 1, {
            name = "New Toy box (1)",
            isCollapsed = true,
            icon = 454046,
            toyColor = {
                red = 0,
                blue = 1,
                green = 0,
                alpha = 0.25
            },
            toys = {}
        })
    end
    self.listView:Refresh()
    self.listView.scrollBox:ScrollToBegin()
end

function AttachedScrollTemplateMixin:UpdateIcon(newId)
    if(iconToyBoxId ~= nil) then
        L.ToyJunkie.db.profile.boxes[iconToyBoxId].icon = newId
        L.AttachedFrame.ScrollFrame.listView:Refresh()
    end
end

function AttachedScrollTemplateMixin:GetIcon()
    if(iconToyBoxId ~= nil) then
        return L.ToyJunkie.db.profile.boxes[iconToyBoxId].icon
    end
end