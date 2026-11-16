extends Node2D

@onready var Player = SaveGame.get_player()

func _on_key_picked_by_player() -> void:
	Player.FrameFreeze(.1, 3.0)
	$AnimationPlayer.play("Play")
	$SoundClockCutscene.play()
	await get_tree().create_timer(.2).timeout
	Player.GroundSmash = true
	Player.PressingGroundSmash = true
