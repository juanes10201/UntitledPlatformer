extends Node2D

@export var EditorPlace : Node2D
@export var LevelEditor : Node2D
@export var LevelData : Node2D

#Los datos se guardan todos en diccionarios y sub-diccionarios/sub-arrays ahi,
#todo lo que se guarda en json o archivo es un diccionario basicamente

#El formato es de la siguiente manera
#var Clipboard : Dictionary = {
#	"tiles":
#		[
#			vector2i[Z,Z]: [ZZZZZZZZZZZZZZZZ],
#			vector2i[Z,1]: [ZZZZZZZZZZZZZZZZ],
#			vector2i[Z,2]: [ZZZZZZZZZZZZZZZZ]
#			vector2i[1,Z]: [ZZZZZZZZZZZZZZZZ],
#			En este caso los chunks estarian en posicion [Z,Z], [1,Z], [2,Z], [Z,1]
#		], #los niveles se dividen en chunks de 8x8
#	"Nodes": {
#		"asset": "res://assets/Nodes/Obj/Gameplay/Enemie/enemie.tscn",
#		"EveryModifiedAtribute" : "example, value"
#	}
#}

#

var Clipboard : Dictionary[Vector2i, String] = {}#: "AAAAAAAAAZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"}
const ChunkSize : int = 8
const ChunkDefaultValue : String = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"

@export var ParentOriginalNodes : Node2D
var OriginalNodesLoaded : Dictionary = {}

var PrecalcEditorAllTerrainsId : Dictionary[Vector2i, int] = {}
var PrecalculatedEditorTerrains : Array[Vector2i] = []

func _ready() -> void:
	PreCalcEditorTerrains()

func PreCalcEditorTerrains(Tilemap : TileMapLayer = EditorPlace.SelectedTilemap) -> void:
	var Tileset : TileSet = Tilemap.tile_set
	var Count : int = 0
	for i in range(Tileset.get_terrain_sets_count()):
		for l in range(Tileset.get_terrains_count(i)):
			Count += 1
			var vector = Vector2i(i, l)
			PrecalcEditorAllTerrainsId[vector] = Count
			PrecalculatedEditorTerrains.append(vector)

func GetOriginalNode(Number : int, SubNumber : int) -> Node2D:
	var _original_scene_path = LevelEditor.SelectableObjects[Number][SubNumber]
	var _original_scene = null
	var DictionaryId : Vector2i = Vector2i(Number, SubNumber)
	if(DictionaryId in OriginalNodesLoaded):
		_original_scene = OriginalNodesLoaded[DictionaryId]
	else:
		_original_scene = GlobalFunctions.Create_node2d(_original_scene_path, ParentOriginalNodes) #_original_packed_scene.get_state()
		OriginalNodesLoaded[DictionaryId] = _original_scene
	if(_original_scene):
		return _original_scene
	return null

func GetSavedDataNodes(Data : Array) -> void:
	for _child in LevelEditor.get_level_data_gameplay_objects_node().get_children():
		_child.queue_free()
	for NodeData in Data:
		var EditorId : Vector2i = NodeData["EditorId"]
		var Properties : Dictionary = NodeData["Properties"]
		
		var _original_scene = GetOriginalNode(EditorId.x, EditorId.y)
		if(_original_scene):
			var new_node = _original_scene.duplicate()
			LevelEditor.get_level_data_gameplay_objects_node().add_child(new_node)
			
			for PropertyName in Properties:
				var PropertyValue = Properties[PropertyName]
				if(PropertyName in new_node):
					new_node.set(PropertyName, PropertyValue)
	_reset_original_nodes()

func SaveDataNodes(Nodes : Array) -> Array:
	print("Nodes: " + str(Nodes))
	var _result : Array = []
	for _node in Nodes:
		var _node_result : Dictionary = {}
		if(_node.has_meta(EditorPlace.NewNodeMetaNumber) && _node.has_meta(EditorPlace.NewNodeMetaSubNumber)):
			var _node_number = _node.get_meta(EditorPlace.NewNodeMetaNumber)
			var _node_subnumber = _node.get_meta(EditorPlace.NewNodeMetaSubNumber)
			print("node number: " + str(_node_number))
			print("node subnumber: " + str(_node_subnumber))
			
			var DictionaryId : Vector2i = Vector2i(_node_number, _node_subnumber)
			_node_result["EditorId"] = DictionaryId
			var _original_scene = GetOriginalNode(_node_number, _node_subnumber)
			if(_original_scene):
				var Properties : Dictionary = {}
				for property in _original_scene.get_property_list():
					var property_name = property.name
					var property_value = _original_scene.get(property_name)
					var changed_property_value = _node.get(property_name)
					if(property_name in _node && property_value != changed_property_value):
						if !(changed_property_value is Node):
							Properties[property_name] = changed_property_value
						#print("Value difference!: Name: " + str(property_name) + "; Value: " + str(property_value))
				_node_result["Properties"] = Properties
				_result.append(_node_result)
	OriginalNodesLoaded = {}
	_reset_original_nodes()
	return _result

func _reset_original_nodes() -> void:
	for OriginalChild in ParentOriginalNodes.get_children():
		OriginalChild.queue_free()

func SaveFilesDataTiles(SaveData : Dictionary) -> Array:# Dictionary[Vector2i, String]:
	#var Current : int = 0
	var Result : Array = []
	for Tileset in LevelEditor.TilesetLayers:
		var Saved = SaveDataAllTilesTileset(Tileset, SaveData)
		#print(Saved)
		print("Saved clipboard data")
		Result.append(Saved)
	return Result

func SaveDataAllTilesTileset(Tileset : TileMapLayer, SaveData : Dictionary) -> Dictionary[Vector2i, String]:
	return SaveDataTileset(Tileset.get_used_cells(), Tileset, SaveData)

func GetTerrainFromPrecalcId(id : int) -> Vector2i:
	if(id < 0):
		return Vector2i(0, 0)
	if(id < PrecalculatedEditorTerrains.size()):
		return PrecalculatedEditorTerrains[id]
	return Vector2i(0, 0)

func GetPrecalcTerrainId(TerrainSet : int, SubTerrain : int) -> int:
	var VectorPos = Vector2i(TerrainSet, SubTerrain)
	if(VectorPos in PrecalcEditorAllTerrainsId):
		return PrecalcEditorAllTerrainsId[VectorPos]-1
	return -1

func SaveDataTileset(Tiles : Array, Tilemap : TileMapLayer, SaveData : Dictionary) -> Dictionary[Vector2i, String]:
	var Saved : Dictionary[Vector2i, String] = { }
	#print(floor(-0.25))
	for Tile in Tiles:
		var Chunk : Vector2i = Vector2i(floor(float(Tile.x)/float(ChunkSize)), floor(float(Tile.y)/float(ChunkSize)) )
		#print("Chunk:" + str(Chunk))
		var ChunkPos : Vector2i = Vector2i( abs(Tile.x) % ChunkSize, abs(Tile.y) % ChunkSize )
		if(Tile.x < 0): ChunkPos.x = ChunkSize - ChunkPos.x
		if(Tile.y < 0): ChunkPos.y = ChunkSize - ChunkPos.y
		
		var ChunkIndex : int = abs(ChunkPos.x) + (abs(ChunkPos.y) * ChunkSize)
		
		#print("ChunkPos: " + str(ChunkPos))
		#Current += 1
		if(!Chunk in Saved): Saved[Chunk] = ChunkDefaultValue
		var tiledata : TileData = Tilemap.get_cell_tile_data(Tile)
		##El valor del autotile se guarda en hexabinario porque why not
		if(tiledata && ChunkIndex < Saved[Chunk].length() ):
			var terrain_id = GetPrecalcTerrainId(tiledata.terrain_set, tiledata.terrain)
			Saved[Chunk][ChunkIndex] = char(65+abs(terrain_id))
			print("Terrain: " + str(tiledata.terrain))
	return Saved

#const SaveLocation : String = "res://assets/Saved/LevelEditor/"

func SaveToFile(Path : String, Nodes : Array, Tiles : Array, Tilemap : TileMapLayer, SaveData : Dictionary) -> void:
	var SavedTileset = SaveFilesDataTiles(SaveData)
	var SavedNodes = SaveDataNodes(Nodes)
	var Saved : Dictionary = {
		"Tileset" = SavedTileset,
		"Nodes" = SavedNodes
	}
	var file = FileAccess.open(Path, FileAccess.WRITE)
	file.store_string(var_to_str(2))
	file.close()
	LevelData.LevelPath = Path
	print("Saved!")

func LoadData(Path : String) -> void:
	print("Opening level data from " + str(Path))
	var file = FileAccess.open(Path, FileAccess.READ)
	if file:
		var data = str_to_var(file.get_as_text())
		GetSavedDataNodes(data["Nodes"])
		LoadDataTiles(LevelEditor.TilesetLayers, data["Tileset"])
		file.close()
		LevelData.LevelPath = Path
	else:
		print("File not found")

func SaveDataTileToClipboard(Tiles : Array, Tilemap : TileMapLayer, SaveData : Dictionary) -> void:
	Clipboard = SaveDataTileset(Tiles, Tilemap, SaveData)

func LoadDataTiles(Tilemaps : Array[TileMapLayer], SaveData : Array) -> void:
	for Tilemap in Tilemaps:
		Tilemap.clear()
	for i in range(SaveData.size()):
		if(i >= Tilemaps.size()): return
		LoadDataTileset(Tilemaps[i], SaveData[i])

func LoadDataTileset(Tilemap : TileMapLayer, SaveDataLayer : Dictionary) -> void:
	for Chunk in SaveDataLayer:
		for Index in range(0, SaveDataLayer[Chunk].length()):
			var Pos : Vector2i = Vector2i(Chunk.x*ChunkSize+ Index%ChunkSize, Chunk.y*ChunkSize+ Index/ChunkSize)
			#print(Pos)
			if(SaveDataLayer[Chunk][Index] == 'Z'):
				EditorPlace._erase_tile_terrain_local_pos(Pos)
			else:
				var TerrainId : int = SaveDataLayer[Chunk][Index].unicode_at(0) - 65
				var Terrain : Vector2i = GetTerrainFromPrecalcId(TerrainId)
				#print(SubTile)
				EditorPlace._place_tile_terrain_local_pos(Pos, Tilemap, Terrain.x, Terrain.y)

func SaveEverythingToFile(path : String) -> void:
	var ChildrenNodes : Array = LevelEditor.get_level_data_gameplay_objects_node().get_children()
	SaveToFile(path, ChildrenNodes, EditorPlace.SelectedTilemap.get_used_cells(), EditorPlace.SelectedTilemap, Clipboard)

func _on_editor_save_file_dialog_file_selected(path: String) -> void:
	SaveEverythingToFile(path)
	GlobalFunctions.OpenedFileDialog = false


func _on_editor_load_file_dialog_file_selected(path: String) -> void:
	LoadData(path)
	GlobalFunctions.OpenedFileDialog = false


func _on_editor_save_file_dialog_canceled() -> void:
	GlobalFunctions.OpenedFileDialog = false

func _on_editor_load_file_dialog_canceled() -> void:
	GlobalFunctions.OpenedFileDialog = false
