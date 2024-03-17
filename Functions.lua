local addonName, L = ...

function L:CursorHasToy()
    if (GetCursorInfo()) then
        local itemType, id = GetCursorInfo()
        if(id) then
            if (C_ToyBox.GetToyInfo(id)) then
                return true
            end
        end
    end
    return false
end

function L:CursorOnTopHalf(element)
    local _, y = GetCursorPosition()
    local scale = element:GetEffectiveScale()
    local _, cy = element:GetCenter()

    if (y / scale > cy) then
        return true
    end
    return false
end

function L:GetBackdropColorByToyboxId(id)
    if (L.ToyJunkie.db.profile.boxes[id] ~= nil) then
        if (L.ToyJunkie.db.profile.boxes[id].toyColor ~= nil) then
            return L.ToyJunkie.db.profile.boxes[id].toyColor.red,
                L.ToyJunkie.db.profile.boxes[id].toyColor.green,
                L.ToyJunkie.db.profile.boxes[id].toyColor.blue,
                L.ToyJunkie.db.profile.boxes[id].toyColor.alpha
        end
    end
    return 0, 1, 0, .25
end

function L:IsToyboxNameDuplicate(name, checkCase, ignore)
    checkCase = checkCase or false
    for _, box in pairs(L.ToyJunkie.db.profile.boxes) do
        if (box.name ~= ignore) then
            if (not checkCase) then
                if (string.lower(box.name) == string.lower(name)) then
                    return true
                end
            else
                if (box.name == name) then
                    return true
                end
            end
        end
    end
    return false
end

function L:GetToyboxId(toybox) -- toybox can be from the profile boxes or from list element toy box
    for k, v in pairs(L.ToyJunkie.db.profile.boxes) do
        if (v.name == toybox.name) then
            return k
        end
    end
    return nil
end

function L:GetToyBoxIdByName(name)
    for k, v in pairs(L.ToyJunkie.db.profile.boxes) do
        if (string.lower(v.name) == string.lower(name)) then
            return k
        end
    end
    return nil
end

function L:GetToyIndex(toyId, toyboxId)
    for k, v in pairs(L.ToyJunkie.db.profile.boxes[toyboxId].toys) do
        if (v == toyId) then
            return k
        end
    end
end

function L:strStart(String, Start)
    return strsub(String, 1, string.len(Start)) == Start
end

function L:strContains(str, searchText)
    local contains = true
    local searchTerms = L:searchSplit(searchText)
    for key, searchTerm in pairs(searchTerms) do
        if (not string.find(string.lower(str), searchTerm)) then
            contains = false
        end
    end
    return contains
end

function L:searchSplit(inputstr, sep)
    sep = sep or '%s'
    local t = {}
    for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
        table.insert(t, string.lower(field))
        if s == "" then
            return t
        end
    end
end

function L:AddToy(toyId, toyboxId, index)
    for key, id in pairs(L.ToyJunkie.db.profile.boxes[toyboxId].toys) do
        if (id == toyId) then
            UIErrorsFrame:AddExternalErrorMessage("That toy is already in this toy box.")
            return
        end
    end

    if (index ~= nil) then
        table.insert(L.ToyJunkie.db.profile.boxes[toyboxId].toys, index, toyId)
    else
        table.insert(L.ToyJunkie.db.profile.boxes[toyboxId].toys, toyId)
    end

    if (L.ToyboxFrame:IsShown()) then
        L.ToyboxFrame:UpdateToyButtons(L.ToyJunkie.db.profile.toyboxLastSelectedPage)
    end
end

function L:CheckIfToyExistsInToybox(toyId, toyboxId)
    for key, id in pairs(L.ToyJunkie.db.profile.boxes[toyboxId].toys) do
        if (id == toyId) then
            UIErrorsFrame:AddExternalErrorMessage("That toy is already in the target toy box.")
            return true
        end
    end
    return false
end

function L:GetToyButton(id)
    for k, v in pairs(L.ToyboxFrame.ToyButtonHolderFrame.Buttons) do
        if (v.num == id) then
            return v
        end
    end
end

---------------------------
-- Reusable Context Menu --
---------------------------

function L:CreateContextMenu(menu)
    local dropdownName = "$parent_" .. menu.name .. "_dropdown"
    local items = menu.items or {}
    local title = menu.title

    local dropdown = CreateFrame("Frame", dropdownName, _G["$parent"], "UIDropDownMenuTemplate")

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        if (title ~= nil) then
            info.text = title
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info)
        end

        for key, value in pairs(items) do
            if (value.separator) then
                UIDropDownMenu_AddSeparator()
            else
                info = UIDropDownMenu_CreateInfo()
                info.text = value.text
                info.notCheckable = true
                info.func = value.func
                info.icon = value.icon
                info.colorCode = value.color
                info.tooltipTitle = value.tooltipTitle
                info.tooltipText = value.tooltipText
                info.tooltipWarning = value.tooltipWarning
                info.tooltipOnButton = true
                UIDropDownMenu_AddButton(info)
            end
        end
    end, "MENU")

    return dropdown
end

function L:SettingsMenuDropdown(parent)
    local dropdown = CreateFrame("Frame", "$parent_settingsmenu_dropdown", parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()

        if (level == 1) then
            info.text = "ToyJunkie Settings"
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info)

            info = UIDropDownMenu_CreateInfo()

            info.text = "Compact Display"
            info.checked = L.ToyJunkie.db.profile.compactDisplay
            info.func = function()
                L.ToyJunkie.db.profile.compactDisplay = not L.ToyJunkie.db.profile.compactDisplay
                L.ToyboxFrame:ChangeFrame()
            end
            info.isNotRadio = true
            info.tooltipTitle = "Compact Display"
            info.tooltipText = "Enable compact toy box display"
            info.tooltipOnButton = true
            UIDropDownMenu_AddButton(info)

            info = UIDropDownMenu_CreateInfo()

            info.text = "Show Tooltips"
            info.checked = L.ToyJunkie.db.profile.showTooltips
            info.func = function()
                L.ToyJunkie.db.profile.showTooltips = not L.ToyJunkie.db.profile.showTooltips
            end
            info.isNotRadio = true
            info.tooltipTitle = "Show Tooltips"
            info.tooltipText = "Show tooltips on toys in toy box.\nWhen shown, tooltips are delayed."
            info.tooltipOnButton = true
            UIDropDownMenu_AddButton(info)

            info = UIDropDownMenu_CreateInfo()

            info.text = "Lock Toy Box"
            info.checked = L.ToyJunkie.db.profile.lockToyboxFrame
            info.func = function()
                L.ToyJunkie.db.profile.lockToyboxFrame = not L.ToyJunkie.db.profile.lockToyboxFrame
            end
            info.isNotRadio = true
            info.tooltipTitle = "Show Tooltips"
            info.tooltipText = "Show tooltips on toys in toy box.\nWhen shown, tooltips are delayed."
            info.tooltipOnButton = true
            UIDropDownMenu_AddButton(info)

            info = UIDropDownMenu_CreateInfo()

            info.text = "Minimap Options"
            info.hasArrow = true
            info.menuList = "minimap"
            info.notCheckable = true
            UIDropDownMenu_AddButton(info)

            UIDropDownMenu_AddSeparator()

            info = UIDropDownMenu_CreateInfo()
            info.text = "Profiles"
            info.notCheckable = true
            info.func = function()
                InterfaceOptionsFrame_OpenToCategory(L.ToyJunkie.profiles)
            end
            UIDropDownMenu_AddButton(info)
        elseif (menuList == "minimap") then
            info = UIDropDownMenu_CreateInfo()
            info.text = "Hide Minimap Button"
            info.checked = L.ToyJunkie.db.profile.minimap.hide
            info.func = function()
                if(L.ToyJunkie.db.profile.minimap.hide) then
                    L.ToyJunkie.db.profile.minimap.hide = false
                    L.ToyJunkie.Icon:Show(addonName)
                else
                    L.ToyJunkie.db.profile.minimap.hide = true
                    L.ToyJunkie.Icon:Hide(addonName)
                end
                dropdown:Hide()
            end
            info.isNotRadio = true
            UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
            info.text = "Lock Minimap Button"
            info.checked = L.ToyJunkie.db.profile.minimap.lock
            info.func = function()
                if(L.ToyJunkie.db.profile.minimap.lock) then
                    L.ToyJunkie.db.profile.minimap.lock = false
                    L.ToyJunkie.Icon:Unlock(addonName)
                else
                    L.ToyJunkie.db.profile.minimap.lock = true
                    L.ToyJunkie.Icon:Lock(addonName)
                end
                dropdown:Hide()
            end
            info.isNotRadio = true
            UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
            info.text = "ToyJunkie in Addon Compartment"
            info.checked = L.ToyJunkie.db.profile.addonCompartment
            info.func = function()
                if(L.ToyJunkie.db.profile.addonCompartment) then
                    L.ToyJunkie.db.profile.addonCompartment = false
                    L.ToyJunkie.Icon:RemoveButtonFromCompartment(addonName)
                else
                    L.ToyJunkie.db.profile.addonCompartment = true
                    L.ToyJunkie.Icon:AddButtonToCompartment(addonName)
                end
                dropdown:Hide()
            end
            info.isNotRadio = true
            UIDropDownMenu_AddButton(info, level)
        end
    end, "MENU")

    if(parent == L.ToyboxFrame.SettingsButton) then
        ToggleDropDownMenu(1, nil, dropdown, L.ToyboxFrame, L.ToyboxFrame:GetWidth() + 10, L.ToyboxFrame:GetHeight())
    else
        ToggleDropDownMenu(1, nil, dropdown, "cursor")
    end
end
