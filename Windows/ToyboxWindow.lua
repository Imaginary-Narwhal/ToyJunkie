local addon, L = ...

local isMoving = false
local isResizing = false
local randomToyAvailable = false
local selectedHearthstoneId = 0

local counter = 0

------------------------------
-- Create main toybox frame --
------------------------------

L.ToyboxFrame = CreateFrame("Frame", "ToyJunkie_ToyboxFrame", UIParent, "BackdropTemplate")
L.ToyboxFrame:SetFrameLevel(510)
L.ToyboxFrame:SetBackdrop({

    bgFile = "Interface/Buttons/WHITE8X8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 3.2, right = 3.2, top = 3.2, bottom = 3.2 }
})
L.ToyboxFrame:SetBackdropColor(PANEL_BACKGROUND_COLOR.r, PANEL_BACKGROUND_COLOR.g, PANEL_BACKGROUND_COLOR.b, 1)
L.ToyboxFrame:SetBackdropBorderColor(.5, .5, .5, 1)
L.ToyboxFrame:SetSize(400, 300)
L.ToyboxFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 21, -18)
L.ToyboxFrame:SetResizable(true)

L.ToyboxFrame:RegisterForDrag("LeftButton")
L.ToyboxFrame:SetClampedToScreen(true)
L.ToyboxFrame:SetMovable(true)
L.ToyboxFrame:EnableMouse(true)

L.ToyboxFrame:SetScript("OnDragStart", function(self, button)
    if (not isMoving and not L.ToyJunkie.db.profile.toyBoxFrame.locked) then
        L.ToyboxFrame:StartMoving()
        isMoving = true
    end
end)
L.ToyboxFrame:SetScript("OnDragStop", function(self, button)
    if (isMoving) then
        L.ToyboxFrame:StopMovingOrSizing()
        L.ToyboxFrame:SavePosition()
        isMoving = false
    end
end)
L.ToyboxFrame:SetScript("OnHide", function(self)
    if (isMoving) then
        L.ToyboxFrame:StopMovingOrSizing()
        L.ToyboxFrame:SavePosition()
        isMoving = false
    end
end)

L.ToyboxFrame:SetScript("OnUpdate", function(self)
    if (isResizing) then
        L.ToyboxFrame:UpdateToyButtons()
    end
end)
------------------
-- Close button --
------------------

L.ToyboxFrame.CloseButton = CreateFrame("Button", "$parent_CloseButton", L.ToyboxFrame, "UIPanelCloseButton")
L.ToyboxFrame.CloseButton:SetFrameLevel(L.ToyboxFrame:GetFrameLevel() + 1)
L.ToyboxFrame.CloseButton:SetSize(18, 18)
L.ToyboxFrame.CloseButton:SetPoint("TOPRIGHT", 2, 2)
L.ToyboxFrame.CloseButton:SetScript("OnClick", function(self, button)
    if (button == "LeftButton") then
        L.ToyboxFrame:Toggle()
    end
end)

----------------------
-- Side Menu Button --
----------------------

L.ToyboxFrame.SideMenuButton = CreateFrame("Button", "$parent_SideMenuButton", L.ToyboxFrame)
L.ToyboxFrame.SideMenuButton:SetSize(12, 12)
L.ToyboxFrame.SideMenuButton:SetNormalTexture("Interface/Addons/ToyJunkie/images/menuButton.png")
L.ToyboxFrame.SideMenuButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
L.ToyboxFrame.SideMenuButton:SetPoint("TOPLEFT", 10, -10)
L.ToyboxFrame.SideMenuButton:SetScript("OnClick", function(self, button)
    if (button == "LeftButton") then
        L.ToyboxFrame:ToggleSideMenuBar()
    end
end)
--------------------
--Settings Button --
--------------------

L.ToyboxFrame.SettingsButton = CreateFrame("Button", "$parent_SettingsButton", L.ToyboxFrame)
L.ToyboxFrame.SettingsButton:SetSize(17, 17)

L.ToyboxFrame.SettingsButton:SetNormalTexture("Interface/Addons/ToyJunkie/images/settings-buttons.png")
L.ToyboxFrame.SettingsButton:GetNormalTexture():SetTexCoord(0.21875, 0.765625, 0.023438, 0.3125)

L.ToyboxFrame.SettingsButton:SetPushedTexture("Interface/Addons/ToyJunkie/images/settings-buttons.png")
L.ToyboxFrame.SettingsButton:GetPushedTexture():SetTexCoord(0.21875, 0.765625, 0.335938, 0.625)

L.ToyboxFrame.SettingsButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
L.ToyboxFrame.SettingsButton:SetPoint("TOPRIGHT", -18, 1)
L.ToyboxFrame.SettingsButton:SetScript("OnClick", function(self, button)
    Settings.OpenToCategory(L.catID)
end)
------------------------
-- Lock/Unlock Button --
------------------------

L.ToyboxFrame.LockButton = CreateFrame("Button", "$parent_LockButton", L.ToyboxFrame, "UIPanelButtonTemplate")
L.ToyboxFrame.LockButton:SetSize(18, 17)
L.ToyboxFrame.LockButton:SetText("L")

L.ToyboxFrame.LockButton:SetPoint("TOPRIGHT", -37, 1.5)
L.ToyboxFrame.LockButton:SetScript("OnClick", function(self, button)
    L.ToyJunkie.db.profile.toyBoxFrame.locked = not L.ToyJunkie.db.profile.toyBoxFrame.locked
    if (L.ToyJunkie.db.profile.toyBoxFrame.locked) then
        L.ToyboxFrame.LockButton:SetText("U")
        L.ToyboxFrame.ResizeButton:Hide()
    else
        L.ToyboxFrame.LockButton:SetText("L")
        L.ToyboxFrame.ResizeButton:Show()
    end
end)
L.ToyboxFrame.LockButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    if (self:GetText() == "L") then
        GameTooltip:AddLine("Lock Toybox Window")
    else
        GameTooltip:AddLine("Unlock Toybox Window")
    end
    GameTooltip:Show()
end)

L.ToyboxFrame.LockButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-------------------
-- Resize Button --
-------------------

L.ToyboxFrame.ResizeButton = CreateFrame("Button", "$parent_ResizeButton", L.ToyboxFrame)
L.ToyboxFrame.ResizeButton:SetSize(16, 16)
L.ToyboxFrame.ResizeButton:SetNormalTexture(386864)
L.ToyboxFrame.ResizeButton:SetPushedTexture(386862)
L.ToyboxFrame.ResizeButton:SetHighlightTexture(386863)
L.ToyboxFrame.ResizeButton:SetPoint("BOTTOMRIGHT", -1, 1)
L.ToyboxFrame.ResizeButton:SetScript("OnMouseDown", function(self, button)
    if (button == "LeftButton") then
        L.ToyboxFrame:StartSizing("BOTTOMRIGHT", true)
        L.ToyboxFrame:SetUserPlaced(true)
        isResizing = true
    end
end)

L.ToyboxFrame.ResizeButton:SetScript("OnMouseUp", function(self, button)
    L.ToyboxFrame:StopMovingOrSizing()
    L.ToyboxFrame:SavePosition()
    isResizing = false
end)
------------------
--Side Menu Bar --
------------------

L.ToyboxFrame.SideMenuBar = CreateFrame("Frame", "$parent_SideMenuBar", L.ToyboxFrame, "BackdropTemplate")
L.ToyboxFrame.SideMenuBar:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8X8"
})
L.ToyboxFrame.SideMenuBar:SetBackdropColor(1, 1, 1, .05)
L.ToyboxFrame.SideMenuBar:SetPoint("TOPLEFT", 8, -26)
L.ToyboxFrame.SideMenuBar:SetPoint("BOTTOMLEFT", 8, 6)
L.ToyboxFrame.SideMenuBar:SetWidth(100)

L.ToyboxFrame.SideMenuBar.ToyboxSelectionFrame = Mixin(
    CreateFrame("Frame", "$parent_ToyboxSelectionFrame", L.ToyboxFrame.SideMenuBar),
    L.ToyboxSelectionTemplateMixin)
L.ToyboxFrame.SideMenuBar.ToyboxSelectionFrame:SetPoint("TOPLEFT", 0, 0)
L.ToyboxFrame.SideMenuBar.ToyboxSelectionFrame:SetPoint("BOTTOMRIGHT", 0, 0)
L.ToyboxFrame.SideMenuBar.ToyboxSelectionFrame:OnLoad()

-----------------------------
-- Toy Button Holder Frame --
-----------------------------

L.ToyboxFrame.ToyButtonHolderFrame = CreateFrame("Frame", "$parent_ToyButtonHolderFrame", L.ToyboxFrame, "BackdropTemplate")
L.ToyboxFrame.ToyButtonHolderFrame:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8X8"
})
L.ToyboxFrame.ToyButtonHolderFrame:SetBackdropColor(PANEL_BACKGROUND_COLOR.r, PANEL_BACKGROUND_COLOR.g, PANEL_BACKGROUND_COLOR.b, 1)
L.ToyboxFrame.ToyButtonHolderFrame:SetPoint("TOPLEFT", 130, -27)
L.ToyboxFrame.ToyButtonHolderFrame:SetPoint("BOTTOMRIGHT", -25, 15)

L.ToyboxFrame.ToyButtonHolderFrame.ScrollBox = CreateFrame("Frame", "$parent_ScrollBox", L.ToyboxFrame.ToyButtonHolderFrame, "WowScrollBox")
L.ToyboxFrame.ToyButtonHolderFrame.ScrollBox:SetAllPoints()
L.ToyboxFrame.ToyButtonHolderFrame.ScrollBox:SetInterpolateScroll(true)

L.ToyboxFrame.ToyButtonHolderFrame.ScrollBar = CreateFrame("EventFrame", "$parent_ScrollBar", L.ToyboxFrame.ToyButtonHolderFrame, "MinimalScrollBar")
L.ToyboxFrame.ToyButtonHolderFrame.ScrollBar:SetPoint("TOPLEFT", L.ToyboxFrame.ToyButtonHolderFrame.ScrollBox, "TOPRIGHT", 7, 0)
L.ToyboxFrame.ToyButtonHolderFrame.ScrollBar:SetPoint("BOTTOMLEFT", L.ToyboxFrame.ToyButtonHolderFrame.ScrollBox, "BOTTOMRIGHT", 7, 0)
L.ToyboxFrame.ToyButtonHolderFrame.ScrollBar:SetInterpolateScroll(true)

L.ToyboxFrame.ToyButtonHolderFrame.ScrollView = CreateScrollBoxLinearView()
L.ToyboxFrame.ToyButtonHolderFrame.ScrollView:SetPanExtent(100)

L.ToyboxFrame.ToyButtonHolderFrame.ScrollChild = CreateFrame("Frame", "$parent_ScrollChild", L.ToyboxFrame.ToyButtonHolderFrame.ScrollBox)
L.ToyboxFrame.ToyButtonHolderFrame.ScrollChild:SetPoint("TOPLEFT")
L.ToyboxFrame.ToyButtonHolderFrame.ScrollChild:SetPoint("TOPRIGHT")
L.ToyboxFrame.ToyButtonHolderFrame.ScrollChild:SetHeight(300)
L.ToyboxFrame.ToyButtonHolderFrame.ScrollChild.scrollable = true

ScrollUtil.InitScrollBoxWithScrollBar(L.ToyboxFrame.ToyButtonHolderFrame.ScrollBox,
    L.ToyboxFrame.ToyButtonHolderFrame.ScrollBar,
    L.ToyboxFrame.ToyButtonHolderFrame.ScrollView)


-------------------
-- Random Button --
-------------------

L.ToyboxFrame.RandomToyButton = CreateFrame("Button", "$parent_RandomToyButton", L.ToyboxFrame, "SecureActionButtonTemplate")
L.ToyboxFrame.RandomToyButton:SetNormalTexture(130772)
L.ToyboxFrame.RandomToyButton:SetHighlightTexture(130771)
L.ToyboxFrame.RandomToyButton:SetPushedTexture(130770)
L.ToyboxFrame.RandomToyButton:SetSize(18, 18)
L.ToyboxFrame.RandomToyButton:SetPoint("TOPLEFT", L.ToyboxFrame.ToyButtonHolderFrame, 7, 20)
L.ToyboxFrame.RandomToyButton:RegisterForClicks("AnyDown")
L.ToyboxFrame.RandomToyButton:SetAttribute("type1", "toy")
L.ToyboxFrame.RandomToyButton:HookScript("OnClick", function(self, button)
    if (button == "LeftButton") then
        L.ToyboxFrame:SelectNewRandomToy()
    end
end)
L.ToyboxFrame.RandomToyButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    if (randomToyAvailable) then
        GameTooltip:AddLine("Random Toy")
        GameTooltip:AddLine("Use a random toy from " .. L.ToyJunkie.db.profile.selectedToybox)
    else
        GameTooltip:AddLine("No toys currently available")
    end
    GameTooltip:Show()
end)
L.ToyboxFrame.RandomToyButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-------------------------------
-- Random Hearthstone Button --
-------------------------------L:Pr

L.ToyboxFrame.RandomHearthstoneButton = CreateFrame("Button", "$parent_RandomHearthstoneButton", L.ToyboxFrame, "SecureActionButtonTemplate")
L.ToyboxFrame.RandomHearthstoneButton:SetNormalTexture(5524923)
L.ToyboxFrame.RandomHearthstoneButton:SetSize(18, 18)
L.ToyboxFrame.RandomHearthstoneButton:SetPoint("TOPLEFT", L.ToyboxFrame.RandomToyButton, 25, 0)
L.ToyboxFrame.RandomHearthstoneButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
L.ToyboxFrame.RandomHearthstoneButton:RegisterForClicks("AnyDown")
L.ToyboxFrame.RandomHearthstoneButton:SetAttribute("type1", "toy")

L.ToyboxFrame.RandomHearthstoneButton.Cooldown = CreateFrame("Cooldown", nil, L.ToyboxFrame.RandomHearthstoneButton, "CooldownFrameTemplate")
L.ToyboxFrame.RandomHearthstoneButton.Cooldown:SetAllPoints()
L.ToyboxFrame.RandomHearthstoneButton.Cooldown:SetScale(.75)
L.ToyboxFrame.RandomHearthstoneButton.Cooldown:Hide()
L.ToyboxFrame.RandomHearthstoneButton.Cooldown:SetHideCountdownNumbers(true)
L.ToyboxFrame.RandomHearthstoneButton:RegisterEvent("SPELL_UPDATE_COOLDOWN")

L.ToyboxFrame.RandomHearthstoneButton.CooldownTimer = L.ToyboxFrame.RandomHearthstoneButton:CreateFontString("RandomHearthstone_CooldownTimer", "OVERLAY", "GameFontWhite")
L.ToyboxFrame.RandomHearthstoneButton.CooldownTimer:SetPoint("LEFT", 25, -5)
L.ToyboxFrame.RandomHearthstoneButton.CooldownTimer:SetText("29m 59s")
L.ToyboxFrame.RandomHearthstoneButton.CooldownTimer:SetScale(.75)
L.ToyboxFrame.RandomHearthstoneButton.CooldownTimer:Hide()

function L.ToyboxFrame.RandomHearthstoneButton:CheckCooldown()
    if (selectedHearthstoneId ~= 0) then
        local start, duration, enable = C_Item.GetItemCooldown(selectedHearthstoneId)
        if (start > 0) then
            CooldownFrame_Set(self.Cooldown, start, duration, enable)
            if (duration > 1.5) then
                self.CooldownTimer:Show()
            end
        else
            self.Cooldown:Hide()
            self.CooldownTimer:Hide()
        end
    else
        self.Cooldown:Hide()
        self.CooldownTimer:Hide()
    end
end

L.ToyboxFrame.RandomHearthstoneButton:HookScript("OnClick", function(self, button)
    if (button == "LeftButton") then
        L.ToyboxFrame:SelectNewRandomHearthstone()
    end
    if (button == "RightButton") then
        L.HearthstoneFavorites:SetShown(not L.HearthstoneFavorites:IsShown())
    end
end)
L.ToyboxFrame.RandomHearthstoneButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    if (#L:GetUsableHearthstones() > 0) then
        GameTooltip:AddLine("Random Hearthstone")
        GameTooltip:AddLine("Returns you to " .. GetBindLocation())
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Right click to select favorite hearthstones")
    else
        GameTooltip:AddLine("No hearthstones currently available")
    end
    GameTooltip:Show()
end)
L.ToyboxFrame.RandomHearthstoneButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

L.ToyboxFrame.RandomHearthstoneButton:SetScript("OnEvent", function(self, event)
    if (event == "SPELL_UPDATE_COOLDOWN") then
        self:CheckCooldown()
    end
end)

L.ToyboxFrame.RandomHearthstoneButton:SetScript("OnUpdate", function(self)
    local start, duration, enable = C_Item.GetItemCooldown(selectedHearthstoneId)
    if (start > 0) then
        local time = math.floor(start + duration - GetTime())
        local minutes = math.floor(time / 60)
        local seconds = math.floor(time - (minutes * 60))

        self.CooldownTimer:SetText(format("%02dm %02ds", minutes, seconds))
    end
end)

----------------
-- Quick Toys --
----------------
L.ToyboxFrame.QuickButtons = {}
function L.ToyboxFrame:UpdateQuickButtons()
    if (L.ToyboxFrame.QuickButtons[1] == nil) then
        self:CreateQuickButtons()
    end

    for i = 1, 5 do
        L.ToyboxFrame.QuickButtons[i]:Hide()
        L.ToyboxFrame.QuickButtons[i].Button.id = nil
        L.ToyboxFrame.QuickButtons[i].Button.Cooldown:Hide()
    end

    for key, toyId in pairs(L.ToyJunkie.db.profile.boxes["special"].toys) do
        local button = L.ToyboxFrame.QuickButtons[key].Button
        local _, _, toyIcon = C_ToyBox.GetToyInfo(toyId)
        if (toyIcon == nil) then
            toyIcon = 134400
        end
        button.id = toyId
        button:SetNormalTexture(toyIcon)
        button:SetAttribute("type1", "toy")
        button:SetAttribute("toy1", toyId)
        button:CheckCooldown()
        L.ToyboxFrame.QuickButtons[key]:Show()
    end
end

function L.ToyboxFrame:CreateQuickButtons()
    for i = 1, 5, 1 do
        L.ToyboxFrame.QuickButtons[i] = CreateFrame("Frame", "$parent_QuickButton_" .. i, L.ToyboxFrame, "BackdropTemplate")
        local qb = L.ToyboxFrame.QuickButtons[i]
        qb:SetFrameLevel(509)
        qb:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8X8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 3.2, right = 3.2, top = 3.2, bottom = 3.2 }
        })
        qb:SetBackdropColor(PANEL_BACKGROUND_COLOR.r, PANEL_BACKGROUND_COLOR.g, PANEL_BACKGROUND_COLOR.b, 1)
        qb:SetBackdropBorderColor(.5, .5, .5, 1)
        qb:SetSize(36, 34)
        qb:SetPoint("TOPLEFT", L.ToyboxFrame, "TOPRIGHT", -10, (-36 * (i - 1)) - 15)
        qb.Button = CreateFrame("Button", "$parent_Button", qb, "SecureActionButtonTemplate")
        qb.Button:RegisterForClicks("AnyUp", "AnyDown")
        qb.Button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        qb.Button:SetSize(22, 22)
        qb.Button:SetPoint("Center", qb, "Center", 2, -1)
        qb.Button.Hover = qb.Button:CreateTexture("$parent_Hover", "OVERLAY")
        qb.Button.Hover:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        qb.Button.Hover:SetBlendMode("ADD")
        qb.Button.Hover:SetSize(24, 24)
        qb.Button.Hover:SetPoint("Center")
        qb.Button.Hover:Hide()
        qb.Button:SetScript("OnEnter", function(self)
            self.Hover:Show()
        end)
        qb.Button:SetScript("OnLeave", function(self)
            self.Hover:Hide()
        end)

        qb.Button.Cooldown = CreateFrame("Cooldown", nil, qb.Button, "CooldownFrameTemplate")
        qb.Button.Cooldown:SetAllPoints()
        qb.Button.Cooldown:SetScale(0.7)
        qb.Button.Cooldown:Hide()

        qb.Button:SetScript("OnEvent", function(self, event)
            if (event == "SPELL_UPDATE_COOLDOWN") then
                self:CheckCooldown()
            end
        end)

        function qb.Button:CheckCooldown()
            if (self.id ~= nil) then
                local start, duration, enable = C_Item.GetItemCooldown(self.id)
                if (start > 0) then
                    CooldownFrame_Set(self.Cooldown, start, duration, enable)
                end
            end
        end

        qb:Hide()
    end
end

---------------
-- Functions --
---------------
L.ToyboxFrame.ToyButtons = {}

function L.ToyboxFrame:SelectNewRandomToy()
    if (L.ToyJunkie.db.profile.selectedToybox) then
        local toyList = {}
        local toy = 0
        for id, iToy in pairs(L.ToyJunkie.db.profile.boxes[L:GetToyBoxIdByName(L.ToyJunkie.db.profile.selectedToybox)].toys) do
            local _, dur = C_Item.GetItemCooldown(iToy)
            if (dur == 0) then
                table.insert(toyList, iToy)
            end
        end
        if (#toyList > 0) then
            randomToyAvailable = true
            local count = random(#toyList)
            L.ToyboxFrame.RandomToyButton:SetAttribute("toy1", toyList[count])
        else
            randomToyAvailable = false
            L.ToyboxFrame.RandomToyButton:SetAttribute("toy1", "0")
        end
    end
end

function L.ToyboxFrame:SelectNewRandomHearthstone()
    local hearthstones = L:GetUsableHearthstones()
    if (#hearthstones > 0) then
        local selected = random(#hearthstones)
        selectedHearthstoneId = hearthstones[selected]
        L.ToyboxFrame.RandomHearthstoneButton:SetAttribute("toy1", hearthstones[selected])
        L.ToyboxFrame.RandomHearthstoneButton:CheckCooldown()
        if (L.ToyJunkie.db.profile.createMacro) then
            L:UpdateRandomHearthstoneMacro(hearthstones[selected])
        end
    else
        selectedHearthstoneId = 0
        L.ToyboxFrame.RandomHearthstoneButton:SetAttribute("toy1", "0")
        L.ToyboxFrame.RandomHearthstoneButton:CheckCooldown()
    end
end

function L.ToyboxFrame:GetCurrentlySelectedHearthstoneId()
    return selectedHearthstoneId
end

function L.ToyboxFrame:RefreshToyBoxes()
    L.ToyboxFrame.SideMenuBar.ToyboxSelectionFrame.listView:Refresh()
end

function L.ToyboxFrame:UpdateToyboxDisplay()
    self:ToggleSideMenuBar(true)
    self:RefreshToyBoxes()
    if (L.ToyJunkie.db.profile.toyBoxFrame.locked) then
        L.ToyboxFrame.ResizeButton:Hide()
    else
        L.ToyboxFrame.ResizeButton:Show()
    end
end

function L.ToyboxFrame:ToggleSideMenuBar(redraw)
    if (not redraw) then
        local point, _, relativePoint, x, y = self:GetPoint()
        if (L.ToyJunkie.db.profile.toyBoxFrame.isSideBarShown) then -- If true, hide menu bar
            L.ToyboxFrame:SetWidth(L.ToyJunkie.db.profile.toyBoxFrame.width - 115)
            if (point == "CENTER" or point == "TOP" or point == "BOTTOM") then
                L.ToyboxFrame:SetPoint(point, nil, relativePoint, x - (115 / 2), y)
            end
            if (point == "TOPRIGHT" or point == "RIGHT" or point == "BOTTOMRIGHT") then
                L.ToyboxFrame:SetPoint(point, nil, relativePoint, x - 115, y)
            end
            L.ToyboxFrame.ToyButtonHolderFrame:SetPoint("TOPLEFT", 15, -27)
            L.ToyboxFrame.RandomToyButton:SetPoint("TOPLEFT", L.ToyboxFrame.ToyButtonHolderFrame, 15, 20)
            L.ToyJunkie.db.profile.toyBoxFrame.isSideBarShown = false
            L.ToyboxFrame.SideMenuBar:Hide()
            L.ToyboxFrame:SavePosition()
        else
            L.ToyboxFrame:SetWidth(L.ToyJunkie.db.profile.toyBoxFrame.width + 115)
            if (point == "CENTER" or point == "TOP" or point == "BOTTOM") then
                L.ToyboxFrame:SetPoint(point, nil, relativePoint, x + (115 / 2), y)
            end
            if (point == "TOPRIGHT" or point == "RIGHT" or point == "BOTTOMRIGHT") then
                L.ToyboxFrame:SetPoint(point, nil, relativePoint, x + 115, y)
            end
            L.ToyboxFrame.ToyButtonHolderFrame:SetPoint("TOPLEFT", 130, -27)
            L.ToyboxFrame.RandomToyButton:SetPoint("TOPLEFT", L.ToyboxFrame.ToyButtonHolderFrame, 7, 20)
            L.ToyJunkie.db.profile.toyBoxFrame.isSideBarShown = true
            L.ToyboxFrame:RefreshToyBoxes()
            L.ToyboxFrame.SideMenuBar:Show()
            L.ToyboxFrame:SavePosition()
        end
    end
    L.ToyboxFrame:UpdateBounds()
end

function L.ToyboxFrame:UpdateBounds()
    local iconWidth = L:GetIconMargin() + L.ToyJunkie.db.profile.toyBoxFrame.iconSize * 3 + L:GetIconMargin()
    if (L.ToyJunkie.db.profile.toyBoxFrame.isSideBarShown) then
        L.ToyboxFrame.SideMenuBar:Show()
        iconWidth = 165 + iconWidth
        L.ToyboxFrame:SetResizeBounds(iconWidth, 200)
    else
        L.ToyboxFrame.SideMenuBar:Hide()
        iconWidth = 50 + iconWidth
        L.ToyboxFrame:SetResizeBounds(iconWidth, 200)
    end

    if (L.ToyboxFrame:GetWidth() < iconWidth) then
        L.ToyboxFrame:SetWidth(iconWidth)
    end
end

function L.ToyboxFrame:UpdateToyButtons()
    local numToyboxToys = #L.ToyJunkie.db.profile.boxes[L:GetToyBoxIdByName(L.ToyJunkie.db.profile.selectedToybox)].toys
    if (L.ToyJunkie.db.profile.selectedToybox ~= nil) then
        for k, v in pairs(L.ToyboxFrame.ToyButtons) do
            v:RemoveButton()
        end

        local numStoredToys = #L.ToyboxFrame.ToyButtons

        if (numStoredToys - numToyboxToys < 0) then
            for i = 1, math.abs(numStoredToys - numToyboxToys), 1 do
                table.insert(L.ToyboxFrame.ToyButtons, L:CreateToyButton())
            end
        end
        local b = 1
        for k, toyId in pairs(L.ToyJunkie.db.profile.boxes[L:GetToyBoxIdByName(L.ToyJunkie.db.profile.selectedToybox)].toys) do
            L.ToyboxFrame.ToyButtons[b].id = toyId
            b = b + 1
        end
    end

    local frameWidth = L.ToyboxFrame.ToyButtonHolderFrame.ScrollChild:GetWidth()
    local iconsPerRow = math.floor(frameWidth / (L.ToyJunkie.db.profile.toyBoxFrame.iconSize + (L:GetIconMargin())))


    local activeButtons = L:GetNumOfActiveButtons()

    if (activeButtons > 0) then
        local row = 1
        local column = 1
        for k, button in pairs(L.ToyboxFrame.ToyButtons) do
            if (button.id ~= nil) then
                button:ClearAllPoints()
                button:SetPoint("TOPLEFT", L.ToyboxFrame.ToyButtonHolderFrame.ScrollChild,
                    ((L:GetIconMargin() + L.ToyJunkie.db.profile.toyBoxFrame.iconSize) * (row - 1)) + L:GetIconMargin(),
                    -(((L:GetIconMargin() + L.ToyJunkie.db.profile.toyBoxFrame.iconSize) * (column - 1)) + L:GetIconMargin())
                )
                button:Show()
                button:UpdateButton(button.id)
                row = row + 1
                if (row > iconsPerRow) then
                    row = 1
                    column = column + 1
                end
            end
        end
        if (row == 1) then
            column = column - 1
        end
        L.ToyboxFrame.ToyButtonHolderFrame.ScrollChild:SetHeight((L:GetIconMargin() + L.ToyJunkie.db.profile.toyBoxFrame.iconSize) * (column) + L:GetIconMargin())
    else
        L.ToyboxFrame.ToyButtonHolderFrame.ScrollChild:SetHeight(0)
    end
    L.ToyboxFrame.ToyButtonHolderFrame.ScrollView:RecalculateExtent(L.ToyboxFrame.ToyButtonHolderFrame.ScrollBox)
    L.ToyboxFrame.ToyButtonHolderFrame.ScrollBox:FullUpdate()
    if (frameWidth == 0 and numToyboxToys > 0) then
        L.ToyboxFrame:UpdateToyButtons()
    end
end

function L.ToyboxFrame:Toggle(auto, force)
    if (force == nil) then
        if (self:IsShown()) then
            force = "CLOSE"
        else
            force = "OPEN"
        end
    end
    if (force ~= "OPEN" and force ~= "CLOSE") then
        L.ToyJunkie:Print("Error in ToyboxFrame toggle. (force) must be OPEN or CLOSE")
        return
    end
    if (#L.ToyJunkie.db.profile.boxes > 0) then
        if (not L.ToyJunkie.db.profile.selectedToybox) then
            L.ToyJunkie.db.profile.selectedToybox = L.ToyJunkie.db.profile.boxes[1].name
        end
    else
        self:Hide()
        return
    end

    if (auto) then
        if (force == "CLOSE") then
            self:Hide()
        else
            if (not L.isInCombat) then
                self:UpdateToyboxDisplay()
                self:UpdateToyButtons()
                self:UpdateQuickButtons()
                self:Show()
            end
        end
    else
        if (force == "CLOSE") then
            self:Hide()
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
            L.ToyJunkie.db.profile.toyboxShown = false
        else
            if (not L.isInCombat) then
                self:UpdateToyboxDisplay()
                self:UpdateToyButtons()
                self:UpdateQuickButtons()
                self:Show()
                PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
                L.ToyJunkie.db.profile.toyboxShown = true
            end
        end
    end
end

function L.ToyboxFrame:UpdatePosition()
    self:ClearAllPoints()
    self:SetPoint(
        L.ToyJunkie.db.profile.toyBoxFrame.location.point,
        nil,
        L.ToyJunkie.db.profile.toyBoxFrame.location.relativePoint,
        L.ToyJunkie.db.profile.toyBoxFrame.location.offsetX,
        L.ToyJunkie.db.profile.toyBoxFrame.location.offsetY
    )
    self:SetWidth(L.ToyJunkie.db.profile.toyBoxFrame.width)
    self:SetHeight(L.ToyJunkie.db.profile.toyBoxFrame.height)
    if (L.ToyJunkie.db.profile.toyBoxFrame.isSideBarShown) then
        L.ToyboxFrame.ToyButtonHolderFrame:SetPoint("TOPLEFT", 130, -25)
        L.ToyboxFrame.RandomToyButton:SetPoint("TOPLEFT", L.ToyboxFrame.ToyButtonHolderFrame, 7, 20)
    else
        L.ToyboxFrame.ToyButtonHolderFrame:SetPoint("TOPLEFT", 15, -25)
        L.ToyboxFrame.RandomToyButton:SetPoint("TOPLEFT", L.ToyboxFrame.ToyButtonHolderFrame, 15, 20)
    end

    if (L.ToyJunkie.db.profile.toyBoxFrame.locked) then
        L.ToyboxFrame.LockButton:SetText("U")
        L.ToyboxFrame.ResizeButton:Hide()
    else
        L.ToyboxFrame.LockButton:SetText("L")
        L.ToyboxFrame.ResizeButton:Show()
    end
end

function L.ToyboxFrame:SavePosition()
    L.ToyJunkie.db.profile.toyBoxFrame.location.point,
    _,
    L.ToyJunkie.db.profile.toyBoxFrame.location.relativePoint,
    L.ToyJunkie.db.profile.toyBoxFrame.location.offsetX,
    L.ToyJunkie.db.profile.toyBoxFrame.location.offsetY = L.ToyboxFrame:GetPoint()
    L.ToyJunkie.db.profile.toyBoxFrame.width = L.ToyboxFrame:GetWidth()
    L.ToyJunkie.db.profile.toyBoxFrame.height = L.ToyboxFrame:GetHeight()
end

--Final Setup
L.ToyboxFrame:Hide()
