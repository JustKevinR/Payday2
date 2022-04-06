local T_data = tweak_data
local M_player = managers.player

--------------------------------------------------------------------------------------------
-- SIMPLE MENU
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


---------------------------------------------------------------------------------------------------------------------------------
--GLOBALS

 function isPlaying()
		if not BaseNetworkHandler then return false end
		return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
	end
	

function inGame()
		if not game_state_machine then return false end
		return string.find(game_state_machine:current_state_name(), "game")
	end
	
local isMultiplayer = isMultiplayer or function()
        if managers.network == nil then
            return false
        end
        return managers.network:session()
    end

----------------------------------------------------------------------------------------------------------------
-- OPEN MENU
local function openmenu(menu)
        menu:show()
end

local function Main_menu()
    openmenu(mymenu_main)
end

local function Dodge_menu()
    openmenu(mymenu_dodge)
end

local function Inventory_items_menu()
    openmenu(mymenu_inventory_items)
end

local function NPC_menu()
    openmenu(mymenu_npc)
end

--temp----------------------------------------------
local function Temp_menu()
    openmenu(mymenu_temp)
end
--temp----------------------------------------------

-- other functions
local function display_hint(U_hint)
    managers.hud:show_hint( { text = U_hint .. '!' } )
end
---------------------------------------------------------------------------------------------------------------------------------
--FUNCTIONS

--inventory functions
local function add_keycard()
    M_player:add_special( { name = "bank_manager_key", silent = true, amount = 1 } )
    display_hint("Keycard added")
end
local function add_crowbar()
    M_player:add_special( { name = "crowbar", silent = true, amount = 1 } )
    display_hint("Crowbar added")
end
local function add_planks()
    M_player:add_special( { name = "planks", silent = true, amount = 1 } )
    display_hint("Planks added")
end
local function add_glassCutter()
    M_player:add_special( { name = "glass_cutter", silent = true, amount = 1 } )
    display_hint("Glass cutters added")
end
local function add_gasCan()
    M_player:add_special( { name = "gas", silent = true, amount = 1 } )
    display_hint("Gas can added")
end
local function add_muriaticAcid ()
    M_player:add_special( { name = "acid", silent = true, amount = 1 } )
    display_hint("Muriatic acid added")
end
local function add_hydrogenChlorided()
    M_player:add_special( { name = "hydrogen_chloride", silent = true, amount = 1 } )
    display_hint("Hydrogen chloride added")
end
local function add_causticSoda()
    M_player:add_special( { name = "caustic_soda", silent = true, amount = 1 } )
    display_hint("Caustic soda added")
end
local function add_cookingCombo()
    M_player:add_special( { name = "caustic_soda", silent = true, amount = 1 } )
    M_player:add_special( { name = "acid", silent = true, amount = 1 } )
    M_player:add_special( { name = "hydrogen_chloride", silent = true, amount = 1 } )
    display_hint("Cooking combo added")
end

--dodge functions
local function Default()   
    T_data.player.damage.DODGE_INIT = 0
    display_hint('dodge set to default')
end
local function five()   
    T_data.player.damage.DODGE_INIT = 0.5
    display_hint("dodge increased by 5%")
end
local function ten()   
    T_data.player.damage.DODGE_INIT = 0.10
    display_hint("dodge increased by 10%")
end
local function fifteen()   
    T_data.player.damage.DODGE_INIT = 0.15
    display_hint('dodge increased by +15%')
end
local function twenty()   
    T_data.player.damage.DODGE_INIT = 0.20
    display_hint('dodge increased by +20%')
end
local function thirty()   
    T_data.player.damage.DODGE_INIT = 0.30
    display_hint('dodge increased by +30%')
end
local function forty()   
    T_data.player.damage.DODGE_INIT = 0.40
    display_hint('dodge increased by +40%')
end
local function fifty()   
    T_data.player.damage.DODGE_INIT = 0.50
    display_hint('dodge increased by +50%')
end
local function sixty()   
    T_data.player.damage.DODGE_INIT = 0.60
    display_hint('dodge increased by +60%')
end
local function ninety()   
    T_data.player.damage.DODGE_INIT = 0.90
    display_hint('dodge increased by +90%')
end
local function hundred()   
    T_data.player.damage.DODGE_INIT = 1
    display_hint('dodge increased by +100%')
end
local function threeHundred()   
    T_data.player.damage.DODGE_INIT = 3
    display_hint('You are Neo')
end


--NPC menu
local function Kill_all_ai()
    function nukeunit(pawn)
        local col_ray = { }
        col_ray.ray = Vector3(1, 0, 0)
        col_ray.position = pawn.unit:position()
    
        local action_data = {}
        action_data.variant = "explosion"
        action_data.damage = 10
        action_data.attacker_unit = managers.player:player_unit()
        action_data.col_ray = col_ray
    
        pawn.unit:character_damage():damage_explosion(action_data)
    end
    
    for u_key,u_data in pairs(managers.enemy:all_civilians()) do
        nukeunit(u_data)
    end
    
    for u_key,u_data in pairs(managers.enemy:all_enemies()) do
        u_data.char_tweak.has_alarm_pager = nil
        nukeunit(u_data)
    end
end

local function No_civi_penalty()
    function MoneyManager.get_civilian_deduction() return 0 end
    function MoneyManager.civilian_killed() return 0 end
end

local function No_alarms()
    if not _setCool then _setCool = CopMovement.set_cool end
        function CopMovement:set_cool( state, giveaway )
            if state == true then _setCool(self, state, giveaway) end
        end
        if not _setWhisper then _setWhisper = GroupAIStateBase.set_whisper_mode end
        function GroupAIStateBase:set_whisper_mode( enabled )
            if enabled == true then _setWhisper(self, true) end
        end
        if not _setObjective then _setObjective = CopBrain.set_objective end
        function CopBrain:set_objective( new_objective )
            if (not new_objective) or (new_objective.stance ~= "hos" and new_objective.attitude ~= "engage") then _setObjective(self, new_objective) end
        end
        if not _setStance then _setStance = CopMovement.set_stance end
        function CopMovement:set_stance( new_stance_name )
            if new_stance_name ~= "hos" then _setStance(self, new_stance_name) end
        end
        if not _setStanceCode then _setStanceCode = CopMovement.set_stance_by_code end
        function CopMovement:set_stance_by_code( new_stance_code )
            if new_stance_code == 1 then _setStanceCode(self, new_stance_code) end
        end
        if not _setInteraction then _setInteraction = CopLogicInactive._set_interaction end
        function CopLogicInactive._set_interaction( data, my_data )
            data.char_tweak.has_alarm_pager = false
            _setInteraction(data, my_data)
        end
        if not _setAllowFire then _setAllowFire = CopMovement.set_allow_fire end
        function CopMovement:set_allow_fire( state )
            if state == false then _setAllowFire(self, state) end
        end
        if not _setAllowFireClient then _setAllowFireClient = CopMovement.set_allow_fire_on_client end
        function CopMovement:set_allow_fire_on_client( state, unit )
            if state == false then _setAllowFireClient(self, state, unit) end
        end
        if not _actionRequest then _actionRequest = CopMovement.action_request end
        function CopMovement:action_request( action_desc )
            if action_desc.variant == "run" then return false end

            return _actionRequest(self, action_desc)
        end
        function CopMovement:on_suppressed( state ) end
        function CopLogicBase._get_logic_state_from_reaction( data, reaction ) return "idle" end 
        function CopLogicIdle.on_alert( data, alert_data ) end 
        function GroupAIStateBase:on_police_called( called_reason ) end 
        function GroupAIStateBase:on_police_weapons_hot( called_reason ) end 
        function GroupAIStateBase:on_gangster_weapons_hot( called_reason ) end 
        function GroupAIStateBase:on_enemy_weapons_hot( is_delayed_callback ) end 
        function GroupAIStateBase:add_alert_listener( id, clbk, filter_num, types, m_pos ) end
        function GroupAIStateBase:criminal_spotted( unit ) end 
        function GroupAIStateBase:report_aggression( unit ) end 
        function GroupAIStateBase:propagate_alert( alert_data ) end
        function GroupAIStateBase:on_criminal_suspicion_progress( u_suspect, u_observer, status ) end
        function PlayerMovement:on_suspicion( observer_unit, status ) end 
        function SecurityCamera:_upd_suspicion( t ) end 
        function SecurityCamera:_sound_the_alarm( detected_unit ) end 
        function SecurityCamera:_set_suspicion_sound( suspicion_level ) end 
end
---------------------------------------------------------------------------------------------------------------------------------
--MENUS

--in-game menu
mymenu_main_options = {
    { text = "Dodge Menu", callback = Dodge_menu },
    { text = "NPC Menu", callback = NPC_menu},
    { text = "Inventory Menu", callback = Inventory_items_menu },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_main = SimpleMenu:new("In-game menu", " ", mymenu_main_options)
if isPlaying() and inGame() and isMultiplayer() and managers.hud then
mymenu_main:show()


--Inventory menu
mymenu_inventory_items_options = {
    {text = 'Add keycard', callback = add_keycard, is_focused_button = true},
    {text = 'Add crowbar', callback = add_crowbar},
    { text = "Add planks", callback = add_planks },
    {text = 'Add glass cutter', callback = add_glassCutter},
    {text = 'Add gas can', callback = add_gasCan},
    { text = "", is_cancel_button = true },
    {text = 'Add muriatic acid', callback = add_muriaticAcid},
    {text = 'Add hydrogen chloride', callback = add_hydrogenChlorided},
    {text = 'Add caustic soda', callback = add_causticSoda},
    { text = "", is_cancel_button = true },
    {text = 'Cooking combo', callback = add_cookingCombo},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true, },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_inventory_items = SimpleMenu:new("Inventory Menu", "Add stuff to inventory.", mymenu_inventory_items_options)
mymenu_inventory_items:hide()

--NPC menu
mymenu_npc_options = {
    { text = "Kill all AI", callback = Kill_all_ai },
    { text = "No killing penalty", callback = No_civi_penalty },
    { text = "No alarms & panic", callback = No_alarms },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_npc = SimpleMenu:new("NPC menu", " ", mymenu_npc_options)
mymenu_npc:hide()

--dodge menu
mymenu_dodge_options = {
    { text = "Default", callback = Default, is_focused_button = true },
    { text = "", is_cancel_button = true },
    { text = "+5%", callback = five },
    { text = "+10%", callback = ten },
    { text = "+15%", callback = fifteen },
    { text = "+20%", callback = twenty },
    { text = "", is_cancel_button = true },
    { text = "+30%", callback = thirty },
    { text = "+40%", callback = forty },
    { text = "+50%", callback = fifty },
    { text = "+60%", callback = sixty },
    { text = "+90%", callback = ninety },
    { text = "+100%", callback = hundred },
    { text = "", is_cancel_button = true },
    { text = "Become Neo", callback = threeHundred },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true},
}
mymenu_dodge = SimpleMenu:new("Dodge menu", "Increase dodge by...", mymenu_dodge_options)
mymenu_dodge:hide()

--temp menu-------------------------------------------------------------------------------------------
mymenu_temp_options = {
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_temp = SimpleMenu:new("Dodge menu", "Increase dodge by...", mymenu_temp_options)
mymenu_temp:hide()
--temp menu end-------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
--In-Game check error

elseif not managers.hud then
_dialog_data = { 
				title = "ERROR!",
				text = "You need to be in game to use this menu!",
				button_list = {{ text = "OK", is_cancel_button = true }},
				id = tostring(math.random(0,0xFFFFFFFF))
			}
			end
if managers.system_menu then
	managers.system_menu:show(_dialog_data)
end