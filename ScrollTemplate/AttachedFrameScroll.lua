local addonName, L = ...

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
    }
)

function ItemListMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self:SetScript("OnMouseDown", self.OnClick)
end

function ItemListMixin:OnClick(button)
    self:TriggerEvent("OnMouseDown", self, button)
end

function ItemListMixin:Init(elementData)
    if(elementData.isHeader) then
        self.Text:SetText(elementData.name)
        self.icon:SetTexture(elementData.icon)
    else
        self.toyCard.Text:SetText(elementData.name)
        self.icon.texture:SetTexture(elementData.icon)
    end
    if(elementData.isHeader) then
        if(elementData.isCollapsed) then
            self.expandIcon:SetTexture(130838)
        else
            self.expandIcon:SetTexture(130821)
        end
    else
        self.toyCard:SetBackdrop(TJ_TOYLISTBACKDROP)
        self.toyCard:SetBackdropColor(L:GetBackdropColorByToyboxId(elementData.toyBoxId))
    end
end

local ListMixin = {}
function ListMixin:OnLoad()
    CallbackRegistryMixin:OnLoad(self)

    self.scrollView = CreateScrollBoxListLinearView()
    self.scrollView:SetElementFactory(function(factory, data)
        if(data.isHeader) then
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

    ScrollUtil.InitScrollBoxWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView)
end

function ListMixin:OnElementInitialize(element, elementData)
    if(not element.OnLoad) then
        Mixin(element, ItemListMixin)
        element:OnLoad()
    end
    element:Init(elementData)
    element:RegisterCallback("OnMouseDown", self.OnElementClicked, self)
end

function ListMixin:OnElementReset(element)
    element:UnregisterCallback("OnMouseDown", self)
end

function ListMixin:OnElementClicked(element, button)
    local data = element.GetData()
    if(data.isHeader) then
        if(button == "LeftButton") then
            for key, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
                if(key == data.id) then
                    L.ToyJunkie.db.profile.boxes[key].isCollapsed = not data.isCollapsed
                else
                    if(not L.ToyJunkie.db.profile.allowMultipleBoxesOpen) then
                        L.ToyJunkie.db.profile.boxes[key].isCollapsed = true
                    end
                end
            end
            self:Refresh()
        elseif (button == "RightButton") then
            local headerMenu = {
                name = "headerContextMenu",
                parent = element,
                title = "Header Options",
                items = {
                    {
                        text = "Edit Toy Box",
                        func = function()
                            local box = L.ToyJunkie.db.profile.boxes[data.id]
                            L.ToyboxEditFrame:EditToy(box)
                        end
                    },
                    {
                        text = (data.isCollapsed) and "Expand" or "Collapse",
                        func = function()
                            for key, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
                                if(key == data.id) then
                                    L.ToyJunkie.db.profile.boxes[key].isCollapsed = not data.isCollapsed
                                else
                                    if(not L.ToyJunkie.db.profile.allowMultipleBoxesOpen) then
                                        L.ToyJunkie.db.profile.boxes[key].isCollapsed = true
                                    end
                                end
                            end
                            self:Refresh()
                        end
                    },
                    {
                        text = "Close"
                    }
                }
            }

            local headerContext = L:CreateContextMenu(headerMenu)
            ToggleDropDownMenu(1, nil, headerContext, "cursor", 10, 5)
        end
    else
        
    end
end

function ListMixin:Refresh()
    if(L.ToyJunkie.db.profile.boxes ~= nil) then
        local data = CreateDataProvider()
        for id, toyBox in pairs(L.ToyJunkie.db.profile.boxes) do
            data:InsertTable({
                { id = id, name = toyBox.name, isHeader = true, isCollapsed = toyBox.isCollapsed, icon = toyBox.icon }
            })
            if(not toyBox.isCollapsed) then
                for _, toyId in pairs(toyBox.toys) do
                    local _, toyName, toyIcon = C_ToyBox.GetToyInfo(toyId)
                    data:InsertTable({
                        { name = toyName, isHeader = false, icon = toyIcon, toyBoxId = id }
                    })
                end
            end
        end
        self.scrollView:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
    end
end

function ListMixin:GetDataProvider()
    if(self ~= nil) then
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
    self.listView:SetDataProvider(self.dataProvider, true)
    self.listView:SetPoint("TOPLEFT")
    self.listView:SetPoint("BOTTOMRIGHT")
end