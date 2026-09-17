extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#get_parent().disable_collision()
	pass

func _on_area_entered(area: Area2D) -> void:
	var playerbody = area.get_parent()
	if(get_parent().Enabled):
		if("InvincibleSlimeCooldown" in playerbody && playerbody.InvincibleSlimeCooldown && !playerbody.InvincibleSlimeCooldown.is_stopped()): return
		if(playerbody.is_in_group("Player")):
			if(area.is_in_group("PlayerEnemiesCollision") && get_parent().enemy_type == 0):
				#Disable enemie collision if enemy type == 0
				if(get_parent().check_collision()): get_parent().disable_collision()
				#If sliding and enemy type's == 0 then do slide action 
				if(playerbody.Slide || playerbody.SnappedOnRail ):
					get_parent()._on_player_slide_signal()
			elif(!playerbody.SnappedOnRail && area.is_in_group("PlayerHitBox") && (get_parent().enemy_type != 0 || !playerbody.Slide)):
				playerbody.On_Death()
		else:
			if(!get_parent().check_collision()): get_parent().enable_collision()
