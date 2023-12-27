local function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
 


local SelectionDemoListItemMixin = CreateFromMixins(CallbackRegistryMixin);
SelectionDemoListItemMixin:GenerateCallbackEvents(
    {
        "OnClick",
    }
);

function SelectionDemoListItemMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self);
    self:SetScript("OnClick", self.OnClick);
end

function SelectionDemoListItemMixin:OnClick()
    self:TriggerEvent("OnClick", self);
end

function SelectionDemoListItemMixin:Init(elementData)
    self.Text:SetText(elementData.text);
    self:SetSelected(elementData.selected);
end

function SelectionDemoListItemMixin:SetSelected(selected)
    self:SetEnabled(not selected);
end

---

local SelectionDemoListMixin = CreateFromMixins(CallbackRegistryMixin);
SelectionDemoListMixin:GenerateCallbackEvents(
    {
        "OnSelectionChanged",
    }
);

function SelectionDemoListMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self)

    self.scrollView = CreateScrollBoxListLinearView();
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
    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self));

    self.scrollBox = CreateFrame("Frame", "DemoScrollBox", self, "WowScrollBoxList");
    --self.scrollBox:SetAllPoints(self);
    --self.scrollBox:Init(self.scrollView);
    self.scrollBox:SetPoint("TOPLEFT")
    self.scrollBox:SetPoint("BOTTOMRIGHT", -24, 0)

    self.scrollBar = CreateFrame("EventFrame", "DemoScrollBar", self, "MinimalScrollBar");
    self.scrollBar:SetPoint("TOPLEFT", self.scrollBox, "TOPRIGHT", 8, 0);
    self.scrollBar:SetPoint("BOTTOMLEFT", self.scrollBox, "BOTTOMRIGHT", 8, 0);

    ScrollUtil.InitScrollBoxWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView)

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.scrollBox);
    self.selectionBehavior:RegisterCallback("OnSelectionChanged", self.OnElementSelectionChanged, self);
end

function SelectionDemoListMixin:OnElementInitialize(element, elementData)
    if not element.OnLoad then
        Mixin(element, SelectionDemoListItemMixin);
        element:OnLoad();
    end

    element:Init(elementData);
    element:SetSelected(self.selectionBehavior:IsSelected(element));
    element:RegisterCallback("OnClick", self.OnElementClicked, self);
end

function SelectionDemoListMixin:OnElementReset(element)
    element:UnregisterCallback("OnClick", self);
end

function SelectionDemoListMixin:OnElementClicked(element)
    self.selectionBehavior:Select(element);
end

function SelectionDemoListMixin:OnElementSelectionChanged(elementData, selected)
    -- Trigger a visual update on the item that was just [de]selected prior
    -- to notifying listeners of the change in selection.

    local element = self.scrollView:FindFrame(elementData);

    if element then
        element:SetSelected(selected);
    end

    -- The below is set up such that we'll only notify listeners of our
    -- *new* selection, and not that we've deselected something in order
    -- to select something new first.

    if selected then
        self:TriggerEvent("OnSelectionChanged", elementData, selected);
    end
end

function SelectionDemoListMixin:GetDataProvider()
    return self.scrollView:GetDataProvider();
end

function SelectionDemoListMixin:SetDataProvider(dataProvider)
    self.scrollView:SetDataProvider(dataProvider);
end

---

local SelectionDemoContentMixin = {};

function SelectionDemoContentMixin:SetContent(elementData)
    if(elementData.isHeader) then
        self:SetText("Clicked header button " .. elementData.content);
    else
        self:SetText("Clicked button " .. elementData.content);
    end
end

---

SelectionDemoMixin = {};

function SelectionDemoMixin:AddToTable()
    SelectionDemo.ButtonCount = SelectionDemo.ButtonCount + 1
    SelectionDemo.dataProvider:InsertTable(
        {
            { text = "Button " .. SelectionDemo.ButtonCount, content = SelectionDemo.ButtonCount, isHeader = (SelectionDemo.ButtonCount - 1) % 5 == 0 }
        }
    )
end

function SelectionDemoMixin:OnLoad()
    bob =self
    self.dataProvider = CreateDataProvider();
    SelectionDemoMixin:AddToTable()
    SelectionDemoMixin:AddToTable()
    SelectionDemoMixin:AddToTable()

    self.listView = Mixin(CreateFrame("Frame", nil, _G["DEMO"]), SelectionDemoListMixin);
    self.listView:OnLoad();
    self.listView:SetDataProvider(self.dataProvider);
    self.listView:SetPoint("TOPLEFT");
    self.listView:SetPoint("BOTTOMRIGHT");
    --self.listView:SetWidth(100);
    --self:SetAllPoints()
    self.listView:RegisterCallback("OnSelectionChanged", self.OnListSelectionChanged, self);

    self.contentView = Mixin(self:CreateFontString(nil, "OVERLAY", "GameFontNormal"), SelectionDemoContentMixin);
    self.contentView:SetPoint("LEFT", self.listView, "RIGHT", 40, 0);
end

function SelectionDemoMixin:OnListSelectionChanged(elementData)
    self.contentView:SetContent(elementData);
end

---

SelectionDemo = Mixin(CreateFrame("Frame", "DEMO", UIParent), SelectionDemoMixin);
SelectionDemo.ButtonCount = 0
SelectionDemo:SetPoint("TOP", 0, -30);
SelectionDemo:SetSize(200, 132);
SelectionDemo:OnLoad();


--My Additions


local addButton = CreateFrame("Button", "AddButton", SelectionDemo, "UIPanelButtonTemplate")
addButton:SetPoint("BOTTOMLEFT", 0, -30)
addButton:SetWidth(70)
addButton:SetText("Add")
addButton:SetScript("OnClick", function()
    SelectionDemoMixin:AddToTable()
end)

local delButton = CreateFrame("Button", "DelButton", SelectionDemo, "UIPanelButtonTemplate")
delButton:SetPoint("BOTTOMLEFT", 0, -55)
delButton:SetText("Delete")
delButton:SetWidth(70)
delButton:SetScript("OnClick", function()
    if(SelectionDemo.ButtonCount > 0) then
        SelectionDemo.dataProvider:RemoveIndex(SelectionDemo.ButtonCount)
        SelectionDemo.ButtonCount = SelectionDemo.ButtonCount - 1
    end
end)