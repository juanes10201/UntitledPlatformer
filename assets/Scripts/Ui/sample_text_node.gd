extends Node2D
@onready var anim = $AnimationPlayer
@onready var text = $SampleText

@export var AnimsMove : Dictionary[String, Array]

var Playing : bool = false

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if(!anim.is_playing() && Playing):
		Playing = false
		get_parent().set_unused_node(self)

func play_score(val : int, _global_pos : Vector2, Direction : Global.ALL_DIRECTIONS = Global.ALL_DIRECTIONS.none) -> void:
	Playing = true
	
	if(val > 0): text.text = "+" + str(val)
	if(val < 0): text.text = "-" + str(val)
	
	if(anim):
		var _key = Global.ALL_DIRECTIONS.keys()[Direction]
		var _index = round(randf_range(0, AnimsMove[_key].size()-1))
		print("Playing anim: key: " + str(_key) + " , index: " + str(_index))
		print("Anim: " + str(AnimsMove[_key][_index]))
		anim.play(AnimsMove[_key][_index])
	global_position = _global_pos
	show()
