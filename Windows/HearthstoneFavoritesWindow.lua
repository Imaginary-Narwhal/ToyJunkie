local addon, L = ...

local isMoving = false
----------------------------------------------
-- Create main Hearthstone Favorites Window --
----------------------------------------------

L.HearthstoneFavorites = CreateFrame("Frame", "ToyJunkie_HearthstoneFavorites", UIParent, "ButtonFrameTemplate")
ButtonFrameTemplate_HidePortrait(L.HearthstoneFavorites)
L.HearthstoneFavorites:SetTitle("Hearthstone Favorites")
ButtonFrameTemplate_HideButtonBar(L.HearthstoneFavorites)
L.HearthstoneFavorites.Inset:SetPoint("TOPLEFT", L.HearthstoneFavorites, "TOPLEFT", 9, -45)
L.HearthstoneFavorites:SetSize(350,350)
L.HearthstoneFavorites:SetPoint("CENTER")
L.HearthstoneFavorites:RegisterForDrag("LeftButton")
L.HearthstoneFavorites:SetClampedToScreen(true)
L.HearthstoneFavorites:SetMovable(true)
L.HearthstoneFavorites:EnableMouse(true)
L.HearthstoneFavorites:SetFrameStrata("DIALOG")

L.HearthstoneFavorites:SetScript("OnShow", function(self)
    local unowned = {}
    for k,v in pairs (L.ToyJunkie.db.profile.hearthstoneFavoriteIds) do
        if(not L:IsHearthstoneOwned(v)) then
            table.insert(unowned, k)
        end
    end

    for k,v in pairs (unowned) do
        table.remove(L.ToyJunkie.db.profile.hearthstoneFavoriteIds, v)
    end
end)

L.HearthstoneFavorites:SetScript("OnDragStart", function(self, button)
    if(not isMoving) then
        self:StartMoving()
        isMoving = true
    end
end)

L.HearthstoneFavorites:SetScript("OnDragStop", function(self, button)
    if (isMoving) then
        self:StopMovingOrSizing()
        isMoving = false
    end
end)
L.HearthstoneFavorites:SetScript("OnHide", function(self)
    if (isMoving) then
        self:StopMovingOrSizing()
        isMoving = false
    end
end)

------------------------------
-- Hearthstone scroll frame --
------------------------------

L.HearthstoneFavorites.ScrollFrame = Mixin(CreateFrame("Frame", "$parent_ScrollFrame", L.HearthstoneFavorites), L.HearthstoneScrollTemplateMixin)
L.HearthstoneFavorites.ScrollFrame:SetPoint("TOPLEFT", L.HearthstoneFavorites.Inset, "TOPLEFT", 5, -7)
L.HearthstoneFavorites.ScrollFrame:SetPoint("BOTTOMRIGHT", L.HearthstoneFavorites.Inset, "BOTTOMRIGHT", -5, 5)
L.HearthstoneFavorites.ScrollFrame:OnLoad()

--Final Setup
L.HearthstoneFavorites:Hide()
