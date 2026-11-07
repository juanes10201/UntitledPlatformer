extends Node2D
@export var CacheAmount : int = 15
@onready var CacheNode : Node2D = $CacheText

func _ready() -> void:
	CacheNode.set_cache_nodes_amount(CacheAmount, false)

#func _process(delta: float) -> void:
#	draw_score(20, Vector2(-266.0, -87))

func draw_score(score : int, global_pos, direction : Global.ALL_DIRECTIONS) -> void:
	var _textNode : Node2D = CacheNode.get_unused_node()
	if(_textNode): _textNode.play_score(score, global_pos, direction)
