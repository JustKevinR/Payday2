--------------------------------------------------------------------------------------------
--Shortcuts
local M_money = managers.money
local M_experience = managers.experience
local G_specs = Global.skilltree_manager.specializations
local M_skilltree = managers.skilltree
local G_blackmarket = Global.blackmarket_manager
local M_achievement = managers.achievment
local G_safehouse = Global.custom_safehouse_manager
local M_safehouse = managers.custom_safehouse
local tab_insert = table.insert


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

local function Perk_points_menu()
    openmenu(mymenu_perk_points)
end

local function Infamy_menu()
    openmenu(mymenu_infamy)
end

local function Continental_menu()
    openmenu(mymenu_continental)
end

local function Safehouse_menu()
    openmenu(mymenu_safehouse)
end
---------------------------------------------------------------------------------------------------------------------------------
--FUNCTIONS

--Main menu functions
local function Unlock_achievements()
	local _award = M_achievement.award
	for id in pairs(M_achievement.achievments) do
		_award(M_achievement, id)
	end
end

local function Lock_achievements()
	M_achievement:clear_all_steam()
end

--Level functions
local function Change_level(level, skill, xp)
    M_experience :_set_current_level(level)
    M_skilltree:_set_points(skill)
    M_experience:debug_add_points(xp)
end

--money functions
local function Add_money(value)
    M_money:_add_to_total(value)
end

local function Reset_money()
    M_money:_deduct_from_total(999999999999999999999)
    M_money:_deduct_from_offshore(999999999999999999999)
end

--Perk points functions
local function Set_perk_points( points )
	G_specs.total_points = points
	G_specs.points = points
end

local function Reset_perks()
    M_skilltree:reset_specializations()
end

--Infamy functions
local function Set_infamy(level)
	M_experience:set_current_rank(level)
end

--inventory functions
local function Unlock_weapons()
    local wep_arr = {
        'new_m4', 'glock_17', 'mp9', 'r870', 'glock_18c', 'amcar', 'm16', 'olympic', 'ak74', 'akm', 'akmsu', 'saiga', 'ak5', 'aug', 'g36', 'p90', 'new_m14', 'deagle', 'new_mp5', 'colt_1911', 'mac10', 'serbu', 'huntsman', 'b92fs', 'new_raging_bull',  'saw'
    }
    for i, name in ipairs(wep_arr) do
        if not managers.upgrades:aquired(name) then
            managers.upgrades:aquire(name)
        end
    end
end

function Giveitems( times, type )
	for i=1, times do
		for mat_id,_ in pairs(tweak_data.blackmarket[type]) do	
			if _.infamous then
				managers.blackmarket:add_to_inventory("infamous", type, mat_id, false)
			elseif _.dlc then
				managers.blackmarket:add_to_inventory("preorder", type, mat_id, false)
			else
				managers.blackmarket:add_to_inventory("normal", type, mat_id, false)
			end
		end
		managers.blackmarket:remove_item("normal", "materials", "plastic", false)
		managers.blackmarket:remove_item("normal", "colors", "nothing", false)
	end
end

local function Unlock_slots()
    local unlocked_mask_slots = G_blackmarket.unlocked_mask_slots
    local unlocked_weapon_slots = G_blackmarket.unlocked_weapon_slots
    local unlocked_primaries = unlocked_weapon_slots.primaries
    local unlocked_secondaries = unlocked_weapon_slots.secondaries
    for i = 1, 500 do
        unlocked_mask_slots[i] = true 
        unlocked_primaries[i] = true
        unlocked_secondaries[i] = true
    end
end

--continental coin functions
local function Continental_coins(value)
	Global.custom_safehouse_manager.total = Application:digest_value(value, true)
end

--safehouse functions
local function Maxout_safehous()
    for room_id, data in pairs(G_safehouse.rooms) do
		local max_tier = data.tier_max
		
		local current_tier = M_safehouse:get_room_current_tier(room_id)
		while max_tier > current_tier do
			current_tier = current_tier + 1
			
			local unlocked_tiers = M_safehouse._global.rooms[room_id].unlocked_tiers
			tab_insert(unlocked_tiers, current_tier)
		end
		
		M_safehouse:set_room_tier(room_id, max_tier)
	end
end

local function Unlock_safehouse_trophies()
	local trophies = M_safehouse:trophies()
	for _, trophy in pairs(trophies) do
		for objective_id in pairs (trophy.objectives) do
			local objective = trophy.objectives[objective_id]
			objective.verify = false
			M_safehouse:on_achievement_progressed(objective.progress_id, objective.max_progress)
		end
	end
end

local function Complete_all_challenges()
    local AutoCompleteChallenge = AutoCompleteChallenge or ChallengeManager.activate_challenge
    function ChallengeManager:activate_challenge(id, key, category)
        if self:has_active_challenges(id, key) then
            local active_challenge = self:get_active_challenge(id, key)
            active_challenge.completed = true
            active_challenge.category = category
            return true
        end
        return AutoCompleteChallenge(self, id, key, category)
    end
end

local function Complete_safehouse_challenge()
    if not CustomSafehouseManager then return end
	function CustomSafehouseManager:set_active_daily(id)
		if self:get_daily_challenge() and self:get_daily_challenge().id ~= id then
			self:generate_daily(id)
		end
		self:complete_daily(id)
	end
end
---------------------------------------------------------------------------------------------------------------------------------
--MENU OPTIONS

--Main menu
mymenu_main_options = {
    { text = "Level Menu", callback = Level_menu },
    { text = "Infamy Menu", callback = Infamy_menu },
    { text = "Perk Menu", callback = Perk_points_menu },
    { text = "Money Menu", callback = Money_menu },
    { text = "Inventory Menu", callback = Inventory_menu },
    { text = "Continental coin Menu", callback = Continental_menu },
    { text = "Safehouse Menu", callback = Safehouse_menu, button_data = callback },
    { text = "", is_cancel_button = true},
    { text = "Unlock all achievements", callback = Unlock_achievements},
    { text = "Lock all achievements", callback = Lock_achievements},
    { text = "", is_cancel_button = true},
    { text = "", is_cancel_button = true },
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_main = SimpleMenu:new("Main menu", " ", mymenu_main_options)
mymenu_main:show()

--safehouse menu
mymenu_safehouse_options = {
    { text = "Maxout safehous", callback = Maxout_safehous},
    { text = "Unlock all trophies", callback = Unlock_safehouse_trophies},
    { text = "Complete all safehouse challenges", callback = Complete_safehouse_challenge},
    { text = "Complete all challenges", callback = Complete_all_challenges},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_safehouse = SimpleMenu:new("Safehouse menu", " ", mymenu_safehouse_options)
mymenu_safehouse:hide()

--ontinental menu
mymenu_continental_options = {
    { text = "Add 10", function() Continental_coins(10) end},
    { text = "Add 20", function() Continental_coins(20) end},
    { text = "Add 50", function() Continental_coins(50) end},
    { text = "Add 100", function() Continental_coins(100) end},
    { text = "Add 200", function() Continental_coins(200) end},
    { text = "Add 300", function() Continental_coins(300) end},
    { text = "Add 500", function() Continental_coins(500) end},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_continental = SimpleMenu:new("Continental coin menu", " ", mymenu_continental_options)
mymenu_continental:hide()

--infamy menu
mymenu_infamy_options = {
    { text = "0", callback = function() Set_infamy(0) end},
    { text = "1", callback = function() Set_infamy(1) end},
    { text = "5", callback = function() Set_infamy(5) end},
    { text = "10", callback = function() Set_infamy(10) end},
    { text = "20", callback = function() Set_infamy(20) end},
    { text = "35", callback = function() Set_infamy(35) end},
    { text = "50", callback = function() Set_infamy(50) end},
    { text = "69", callback = function() Set_infamy(69) end},
    { text = "100", callback = function() Set_infamy(100) end},
    { text = "150", callback = function() Set_infamy(150) end},
    { text = "200", callback = function() Set_infamy(200) end},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_infamy = SimpleMenu:new("Infamy menu", "Set infamy level", mymenu_infamy_options)
mymenu_infamy:hide()

--Perk points menu
mymenu_perk_points_options = {
    { text = "Add 200 perk points", callback = function() Set_perk_points(200) end},
    { text = "Add 300 perk points", callback = function() Set_perk_points(300) end},
    { text = "Add 400 perk points", callback = function() Set_perk_points(400) end},
    { text = "Add 600 perk points", callback = function() Set_perk_points(600) end},
    { text = "Add 1000 perk points", callback = function() Set_perk_points(1000) end},
    { text = "Add 1600 perk points", callback = function() Set_perk_points(1600) end},
    { text = "Add 2400 perk points", callback = function() Set_perk_points(2400) end},
    { text = "Add 3200 perk points", callback = function() Set_perk_points(3200) end},
    { text = "Add 4000 perk points", callback = function() Set_perk_points(4000) end},
    { text = "", is_cancel_button = true },
    { text = "Add 13700 perk points", callback = function() Set_perk_points(13700) end},
    { text = "Reset all perks", callback = Reset_perks},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_perk_points = SimpleMenu:new("Perk points menu", "",mymenu_perk_points_options)
mymenu_perk_points:hide()

--inventory menu
mymenu_inventory_options = {
    { text = "Unlock all weapons", callback = Unlock_weapons },
    { text = "Unlock all slots", callback = Unlock_slots },
    { text = "Unlock all colors", callback = function() Giveitems(1, "colors") end},
    { text = "unlock all materials ", callback = function() Giveitems(1, "materials") end },
    { text = "unlock all textures ", callback = function() Giveitems(1, "textures") end },
    { text = "Give all weapon mods", callback = function() Giveitems(1, "weapon_mods") end },
    { text = "Give all masks", callback = function() Giveitems(1, "masks") end},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu},
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_inventory = SimpleMenu:new("Inventory Menu", "Unlock items.",mymenu_inventory_options)
mymenu_inventory:hide()

--Money menu
mymenu_money_options = {
    { text = "Add 1 mill cash + 4 mill offshore", callback = function()Add_money(5000000) end},
    { text = "Add 10 mill cash + 40 mill offshore", callback = function()Add_money(50000000) end},
    { text = "Add 100 mill cash + 400 mill offshore", callback = function()Add_money(500000000) end},
    { text = "Add 1 billion cash + 4 billion offshore", callback = function()Add_money(5000000000) end},
    { text = "", is_cancel_button = true },
    { text = "Reset money", callback = Reset_money},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu},
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_money = SimpleMenu:new("Money Menu", "Add/remove cash and offshore funds.", mymenu_money_options)
mymenu_money:hide()

--Level menu
mymenu_level_options = {
    { text = "Set level to 0", callback = function () Change_level(0, 0 , 0) end, is_focused_button = true },
    { text = "Set level to 5", callback = function () Change_level(5, 5, 0) end},
    { text = "Set level to 10", callback = function () Change_level(10, 12, 12) end},
    { text = "Set level to 25", callback = function () Change_level(25, 29, 29) end},
    { text = "Set level to 50", callback = function () Change_level(50, 60, 60) end},
    { text = "Set level to 75", callback = function () Change_level(75, 89, 90) end},
    { text = "Set level to 100", callback = function () Change_level(99, 120, 30000000) end},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu},
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_level = SimpleMenu:new("Level menu", " ", mymenu_level_options)
mymenu_level:hide()