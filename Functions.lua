local addonName, L = ...

function L:CursorHasToy()
    if(GetCursorInfo()) then
        local itemType, id = GetCursorInfo()
        if(C_ToyBox.GetToyInfo(id)) then
            return true
        end
    end
    return false
end

function L:CursorOnTopHalf(element)
    local _, y = GetCursorPosition()
    local scale = element:GetEffectiveScale()
    local _, cy = element:GetCenter()

    if(y / scale > cy) then
        return true
    end
    return false
end

function L:GetBackdropColorByToyboxId(id)
    if(L.ToyJunkie.db.profile.boxes[id] ~= nil) then
        if(L.ToyJunkie.db.profile.boxes[id].toyColor ~= nil) then
            return L.ToyJunkie.db.profile.boxes[id].toyColor.red,
                   L.ToyJunkie.db.profile.boxes[id].toyColor.green,
                   L.ToyJunkie.db.profile.boxes[id].toyColor.blue,
                   L.ToyJunkie.db.profile.boxes[id].toyColor.alpha
        end
    end
    return 0,1,0,.25
end

function L:IsToyboxNameDuplicate(name, checkCase, ignore)
    checkCase = checkCase or false
    for _, box in pairs(L.ToyJunkie.db.profile.boxes) do
        if(box.name ~= ignore) then
            if(not checkCase) then
                if(string.lower(box.name) == string.lower(name)) then
                    return true
                end
            else
                if(box.name == name) then
                    return true
                end
            end
        end
    end
    return false
end

function L:strStart(String, Start)
    return strsub(String, 1, string.len(Start)) == Start
end

function L:strContains(str, searchText)
    local contains = true
    local searchTerms = L:searchSplit(searchText)
    for key, searchTerm in pairs(searchTerms) do
        if(not string.find(string.lower(str), searchTerm)) then
            contains = false
        end
    end
    return contains
end

function L:searchSplit(inputstr, sep)
    sep=sep or '%s'
    local t={}
    for field,s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do
       table.insert(t,string.lower(field))
       if s=="" then return t
       end
    end
 end

 function L:AddToy(toyId, toyboxId, index)
    for key, id in pairs(L.ToyJunkie.db.profile.boxes[toyboxId].toys) do
        if(id == toyId) then
            UIErrorsFrame:AddExternalErrorMessage("That toy is already on this list.")
            return
        end
    end

    if(index ~= nil) then
        table.insert(L.ToyJunkie.db.profile.boxes[toyboxId].toys, index, toyId)
    else
        table.insert(L.ToyJunkie.db.profile.boxes[toyboxId].toys, toyId)
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
        if(title ~= nil) then
            info.text = title
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info)
        end

        for key, value in pairs(items) do
            if(value.separator) then
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