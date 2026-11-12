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

@export var AddedTilesLayer : TileMapLayer

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

func SaveSnapshotLevelDataPaths() -> void:
	LevelDataRecursiveNodePaths = {}
	SelfRecursiveNodePaths = {}
	var LevelDataChildNodes : Array = _get_all_nodes(self) 
	#LevelDataChildNodes.append(_get_all_nodes(get_level_data_gameplay_objects_node() ) )
	#LevelDataChildNodes.append(self)
	for _node in LevelDataChildNodes:
		for prop in _node.get_property_list():
			if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
				continue
			var _val = _node.get(prop.name)
			if _val && _val is Node && _val.is_inside_tree() && !(_val in LevelDataRecursiveNodePaths):
				var _path = _val.get_path()
				#Se guarda que la posicion del asset del puntero dado es la del dicc
				LevelDataRecursiveNodePaths[_val] = _path
	for prop in get_property_list():
		#if(prop.usage & PROPERTY_USAGE_EDITOR && prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
		var _val = get(prop.name)
		if _val && _val is Node && _val.is_inside_tree() && !(_val in SelfRecursiveNodePaths):
			var _path = _val.get_path()
			SelfRecursiveNodePaths[_val] = _path
	for TilesetLayer in TilesetLayers:
		if(TilesetLayer):
			var _path = TilesetLayer.get_path()
			SelfRecursiveNodePaths[TilesetLayer] = _path
	#print("Saved Paths: " + str(SelfRecursiveNodePaths))

func LoadSnapshotLevelDataPaths() -> void:
	#print("leveldata: " + str(LevelData))
	var LevelDataChildNodes : Array = _get_all_nodes(self)
	#LevelDataChildNodes.append(self)
	for _node in LevelDataChildNodes:
		for prop in _node.get_property_list():
			var _val = _node.get(prop.name)
			#if _val && _val is Node && _val.is_inside_tree() && _val in LevelDataRecursiveNodePaths:
			#	var _new_node_ref : Node = get_node(LevelDataRecursiveNodePaths[_val])
			#	_node.set(prop.name, _new_node_ref)
				#print("Loaded node: "  + str(_new_node_ref) + " from " + str(_node))
			if _val && _val is Node && _val in LevelDataRecursiveNodePaths:
				var _path = LevelDataRecursiveNodePaths[_val]
				if has_node(_path):
					_node.set(prop.name, get_node(_path))
	for prop in get_property_list():
		var _val = get(prop.name)
		if _val && _val is Node && _val in SelfRecursiveNodePaths:
			var _new_node_ref : Node = get_node(SelfRecursiveNodePaths[_val])
			set(prop.name, _new_node_ref)
	
	for child in get_children():
		if(child.is_in_group("LevelData")):
			LevelData = child
	 
	for i in range(TilesetLayers.size()):
		var TilesetLayer : TileMapLayer = TilesetLayers[i]
		if(TilesetLayer in SelfRecursiveNodePaths):
			var _node = get_node(SelfRecursiveNodePaths[TilesetLayer] )
			TilesetLayers[i] = _node
	EditorPlace.SelectedTilemap = TilesetLayers[0]
	
	LevelDataRecursiveNodePaths = {}
	#Player = get_node("LevelData/Player")
	#Time_Left = get_node("LevelData/Time_Left")
	#PlayerCamera = get_node()
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
			#_cache_editor_elements_values()
			SaveSnapshotLevelData()
			for _tileset in TilesetLayers:
				EditorPlace._set_visible_tileset(_tileset)
			EditorPlace._set_visible_tileset(AddedTilesLayer)
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
