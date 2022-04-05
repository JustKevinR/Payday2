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

----------------------------------------------------------------------------------------------------------------
-- OPEN MENU
function openmenu(menu)
    menu:show()
end

Main_menu = function()
openmenu(mymenu_main)
end

---------------------------------------------------------------------------------------------------------------------------------
--MENUS

--in-game menu
opts = {}
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "", is_cancel_button = true }
opts[#opts+1] = { text = "CLOSE", is_cancel_button = true, is_focused_button = true}
mymenu_main = SimpleMenu:new("In-game menu", " ", opts)
mymenu_main:show()