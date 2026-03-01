local addonName, L = ...

local searchText = ""
local colorPickerToyBoxId = nil
local iconToyBoxId = nil

L.ToyJunkie.noInteraction = false
local movingHeader = nil
local movingToy = nil


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


L.AttachedScrollTemplateMixin = {}

local ItemListMixin = CreateFromMixins(CallbackRegistryMixin)
ItemListMixin:GenerateCallbackEvents(
    {
        "OnMouseUp",
        "OnReceiveDrag",
        "OnDragStart",
        "OnEnter",
        "OnLeave"
    }
)

function ItemListMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self:SetScript("OnMouseUp", self.OnClick)
    self:SetScript("OnReceiveDrag", self.OnReceiveDrag)
    self:SetScript("OnDragStart", self.OnDragStart)
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)
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

function ItemListMixin:OnEnter()
    if(self.GetData().isHeader and self.GetData().id ~= "special") then
        self.EditButton:Show()
    end
    if(not self.GetData().isHeader) then
        self.DeleteToyButton:Show()
    end
    self:TriggerEvent("OnEnter", self)
end

function ItemListMixin:OnLeave()
    if(self.GetData().isHeader) then
        self.EditButton:Hide()  
    else
        self.DeleteToyButton:Hide()

    end
    self:TriggerEvent("OnLeave", self)
end

function ItemListMixin:Init(elementData)
    if (elementData.isHeader) then
        self.Text:SetText(elementData.name)
        self.icon:SetTexture(elementData.icon)
        if(#L.ToyJunkie.db.profile.boxes[elementData.id].toys > 99) then
            self.counterText:SetText("--")
        else
            self.counterText:SetText(#L.ToyJunkie.db.profile.boxes[elementData.id].toys)
        end
        if (elementData.isCollapsed) then
            self.expandIcon:SetTexture(130838)
        else
            self.expandIcon:SetTexture(130821)
        end
        local w = self:GetWidth()
        self.highlightLeft:SetWidth(w / 2)
        self.highlightRight:SetWidth(w / 2)
        self.highlightLeft:Hide()
        self.highlightRight:Hide()
    else
        self.toyCard.Text:SetText(elementData.name)
        self.icon.texture:SetTexture(elementData.icon)
        self.toyCard:SetBackdrop(TJ_TOYLISTBACKDROP)
        self.toyCard:SetBackdropColor(0,0,1,0.25)
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
    self:RegisterEvent("CURSOR_CHANGED")

    CallbackRegistryMixin.OnLoad(self)
    self:SetScript("OnEvent", function(self, event, button)
        if (event == "CURSOR_CHANGED" and L.AttachedFrame:IsVisible()) then
            if (L:CursorHasToy() or movingHeader) then
                L.ToyJunkie.DragBackdrop:Show()
            else
                L.ToyJunkie.DragBackdrop:Hide()
            end
        end
        if (event == "GLOBAL_MOUSE_UP") then
            if (button == "RightButton") then
                if (movingHeader or movingToy) then
                    SetCursor(nil)
                    ClearCursor()
                    L.ToyJunkie.DragHeader:Hide()
                    movingHeader = nil
                    movingToy = nil
                    self:Refresh()
                    L.ToyJunkie.DragBackdrop:Hide()
                end
            elseif (button == "LeftButton") then
                if (movingHeader) then -- Grabbed Header from ToyJunkie Frame
                    local element = GetMouseFoci()[1]
                    if (element.isTJListFrame) then
                        local elementData = element:GetData()
                        if (elementData.isHeader) then
                            if (elementData.name == movingHeader.name) then
                                SetCursor(nil)
                                ClearCursor()
                                L.ToyJunkie.DragHeader:Hide()
                                movingHeader = nil
                                self:Refresh()
                                L.ToyboxFrame:RefreshToyBoxes()
                                L.ToyJunkie.DragBackdrop:Hide()
                            else
                                local box = L.ToyJunkie.db.profile.boxes[movingHeader.id]
                                table.remove(L.ToyJunkie.db.profile.boxes, movingHeader.id)
                                for id, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
                                    if (toyBox.name == elementData.name) then
                                        if (L:CursorOnTopHalf(element)) then
                                            table.insert(L.ToyJunkie.db.profile.boxes, id, box)
                                        else
                                            table.insert(L.ToyJunkie.db.profile.boxes, id + 1, box)
                                        end
                                        break
                                    end
                                end
                                SetCursor(nil)
                                ClearCursor()
                                L.ToyJunkie.DragHeader:Hide()
                                movingHeader = nil
                                self:Refresh()
                                L.ToyboxFrame:RefreshToyBoxes()
                                L.ToyJunkie.DragBackdrop:Hide()
                            end
                        end
                    end
                elseif (L:CursorHasToy() and not movingToy) then -- Grabbed toy from Blizzard Collection Frame
                    local element = GetMouseFoci()[1]
                    if (element.isTJListFrame) then
                        local elementData = element:GetData()
                        local _, toyId = GetCursorInfo()
                        if (elementData.isHeader) then
                            L:AddToy(toyId, elementData.id)
                            ClearCursor()
                            self:Refresh()
                            L.ToyJunkie.DragBackdrop:Hide()
                        else
                            for id, toy in pairs(L.ToyJunkie.db.profile.boxes[elementData.toyBoxId].toys) do
                                if (toy == elementData.toyId) then
                                    if (L:CursorOnTopHalf(element)) then
                                        L:AddToy(toyId, elementData.toyBoxId, id)
                                        break
                                    else
                                        L:AddToy(toyId, elementData.toyBoxId, id + 1)
                                        break
                                    end
                                end
                            end
                            ClearCursor()
                            self:Refresh()
                            L.ToyJunkie.DragBackdrop:Hide()
                        end
                    end
                elseif (movingToy) then
                    local element = GetMouseFoci()[1]
                    if (element.isTJListFrame) then
                        local elementData = element:GetData()
                        local _, toyId = GetCursorInfo()
                        if (elementData.isHeader) then
                            if (movingToy.toyBoxId == L:GetToyboxId(elementData)) then -- move toy to same toy box that you pulled from
                                ClearCursor()
                                SetCursor(nil)
                                movingToy = nil
                                self:Refresh()
                                L.ToyJunkie.DragBackdrop:Hide()
                            else -- Different toy box (drop on toy box name)
                                if (not L:CheckIfToyExistsInToybox(toyId, elementData.id)) then
                                    for key, id in pairs(L.ToyJunkie.db.profile.boxes[movingToy.toyBoxId].toys) do
                                        if (id == toyId) then
                                            table.remove(L.ToyJunkie.db.profile.boxes[movingToy.toyBoxId].toys, key)
                                            break
                                        end
                                    end
                                    L:AddToy(toyId, elementData.id)
                                end
                                ClearCursor()
                                SetCursor(nil)
                                movingToy = nil
                                self:Refresh()
                                L.ToyJunkie.DragBackdrop:Hide()
                            end
                        else                                                     -- move toy to different location in same or different toybox
                            if (elementData.toyBoxId == movingToy.toyBoxId) then -- same toybox
                                if (elementData.toyId == movingToy.toyId) then   --same toy
                                    ClearCursor()
                                    SetCursor(nil)
                                    movingToy = nil
                                    self:Refresh()
                                    L.ToyJunkie.DragBackdrop:Hide()
                                else
                                    for key, id in pairs(L.ToyJunkie.db.profile.boxes[movingToy.toyBoxId].toys) do
                                        if (id == toyId) then
                                            table.remove(L.ToyJunkie.db.profile.boxes[movingToy.toyBoxId].toys, key)
                                            break
                                        end
                                    end
                                    local elementIndex = L:GetToyIndex(elementData.toyId, elementData.toyBoxId)
                                    for id, toy in pairs(L.ToyJunkie.db.profile.boxes[elementData.toyBoxId].toys) do
                                        if(toy == elementData.toyId) then
                                            if(L:CursorOnTopHalf(element)) then
                                                L:AddToy(toyId, elementData.toyBoxId, elementIndex)
                                                break
                                            else
                                                L:AddToy(toyId, elementData.toyBoxId, elementIndex + 1)
                                                break
                                            end
                                        end
                                    end
                                    ClearCursor()
                                    SetCursor(nil)
                                    movingToy = nil
                                    self:Refresh()
                                    L.ToyJunkie.DragBackdrop:Hide()
                                end
                            else -- different toyboxes
                                local elementIndex = L:GetToyIndex(elementData.toyId, elementData.toyBoxId)
                                if (not L:CheckIfToyExistsInToybox(toyId, elementData.toyBoxId)) then
                                    for key, id in pairs(L.ToyJunkie.db.profile.boxes[movingToy.toyBoxId].toys) do
                                        if (id == toyId) then
                                            table.remove(L.ToyJunkie.db.profile.boxes[movingToy.toyBoxId].toys, key)
                                            break
                                        end
                                    end
                                    if (L:CursorOnTopHalf(element)) then
                                        L:AddToy(toyId, elementData.toyBoxId, elementIndex)
                                    else
                                        L:AddToy(toyId, elementData.toyBoxId, elementIndex + 1)
                                    end
                                end
                                ClearCursor()
                                SetCursor(nil)
                                movingToy = nil
                                self:Refresh()
                                L.ToyJunkie.DragBackdrop:Hide()
                            end
                        end
                    end
                end
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

    self:SetScript("OnUpdate", self.OnUpdate)
end

function ListMixin:OnUpdate(self, elapsed)
    local element = GetMouseFoci()[1]
    if (element and element.isTJListFrame) then
        if (movingHeader) then
            local elementData = element.GetData()
            if (elementData.isHeader) then
                if (elementData.name ~= movingHeader.name) then
                    L.ToyJunkie.DropLineFrame:Display(element)
                else
                    L.ToyJunkie.DropLineFrame:Hide()
                end
            else
                L.ToyJunkie.DropLineFrame:Hide()
            end
        elseif (L:CursorHasToy()) then
            local elementData = element.GetData()
            if (not elementData.isHeader) then
                if (movingToy) then
                    if (elementData.toyId == movingToy.toyId and elementData.toyBoxId == movingToy.toyBoxId) then
                        L.ToyJunkie.DropLineFrame:Hide()
                    else
                        L.ToyJunkie.DropLineFrame:Display(element)
                    end
                else
                    L.ToyJunkie.DropLineFrame:Display(element)
                end
            else
                L.ToyJunkie.DropLineFrame:Hide()
            end
        else
            if (L.ToyJunkie.DropLineFrame:IsShown()) then
                L.ToyJunkie.DropLineFrame:Hide()
            end
        end
    else
        if (L.ToyJunkie.DropLineFrame:IsShown()) then
            L.ToyJunkie.DropLineFrame:Hide()
        end
    end
end

function ListMixin:OnElementInitialize(element, elementData)
    if (not element.OnLoad) then
        Mixin(element, ItemListMixin)
        element:OnLoad()
    end
    element:Init(elementData)
    element:RegisterCallback("OnMouseUp", self.OnElementClicked, self)
    element:RegisterCallback("OnDragStart", self.OnDragStart, self)
    element:RegisterCallback("OnEnter", self.OnEnter, self)
    element:RegisterCallback("OnLeave", self.OnLeave, self)
end

function ListMixin:OnElementReset(element)
    element:UnregisterCallback("OnMouseUp", self)
    element:UnregisterCallback("OnDragStart", self)
    element:UnregisterCallback("OnEnter", self)
    element:UnregisterCallback("OnLeave", self)
end

function ListMixin:OnEnter(element)
    local data = element:GetData()
    if (data.isHeader) then
        if (L:CursorHasToy() or movingToy) then
            element.highlightLeft:Show()
            element.highlightRight:Show()
        end
    end
end

function ListMixin:OnLeave(element)
    local data = element:GetData()
    if (data.isHeader) then
        if (L:CursorHasToy() or movingToy) then
            element.highlightLeft:Hide()
            element.highlightRight:Hide()
        end
    end
end

function ListMixin:OnDragStart(element)
    ar = self
    local data = element:GetData()
    if (movingHeader == nil and movingToy == nil and GetCursorInfo() == nil) then
        if(data.id ~= "special") then
            if (data.isHeader) then
                movingHeader = data
                self:CollapseHeaders()
                L.ToyJunkie.DragBackdrop:Show()
                SetCursor("ITEM_CURSOR")
                L.ToyJunkie.DragHeader.Text:SetText(data.name)
                L.ToyJunkie.DragHeader.Icon:SetTexture(data.icon)
                L.ToyJunkie.DragHeader:Show()
            else
                movingToy = data
                C_Item.PickupItem(data.toyId)
                self:Refresh()
            end
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
                end
            --[[else
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
                                            L.ToyboxFrame:UpdateToyButtons()
                                            L.ToyboxFrame:SelectNewRandomToy()
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
                end]]
            end
        end
    end
end

function ListMixin:Refresh()
    if (L.ToyJunkie.db.profile.boxes ~= nil) then
        local data = CreateDataProvider()
        for id, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
            if(movingHeader ~= nil and id == "special") then
                break
            end
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
                    if (toyBox.toys) then
                        for _, toyId in pairs(toyBox.toys) do
                            local _, toyName, toyIcon = C_ToyBox.GetToyInfo(toyId)
                            data:InsertTable({
                                {
                                    name = toyName,
                                    isHeader = false,
                                    icon = toyIcon,
                                    toyBoxId = id,
                                    toyId = toyId,
                                    pickedUp = self:IsPickedUp(toyId, false, id)
                                }
                            })
                        end
                    end
                end
            end
        end
        self.scrollView:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
    end
end

function ListMixin:IsPickedUp(id, isHeader, toyBoxId)
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
            if (movingToy.toyId == id and movingToy.toyBoxId == toyBoxId) then
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
    if (not movingHeader) then
        for id, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
            toyBox.isCollapsed = self:AreAnyHeadersExpanded()
        end
        self:Refresh()
        self:SetExpandCollapseButton()
    end
end

function L.AttachedScrollTemplateMixin:OnLoad()
    self.dataProvider = CreateDataProvider()

    self.listView = Mixin(CreateFrame("Frame", nil, self), ListMixin)
    self.listView:OnLoad()
    self.listView:SetDataProvider(self.dataProvider)
    self.listView:SetPoint("TOPLEFT")
    self.listView:SetPoint("BOTTOMRIGHT")
end

function L.AttachedScrollTemplateMixin:AddToybox()
    L.ToyBoxEditFrame:New()
    L.ToyBoxEditFrame:SetCallback(function(id, newName, newIcon, delete)
        if(#L.ToyJunkie.db.profile.boxes < 1) then
            L.ToyJunkie.db.profile.selectedToybox = newName
        end

        table.insert(L.ToyJunkie.db.profile.boxes, 1, {
            name = newName,
            isCollapsed = true,
            icon = newIcon,
            toys = {}
        })
        self.listView:Refresh()
        self.listView.scrollBox:ScrollToBegin()
        L.ToyboxFrame:RefreshToyBoxes()
    end)
end

function L.AttachedScrollTemplateMixin:UpdateIcon(newId)
    if (iconToyBoxId ~= nil) then
        L.ToyJunkie.db.profile.boxes[iconToyBoxId].icon = newId
        L.AttachedFrame.ScrollFrame.listView:Refresh()
    end
end

function L.AttachedScrollTemplateMixin:GetIcon()
    if (iconToyBoxId ~= nil) then
        return L.ToyJunkie.db.profile.boxes[iconToyBoxId].icon
    end
end

function TJ_EditToyBox(element)
    local toyBox = element:GetData()
    L.ToyBoxEditFrame:Open(toyBox.id)
    L.ToyBoxEditFrame:SetCallback(function(id, newName, newIcon, delete)
        if(not delete) then
            local editToybox = L.ToyJunkie.db.profile.boxes[id]
            editToybox.name = newName
            editToybox.icon = newIcon
            L.AttachedFrame.ScrollFrame.listView:Refresh()
            L.ToyboxFrame:RefreshToyBoxes()
            L.ToyBoxEditFrame:Hide()
        else
            local editToybox = L.ToyJunkie.db.profile.boxes[id]
            table.remove(L.ToyJunkie.db.profile.boxes, id)
            if(#L.ToyJunkie.db.profile.boxes > 0) then
                if(L.ToyJunkie.db.profile.selectedToybox == editToybox.name) then
                    L.ToyJunkie.db.profile.selectedToybox = L.ToyJunkie.db.profile.boxes[1].name
                end
                L.ToyboxFrame:RefreshToyBoxes()
                L.ToyboxFrame:SelectNewRandomToy()
                L.ToyboxFrame:UpdateToyButtons()
            else
                L.ToyJunkie.db.profile.selectedToybox = nil
                L.ToyboxFrame:Toggle(true, "CLOSE")
            end
            L.AttachedFrame.ScrollFrame.listView:Refresh()
        end
    end)
end

function TJ_RemoveToy(element)
    local cToy = element:GetData()
    print(cToy.name)
    for k, toy in pairs(L.ToyJunkie.db.profile.boxes[cToy.toyBoxId].toys) do
        if(cToy.toyId == toy) then
            table.remove(L.ToyJunkie.db.profile.boxes[cToy.toyBoxId].toys, key)
            L.ToyboxFrame:UpdateToyButtons()
            L.ToyboxFrame:SelectNewRandomToy()
        end
    end
    L.AttachedFrame.ScrollFrame.listView:Refresh()
end