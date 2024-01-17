local addonName, L = ...

local isMoving = false

------------------------------
-- Create main toybox frame --
------------------------------

L.ToyboxFrame = CreateFrame("Frame", "ToyJunkie_ToyboxFrame", UIParent, "BackdropTemplate")
L.ToyboxFrame:SetFrameLevel(5)
--L.ToyboxFrame.Bg = CreateFrame("Frame", "$parent_Bg", L.ToyboxFrame, "FlatPanelBackgroundTemplate")
L.ToyboxFrame.Bg = L.ToyboxFrame:CreateTexture()
L.ToyboxFrame.Bg:SetDrawLayer("BACKGROUND")
L.ToyboxFrame.Bg:SetPoint("TOPLEFT", 2, -2)
L.ToyboxFrame.Bg:SetPoint("BOTTOMRIGHT", -2, 2)
L.ToyboxFrame.Bg:SetColorTexture(PANEL_BACKGROUND_COLOR.r, PANEL_BACKGROUND_COLOR.g, PANEL_BACKGROUND_COLOR.b, 1)
L.ToyboxFrame:SetBackdrop({
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
L.ToyboxFrame:SetBackdropBorderColor(.5, .5, .5, 1)
L.ToyboxFrame:SetSize(194, 204)
L.ToyboxFrame:SetPoint("TOPLEFT", 20, -20)

L.ToyboxFrame:RegisterForDrag("LeftButton")
L.ToyboxFrame:SetClampedToScreen(true)
L.ToyboxFrame:SetMovable(true)
L.ToyboxFrame:EnableMouse(true)

L.ToyboxFrame:SetScript("OnDragStart", function(self, button)
    if (not isMoving) then
        L.ToyboxFrame:StartMoving()
        isMoving = true
    end
end)
L.ToyboxFrame:SetScript("OnDragStop", function(self, button)
    if (isMoving) then
        L.ToyboxFrame:StopMovingOrSizing()
        isMoving = false
    end
end)
L.ToyboxFrame:SetScript("OnHide", function(self)
    if (isMoving) then
        L.ToyboxFrame:StopMovingOrSizing()
        isMoving = false
    end
end)

L.ToyboxFrame.CloseButton = CreateFrame("Button", "$parent_CloseButton", L.ToyboxFrame, "UIPanelCloseButton")
L.ToyboxFrame.CloseButton:SetSize(18, 18)
L.ToyboxFrame.CloseButton:SetPoint("TOPRIGHT", 0, 0)
L.ToyboxFrame.CloseButton:SetScript("OnClick", function(self, button)
    if (button == "LeftButton") then
        L.ToyboxFrame:Toggle()
    end
end)

L.ToyboxFrame.Icon = L.ToyboxFrame:CreateTexture()
L.ToyboxFrame.Icon:SetSize(16, 16)
L.ToyboxFrame.Icon:SetPoint("TOPLEFT", 7, -7)
L.ToyboxFrame.Icon:SetTexture(454046)

L.ToyboxFrame.Title = L.ToyboxFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
L.ToyboxFrame.Title:SetPoint("TOPLEFT", L.ToyboxFrame, 25, -9)
L.ToyboxFrame.Title:SetPoint("TOPRIGHT", L.ToyboxFrame, -40, -24)
L.ToyboxFrame.Title:SetWordWrap(false)

L.ToyboxFrame.ToyButtonHolderFrame = CreateFrame("Frame", "$parent_ToyButtonHolderFrame", L.ToyboxFrame)
L.ToyboxFrame.ToyButtonHolderFrame:SetScale(1)
L.ToyboxFrame.ToyButtonHolderFrame:SetPoint("TOPLEFT", 15, -30)
L.ToyboxFrame.ToyButtonHolderFrame:SetSize(164, 164)


--------------------
-- Page Interface --
--------------------
L.ToyboxFrame.PageInterface = CreateFrame("Frame", "$parent_PageInterface", L.ToyboxFrame, "BackdropTemplate")
L.ToyboxFrame.PageInterface:SetFrameLevel(4)
L.ToyboxFrame.PageInterface.Bg = L.ToyboxFrame.PageInterface:CreateTexture()
L.ToyboxFrame.PageInterface.Bg:SetDrawLayer("BACKGROUND")
L.ToyboxFrame.PageInterface.Bg:SetPoint("TOPLEFT", 2, -2)
L.ToyboxFrame.PageInterface.Bg:SetPoint("BOTTOMRIGHT", -2, 2)
L.ToyboxFrame.PageInterface.Bg:SetColorTexture(PANEL_BACKGROUND_COLOR.r, PANEL_BACKGROUND_COLOR.g, PANEL_BACKGROUND_COLOR.b, 1)
L.ToyboxFrame.PageInterface:SetBackdrop({
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
L.ToyboxFrame.PageInterface:SetBackdropBorderColor(.5, .5, .5, 1)
L.ToyboxFrame.PageInterface:SetSize(95, 30)
L.ToyboxFrame.PageInterface:SetPoint("BOTTOM", 0, -22)

L.ToyboxFrame.PageInterface.PrevPageButton = CreateFrame("Button", "$parent_PrevToyButton", L.ToyboxFrame.PageInterface)
L.ToyboxFrame.PageInterface.PrevPageButton:SetPoint("BOTTOMLEFT", -3, -4)
L.ToyboxFrame.PageInterface.PrevPageButton.Bg = L.ToyboxFrame.PageInterface.PrevPageButton:CreateTexture(nil, "BACKGROUND") --Button is transparent, added black background to create solid
L.ToyboxFrame.PageInterface.PrevPageButton.Bg:SetPoint("TOPLEFT", 4, -5)
L.ToyboxFrame.PageInterface.PrevPageButton.Bg:SetPoint("BOTTOMRIGHT", -4, 5)
L.ToyboxFrame.PageInterface.PrevPageButton.Bg:SetColorTexture(0,0,0,1)
L.ToyboxFrame.PageInterface.PrevPageButton:SetSize(24,24)
L.ToyboxFrame.PageInterface.PrevPageButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Up")
L.ToyboxFrame.PageInterface.PrevPageButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Down")
L.ToyboxFrame.PageInterface.PrevPageButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Disabled")
L.ToyboxFrame.PageInterface.PrevPageButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
L.ToyboxFrame.PageInterface.PrevPageButton:SetScript("OnClick", function(self)
    PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN)
    L.ToyboxFrame:UpdateToyButtons(L.ToyJunkie.db.profile.toyboxLastSelectedPage - 1)
end)

L.ToyboxFrame.PageInterface.NextPageButton = CreateFrame("Button", "$parent_NextPageButton", L.ToyboxFrame.PageInterface)
L.ToyboxFrame.PageInterface.NextPageButton:SetPoint("BOTTOMRIGHT", 3, -4)
L.ToyboxFrame.PageInterface.NextPageButton.Bg = L.ToyboxFrame.PageInterface.NextPageButton:CreateTexture(nil, "BACKGROUND") --Button is transparent, added black background to create solid
L.ToyboxFrame.PageInterface.NextPageButton.Bg:SetPoint("TOPLEFT", 4, -5)
L.ToyboxFrame.PageInterface.NextPageButton.Bg:SetPoint("BOTTOMRIGHT", -4, 5)
L.ToyboxFrame.PageInterface.NextPageButton.Bg:SetColorTexture(0,0,0,1)
L.ToyboxFrame.PageInterface.NextPageButton:SetSize(24,24)
L.ToyboxFrame.PageInterface.NextPageButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Up")
L.ToyboxFrame.PageInterface.NextPageButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Down")
L.ToyboxFrame.PageInterface.NextPageButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Disabled")
L.ToyboxFrame.PageInterface.NextPageButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
L.ToyboxFrame.PageInterface.NextPageButton:SetScript("OnClick", function(self)
    PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN)
    L.ToyboxFrame:UpdateToyButtons(L.ToyJunkie.db.profile.toyboxLastSelectedPage + 1)
end)

L.ToyboxFrame.PageInterface.PageIndicator = L.ToyboxFrame.PageInterface:CreateFontString(nil, "OVERLAY", "GameTooltipText")
L.ToyboxFrame.PageInterface.PageIndicator:SetPoint("BOTTOM", 0, 7)

function L.ToyboxFrame.PageInterface.PageIndicator:SetPages(currentPage, maxPage)
    self:SetText(currentPage .. " / " .. maxPage)
end

function L.ToyboxFrame.PageInterface:UpdatePageButtons(currentPage, maxPage)
    if(maxPage == 1) then
        self:Hide()
    else
        self:Show()
    end
    if(currentPage == 1) then
        self.PrevPageButton:Disable()
    else
        self.PrevPageButton:Enable()
    end
    if(currentPage == maxPage) then
        self.NextPageButton:Disable()
    else
        self.NextPageButton:Enable()
    end
end

----------------------
-- Toybox Functions --
----------------------
function L.ToyboxFrame:UpdateAll()
    self:UpdateToyboxDisplay()
    self:UpdateToyButtons(L.ToyJunkie.db.profile.toyboxLastSelectedPage)
end

function L.ToyboxFrame:UpdateToyboxDisplay()
    local idx = 1
    for id, box in pairs(L.ToyJunkie.db.profile.boxes) do
        if(box.name == L.ToyJunkie.db.profile.selectedToybox) then
            idx = id
            break
        end
    end
    self.Title:SetText(L.ToyJunkie.db.profile.boxes[idx].name)
    self.Icon:SetTexture(L.ToyJunkie.db.profile.boxes[idx].icon)
end

function L.ToyboxFrame:CreateToyButtons()
    local holder = L.ToyboxFrame.ToyButtonHolderFrame
    holder.Buttons = {}

    local buttonPoints = {
        { num = 1, x = 0, y = 0 },
        { num = 2, x = 58, y = 0 },
        { num = 3, x = 116, y = 0 },
        { num = 4, x = 0, y = -58 },
        { num = 5, x = 58, y = -58 },
        { num = 6, x = 116, y = -58 },
        { num = 7, x = 0, y = -116 },
        { num = 8, x = 58, y = -116 },
        { num = 9, x = 116, y = -116 },
    }

    for i=1, 9 do
        local button = CreateFrame("Button", "$parent_ToyButton" .. i, holder, "SecureActionButtonTemplate")
        button:SetSize(48, 48)
        button:RegisterForClicks("AnyUp", "AnyDown")
        button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
        button.Cooldown = CreateFrame("Cooldown", "$parent_Cooldown", button, "CooldownFrameTemplate")
        button.Cooldown:SetAllPoints()
        button.Cooldown:Hide()
        button:SetScript("OnEvent", function(self, event)
            if(event == "SPELL_UPDATE_COOLDOWN") then
                if(self.id ~= nil) then
                    local start, duration, enable = GetItemCooldown(self.id)
                    if(start > 0) then
                        CooldownFrame_Set(self.Cooldown, start, duration, enable)
                    end
                end
            end
        end)

        button:HookScript("OnEnter", function(self)
            if(self.id ~= nil and L.ToyJunkie.db.profile.showTooltips) then
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                local _, toyName = C_ToyBox.GetToyInfo(self.id)
                GameTooltip:AddLine(toyName)
                GameTooltip:Show()
            end
        end)

        button:HookScript("OnLeave", function(self) 
            if(self.id ~= nil and L.ToyJunkie.db.profile.showTooltips) then
                GameTooltip:Hide()
            end
        end)

        button.id = nil
        for k, v in pairs(buttonPoints) do
            if(v.num == i) then
                button:SetPoint("TOPLEFT", v.x, v.y)
                button.num = v.num
                break
            end
        end
        --button:Hide()
        table.insert(holder.Buttons, button)
    end
end

function L.ToyboxFrame:CheckCooldowns(buttonNum)
    if(buttonNum == nil) then
        for i=1, 9 do
            local button = L:GetToyButton(i)
            if(button.id ~= nil) then
                local start, duration, enable = GetItemCooldown(button.id)
                if(start > 0) then
                    CooldownFrame_Set(button.Cooldown, start, duration, enable)
                else
                    button.Cooldown:Hide()
                end
            end
        end
    else
        local button = L:GetToyButton(buttonNum)
        if(button.id ~= nil) then
            local start, duration, enable = GetItemCooldown(button.id)
            if(start > 0) then
                CooldownFrame_Set(button.Cooldown, start, duration, enable)
            else
                button.Cooldown:Hide()
            end
        end
    end
end

function L.ToyboxFrame:UpdateToyButtons(page)
    local toys = L.ToyJunkie.db.profile.boxes[L:GetToyBoxIdByName(L.ToyJunkie.db.profile.selectedToybox)].toys
    local currentPage = page or 1
    for i=1, 9 do
        L:GetToyButton(i):Hide()
    end

    if(toys ~= nil) then
        local totalPages = math.ceil(#toys / 9)
        local endIndex = 0
        if(totalPages == 0) then
            totalPages = 1
        end
        if(currentPage > totalPages) then
            currentPage = 1
        end
        local startIndex = (currentPage * 9) - 8

        for i=0, 8 do
            local toyId = toys[i + startIndex]
            local button = L:GetToyButton(i + 1)
            if(toyId) then
                local _, _, toyIcon = C_ToyBox.GetToyInfo(toyId)
                if(toyIcon ~= nil) then
                    button.id = toyId
                    button:SetNormalTexture(toyIcon)
                    button:SetAttribute("type1", "toy")
                    button:SetAttribute("toy1", toyId)
                    button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
                    button:Show()
                    L.ToyboxFrame:CheckCooldowns(i + 1)
                end
            else
                button:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
                button.id = nil
                button:Hide()
            end
        end
        L.ToyboxFrame.PageInterface:UpdatePageButtons(currentPage, totalPages)
        L.ToyboxFrame.PageInterface.PageIndicator:SetPages(currentPage, totalPages)
    end
    L.ToyJunkie.db.profile.toyboxLastSelectedPage = currentPage
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
        if(not L.ToyJunkie.db.profile.selectedToybox) then
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
            self:UpdateToyboxDisplay()
            self:UpdateToyButtons(L.ToyJunkie.db.profile.toyboxLastSelectedPage)
            self:Show()
        end
    else
        if (force == "CLOSE") then
            self:Hide()
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
            L.ToyJunkie.db.profile.toyboxShown = false
        else
            if (not L.isInCombat) then
                self:UpdateToyboxDisplay()
                self:UpdateToyButtons(L.ToyJunkie.db.profile.toyboxLastSelectedPage)
                self:Show()
                PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
                L.ToyJunkie.db.profile.toyboxShown = true
            end
        end
    end
end

L.ToyboxFrame:Hide()
L.ToyboxFrame:CreateToyButtons()
