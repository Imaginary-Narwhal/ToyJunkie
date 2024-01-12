local addonName, L = ...

local searchText = ""
local colorPickerToyBoxId = nil
local iconToyBoxId = nil

L.ToyJunkie.noInteraction = false
local movingHeader = nil
local movingToy = nil
local firstMove = false


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
    if (restore) then
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
    ColorPickerFrame.previousValues = { r, g, b, a }
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallBack, changedCallBack,
        changedCallBack
    ColorPickerFrame:SetColorRGB(r, g, b)
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
        "OnMouseUp",
        "OnEditCancelMouseDown",
        "OnEditSubmitMouseDown",
        "OnEditTextChanged",
        "OnReceiveDrag",
        "OnDragStart"
    }
)

function ItemListMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self:SetScript("OnMouseUp", self.OnClick)
    self:SetScript("OnReceiveDrag", self.OnReceiveDrag)
    self:SetScript("OnDragStart", self.OnDragStart)
    if (self.RenameBox ~= nil) then
        self.RenameBox.Cancel:SetScript("OnMouseDown", self.EditCancelOnClick)
        self.RenameBox.Submit:SetScript("OnMouseDown", self.EditSubmitOnClick)
        self.RenameBox:SetScript("OnEscapePressed", self.EditEscapePressed)
        self.RenameBox:SetScript("OnEnterPressed", self.EditEnterPressed)
        self.RenameBox:SetScript("OnTextChanged", self.EditTextChanged)
    end
end

function ItemListMixin:OnClick(button)
    self:TriggerEvent("OnMouseUp", self, button)
end

function ItemListMixin:OnReceiveDrag()
    self:TriggerEvent("OnReceiveDrag", self)
end

function ItemListMixin:OnDragStart()
    self:TriggerEvent("OnDragStart", self)
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
    if (elementData.pickedUp) then
        self:SetAlpha(.25)
        if (elementData.isHeader) then
            self.expandIcon:Hide()
        end
    else
        self:SetAlpha(1)
        if (elementData.isHeader) then
            self.expandIcon:Show()
        end
    end
    self.isTJListFrame = true
    self:RegisterForDrag("LeftButton")
end

local ListMixin = {}
function ListMixin:OnLoad()
    CallbackRegistryMixin:OnLoad(self)
    self:SetScript("OnEvent", function(self, event, button)
        if (event == "GLOBAL_MOUSE_UP") then
            if (not firstMove) then
                if (button == "RightButton") then
                    if (movingHeader) then
                        SetCursor(nil)
                        ClearCursor()
                        L.ToyJunkie.DragHeader:Hide()
                        movingHeader = nil
                        self:Refresh()
                        L.ToyJunkie.DragBackdrop:Hide()
                    end
                elseif (button == "LeftButton") then
                    if (movingHeader) then
                        local element = GetMouseFocus()
                        if (element.isTJListFrame) then
                            local elementData = element:GetData()
                            if (elementData.isHeader) then
                                if (elementData.name == movingHeader.name) then
                                    SetCursor(nil)
                                    ClearCursor()
                                    L.ToyJunkie.DragHeader:Hide()
                                    movingHeader = nil
                                    self:Refresh()
                                    L.ToyJunkie.DragBackdrop:Hide()
                                else
                                    table.remove(L.ToyJunkie.db.profile.boxes, movingHeader.id)
                                    table.insert(L.ToyJunkie.db.profile.boxes, elementData.id, movingHeader)
                                    SetCursor(nil)
                                    ClearCursor()
                                    L.ToyJunkie.DragHeader:Hide()
                                    movingHeader = nil
                                    self:Refresh()
                                    L.ToyJunkie.DragBackdrop:Hide()
                                end
                            end
                        elseif (element == L.ToyJunkie.DragBackdrop) then
                            SetCursor(nil)
                            ClearCursor()
                            L.ToyJunkie.DragHeader:Hide()
                            movingHeader = nil
                            self:Refresh()
                            L.ToyJunkie.DragBackdrop:Hide()
                        end
                    end
                end
            else
                firstMove = false
            end
        end
    end)

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
    sb = self.searchBar
    self.searchBar:SetPoint("TOPLEFT", 60, 38)
    self.searchBar:SetSize(150, 40)
    self.searchBar:SetAutoFocus(false)
    self.searchBar:SetScript("OnTextChanged", function(self)
        if (self:GetText() == "") then
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
    self.searchBar.ClearButton:SetSize(14, 14)
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

    self.ExpandCollapseButton = CreateFrame("Button", "$parent_ExpandCollapseButton", self, "BackdropTemplate")
    self.ExpandCollapseButton:SetSize(50, 22)
    self.ExpandCollapseButton:SetBackdrop(BACKDROP_TOAST_12_12)
    self.ExpandCollapseButton:SetPoint("TOPLEFT", 0, 29)
    self.ExpandCollapseButton.icon = self.ExpandCollapseButton:CreateTexture(nil, "ARTWORK")
    self.ExpandCollapseButton.icon:SetSize(20, 20)
    self.ExpandCollapseButton.icon:SetPoint("LEFT")
    self.ExpandCollapseButton.text = self.ExpandCollapseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.ExpandCollapseButton.text:SetText("All")
    self.ExpandCollapseButton.text:SetPoint("RIGHT", -10, 0)
    self.ExpandCollapseButton:SetScript("OnClick", function(self)
        L.AttachedFrame.ScrollFrame.listView:ExpandCollapseAll()
        GameTooltip:Hide()
    end)
    self.ExpandCollapseButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        if (L.AttachedFrame.ScrollFrame.listView:AreAnyHeadersExpanded()) then
            GameTooltip:AddLine("Collapse all toy boxes")
        else
            GameTooltip:AddLine("Expand all toy boxes")
        end
        GameTooltip:Show()
    end)
    self.ExpandCollapseButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    ScrollUtil.InitScrollBoxWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView)
end

function ListMixin:OnElementInitialize(element, elementData)
    if (not element.OnLoad) then
        Mixin(element, ItemListMixin)
        element:OnLoad()
    end
    element:Init(elementData)
    element:RegisterCallback("OnMouseUp", self.OnElementClicked, self)
    element:RegisterCallback("OnEditCancelMouseDown", self.OnEditCancelMouseDown, self)
    element:RegisterCallback("OnEditSubmitMouseDown", self.OnEditSubmitMouseDown, self)
    element:RegisterCallback("OnEditTextChanged", self.OnEditTextChanged, self)
    element:RegisterCallback("OnReceiveDrag", self.OnReceiveDrag, self)
    element:RegisterCallback("OnDragStart", self.OnDragStart, self)
end

function ListMixin:OnElementReset(element)
    element:UnregisterCallback("OnMouseUp", self)
    element:UnregisterCallback("OnEditCancelMouseDown", self)
    element:UnregisterCallback("OnEditTextChanged", self)
    element:UnregisterCallback("OnEditSubmitMouseDown", self)
    element:UnregisterCallback("OnReceiveDrag", self)
    element:UnregisterCallback("OnDragStart", self)
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

function ListMixin:OnDragStart(element)
    local data = element:GetData()
    if (movingHeader == nil and movingToy == nil and GetCursorInfo() == nil) then
        if (data.isHeader) then
            firstMove = true
            movingHeader = data
            self:CollapseHeaders()
            L.ToyJunkie.DragBackdrop:Show()
            SetCursor("ITEM_CURSOR")
            L.ToyJunkie.DragHeader.Text:SetText(data.name)
            L.ToyJunkie.DragHeader.Icon:SetTexture(data.icon)
            L.ToyJunkie.DragHeader:Show()
        else
            print("toy draggin")
        end
    end
end

function ListMixin:OnReceiveDrag(element)
    if (not L.ToyJunkie.noInteraction) then
        local data = element.GetData()
        if (GetCursorInfo() ~= nil) then
            if (data.isHeader) then
                local itemType, toyId = GetCursorInfo()
                if (itemType == "item") then
                    if (C_ToyBox.GetToyInfo(toyId) ~= nil) then
                        L:AddToy(toyId, data.id)
                        ClearCursor()
                        self:Refresh()
                    end
                end
            else
                local itemType, toyId = GetCursorInfo()
                local elementId
                for key, toy in pairs(L.ToyJunkie.db.profile.boxes[data.toyBoxId].toys) do
                    if (toy == data.toyId) then
                        elementId = key
                    end
                end
                if (itemType == "item") then
                    if (C_ToyBox.GetToyInfo(toyId) ~= nil) then
                        L:AddToy(toyId, data.toyBoxId, elementId or 1)
                        ClearCursor()
                        self:Refresh()
                    end
                end
            end
            --[[elseif (L.ToyJunkie.movingHeader ~= nil) then
            if(data.isHeader) then
                if(data.id == L.ToyJunkie.movingHeader) then
                    L.ToyJunkie.movingHeader = nil
                    L.ToyJunkie.DragBackdrop:Hide()
                    SetCursor(nil)
                    L.ToyJunkie.DragHeader:Hide()
                    self:Refresh()
                end
            end]]
        end
    end
end

function ListMixin:OnElementClicked(element, button)
    if (not L.ToyJunkie.noInteraction) then
        local data = element.GetData()
        if (GetCursorInfo() == nil and movingHeader == nil and movingToy == nil) then
            if (data.isHeader) then
                if (button == "LeftButton") then
                    L.ToyJunkie.db.profile.boxes[data.id].isCollapsed = not data.isCollapsed
                    self:Refresh()
                    self:SetExpandCollapseButton()
                elseif (button == "RightButton") then
                    local headerContext = L:CreateContextMenu(
                        {
                            name = "headerContextMenu",
                            parent = element,
                            title = "Toy box Options",
                            items = {
                                {
                                    text = "Rename",
                                    tooltipTitle = "Rename",
                                    tooltipText = "Rename the toy box",
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
                                        ShowColorPicker(colors.red, colors.green, colors.blue, colors.alpha,
                                            toyColorCallback)
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
                if (button == "RightButton") then
                    local toyContext = L:CreateContextMenu({
                        name = "toyContextMenu",
                        parent = element,
                        title = "Toy Options",
                        items = {
                            {
                                text = "Remove Toy",
                                color = "|cffff0000",
                                tooltipTitle = "Remove Toy",
                                tooltipText = "Remove toy from this toy box",
                                func = function()
                                    for key, toy in pairs(L.ToyJunkie.db.profile.boxes[data.toyBoxId].toys) do
                                        if (toy == data.toyId) then
                                            table.remove(L.ToyJunkie.db.profile.boxes[data.toyBoxId].toys, key)
                                        end
                                    end
                                    self:Refresh()
                                end
                            },
                            {
                                separator = true
                            },
                            {
                                text = "Close"
                            }
                        }
                    })
                    ToggleDropDownMenu(1, nil, toyContext, "cursor", 10, 5)
                end
            end
        else
            if (GetCursorInfo() ~= nil) then
                if (data.isHeader) then
                    local itemType, toyId = GetCursorInfo()
                    if (itemType == "item") then
                        if (C_ToyBox.GetToyInfo(toyId) ~= nil) then
                            L:AddToy(toyId, data.id)
                            ClearCursor()
                            self:Refresh()
                        end
                    end
                else
                    local itemType, toyId = GetCursorInfo()
                    local elementId
                    for key, toy in pairs(L.ToyJunkie.db.profile.boxes[data.toyBoxId].toys) do
                        if (toy == data.toyId) then
                            elementId = key
                        end
                    end
                    if (itemType == "item") then
                        if (C_ToyBox.GetToyInfo(toyId) ~= nil) then
                            L:AddToy(toyId, data.toyBoxId, elementId or 1)
                            ClearCursor()
                            self:Refresh()
                        end
                    end
                end
            elseif (L.ToyJunkie.movingHeader ~= nil) then

            end
        end
    end
end

function ListMixin:Refresh()
    if (L.ToyJunkie.db.profile.boxes ~= nil) then
        local data = CreateDataProvider()
        for id, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
            local excludeToybox = false
            if (searchText ~= "") then
                if (not L:strContains(toyBox.name, searchText)) then
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
                        icon = toyBox.icon,
                        pickedUp = self:IsPickedUp(id, true)
                    }
                })
                if (not toyBox.isCollapsed) then
                    for _, toyId in pairs(toyBox.toys) do
                        local _, toyName, toyIcon = C_ToyBox.GetToyInfo(toyId)
                        data:InsertTable({
                            {
                                name = toyName,
                                isHeader = false,
                                icon = toyIcon,
                                toyBoxId = id,
                                toyId = toyId,
                                pickedUp = self:IsPickedUp(toyId, false)
                            }
                        })
                    end
                end
            end
        end
        self.scrollView:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
    end
end

function ListMixin:IsPickedUp(id, isHeader)
    if (isHeader) then
        if (movingHeader) then
            if (movingHeader.id == id) then
                return true
            else
                return false
            end
        end
    else
        if (movingToy) then
            if (L.ToyJunkie.movingToy.toyId == id) then
                return true
            else
                return false
            end
        end
    end
    return false
end

function ListMixin:GetDataProvider()
    if (self ~= nil) then
        return self.scrollView:GetDataProvider()
    end
end

function ListMixin:SetDataProvider(dataProvider)
    self.scrollView:SetDataProvider(dataProvider)
end

function ListMixin:CollapseHeaders()
    for id, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
        toyBox.isCollapsed = true
    end
    self:Refresh()
    self:SetExpandCollapseButton()
end

function ListMixin:AreAnyHeadersExpanded()
    for k, v in pairs(self:GetDataProvider().collection) do
        if (not v.isCollapsed) then
            return true
        end
    end
    return false
end

function ListMixin:SetExpandCollapseButton()
    if (self:AreAnyHeadersExpanded()) then
        self.ExpandCollapseButton.icon:SetTexture(130821)
    else
        self.ExpandCollapseButton.icon:SetTexture(130838)
    end
end

function ListMixin:ExpandCollapseAll()
    for id, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
        toyBox.isCollapsed = self:AreAnyHeadersExpanded()
    end
    self:Refresh()
    self:SetExpandCollapseButton()
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
    if (iconToyBoxId ~= nil) then
        L.ToyJunkie.db.profile.boxes[iconToyBoxId].icon = newId
        L.AttachedFrame.ScrollFrame.listView:Refresh()
    end
end

function AttachedScrollTemplateMixin:GetIcon()
    if (iconToyBoxId ~= nil) then
        return L.ToyJunkie.db.profile.boxes[iconToyBoxId].icon
    end
end
