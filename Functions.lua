local addonName, L = ...

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
            info = UIDropDownMenu_CreateInfo()
            info.text = value
            info.notCheckable = true
            --info.func = FIGURE IT OUT!
            UIDropDownMenu_AddButton(info)
        end
    end, "MENU")

    return dropdown
end



--- Opts:
---     name (string): Name of the dropdown (lowercase)
---     parent (Frame): Parent frame of the dropdown.
---     items (Table): String table of the dropdown options.
---     defaultVal (String): String value for the dropdown to default to (empty otherwise).
---     changeFunc (Function): A custom function to be called, after selecting a dropdown option.
local function createDropdown(opts)
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local dropdown_width = 0
    local default_val = opts['defaultVal'] or ''
    local change_func = opts['changeFunc'] or function (dropdown_val) end

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
        dd_title:SetText(item)
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
end