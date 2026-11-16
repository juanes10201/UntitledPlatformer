extends Node2D

@onready var Player = SaveGame.get_player()
var BodyEntered : bool = false 

@export var FrameFreezeAmount : float = .1
@export var FrameFreezeTime : float = 3.0
@export var EndInGroundsmash : bool = true

func _on_key_picked_by_player() -> void:
	if(BodyEntered): return
	BodyEntered = true
	Player.FrameFreeze(FrameFreezeAmount, FrameFreezeTime)
	Player._set_on_water_sound_effects(true)
	$AnimationPlayer.play("Play")
	if($SoundClockCutscene): $SoundClockCutscene.play()
	await get_tree().create_timer(.2).timeout
	if(EndInGroundsmash):
		Player.GroundSmash = true
		Player.PressingGroundSmash = true
	Player._set_on_water_sound_effects(false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	_on_key_picked_by_player()
