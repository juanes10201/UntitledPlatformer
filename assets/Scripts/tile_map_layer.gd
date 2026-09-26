@tool
extends TileMapLayer

@onready var Player = $"../Player"
@export var ShadowShader : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(ShadowShader): update_neighbor_map(self)
	pass # Replace with function body.

func update_neighbor_map() -> void:
	pass
	#var _initial_image =

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#var _tile_size = material.get_shader_parameter("chunk_size")
	
	#var sides := PackedInt32Array()
	#sides.resize(_tile_size*_tile_size)
	#sides.fill(0)
	#
	#for _tile in get_used_cells():
	#	 var _local_coord = _tile
