local addonName, L = ...



--The cursor can't be changed while over WorldFrame, so this frame acts as a backdrop beneath the UI
--so the cursor can remain an ITEM_CURSOR while dragging. (it also serves to capture clicks to drop
--the stuff off the cursor.)

L.ToyJunkie.DragBackdrop = CreateFrame("Button", "ToyJunkie_DragBackdrop", UIParent)
L.ToyJunkie.DragBackdrop:SetFrameStrata("LOW")
L.ToyJunkie.DragBackdrop:SetFrameLevel(0)
L.ToyJunkie.DragBackdrop:SetAllPoints()
L.ToyJunkie.DragBackdrop:Hide()
L.ToyJunkie.DragBackdrop:SetScript("OnShow", function(self)
    L.AttachedFrame.ScrollFrame.listView:RegisterEvent("GLOBAL_MOUSE_UP")
end)
L.ToyJunkie.DragBackdrop:SetScript("OnHide", function(self)
    L.AttachedFrame.ScrollFrame.listView:UnregisterEvent("GLOBAL_MOUSE_UP")
end)

--[[L.ToyJunkie.DragBackdrop:SetScript("OnEvent",function(self, event, button)
    if(event == "GLOBAL_MOUSE_UP") then
        if(button == "RightButton") then
            SetCursor(nil)
            ClearCursor()
            if(L.ToyJunkie.movingHeader ~= nil) then
                L.ToyJunkie.DragHeader:Hide()
                L.ToyJunkie.movingHeader = nil
                L.AttachedFrame.ScrollFrame.listView:Refresh()
                self:Hide()
            end
        end
    end
end)]]

L.ToyJunkie.DragHeader = CreateFrame("Frame", "ToyJunkie_DragHeaderFrame", L.ToyJunkie.DragBackdrop, "BackdropTemplate")
L.ToyJunkie.DragHeader:SetPoint("CENTER")
L.ToyJunkie.DragHeader:SetFrameStrata("TOOLTIP")
L.ToyJunkie.DragHeader:SetBackdrop(BACKDROP_TOAST_12_12)
L.ToyJunkie.DragHeader:SetSize(150,30)

L.ToyJunkie.DragHeader.Text = L.ToyJunkie.DragHeader:CreateFontString(nil, "OVERLAY", "GameFontWhite")
L.ToyJunkie.DragHeader.Text:SetText("")
L.ToyJunkie.DragHeader.Text:SetPoint("LEFT", 35, 0)
L.ToyJunkie.DragHeader.Text:SetPoint("RIGHT", -10, 0)
L.ToyJunkie.DragHeader.Text:SetJustifyH("LEFT")
L.ToyJunkie.DragHeader.Text:SetWordWrap(false)

L.ToyJunkie.DragHeader.Icon = L.ToyJunkie.DragHeader:CreateTexture(nil, "ARTWORK")
L.ToyJunkie.DragHeader.Icon:SetTexture(454046)
L.ToyJunkie.DragHeader.Icon:SetSize(18,18)
L.ToyJunkie.DragHeader.Icon:SetPoint("LEFT", 10, 0)

L.ToyJunkie.DragHeader:SetScript("OnUpdate", function(self, elapsed)
    if(self:IsShown()) then
        local x,y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x/scale, y/scale)
    end
end)

L.ToyJunkie.DragHeader:Hide()