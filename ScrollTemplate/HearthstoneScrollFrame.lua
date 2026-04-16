local addonName, L = ...

local searchText = ""
local Hearthstones = {}
local showAllHearthstones = false


---------------
-- Backdrops --
---------------

local TJ_BACKDROP = {
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
    tile = true,
    tileEdge = true,
    tileSize = 12,
    edgeSize = 12,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
};



L.HearthstoneScrollTemplateMixin = {}



local ItemListMixin = CreateFromMixins(CallbackRegistryMixin)
ItemListMixin:GenerateCallbackEvents(
    {
        "OnMouseUp"
    }
)
function ItemListMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self:SetScript("OnMouseUp", self.OnClick)
end

function ItemListMixin:OnClick(button)
    self:TriggerEvent("OnMouseUp", self, button)
end

function ItemListMixin:Init(elementData)
    self.hearthstoneCard.Text:SetText(elementData.name)
    self.icon.texture:SetTexture(elementData.icon)
    self.hearthstoneCard:SetBackdrop(TJ_BACKDROP)
    self.hearthstoneCard:SetBackdropColor(PANEL_BACKGROUND_COLOR.r, PANEL_BACKGROUND_COLOR.g, PANEL_BACKGROUND_COLOR.b, 1)

    self:RegisterForClicks("AnyDown")
    self:SetAttribute("type2", "toy")
    self:SetAttribute("toy2", elementData.id)

    if(not elementData.owned) then
        self.icon.texture:SetDesaturated(true)
    else
        self.icon.texture:SetDesaturated(false)
        if(not L:IsHearthstoneFavorited(elementData.id)) then
            self.favoriteHeart.texture:SetDesaturated(true)
        else
            self.favoriteHeart.texture:SetDesaturated(false)
        end

        self.favoriteHeart:SetScript("OnMouseUp", function(self, button)
        if(PlayerHasToy(elementData.id)) then
            if(elementData.owned) then
                if(L:IsHearthstoneFavorited(elementData.id)) then
                    local result = L:RemoveFavoriteHearthstone(elementData.id)
                    if(result == 2) then
                        UIErrorsFrame:AddExternalErrorMessage("Must have at least one Hearthstone favorited!")
                    else
                        L.HearthstoneFavorites.ScrollFrame.listView:Refresh()
                        L.ToyboxFrame:SelectNewRandomHearthstone()
                    end
                else
                    L:AddFavoriteHearthstone(elementData.id)
                        L.HearthstoneFavorites.ScrollFrame.listView:Refresh()
                    L.ToyboxFrame:SelectNewRandomHearthstone()
                end
            end
        end
    end)
    end
end


local ListMixin = {}
function ListMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self.scrollView = CreateScrollBoxListLinearView()
    self.scrollView:SetElementFactory(function(factory, data)
        if(data.owned) then
            factory("TJ_HearthstoneTemplate", function(button, data)
                self:OnElementInitialize(button, data)
            end)
        else
            factory("TJ_HearthstoneUnownedTemplate", function(button, data)
                self:OnElementInitialize(button, data)
            end)
        end
    end)
    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self))

    self.scrollBox = CreateFrame("Frame", "$parent_ScrollBox", self, "WoWScrollBoxList")
    self.scrollBox:SetPoint("TOPLEFT")
    self.scrollBox:SetPoint("BOTTOMRIGHT", -24, 0)

    self.scrollBar = CreateFrame("EventFrame", "$parent_ScrollBar", self, "MinimalScrollBar")
    self.scrollBar:SetPoint("TOPLEFT", self.scrollBox, "TOPRIGHT", 8, 0)
    self.scrollBar:SetPoint("BOTTOMLEFT", self.scrollBox, "BOTTOMRIGHT", 8, 0)

    self.searchBar = CreateFrame("EditBox", "$parent_SearchBar", self, "InputBoxTemplate")
    self.searchBar:SetPoint("TOPLEFT", L.HearthstoneFavorites, "TOPLEFT", 25, -15)
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
    self.searchBar.Placeholder:SetText("Search hearthstones")
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

    self.hearthstoneFilter = CreateFrame("CheckButton", "$parent_HearthstoneFilter", self, "UICheckButtonTemplate")
    self.hearthstoneFilter:SetPoint("TOPRIGHT", L.HearthstoneFavorites, "TOPRIGHT", -125, -19)
    self.hearthstoneFilter.text:SetText("Show all Hearthstones")
    self.hearthstoneFilter:SetChecked(showAllHearthstones)
    self.hearthstoneFilter:SetScript("OnClick", function(self, button)
        if(self:GetChecked()) then
            showAllHearthstones = true
            self:GetParent():Refresh()
        else
            showAllHearthstones = false
            self:GetParent():Refresh()
        end
    end)
    

    ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView)

    self:SetScript("OnUpdate", self.OnUpdate)
end

function ListMixin:OnUpdate(self, elapsed)

end

function ListMixin:OnElementInitialize(element, elementData)
    if(not element.OnLoad) then
        Mixin(element, ItemListMixin)
        element:OnLoad()
    end

    element:Init(elementData)
    element:RegisterCallback("OnMouseUp", self.OnElementClicked, self)
end

function ListMixin:OnElementReset(element)
    element:UnregisterCallback("OnMouseUp", self)
end

function ListMixin:OnElementClicked(element, button)
    if(button == "LeftButton") then
    local data = element:GetData()
        if(PlayerHasToy(data.id)) then
            if(data.owned) then
                if(L:IsHearthstoneFavorited(data.id)) then
                    local result = L:RemoveFavoriteHearthstone(data.id)
                    if(result == 2) then
                        UIErrorsFrame:AddExternalErrorMessage("Must have at least one Hearthstone favorited!")
                    else
                        self:Refresh()
                        L.ToyboxFrame:SelectNewRandomHearthstone()
                    end
                else
                    L:AddFavoriteHearthstone(data.id)
                    self:Refresh()
                    L.ToyboxFrame:SelectNewRandomHearthstone()
                end
            end
        end
    end
end

function ListMixin:Refresh()
    local data = CreateDataProvider()
    local Hearthstones = L:GetAllHearthstones()
    for id, hearthstone in pairs(Hearthstones) do
        local excludeHearthstone = false
        if(searchText ~= "") then
            if(not L:strContains(hearthstone.Name, searchText)) then
                excludeHearthstone = true
            end
        end
        if(not showAllHearthstones) then
            if(not hearthstone.Owned) then
                excludeHearthstone = true
            end
        end

        if(not excludeHearthstone) then
            data:InsertTable({
                {
                    id = id,
                    name = hearthstone.Name,
                    icon = hearthstone.Icon,
                    owned = hearthstone.Owned
                }
            })
        end
    end
    self.scrollView:SetDataProvider(data)
end

function ListMixin:GetDataProvider()
    if(self ~= nil) then
        return self.scrollView:GetDataProvider()
    end
end

function ListMixin:SetDataProvider(dataProvider)
    self.scrollView:SetDataProvider(dataProvider)
end

function L.HearthstoneScrollTemplateMixin:OnLoad(hearthstones)
    self.dataProvider = CreateDataProvider()
    self.listView = Mixin(CreateFrame("Frame", nil, self), ListMixin)
    self.listView:OnLoad()
    self.listView:SetDataProvider(self.dataProvider)
    self.listView:SetPoint("TOPLEFT")
    self.listView:SetPoint("BOTTOMRIGHT")
end

function L.HearthstoneScrollTemplateMixin:UpdateHearthstones()
    HearthStones = L:GetAllHearthstones()
    self.listView:Refresh()
end
