@tool
extends TileMapLayer

@onready var Player = $"../Player"
@export_group("Shading")
@export var ShadowShader : bool = false
@export var IsShadedSubtile : bool = false
@export var AddedOfset : Vector2 = Vector2(0.0, 0.0)
var LoadedShadeShader : bool = false
@export_tool_button("Redraw Neighbor Map", "Callable")
var update_neighbor_map_action: Callable:
	get: return update_neighbor_map
@export_tool_button("Reset Neighbor Map", "Callable")
var reset_neighbor_map_action: Callable:
	get: return reset_neighbor_map

enum PosBorderX{
	None = 0,
	East = 1,
	West = 2,
	Both = 3
}
enum PosBorderY{
	None = 0,
	North = 1,
	South = 2,
	Both = 3
}
enum PosBorderDiagonal{
	None = 0,
	UpperRight = 1,
	UpperLeft = 2,
	DownRight = 3,
	DownLeft = 4
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(ShadowShader): update_neighbor_map()
	else: reset_neighbor_map()
	#pass # Replace with function body.

func _generate_map_image() -> ImageTexture:
	var _tileset_rect2i : Rect2i = get_used_rect()
	var _tileset_size : Vector2i = _tileset_rect2i.size
	var _image = Image.create_empty(_tileset_size.x, _tileset_size.y, false, Image.FORMAT_RGBA8)
	var _tileset_offset = AddedOfset #Vector2(1.0, -1.0)#position#Vector2i(round(position.x), round(position.y))
	var _tileset_origin = Vector2(_tileset_rect2i.position)+_tileset_offset
	print("Tileset offset: " + str(_tileset_origin))
	if(material):
		material.set_shader_parameter("map_size", Vector2(_tileset_rect2i.size))
		material.set_shader_parameter("map_origin", _tileset_origin)# - Vector2(1.0, 1.0) )
		material.set_shader_parameter("cell_size", Vector2(tile_set.tile_size))
	
	for _tile in get_used_cells():		
		var _tile_pos = _tile-_tileset_rect2i.position
		var _tile_border_x : PosBorderX = PosBorderX.None
		var _tile_border_y : PosBorderY = PosBorderY.None
		
		var _is_east_border : bool = !( (_tile + Vector2i(1, 0)) in get_used_cells() )
		var _is_west_border : bool = !( (_tile + Vector2i(-1, 0)) in get_used_cells() )
		var _is_north_border : bool = !( (_tile + Vector2i(0, 1)) in get_used_cells() )
		var _is_south_border : bool = !( (_tile + Vector2i(0, -1)) in get_used_cells() )
		
		if(_is_east_border && _is_west_border):
			_tile_border_x = PosBorderX.Both
		elif _is_east_border:
			_tile_border_x = PosBorderX.East
		elif _is_west_border:
			_tile_border_x = PosBorderX.West
			
		if (_is_north_border && _is_south_border):
			_tile_border_y = PosBorderY.Both
		elif _is_north_border:
			_tile_border_y = PosBorderY.North
		elif _is_south_border:
			_tile_border_y = PosBorderY.South
		
		var _tile_border_diagonal : PosBorderDiagonal = PosBorderDiagonal.None
		
		#Diagonals
		if(_tile_border_x != PosBorderX.Both && _tile_border_y != PosBorderY.Both):
			if(!( (_tile + Vector2i(1, 1)) in get_used_cells() ) && _tile_border_y != PosBorderY.North && _tile_border_x != PosBorderX.East):
				_tile_border_diagonal = PosBorderDiagonal.UpperRight
			if(!( (_tile + Vector2i(-1, 1)) in get_used_cells() ) && _tile_border_y != PosBorderY.North && _tile_border_x != PosBorderX.West):
				_tile_border_diagonal = PosBorderDiagonal.UpperLeft
			if(!( (_tile + Vector2i(1, -1)) in get_used_cells() ) && _tile_border_y != PosBorderY.South && _tile_border_x != PosBorderX.East):
				_tile_border_diagonal = PosBorderDiagonal.DownRight
			if(!( (_tile + Vector2i(-1, -1)) in get_used_cells() ) && _tile_border_y != PosBorderY.South && _tile_border_x != PosBorderX.West):
				_tile_border_diagonal = PosBorderDiagonal.DownLeft
		
		var _tile_border_num_x : float = float(_tile_border_x)/float(PosBorderX.size())
		var _tile_border_num_y : float = float(_tile_border_y)/float(PosBorderY.size())
		
		var _tile_border_num_diagonal : float = float(_tile_border_diagonal)/float(PosBorderDiagonal.size())
		
		var _tile_color : Color = Color(_tile_border_num_x, _tile_border_num_y, _tile_border_num_diagonal, 1.0)
		#print("Border x: " + str(_tile_color))
		#print("Border y: " + str(_tile_border_num_y))
		if(_tile_border_num_diagonal != 0.0): print("Border diagonal: " + str(_tile_border_num_diagonal))
		_image.set_pixel(_tile_pos.x, _tile_pos.y, _tile_color)
	return ImageTexture.create_from_image(_image)

func update_neighbor_map() -> void:
	LoadedShadeShader = true
	print("Updating the neighbor map")
	var _map_image : ImageTexture = _generate_map_image()
	var _map_image_material := material as ShaderMaterial  
	material.set_shader_parameter("border_map", _map_image)
	
	print("Updated the neighbor map!")

func reset_neighbor_map() -> void:
	LoadedShadeShader = false
	var _unused_image = Image.create_empty(0, 0, false, Image.FORMAT_RGBA8)
	var _unused_image_texture : ImageTexture = ImageTexture.create_from_image(_unused_image)
	if (material && "shader_parameter_border_map" in material.get_property_list()):
		material.set_shader_parameter("border_map", _unused_image_texture)

func _process(delta: float) -> void:
	if(!Engine.is_editor_hint() && Edition.Is_in_editor ):
		if(!LoadedShadeShader && ShadowShader):
			update_neighbor_map()
		elif(LoadedShadeShader && !ShadowShader):
			reset_neighbor_map()
	
	#var _tile_size = material.get_shader_parameter("chunk_size")
	
	#var sides := PackedInt32Array()
	#sides.resize(_tile_size*_tile_size)
	#sides.fill(0)
	#
	#for _tile in get_used_cells():
	#	 var _local_coord = _tile
