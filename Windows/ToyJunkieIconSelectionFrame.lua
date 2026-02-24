local addon, L = ...

L.IconSelectionFrame = Mixin(CreateFrame("Frame", "$parent_IconSelectionFrame", L.AttachedFrame, "ButtonFrameBaseTemplate"), IconScrollTemplateMixin)
ButtonFrameTemplate_HidePortrait(L.IconSelectionFrame)
L.IconSelectionFrame:SetFrameStrata("DIALOG")
L.IconSelectionFrame.CloseButton:Hide()
L.IconSelectionFrame:SetPoint("CENTER")
L.IconSelectionFrame:SetSize(500, 500)
L.IconSelectionFrame:OnLoad()
L.IconSelectionFrame:SetScript("OnShow", function(self)
    L.ToyJunkie.noInteraction = true
end)
L.IconSelectionFrame:SetScript("OnHide", function(self)
    L.ToyJunkie.noInteraction = false
end)
L.IconSelectionFrame:Hide()