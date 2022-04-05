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
function openmenu(menu)
        menu:show()
end

Main_menu = function()
    openmenu(mymenu_main)
end

Dodge_menu = function()
    openmenu(mymenu_dodge)
end

Inventory_menu = function()
    openmenu(mymenu_inventory)
end

---------------------------------------------------------------------------------------------------------------------------------
--FUNCTIONS

--inventory functions
add_keycard = add_keycard or function()
    managers.player:add_special( { name = "bank_manager_key", silent = true, amount = 1 } )
    managers.hud:show_hint( { text = "Keycard added!" } )
end
add_crowbar = add_crowbar or function()
    managers.player:add_special( { name = "crowbar", silent = true, amount = 1 } )
    managers.hud:show_hint( { text = "Crowbar added!" } )
end
add_planks = add_planks or function()
    managers.player:add_special( { name = "planks", silent = true, amount = 1 } )
    managers.hud:show_hint( { text = "Planks added!" } )
end
add_glassCutter = add_glassCutter or function()
    managers.player:add_special( { name = "glass_cutter", silent = true, amount = 1 } )
    managers.hud:show_hint( { text = "Glass cutters added!" } )
end
add_gasCan = add_gasCan or function()
    managers.player:add_special( { name = "gas", silent = true, amount = 1 } )
    managers.hud:show_hint( { text = "Gas can added!" } )
end
add_muriaticAcid = add_muriaticAcid or function()
    managers.player:add_special( { name = "acid", silent = true, amount = 1 } )
    managers.hud:show_hint( { text = "Muriatic acid added!" } )
end
add_hydrogenChlorided = add_hydrogenChlorided or function()
    managers.player:add_special( { name = "hydrogen_chloride", silent = true, amount = 1 } )
    managers.hud:show_hint( { text = "Hydrogen chloride added!" } )
end
add_causticSoda = add_causticSoda or function()
    managers.player:add_special( { name = "caustic_soda", silent = true, amount = 1 } )
    managers.hud:show_hint( { text = "Caustic soda added!" } )
end
add_cookingCombo = add_cookingCombo or function()
    managers.player:add_special( { name = "caustic_soda", silent = true, amount = 1 } )
    managers.player:add_special( { name = "acid", silent = true, amount = 1 } )
    managers.player:add_special( { name = "hydrogen_chloride", silent = true, amount = 1 } )
    managers.hud:show_hint( { text = "Cooking combo added!" } )
end

--dodge functions
Default = Default or function()   
    tweak_data.player.damage.DODGE_INIT = 0
    managers.hud:show_hint( { text = "dodge set to default!" } )
end
five = five or function()   
    tweak_data.player.damage.DODGE_INIT = 0.5
    managers.hud:show_hint( { text = "dodge increased by 5%!" } )
end
ten = ten or function()   
    tweak_data.player.damage.DODGE_INIT = 0.10
    managers.hud:show_hint( { text = "dodge increased by 10%!" } )
end
fifteen = fifteen or function()   
    tweak_data.player.damage.DODGE_INIT = 0.15
    managers.hud:show_hint( { text = "dodge increased by +15%!" } )
end
twenty = twenty or function()   
    tweak_data.player.damage.DODGE_INIT = 0.20
    managers.hud:show_hint( { text = "dodge increased by +20%!" } )
end
thirty = thirty or function()   
    tweak_data.player.damage.DODGE_INIT = 0.30
    managers.hud:show_hint( { text = "dodge increased by +30%!" } )
end
forty = forty or function()   
    tweak_data.player.damage.DODGE_INIT = 0.40
    managers.hud:show_hint( { text = "dodge increased by +40%!" } )
end
fifty = fifty or function()   
    tweak_data.player.damage.DODGE_INIT = 0.50
    managers.hud:show_hint( { text = "dodge increased by +50%!" } )
end
sixty = sixty or function()   
    tweak_data.player.damage.DODGE_INIT = 0.60
    managers.hud:show_hint( { text = "dodge increased by +60%!" } )
end
ninety = ninety or function()   
    tweak_data.player.damage.DODGE_INIT = 0.90
    managers.hud:show_hint( { text = "dodge increased by +90%!" } )
end
hundred = hundred or function()   
    tweak_data.player.damage.DODGE_INIT = 1
    managers.hud:show_hint( { text = "dodge increased by +100%!" } )
end
threeHundred = threeHundred or function()   
    tweak_data.player.damage.DODGE_INIT = 3
    managers.hud:show_hint( { text = "You are Neo!" } )
end

---------------------------------------------------------------------------------------------------------------------------------
--MENUS

--in-game menu
opts = {}
opts[#opts+1] = { text = "Dodge", callback = Dodge_menu }
opts[#opts+1] = { text = "Inventory", callback = Inventory_menu }
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
mymenu_main = SimpleMenu:new("In-game menu", " ", opts)
if isPlaying() and inGame() and isMultiplayer() and managers.hud then
mymenu_main:show()

--Inventory menu
opts = {}
opts[#opts+1] = {text = 'Add keycard', callback = add_keycard, is_focused_button = true}
opts[#opts+1] = {text = 'Add crowbar', callback = add_crowbar}
opts[#opts+1] = { text = "Add planks", callback = add_planks }
opts[#opts+1] = {text = 'Add glass cutter', callback = add_glassCutter}
opts[#opts+1] = {text = 'Add gas can', callback = add_gasCan}
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = {text = 'Add muriatic acid', callback = add_muriaticAcid}
opts[#opts+1] = {text = 'Add hydrogen chloride', callback = add_hydrogenChlorided}
opts[#opts+1] = {text = 'Add caustic soda', callback = add_causticSoda}
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = {text = 'Cooking combo', callback = add_cookingCombo}
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "", is_cancel_button = true, }
opts[#opts+1] = { text = "Back", callback = Main_menu }
opts[#opts+1] = { text = "CLOSE", is_cancel_button = true}
mymenu_inventory = SimpleMenu:new("Inventory Menu", "Add stuff to inventory.", opts)
mymenu_inventory:hide()

--dodge menu
opts = {}
opts[#opts+1] = { text = "Default", callback = Default, is_focused_button = true }
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "+5%", callback = five }
opts[#opts+1] = { text = "+10%", callback = ten }
opts[#opts+1] = { text = "+15%", callback = fifteen }
opts[#opts+1] = { text = "+20%", callback = twenty }
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "+30%", callback = thirty }
opts[#opts+1] = { text = "+40%", callback = forty }
opts[#opts+1] = { text = "+50%", callback = fifty }
opts[#opts+1] = { text = "+60%", callback = sixty }
opts[#opts+1] = { text = "+90%", callback = ninety }
opts[#opts+1] = { text = "+100%", callback = hundred }
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "Become Neo", callback = threeHundred }
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "Back", callback = Main_menu }
opts[#opts+1] = { text = "CLOSE", is_cancel_button = true}
mymenu_dodge = SimpleMenu:new("Dodge menu", "Increase dodge by...", opts)
mymenu_dodge:hide()

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