local auto_shout_elves = true	-- Set to true if you want to shout automatically at elves, false otherwise
local auto_bag_presents = true	-- Set to true if you want to automatically bag presents, false otherwise

-----------------------------------------------------------------------------------------------------------------------

local elves = {	["4b02693553a926c3"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_1/civ_male_helper_1
				["28f247256e821a74"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_2/civ_male_helper_2
				["23bb5d4857a1a16c"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_3/civ_male_helper_3
				["871dae12e3cddbd8"] = true, -- units/pd2_dlc_cane/characters/civ_male_helper_4/civ_male_helper_4
			}

local old_update = ObjectInteractionManager.update
function ObjectInteractionManager:update(t, dt)
	old_update(self, t, dt)

	--in-game check
	if BaseNetworkHandler and BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()] then
		-- Auto-shout
		for _,unit in pairs(World:find_units_quick("all", 21)) do
			if auto_shout_elves and elves[unit:name():key()] and not unit:anim_data().unintimidateable then
				local local_unit = managers.player:local_player()
				unit:brain():on_intimidated(tweak_data.player.long_dis_interaction.intimidate_strength, local_unit)
			end
		end

		-- Auto-bag
		if not auto_bag_presents then return end
		for _,unit in pairs(self._interactive_units) do
			local interact = unit:interaction()
			if interact.tweak_data == "hold_pku_present" and interact._active then
				managers.player:drop_carry() -- In case you are already carrying a bag
				unit:interaction():interact(managers.player:local_player())
				managers.player:drop_carry()
			end
		end
	end
end
