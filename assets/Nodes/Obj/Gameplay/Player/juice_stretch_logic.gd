extends Node2D

@onready var Sprite : Node2D = get_parent()
@export var Juice = true

#region Streching and scaling
@onready var original_scale = Sprite.scale
var Stretch_Tween : Tween
var Doing_Tween : bool = false
var Tween_scale_to : Vector2 = Vector2(0.0, 0.0)
var TweenTickContinue : bool = false
var TweenGoBack : bool = true

var CanOverride : bool = true

@onready var Offset : Vector2 = Sprite.offset if "offset" in Sprite else Vector2(0.0,0.0)
enum OffsetDirections{
	Center = 0,
	Up = 1,
	Down = 2
}
var OffsetDirection : OffsetDirections = OffsetDirections.Center
@export var UpdateOffset : bool = false

func _ready() -> void:
	if(Juice && SaveGame.get_config_value("Juice") != null):
		Juice = SaveGame.get_config_value("Juice")

func stretch_reset():
	Stretch_Tween = null
	Doing_Tween = false
	Sprite.scale = original_scale
	CanOverride = true

func stretch_size(From : Vector2, To : Vector2, TimeTo : float = .7, Override : bool = true, GoBack : bool = true, ease : Tween.EaseType = Tween.EASE_IN_OUT, trans : Tween.TransitionType = Tween.TRANS_CUBIC, _OffsetDirection : OffsetDirections = OffsetDirections.Center, _CanBeOverriden : bool = true):
	if(!Juice): return
	if(!CanOverride && Doing_Tween): return
	CanOverride = _CanBeOverriden
	TweenTickContinue = true
	TweenGoBack = GoBack
	_OffsetDirection = OffsetDirection
	#if(Tween_scale_to == To): return
	if(Override || !Doing_Tween):
		stretch_reset()
		Sprite.scale = original_scale*From
		Stretch_Tween = get_tree().create_tween()
		Stretch_Tween.tween_property(Sprite, "scale", original_scale*To, TimeTo)
		Tween_scale_to = original_scale*To
		if(ease): Stretch_Tween.set_ease(ease)
		if(trans): Stretch_Tween.set_trans(trans)

#func _process(delta: float) -> void:
	#stretch_size(Vector2(.5,.5), Vector2(.5,.5) )

func _stretch_offset():
	var frame_size = Sprite.sprite_frames.get_frame_texture(Sprite.animation, Sprite.frame).get_size()
	Sprite.offset = Offset
	if(OffsetDirection == OffsetDirections.Down):
		Sprite.offset.y = Offset.y+frame_size.y/2-(Tween_scale_to.y/original_scale.y)*(frame_size.y/2)
	elif(OffsetDirection == OffsetDirections.Up):
		Sprite.offset.y = Offset.y+frame_size.y/2+(Tween_scale_to.y/original_scale.y)*(frame_size.y/2)
	#print(Offset.y)
	
func _stretch_tick(delta : float):
	if(!Juice): return
	Doing_Tween = !Stretch_Tween || Stretch_Tween.is_running()
	if(!Doing_Tween || !TweenTickContinue):
		CanOverride = true
		if(TweenGoBack):
			stretch_size(Sprite.scale, original_scale, .2, true, false)
		else:
			stretch_reset()
	TweenTickContinue = false
	if(UpdateOffset): _stretch_offset()
#endregion
