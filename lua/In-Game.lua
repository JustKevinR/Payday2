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

local function Stealth_menu()
    openmenu(mymenu_stealth)
end

local function Character_menu()
    openmenu(mymenu_character)
end

local function Fov_menu()
    openmenu(mymenu_fov)
end

local function Additional_character_menu()
    openmenu(mymenu_additional_character)
end

local function Equipment_menu()
    openmenu(mymenu_equipment)
end

local function Sentry_menu()
    openmenu(mymenu_sentry)
end

local function Carry_mod_menu()
    openmenu(mymenu_carry_mod)
end

local function Interactions_menu()
    openmenu(mymenu_interactions)
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
local function dodge(value)
    T_data.player.damage.DODGE_INIT = (value)
    display_hint("dodge increased")
end

--Stealth menu
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
    display_hint('All ai killed')
end

local function No_civi_penalty()
    function MoneyManager.get_civilian_deduction() return 0 end
    function MoneyManager.civilian_killed() return 0 end
    display_hint('Civi penalty disabled')
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
        display_hint('Alarms disabled')
end

local function Demi_stealth()
    function GroupAIStateBase:on_successful_alarm_pager_bluff() end
    function ECMJammerBase:update( unit, t, dt )
        self._battery_life = self._max_battery_life
    end

    if not _setWhisper then _setWhisper = GroupAIStateBase.set_whisper_mode end
        function GroupAIStateBase:set_whisper_mode( enabled )
    if enabled == true then _setWhisper(self, true) end
    end

    if not _setAllowFire then _setAllowFire = CopMovement.set_allow_fire end
        function CopMovement:set_allow_fire( state )
    if state == false then _setAllowFire(self, state) end
    end

    if not _setAllowFireClient then _setAllowFireClient = CopMovement.set_allow_fire_on_client end
        function CopMovement:set_allow_fire_on_client( state, unit )
    if state == false then _setAllowFireClient(self, state, unit) end
    end

    function GroupAIStateBase:on_police_called( called_reason ) end
    function CivilianLogicFlee.clbk_chk_call_the_police( ignore_this, data ) end
    function SecurityCamera:_sound_the_alarm( detected_unit ) end
    function SecurityCamera:_set_suspicion_sound( suspicion_level ) end
    function CopLogicArrest._say_call_the_police( data, my_data ) end
    if not _actionRequest then _actionRequest = CopMovement.action_request end
        function CopMovement:action_request( action_desc )
    if action_desc.variant == "run" then return false end
        return _actionRequest(self, action_desc)
    end
    display_hint('Demi stealth activated')
end

local function Infinite_pagers()
    function GroupAIStateBase:on_successful_alarm_pager_bluff() end
    display_hint('Infinite pagers activated')
end

local function Infinite_ecm()
    function ECMJammerBase:update( unit, t, dt )
        self._battery_life = self._max_battery_life
    end
    display_hint('Infinite ecm activated')
end

local function Stop_calling_cops()
    function GroupAIStateBase:on_police_called( called_reason ) end
    display_hint('Cops will not be called')
end

local function Stop_civs_report()
    function CivilianLogicFlee.clbk_chk_call_the_police( ignore_this, data ) end
    display_hint('Civs will not report you')
end

local function Stop_cam_alarm()
    function SecurityCamera:_sound_the_alarm( detected_unit ) end
    function SecurityCamera:_set_suspicion_sound( suspicion_level ) end
    display_hint('Cam alarm disabled')
end

local function Stop_buttons_burning_intel()
    if not _actionRequest then _actionRequest = CopMovement.action_request end
        function CopMovement:action_request( action_desc )
    if action_desc.variant == "run" then return false end
        return _actionRequest(self, action_desc)
    end
    display_hint('Panic buttons & intel burning disabled')
end

local function Infinite_cable_ties()
    function PlayerManager:remove_special( name ) end
    display_hint("Infinite cable ties activated")
end

--Fov functions
local function Fov(value)
    M_player:player_unit():camera()._camera_object:set_fov(value)
end

--character functions
local function Godmode()
    M_player:player_unit():character_damage():set_invulnerable( true )
    display_hint('Godmode activated')
end

local function No_fall_damage()
    function PlayerDamage:damage_fall( data ) end
    display_hint('No fall damage activated')
end

local function Infinite_stamina()
    function PlayerMovement:_change_stamina( value ) end
    function PlayerMovement:is_stamina_drained() return false end
    function PlayerStandard:_can_run_directional() return true end
    display_hint('Infinite stamina activated')
end

local function No_weapon_recoil()
    NewRaycastWeaponBase.recoil_multiplier = function(self) return 0 end
    display_hint('No weapon recoil activated')
end

local function Fast_reload()
    NewRaycastWeaponBase.reload_speed_multiplier = function(self) return 2000 end
    display_hint('Fast reload activated')
end

local function Crazy_firerate()
    NewRaycastWeaponBase.fire_rate_multiplier = function(self) return 10 end
    display_hint('Crazy firerate activated')
end

local function Fast_weapon_swap()
    PlayerStandard._get_swap_speed_multiplier = function(self) return 2000 end
    display_hint('Fast weapon swap activated')
end

local function Infinite_ammo_clip()
    if not _fireWep then _fireWep = NewRaycastWeaponBase.fire end
        function NewRaycastWeaponBase:fire( from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit )
            local result = _fireWep( self, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit )
                if managers.player:player_unit() == self._setup.user_unit then
                    self.set_ammo(self, 1.0)
                end
            return result
        end
        display_hint('Infinite ammo clip activated')
end

local function Infinite_saw()
    if not _fireSaw then _fireSaw = SawWeaponBase.fire end
    function SawWeaponBase:fire( from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit )
        local result = _fireSaw( self, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit )
            if managers.player:player_unit() == self._setup.user_unit then
                self.set_ammo(self, 1.0)
            end
        return result
    end
    display_hint('Infinite saw activated')
end

local function Instant_interaction()
    if not _getTimer then _getTimer = BaseInteractionExt._get_timer end
        function BaseInteractionExt:_get_timer()
            if self.tweak_data == "corpse_alarm_pager" and not isMultiplayer() then
                return 0.1
            end
            if self.tweak_data == "corpse_alarm_pager" and isMultiplayer() then
                return _getTimer(self)
            end
            return 0
        end
        display_hint('Instant interaction activated')
end

local function x2_stats()
    if not _upgradeValue then _upgradeValue = PlayerManager.upgrade_value end
        function PlayerManager:upgrade_value( category, upgrade, default )
            if category == "player" and upgrade == "health_multiplier" then
                return 2
            elseif category == "player" and upgrade == "armor_multiplier" then
                return 2
            elseif category == "player" and upgrade == "passive_damage_multiplier" then
                return 2
            else
                return _upgradeValue(self, category, upgrade, default)
            end
    end
managers.player:player_unit():character_damage():replenish()
    display_hint('X2 stats activated')
end

local function Instant_kill()
    function RaycastWeaponBase._get_current_damage()
		return math.huge
	end
    display_hint('One hit kill activated')
end


local function Instant_melee_kill()
    local damage_melee_original = backuper.backup(backuper, 'CopDamage.damage_melee')
	function CopDamage:damage_melee( attack_data, ... )
		attack_data.damage = attack_data.damage * 5000
		return damage_melee_original( self, attack_data, ... )
	end
    display_hint('Instant meele kill activated')
end

local function Fast_melee_charge()
    for k,t in pairs(tweak_data.blackmarket.melee_weapons) do
		local stats = t.stats
		local charge_time = stats and stats.charge_time
		if k ~= 'weapon' and charge_time then
			if not stats.old_charge_time then
				stats.old_charge_time = charge_time
				stats.charge_time = 0.001
			else
				stats.charge_time = stats.old_charge_time
				stats.old_charge_time = nil
			end
		end
	end
end
----Additional character functions
local function Instant_mask()
    T_data.player.put_on_mask_time = 0.1
    display_hint('Instant mask activated')
end

local function Super_jump()
    function PlayerStandard:_perform_jump(jump_vec)
        local v = math.UP * 470
        if self._running then
            v = math.UP * 470 * 1.5
        end
        self._unit:mover():set_velocity( v )
    end
    display_hint('Super jump activated')
end

local function No_flashbangs()
    function CoreEnvironmentControllerManager:set_flashbang( flashbang_pos, line_of_sight, travel_dis, linear_dis ) end
    display_hint('Flashbangs disabled')
end

local function Disable_tasers()
    function PlayerTased:enter( state_data, enter_data )
        PlayerTased.super.enter( self, state_data, enter_data )
        self._next_shock = Application:time() + 10
        self._taser_value = 1
        self._recover_delayed_clbk = "PlayerTased_recover_delayed_clbk"
        managers.enemy:add_delayed_clbk( self._recover_delayed_clbk, callback( self, self, "clbk_exit_to_std" ), Application:time() )
    end
    display_hint('Tasers disabled')
end

--Equipment functions

local function Infinite_equipment()
    function PlayerManager:remove_equipment( equipment_id ) end
    display_hint('Infinite equipment activated')
end

local function Instant_deploy()
    PlayerManager.selected_equipment_deploy_timer = function(self) return 0 end
    display_hint('Instant deply activated')
end

local function Unlimited_doctor_bag()
    function DoctorBagBase:_take( unit )
        unit:character_damage():recover_health()
        return 0
    end
    display_hint('Unlimited doctor bag activated')
end

--Sentry gun functions
local function Sentry_inf_ammo_recoil()
    function SentryGunWeapon:fire( blanks, expend_ammo )
        local fire_obj = self._effect_align[ self._interleaving_fire ]
        local from_pos = fire_obj:position()
        local direction = fire_obj:rotation():y()
        mvector3.spread( direction, tweak_data.weapon[ self._name_id ].SPREAD * self._spread_mul )
        World:effect_manager():spawn( self._muzzle_effect_table[ self._interleaving_fire ] ) -- , normal = col_ray.normal } )
        if self._use_shell_ejection_effect then
            World:effect_manager():spawn( self._shell_ejection_effect_table )
        end
        local ray_res = self:_fire_raycast( from_pos, direction, blanks )
        if self._alert_events and ray_res.rays then
            RaycastWeaponBase._check_alert( self, ray_res.rays, from_pos, direction, self._unit )
        end
        return ray_res
    end
    display_hint('Sentry gun infinite ammo & no recoil activated')
end

local function Sentry_god_mode()
    function SentryGunDamage:damage_bullet( attack_data ) end
end

--Carry mod functions
local function Carry_mod(distance, speed, jump)
    local car_arr = { 'being', 'mega_heavy', 'heavy', 'medium', 'light', 'coke_light' }
    for i, name in ipairs(car_arr) do
        T_data.carry.types[ name ].throw_distance_multiplier = (distance)
        T_data.carry.types[ name ].move_speed_modifier = (speed)
        T_data.carry.types[ name ].jump_modifier = (jump)
        T_data.carry.types[ name ].can_run = true
    end
    display_hint('Carry mod activated')
end

--interaction functions
local function Fast_drilling()
    function TimerGui:_set_jamming_values() return end
        function TimerGui:start( timer )
                timer = 0.01
                if self._jammed then
                        self:_set_jammed( false )
                        return
                end

                if not self._powered then
                        self:_set_powered( true )
                        return
                end

                if self._started then
                        return
                end

                self:_start( timer )
                if managers.network:session() then
                        managers.network:session():send_to_peers_synched( "start_timer_gui", self._unit, timer )
                end
        end
        display_hint('Fast drill activated')
end
local function I_I_distance()
    function BaseInteractionExt:interact_distance()
        if self.tweak_data == "access_camera"
            or self.tweak_data == "shaped_sharge"
            or tostring(self._unit:name()) == "Idstring(@ID14f05c3d9ebb44b6@)"
            or self.tweak_data == "burning_money"
            or self.tweak_data == "stn_int_place_camera"
            or self.tweak_data == "trip_mine" then
            return self._tweak_data.interact_distance or tweak_data.interaction.INTERACT_DISTANCE
        end
        return 20000 -- default is 200
    end
    display_hint('Increased interaction distance')
end

--Interact_while_in_casing_mode
local function Interact_while_in_casing_mode()
    local old_is_in = old_is_in or BaseInteractionExt._is_in_required_state
    function BaseInteractionExt:_is_in_required_state(movement_state)
        return movement_state == "mask_off" and true or old_is_in(self, movement_state)
    end
    display_hint('Interact while in casing mode')
end

--Twice_as_fast_drilling
local function Twice_as_fast_drilling()
    local timer_multiplier = 2	-- How much faster the drilling will be: 2 = twice as fast, 0.5 = twice as long
    local old_start = TimerGui._start
    function TimerGui:_start(timer, current_timer)
        old_start(self, timer / timer_multiplier, current_timer)
    end
    display_hint('Twice as fast drilling')
end

--Use_shaped_charges
local function Use_shaped_charges()
    local function do_charge_tweak(unit)
        if unit:interaction().tweak_data == "shaped_sharge" then -- Lol nice spelling overkill
            unit:interaction()._tweak_data.required_deployable = nil
            unit:interaction()._tweak_data.deployable_consume = false
        end
    end

    local o_interaction_add_unit = ObjectInteractionManager.add_unit
    function ObjectInteractionManager:add_unit(unit)
        o_interaction_add_unit(self, unit)
        do_charge_tweak(unit)
    end

    for _,unit in pairs(managers.interaction._interactive_units) do do_charge_tweak(unit) end
    display_hint('Now you use shaped charges without having them equipped')
end

--No_bag_throw_cooldown
local function No_bag_throw_cooldown()
    local old_check_use = PlayerStandard._check_use_item
    function PlayerStandard:_check_use_item(t, input)
        if input.btn_use_item_release and self._throw_time and t and t < self._throw_time then
            managers.player:drop_carry()
            self._throw_time = nil
            return true
        else return old_check_use(self, t, input) end
    end
    display_hint('No bag throw cooldown')
end

local function Infinite_hostage_follower_distance()
    local old_set_objective = CopBrain.set_objective
	function CopBrain:set_objective(new_objective, params)
		if new_objective and new_objective.lose_track_dis then new_objective.lose_track_dis = 5000000 end
		old_set_objective(self, new_objective, params)
	end
    display_hint('Infinite hostage follower distance')
end
--ragdoll_push_effect
local function ragdoll_push_effect()
    local push_scale 		= 2.0	-- Value between 0.0 - 10.0, sets the force of the push, 1.0 is normal shotgun push
    local push_direction 	= 0.5	-- Value between 0.0 - 1.0, sets the height direction of the push, 1.0 is all the way up, 0.0 is all the way down

    local dmgmul = 0
    local old_collect = RaycastWeaponBase._collect_hits
    function RaycastWeaponBase:_collect_hits(from, to)
        local unique_hits, hit_enemy = old_collect(self, from, to)

        if hit_enemy and unique_hits[1] then
            local p_unit = managers.player:player_unit()
            local dam = self:get_damage_falloff(self:_get_current_damage(dmgmul), unique_hits[1], p_unit)
            local hit_result = self._bullet_class:on_collision(unique_hits[1], self._unit, p_unit, dam)
            if hit_result and hit_result.type == "death" then
                local unit = unique_hits[1].unit
                if unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
                    unit:movement()._active_actions[1]:force_ragdoll() end

                for i = 0, unit:num_bodies() - 1 do
                    local u_body = unit:body(i)

                    if u_body:enabled() and u_body:dynamic() then
                        World:play_physic_effect(Idstring("physic_effects/shotgun_hit"), u_body,
                        Vector3(unique_hits[1].ray.x, unique_hits[1].ray.y, unique_hits[1].ray.z + push_direction) * 600 * push_scale, 4 * u_body:mass(),
                        (unique_hits[1].ray:cross(math.UP) + math.UP * 0.5) * -1000 * math.sign(mvector3.distance(unique_hits[1].hit_position, unit:position()) - 100), 2)
                    end
                end
            end
        end

        return unique_hits, hit_enemy
    end

    local old_fire = RaycastWeaponBase._fire_raycast
    function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
        dmgmul = dmg_mul
        return old_fire(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
    end
    display_hint('Ragdoll push effect with any weapon')
end

--Infinite_hostage_followers
local function Infinite_hostage_followers()
    tweak_data.player.max_nr_following_hostages = 1000
    display_hint('Infinite hostage followers')
end

--collect_gage
local function collect_gage()
    local player = managers.player:player_unit()
    if alive(player) then
        for _, unit in pairs(managers.interaction._interactive_units) do
            local interaction = unit:interaction()
            if interaction.tweak_data == "gage_assignment" then
                interaction:interact(player)
            end
        end
    end

end
---------------------------------------------------------------------------------------------------------------------------------
--MENUS

--in-game menu
mymenu_main_options = {
    { text = "Dodge Menu", callback = Dodge_menu },
    { text = "Stealth Menu", callback = Stealth_menu},
    { text = "Inventory Menu", callback = Inventory_items_menu },
    { text = "Character Menu", callback = Character_menu },
    { text = "Equipment Menu", callback = Equipment_menu },
    { text = "Interactions Menu", callback = Interactions_menu },
    { text = "", is_cancel_button = true },
    { text = "Interactions Menu", callback = collect_gage },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
}
mymenu_main = SimpleMenu:new("In-game menu", " ", mymenu_main_options)
if isPlaying() and inGame() and isMultiplayer() and managers.hud then
mymenu_main:show()

--interactions menu
mymenu_interactions_options = {
    { text = "Instant interaction", callback = Instant_interaction },
    { text = "Fast drilling (use before placing drill)", callback = Fast_drilling },
    { text = "Increased interaction distance", callback = I_I_distance },
    { text = "No bag throw cooldown", callback = No_bag_throw_cooldown },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_interactions = SimpleMenu:new("Interactions menu", " ", mymenu_interactions_options)
mymenu_interactions:hide()

--Carry mod menu
mymenu_carry_mod_options = {
    { text = "Carry mod", callback = function() Carry_mod(1.5, 1, 1) end},
    { text = "Carry mod x2", callback = function() Carry_mod(3, 2, 2) end},
    { text = "Carry mod x3", callback = function() Carry_mod(4.5, 3, 3) end},
    { text = "Carry mod x4", callback = function() Carry_mod(6, 4, 4) end },
    { text = "Carry mod x10", callback = function() Carry_mod(15, 10, 10) end },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Character_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_carry_mod = SimpleMenu:new("Carry mod multiplier", " ",mymenu_carry_mod_options)
mymenu_carry_mod:hide()

--Sentry gun menu
mymenu_sentry_options = {
    { text = "Infinite ammo & no recoil", callback = Sentry_inf_ammo_recoil },
    { text = "Sentry god mode", callback = Sentry_god_mode },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Equipment_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_sentry = SimpleMenu:new("Sentry gun menu", " ", mymenu_sentry_options)
mymenu_sentry:hide()

--Equipment Menu
mymenu_equipment_options = {
    { text = "Infinite equipment", callback = Infinite_equipment },
    { text = "Unlimited doctor bag uses", callback = Unlimited_doctor_bag },
    { text = "Instant deploy", callback = Instant_deploy },
    { text = "", is_cancel_button = true },
    { text = "Sentry gun menu", callback = Sentry_menu },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_equipment = SimpleMenu:new("Equipment Menu", " ", mymenu_equipment_options)
mymenu_equipment:hide()

--character menu
mymenu_character_options = {
    { text = "Godmode", callback = Godmode },
    { text = "x2 stats", callback = x2_stats },
    { text = "No fall damage", callback = No_fall_damage },
    { text = "Infinite stamina", callback = Infinite_stamina },
    { text = "No weapon recoil", callback = No_weapon_recoil },
    { text = "One hit kill", callback = Instant_kill },
    { text = "One hit melee kill", callback = Instant_melee_kill },
    { text = "Fast melee charge", callback = Fast_melee_charge },
    { text = "Fast reload", callback = Fast_reload },
    { text = "Crazy firerate", callback = Crazy_firerate },
    { text = "Fast weapon swap", callback = Fast_weapon_swap },
    { text = "Infinite ammo clip", callback = Infinite_ammo_clip },
    { text = "Instant interaction", callback = Instant_interaction },
    { text = "Ragdoll push effect with any weapon", callback = ragdoll_push_effect},
    { text = "", is_cancel_button = true },
    { text = "Infinite saw", callback = Infinite_saw },
    { text = "", is_cancel_button = true },
    { text = "Carry mod menu", callback = Carry_mod_menu },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Additional menu",callback = Additional_character_menu },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_character = SimpleMenu:new("Character menu", " ", mymenu_character_options)
mymenu_character:hide()

--Additional character menu
mymenu_additional_character_options = {
    { text = "Instant mask", callback = Instant_mask },
    { text = "Super jump", callback = Super_jump },
    { text = "No flashbangs", callback = No_flashbangs },
    { text = "Disable tasers", callback = Disable_tasers },
    { text = "FOV menu", callback = Fov_menu },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Character_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_additional_character = SimpleMenu:new("Additional character menu", " ", mymenu_additional_character_options)
mymenu_additional_character:hide()

--Fov menu
mymenu_fov_options = {
    { text = "80°", callback = function() Fov(80) end},
    { text = "90°", callback = function() Fov(90) end },
    { text = "100°", callback = function() Fov(100) end},
    { text = "120°", callback = function() Fov(120) end},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Additional_character_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_fov = SimpleMenu:new("Fov menu", "Change your FOV", mymenu_fov_options)
mymenu_fov:hide()

--Inventory menu
mymenu_inventory_items_options = {
    {text = 'Add keycard', callback = add_keycard, is_focused_button = true},
    {text = 'Add crowbar', callback = add_crowbar},
    { text = "Add planks", callback = add_planks },
    {text = 'Add glass cutter', callback = add_glassCutter},
    {text = 'Add gas can', callback = add_gasCan},
    {text = 'Add muriatic acid', callback = add_muriaticAcid},
    {text = 'Add hydrogen chloride', callback = add_hydrogenChlorided},
    {text = 'Add caustic soda', callback = add_causticSoda},
    {text = 'Use shaped charges', callback = Use_shaped_charges},
    { text = "", is_cancel_button = true },
    {text = 'Cooking combo', callback = add_cookingCombo},
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true, },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_inventory_items = SimpleMenu:new("Inventory Menu", "Add stuff to inventory.", mymenu_inventory_items_options)
mymenu_inventory_items:hide()

--Stealth  menu
mymenu_stealth_options = {
    { text = "Kill all AI", callback = Kill_all_ai },
    { text = "No killing penalty", callback = No_civi_penalty },
    { text = "Infinite pagers", callback = Infinite_pagers },
    { text = "Infinite ECM", callback = Infinite_ecm },
    {text = 'Infinite cable ties', callback = Infinite_cable_ties},
    { text = "Stop people calling cops", callback = Stop_calling_cops },
    { text = "Stops civs from reporting you", callback = Stop_civs_report },
    { text = "Disable cam alarm", callback = Stop_cam_alarm },
    { text = "Prevent panic buttons & intel burning", callback = Stop_buttons_burning_intel },
    { text = "Interact while in casing mode", callback = Interact_while_in_casing_mode },
    { text = "Infinite hostage follower distance", callback = Infinite_hostage_follower_distance },
    { text = "Infinite hostage followers", callback = Infinite_hostage_followers },
    { text = "", is_cancel_button = true },
    { text = "Twice as fast drilling times", callback = Twice_as_fast_drilling },
    { text = "", is_cancel_button = true },
    { text = "100% Stealth", callback = No_alarms },
    { text = "Demi stealth", callback = Demi_stealth },
    { text = "", is_cancel_button = true },
    { text = "", is_cancel_button = true },
    { text = "Back", callback = Main_menu },
    { text = "CLOSE", is_cancel_button = true}
}
mymenu_stealth = SimpleMenu:new("Stealth menu", " ", mymenu_stealth_options)
mymenu_stealth:hide()

--dodge menu
mymenu_dodge_options = {
    { text = "Default", callback = function() dodge(0) end , is_focused_button = true,},
    { text = "", is_cancel_button = true },
    { text = "+5%", callback = function() dodge(0.05) end},
    { text = "+10%", callback = function() dodge(0.1) end},
    { text = "+15%", callback = function() dodge(0.15) end},
    { text = "+20%", callback = function() dodge(0.2) end},
    { text = "", is_cancel_button = true },
    { text = "+30%", callback = function() dodge(0.3) end},
    { text = "+40%", callback = function() dodge(0.4) end},
    { text = "+50%", callback = function() dodge(0.5) end},
    { text = "+60%", callback = function() dodge(0.6) end},
    { text = "+90%", callback = function() dodge(0.9) end},
    { text = "+100%", callback = function() dodge(1) end},
    { text = "", is_cancel_button = true },
    { text = "Become Neo", callback = function() dodge(3) end},
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
