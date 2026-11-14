extends Node2D

var AdvancedMode

var IsTileMapSelected : bool = false
@export var Cursor : Node2D
@export var SelectableObjects : Array[Array]
@export var SelectableAutotiles : Array[int]
@export var AutotileTilemapLayers : Array[int]
@export var TilesetLayers : Array[TileMapLayer]
@export var EditorCamera : Camera2D
@export var Time_Left : Timer
@export var Player : Node2D
@export var PlayerCamera : Camera2D
@export var LevelData : Node2D
@export var EditorPlayerTrail : Line2D

@export var EditorPlace : Node2D

var OpenedFileDialog : bool = false

@export var AddedTilesLayers : Array[TileMapLayer]
var CurrentAddedTileLayer : int = 1

var LevelDataGameplayObjects : Node2D
var Paused : bool = false

var CurrentUiPage : int = 0

func get_level_data() -> Node2D:
	if(!LevelData): LevelData = get_node("EditorPlace")
	return LevelData

func get_level_data_gameplay_objects_node() -> Node2D:
	var _level_data = get_level_data()
	return _level_data.get_node("GameplayObjects")

func _get_all_nodes(node: Node) -> Array:
	var result = [node]
	for child in node.get_children():
		result += _get_all_nodes(child)
	return result

var LevelDataRecursiveNodePaths : Dictionary = {}
var SelfRecursiveNodePaths : Dictionary = {}

func StoreNodeReferences(node : Node, StoreArray : Dictionary) -> void:
	for prop in node.get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		var _val = node.get(prop.name)
		if _val && _val is Node && _val.is_inside_tree() && !(_val in LevelDataRecursiveNodePaths):
			#Se guarda que la posicion del asset del puntero dado es la del dicc
			StoreVarReference(_val, StoreArray)
			var _path = _val.get_path()

func StoreVarReference(val, StoreArray : Dictionary) -> void:
	var path = val.get_path()
	StoreArray[val] = path

func StoreArrayReference(array, StoreArray : Dictionary) -> void:
	for _element in array:
		StoreVarReference(_element, StoreArray)

func SaveSnapshotLevelDataPaths() -> void:
	LevelDataRecursiveNodePaths = {}
	SelfRecursiveNodePaths = {}
	var LevelDataChildNodes : Array = _get_all_nodes(self) 
	LevelDataChildNodes.append(self)
	for _node in LevelDataChildNodes:
		StoreNodeReferences(_node, LevelDataRecursiveNodePaths)
	for prop in get_property_list():
		StoreNodeReferences(self, SelfRecursiveNodePaths)
	StoreArrayReference(TilesetLayers, SelfRecursiveNodePaths)
	StoreArrayReference(AddedTilesLayers, SelfRecursiveNodePaths)
	
func LoadNodeDataPaths(_Node : Node, Paths : Dictionary) -> void:
	for prop in _Node.get_property_list():
		LoadPropertyDataPaths(prop, _Node, Paths)

func LoadArrayDataPaths(Arr : Array, Paths : Dictionary) -> void:
	for i in range(Arr.size()):
		var _OriginalNode : TileMapLayer = Arr[i]
		if(_OriginalNode in Paths):
			var _NewNodePointer = get_node(Paths[_OriginalNode] )
			Arr[i] = _NewNodePointer

func LoadPropertyDataPaths(prop, _Node : Node, Paths : Dictionary) -> void:
	var _val = _Node.get(prop.name)
	if _val && _val is Node && _val in Paths:
		var _path = Paths[_val]
		if has_node(_path):
			_Node.set(prop.name, get_node(_path))

func LoadSnapshotLevelDataPaths() -> void:
	var LevelDataChildNodes : Array = _get_all_nodes(self)
	for _node in LevelDataChildNodes:
		LoadNodeDataPaths(_node, LevelDataRecursiveNodePaths)
	LoadNodeDataPaths(self, SelfRecursiveNodePaths)
	
	for child in get_children():
		if(child.is_in_group("LevelData")):
			LevelData = child
	
	LoadArrayDataPaths(TilesetLayers, SelfRecursiveNodePaths)
	LoadArrayDataPaths(AddedTilesLayers, SelfRecursiveNodePaths)
	
	EditorPlace.SelectedTilemap = TilesetLayers[0]
	
	LevelDataRecursiveNodePaths = {}
	if(Player):
		Player.Sprite.show()

var SnapshotLevelData : Node2D

func SaveSnapshotLevelData() -> void:
	if(LevelData):
		SnapshotLevelData = LevelData.duplicate()#DUPLICATE_USE_INSTANTIATION)
		SaveSnapshotLevelDataPaths()
		#print("Saved Snapshot: " + str(SnapshotLevelData))

func _reset_play() -> void:
	if(SnapshotLevelData):
		if(LevelData):
			var OldLevelData = LevelData
			remove_child(OldLevelData)
			LevelData = SnapshotLevelData.duplicate()#DUPLICATE_USE_INSTANTIATION)
			LevelData.name = "LevelData"
			add_child(LevelData)
			
			LoadSnapshotLevelDataPaths()
			if(OldLevelData):
				OldLevelData.free()
			
			Time_Left = get_node("LevelData/Time_Left")
			print("Time_Left: " + str(Time_Left))
			if(Time_Left):
				Time_Left.start()
		print("Reloaded to original level data snapshot") 
		if(SnapshotLevelData):
			SnapshotLevelData.free()
		SnapshotLevelData = null
		#print("\nNew tileset layers: " + str(TilesetLayers))
	#for i in range(SaveGame.get_player().LASERS_ENABLED.size()):
	#	SaveGame.get_player().LASERS_ENABLED[i] = false
	#if(Player):
	#	EditorCamera.position = Player.position
	#	Player.editor_reset()
	#for child in get_children():
	#	if(child.is_in_group("Enemie") || child.is_in_group("sand") || child.is_in_group("Laser")):
	#		child.editor_reset()

func _ready() -> void:
	Edition.Is_in_editor = true
	Time_Left.start()
	Time_Left.paused = true
	if(Player):
		Player._set_time_state(false, false)
	
func _process(delta: float) -> void:
	if(OpenedFileDialog && !GlobalFunctions.OpenedFileDialog):
		ButtonHovered = false
	elif(GlobalFunctions.OpenedFileDialog):
		ButtonHovered = true
	OpenedFileDialog = GlobalFunctions.OpenedFileDialog
	if(Player && !Edition.Is_playing_in_editor && (!Time_Left.is_stopped() || !Time_Left.paused) ):
		Player._set_time_state(false, false)
	_play_state_tick()

func set_play_state(state : bool) -> void:
	if(!Paused):
		if(state):
			var _AddedTilesLayer : TileMapLayer = AddedTilesLayers[CurrentAddedTileLayer]
			#_cache_editor_elements_values()
			SaveSnapshotLevelData()
			for _tileset in TilesetLayers:
				EditorPlace._set_visible_tileset(_tileset)
			EditorPlace._set_visible_tileset(_AddedTilesLayer)
		else:
			_reset_play()
	Edition.Is_playing_in_editor = state
	Edition.Is_in_editor = true
	EditorPlayerTrail.Activated = state
	
	Player.Physics = state
	Player.EnemiesPhysics = state
	
	EditorCamera.set_enabled_camera(!state)
	PlayerCamera.enabled = state

func _play_state_tick(ResetAll : bool = false) -> void:
	if(Input.is_action_just_pressed("ui_editor_play") || Input.is_action_just_pressed("ui_editor_pause") ):
		print("Is playing in editor: " + str(Edition.Is_playing_in_editor))
		if(!Edition.Is_playing_in_editor && Input.is_action_just_pressed("ui_editor_pause")):
			return
		set_play_state(!Edition.Is_playing_in_editor)
		
		if(Input.is_action_just_pressed("ui_editor_pause")):
			if(Player):
				Player.Paused = true
			Paused = true
			Time_Left.paused = true
		else:
			if(Edition.Is_playing_in_editor): Time_Left.paused = false
			else:
				Time_Left.start()
				Time_Left.paused = true
			Paused = false
		#Si es que quiere detener de jugar se resetea el estado del jugador
		#if((Input.is_action_just_pressed("ui_editor_play") && !Edition.Is_playing_in_editor) || ResetAll) :
		#	_reset_play()

func _cache_editor_elements_values() -> void:
	pass
	#if(Player): Player.cache_values_editor()
	#for child in get_children():
	#	if(child.is_in_group("Enemie") || child.is_in_group("sand")):
	#		child.cache_values_editor()

func _on_buttonplus_time_pressed() -> void:
	Time_Left.wait_time += 1.0
	Time_Left.start()
	Time_Left.paused = true

func _on_button_minus_time_pressed() -> void:
	Time_Left.wait_time -= 1.0
	Time_Left.start()
	Time_Left.paused = true


func _on_advanced_mode_button_pressed() -> void:
	AdvancedMode = !AdvancedMode

var ButtonHovered : bool = false

func _button_hovered() -> void:
	ButtonHovered = true

func _button_not_hovered() -> void:
	ButtonHovered = false


func go_next_ui_page() -> void:
	CurrentUiPage += 1

func go_previous_ui_page() -> void:
	CurrentUiPage -= 1

func set_page_editor(page : int) -> void:
	CurrentUiPage = page
