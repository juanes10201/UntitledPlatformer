extends Node2D

@export_multiline var AltText : String
@export_multiline var AltAltText : String
@onready var TutorialParent : RichTextLabel = get_parent()
@export var Buttons : Array[AnimatedSprite2D] = [] 
@onready var JitterclickTimer = $JitterclickTimer
@onready var Player = SaveGame.get_player()
const AmountJitterclick : int = 2
const ActionPressed : String = "player_jump"
var CurrentAmountJitterclick : int = 0
var DetectedShitterclick : bool = false

func _hide_buttons() -> void:
	for _buttons in Buttons:
		_buttons.hide()

func detected_jitterclick():
	if(DetectedShitterclick): return
	_hide_buttons()
	TutorialParent.text = ""
	TutorialParent.OgText = AltText
	DetectedShitterclick = true

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed(ActionPressed)):
		#if(!Player.WallJump && Player.PreWallJumpTimer.is_stopped()):
		#	return
		if(JitterclickTimer.is_stopped()):
			CurrentAmountJitterclick = 0
		else:
			CurrentAmountJitterclick += 1
		JitterclickTimer.start()
		if(CurrentAmountJitterclick >= AmountJitterclick):
			detected_jitterclick()
