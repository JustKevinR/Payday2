_toggleKB = not _toggleKB

if _toggleKB then
	tweak_data.player.damage.DODGE_INIT = 0.20
	managers.hud:show_hint( { text = "Better dodge loaded!" } )
  else
    tweak_data.player.damage.DODGE_INIT = 0
    managers.hud:show_hint( { text = "Better dodge disabled!" } )
end
