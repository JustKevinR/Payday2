--------------------------------------------------------------------------------------------
--Shortcuts
local M_money = managers.money
local M_xp = managers.experience
local M_skill = managers.skilltree


--------------------------------------------------------------------------------------------
--SimpleMenu

if not SimpleMenu then
    SimpleMenu = class()

    function SimpleMenu:init(title, message, options)
        self.dialog_data = { title = title, text = message, button_list = {},
                             id = tostring(math.random(0,0xFFFFFFFF)) }
        self.visible = false
        for _,opt in ipairs(options) do
            local elem = {}
            elem.text = opt.text
            opt.data = opt.data or nil
            opt.callback = opt.callback or nil
            elem.callback_func = callback(self, self, "_do_callback",
                                          { data = opt.data,
                                            callback = opt.callback})
            elem.cancel_button = opt.is_cancel_button or false
            if opt.is_focused_button then
                self.dialog_data.focus_button = #self.dialog_data.button_list+1
            end
            table.insert(self.dialog_data.button_list, elem)
        end
        return self
    end

    function SimpleMenu:_do_callback(info)
        if info.callback then
            if info.data then
                info:callback(info.data)
            else
                info:callback()
            end
        end
        self.visible = false
    end

    function SimpleMenu:show()
        if self.visible then
            return
        end
        self.visible = true
        managers.system_menu:show(self.dialog_data)
    end

    function SimpleMenu:hide()
        if self.visible then
            managers.system_menu:close(self.dialog_data.id)
            self.visible = false
            return
        end
    end
end


----------------------------------------------------------------------------------------------------------------
-- OPEN MENU
local function openmenu(menu)
    menu:show()
end

local function Main_menu()
    openmenu(mymenu_main)
end

local function Level_menu()
    openmenu(mymenu_level)
end

local function Money_menu()
    openmenu(mymenu_money)
end

local function Inventory_menu()
    openmenu(mymenu_inventory)
    
end


---------------------------------------------------------------------------------------------------------------------------------
--FUNCTIONS

--Level functions
local function level_optionone()
    M_xp :_set_current_level(0)
    M_skill:_set_points(0)
end

local function level_optionsix()
    M_xp :_set_current_level(5)
    M_skill:_set_points(5)
end

local function level_optionseven()
    M_xp :_set_current_level(10)
    M_skill:_set_points(12)
end

local function level_optiontwo()
    M_xp :_set_current_level(25)
    M_skill:_set_points(29)
end

local function level_optionthree()
    M_xp :_set_current_level(50)
    M_skill:_set_points(60)
end

local function level_optionfour()
    M_xp :_set_current_level(75)
    M_skill:_set_points(89)
end

local function level_optionfive()
    M_xp:_set_current_level(99)
    M_xp:debug_add_points( 30000000)
    M_skill:_set_points(120)
end


--money functions
local function one_four_mil()
    M_money:_add_to_total(5000000)
end

local function ten_forty_mil()
    M_money:_add_to_total(50000000)
end

local function hundred_four_hundred_mil()
    M_money:_add_to_total(500000000)
end

local function one_four_bil()
    M_money:_add_to_total(5000000000)
end

local function reset_money()
    M_money:_deduct_from_total(999999999999999999999)
    M_money:_deduct_from_offshore(999999999999999999999)
end


--inventory functions
local function unlock_weapons()
    local wep_arr = {
        'new_m4', 'glock_17', 'mp9', 'r870', 'glock_18c', 'amcar', 'm16', 'olympic', 'ak74', 'akm', 'akmsu', 'saiga', 'ak5', 'aug', 'g36', 'p90', 'new_m14', 'deagle', 'new_mp5', 'colt_1911', 'mac10', 'serbu', 'huntsman', 'b92fs', 'new_raging_bull',  'saw'
    }
    for i, name in ipairs(wep_arr) do
        if not managers.upgrades:aquired(name) then
            managers.upgrades:aquire(name)
        end
    end
end

local function unlock_weapon_mods()
    for mod_id,_ in pairs(tweak_data.blackmarket.weapon_mods) do
        tweak_data.blackmarket.weapon_mods[ mod_id ].unlocked = true
        managers.blackmarket:add_to_inventory("normal", "weapon_mods", mod_id, false)
    end
end

local function unlock_masks()
    managers.blackmarket:_setup_masks()
    for mask_id,_ in pairs(tweak_data.blackmarket.masks) do
        Global.blackmarket_manager.masks[mask_id].unlocked = true
        managers.blackmarket:add_to_inventory("normal", "masks", mask_id, false)
    end
end
---------------------------------------------------------------------------------------------------------------------------------
--MENU OPTIONS

--Main menu
mymenu_main_options = {
    { text = "Level Menu", callback = Level_menu },
    { text = "Money Menu", callback = Money_menu },
    { text = "Inventory Menu", callback = Inventory_menu },
    { text = "", is_cancel_button = true},
    { text = "", is_cancel_button = true },
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_main = SimpleMenu:new("Main menu", " ", mymenu_main_options)
mymenu_main:show()

--inventory menu
mymenu_inventory_options = {
    { text = "Unlock all weapons", callback = unlock_weapons },
    { text = "Unlock all weapon mods", callback = unlock_weapon_mods },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu},
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_inventory = SimpleMenu:new("Inventory Menu", "Unlock items.",mymenu_inventory_options)
mymenu_inventory:hide()

--Money menu
mymenu_money_options = {
    { text = "Add 1 mill cash + 4 mill offshore", callback = one_four_mil},
    { text = "Add 10 mill cash + 40 mill offshore", callback = ten_forty_mil},
    { text = "Add 100 mill cash + 400 mill offshore", callback = hundred_four_hundred_mil},
    { text = "Add 1 billion cash + 4 billion offshore", callback = one_four_bil},
    { text = "", is_cancel_button = true },
    { text = "Reset money", callback = reset_money},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu},
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_money = SimpleMenu:new("Money Menu", "Add/remove cash and offshore funds.", mymenu_money_options)
mymenu_money:hide()

--Level menu
mymenu_level_options = {
    { text = "Set level to 0", callback = level_optionone, is_focused_button = true },
    { text = "Set level to 5", callback = level_optionsix },
    { text = "Set level to 10", callback = level_optionseven },
    { text = "Set level to 25", callback = level_optiontwo },
    { text = "Set level to 50", callback = level_optionthree },
    { text = "Set level to 75", callback = level_optionfour },
    { text = "Set level to 100", callback = level_optionfive },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu},
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_level = SimpleMenu:new("Level menu", " ", mymenu_level_options)
mymenu_level:hide()