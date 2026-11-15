@tool
extends TileMapLayer

@onready var Player = $"../Player"
@export_group("Water Level")
@export var WaterLevel : float = 0.0
@onready var WaterLevelGoTo : float = WaterLevel

#func _ready() -> void:
	#print(is_tile_water_global(-314, -344))

#Check if tile is water and below Water Level
#region Check tile
func is_tile_water_local(X : int, Y : int) -> bool:
	var tile_pos: Vector2i = local_to_map(Vector2i(X, Y))
	return true if get_cell_tile_data(tile_pos) else false

func is_tile_water_global(X : int, Y : int) -> bool:
	var tile_pos_local = to_local(Vector2i(X, Y))
	return is_tile_water_local(tile_pos_local.x, tile_pos_local.y)

func _is_tile_on_water_level_global(X : int, Y : int) -> bool:
	if(Y > WaterLevel): return false
	else: return is_tile_water_global(X, Y)
#endregion

func _process(delta: float) -> void:
	#if(Edition.Is_in_editor):
	#	material.set_shader_parameter("opacity_post_border", .5)
	#else:
	#	material.set_shader_parameter("opacity_post_border", 0.0)
	material.set_shader_parameter("water_surface_y", WaterLevel)
	if !Engine.is_editor_hint():
		if(Edition.Is_in_editor): WaterLevelGoTo = WaterLevel
		else: WaterLevel = lerpf(WaterLevel, WaterLevelGoTo, 5*delta)
