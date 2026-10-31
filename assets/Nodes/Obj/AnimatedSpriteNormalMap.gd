extends Node2D

var flip_h : bool
var animation : String
@export var OverrideAnim : bool = false
@onready var JuiceStretchLogic : Node2D = $JuiceStretchLogic
@onready var FrameHitTimer : Timer = $FrameHitTimer

func _start_frame_hit() -> void:
	if(FrameHitTimer):
		print("Started frame hit")
		FrameHitTimer.stop()
		FrameHitTimer.start()

func _ready() -> void:
	$Anim.play("Idle")

func _process(delta: float) -> void:
	if(FrameHitTimer):
		if(!FrameHitTimer.is_stopped()):
			material.set_shader_parameter("time", FrameHitTimer.time_left)
			material.set_shader_parameter("end_time", FrameHitTimer.wait_time)
		else:
			material.set_shader_parameter("time", 0.0)
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
