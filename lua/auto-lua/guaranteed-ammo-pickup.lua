local guaranteed = true				-- If no ammo would be picked up, pick up 1
local multiplier_special = 2		-- Ammo pickup multiplier for grenade launchers and bows
local multiplier_rest = 3			-- Ammo pickup multiplier for all other weapons
local flamethrower_minimum = 50		-- Minimum pickup for flamethrowers, requires guaranteed to be true

-------------------------------------------------------------------------------------------------------------------------------------------

function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
	local function _add_ammo(ammo_base, ratio, add_amount_override)
		if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
			return false, 0
		end

		local multiplier_min = 1
		local multiplier_max = 1

		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_min_mul then
			multiplier_min = ammo_base._ammo_data.ammo_pickup_min_mul
		else
			multiplier_min = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
			multiplier_min = multiplier_min + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
			multiplier_min = multiplier_min + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
		end

		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_max_mul then
			multiplier_max = ammo_base._ammo_data.ammo_pickup_max_mul
		else
			multiplier_max = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
			multiplier_max = multiplier_max + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
			multiplier_max = multiplier_max + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
		end

		local add_amount = add_amount_override
		local picked_up = true

		if not add_amount then
			local rng_ammo = math.lerp(ammo_base._ammo_pickup[1] * multiplier_min, ammo_base._ammo_pickup[2] * multiplier_max, math.random())
			add_amount = math.max(0, math.round(rng_ammo))
		end

		add_amount = math.floor(add_amount * (ratio or 1))

		-- Guaranteed ammo pickup
		if add_amount < 1 and guaranteed then
			add_amount = 1

			-- Flamethrowers get 50 minimum
			if self:is_category("flamethrower") then add_amount = flamethrower_minimum end
		elseif add_amount >= 1 then
			-- Grenade launchers and bows get double
			if (self:is_category("grenade_launcher") or self:is_category("bow")) or self:is_category("crossbow") then
				add_amount = add_amount * multiplier_special

			-- Rest gets triple
			else
				add_amount = add_amount * multiplier_rest
			end
		end

		ammo_base:set_ammo_total(math.clamp(ammo_base:get_ammo_total() + add_amount, 0, ammo_base:get_ammo_max()))

		return picked_up, add_amount
	end

	local picked_up, add_amount = nil
	picked_up, add_amount = _add_ammo(self, ratio, add_amount_override)

	if self.AKIMBO then
		local akimbo_rounding = self:get_ammo_total() % 2 + #self._fire_callbacks

		if akimbo_rounding > 0 then
			_add_ammo(self, nil, akimbo_rounding)
		end
	end

	for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
		if gadget and gadget.ammo_base then
			local p, a = _add_ammo(gadget:ammo_base(), ratio, add_amount_override)
			picked_up = p or picked_up
			add_amount = add_amount + a
		end
	end

	return picked_up, add_amount
end
