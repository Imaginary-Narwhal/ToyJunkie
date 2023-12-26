local addonName, L = ...

---------------
-- Backdrops --
---------------

TJ_HEADER_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileEdge = true,
    tileSize = 8,
    edgeSize = 8,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}


AttachedScrollTemplateMixin = {}

local ItemListMixin = CreateFromMixins(CallbackRegistryMixin)
ItemListMixin:GenerateCallbackEvents(
    {
        "OnClick",
    }
)

function ItemListMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self:SetScript("OnClick", self.OnClick)
end

function ItemListMixin:OnClick()
    self:TriggerEvent("OnClick", self)
end

function ItemListMixin:Init(elementData)
    print(elementData.name)
    self:SetText(elementData.name)
    if(elementData.isHeader) then
        --is collapsed set possible plus/minus icon
    end
    --self:Icon thingy
end

local ListMixin = {}
function ListMixin:OnLoad()
    CallbackRegistryMixin:OnLoad(self)

    self.scrollView = CreateScrollBoxListLinearView()
    self.scrollView:SetElementFactory(function(factory, data)
        if(data.isHeader) then
            factory("HeaderTemplate", function(button, data)
                if(not button.OnLoad) then
                    Mixin(button, ItemListMixin)
                    button:OnLoad()
                end

                button:Init(data)
                button:RegisterCallback("OnClick", self.OnElementClicked, self)
            end)
        else
            factory("ToyTemplate", function(button, data)
                if(not button.OnLoad) then
                    Mixin(button, ItemListMixin)
                    button:OnLoad()
                end

                button:Init(data)
                button:RegisterCallback("OnClick", self.OnElementClicked, self)
            end)
        end
    end)
    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset), self)

    self.scrollBox = CreateFrame("Frame", "$parent_ScrollBox", self, "WowScrollBoxList")
    self.scrollBox:SetPoint("TOPLEFT")
    self.scrollBox:SetPoint("BOTTOMRIGHT", -24, 0)

    self.scrollBar = CreateFrame("EventFrame", "$parent_ScrollBar", self, "MinimalScrollBar")
    self.scrollBar:SetPoint("TOPLEFT", self.scrollBox, "TOPRIGHT", 8, 0)
    self.scrollBar:SetPoint("BOTTOMLEFT", self.scrollBox, "BOTTOMRIGHT", 8, 0)

    ScrollUtil.InitScrollBoxWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView)
end

function ListMixin:OnElementReset(element)
    element:UnregisterCallback("OnClick", self)
end

function ListMixin:OnElementClicked(element)
    print("Clicked")
end

function ListMixin:GetDataProvider()
    return self.scrollView:GetDataProvider()
end

function ListMixin:SetDataProvider(dataProvider)
    self.scrollView:SetDataProvider(dataProvider)
end

function AttachedScrollTemplateMixin:OnLoad()
    self.dataProvider = CreateDataProvider()
    self.dataProvider:InsertTable(
        {
            { name = "Toy Header", isHeader = true },
            --{ name = "Toy 1", isHeader = false}
        }
    )
    self.listView = Mixin(CreateFrame("Frame", nil, self), ListMixin)
    self.listView:OnLoad()
    self.listView:SetDataProvider(self.dataProvider)
    self.listView:SetPoint("TOPLEFT")
    self.listView:SetPoint("BOTTOMRIGHT")
end
