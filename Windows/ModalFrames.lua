local addonName, L = ...

IN_MODAL = {
    YesNo = 1,
    Okay = 2,
    OkayCancel = 3
}

IN_MODAL_RESULT = {
    Yes = 1,
    Okay = 1,
    Cancel = 2,
    No = 2
}


local button1Function = nil
local button2Function = nil


----------------------------
-- Set up popup container --
----------------------------
L.ModalContainer = CreateFrame("Frame", "ToyJunkie_ModalFrame", UIParent, "ButtonFrameTemplate")
ButtonFrameTemplate_HidePortrait(L.ModalContainer)
ButtonFrameTemplate_HideAttic(L.ModalContainer)
L.ModalContainer:SetFrameStrata("FULLSCREEN")
L.ModalContainer:SetFrameLevel(9001)
L.ModalContainer.CloseButton:Hide()
L.ModalContainer:SetSize(500, 100)
L.ModalContainer:SetPoint("TOP", 0, -50)
L.ModalContainer.Inset:SetPoint("TOPLEFT", 10, -24) --Fix inset positioning
L.ModalContainer:SetTitle("Modal Title")
L.ModalContainer.Message = L.ModalContainer.Inset:CreateFontString("$parent_Message", "OVERLAY", "GameFontHighlight")
L.ModalContainer.Message:SetPoint("TOPLEFT", 5, -5)
L.ModalContainer.Message:SetPoint("BOTTOMRIGHT", -5, 5)
L.ModalContainer.Message:SetText("Modal Message")

L.ModalContainer.Button1 = CreateFrame("Button", "$parent_Button1", L.ModalContainer, "UIMenuButtonStretchTemplate")
L.ModalContainer.Button1:SetText("Button1")
L.ModalContainer.Button1:SetPoint("BOTTOMRIGHT", -10, 3)
L.ModalContainer.Button1:SetSize(100,23)
L.ModalContainer.Button1:SetScript("OnClick", function(self)
    if(button1Function) then
        button1Function()
    else
        L.ToyJunkie:Print("Button1 function not set!")
    end
end)
L.ModalContainer.Button1:Hide()

L.ModalContainer.Button2 = CreateFrame("Button", "$parent_Button2", L.ModalContainer, "UIMenuButtonStretchTemplate")
L.ModalContainer.Button2:SetText("Button2")
L.ModalContainer.Button2:SetPoint("BOTTOMRIGHT", -110, 3)
L.ModalContainer.Button2:SetSize(100, 23)
L.ModalContainer.Button2:SetScript("OnClick", function(self)
    if(button2Function) then
        button2Function()
    else
        L.ToyJunkie:Print("Button2 function not set!")
    end
end)
L.ModalContainer.Button2:Hide()
L.ModalContainer:Hide()

L.ModalContainer.Overlay = CreateFrame("Button", "$parent_Overlay", L.ModalContainer)
L.ModalContainer.Overlay:SetFrameStrata("FULLSCREEN")
L.ModalContainer.Overlay:SetFrameLevel(9000)
L.ModalContainer.Overlay:SetAllPoints(UIParent)


--------------------------
-- Functions for Modals --
--------------------------

function L.ModalContainer:Open(type, title, msg, callbackFunc)
    if(L.isInCombat) then
        UIErrorsFrame:AddExternalErrorMessage("Currently in combat, cannot open popup. Try again when combat is ended.")
        return
    end


    self:SetTitle(title)
    self.Message:SetText(msg)
    self:SetHeight(75 + self.Message:GetStringHeight())
    self:Show()
    if(type == 1) then
        self.Button1:Show()
        self.Button1:SetText("No")
        button1Function = function()
            if(callbackFunc) then
                callbackFunc(2)
                self:Hide()
                self:Reset()
            else
                L.ToyJunkie:Print("Callback function not set!")
            end
        end
        self.Button2:Show()
        self.Button2:SetText("Yes")
        button2Function = function()
            if(callbackFunc) then
                callbackFunc(1)
                self:Hide()
                self:Reset()
            else
                L.ToyJunkie:Print("Callback function not set!")
            end
        end
    end

    if(type == 2) then
        self.Button1:Show()
        self.Button1:SetText("Okay")
        button1Function = function()
            self:Hide()
            self:Reset()
        end
    end
end

function L.ModalContainer:Reset()
    self.Button1:Hide()
    self.Button2:Hide()
    button1Function = nil
    button2Function = nil
    callbackFunction = nil
end

if(JunkieDebug) then
    modal = YesNoFrame
end
