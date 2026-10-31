extends Node2D

var flip_h : bool
var animation : String
@export var OverrideAnim : bool = false
@onready var JuiceStretchLogic : Node2D = $JuiceStretchLogic

func _ready() -> void:
	$Anim.play("Idle")

func _process(delta: float) -> void:
	#if(OverrideAnim): $Anim.pause()
	#if(OverrideAnim != ""):
	#	play(OverrideAnim, true, OverrideAnimTime)
	for Child in get_children():
		if(Child.get_class() == "Sprite2D"):
			Child.flip_h = flip_h

func play(Anim : String):
	if(OverrideAnim): return
	animation = Anim
	#if(!OverrideTime):
	$Anim.play(Anim)
	#elif($Anim.speed_scale > 0.0):
	#	$Anim.play_section(Anim, OverrideTimeTime, OverrideTimeTime+.1)
	#	await get_tree().create_timer(0.3).timeout
	#	$Anim.speed_scale = 0.0
