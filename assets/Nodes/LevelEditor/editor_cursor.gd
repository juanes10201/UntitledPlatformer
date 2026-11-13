extends Area2D

@onready var LevelEditor = get_parent()
@export var EditorPlace : Node2D

var OnGrid : bool = false

var SelectedNode : int = 0
var SelectedSubNode : int =0

#var OnGrid : bool = true
var GridSize : int = 16
var GridSizeSmall : int = 8

@export var TooltipUi : Node2D

var SelectedSubTile : int = 0
var SelectingLights : bool = false

enum TileTools{
	Pencil = 0,
	Rectangle = 1,
	Slope = 2,
	HalfSlope = 3
}

#La idea es que haya 2 posibles comportamientos
#Uno que funciona en base a un grid 16x16 que seria los de los diferentes tilemaps
#Y el otro consiste en importar diferentes objetos tscn, los cuales pueden ser movidos por el cursor
#y ademas cambiados sus valores @export

func _tick_position(delta: float) -> void:
	#Grid position
	if(LevelEditor.IsTileMapSelected): position = floor(get_global_mouse_position()/GridSize)*GridSize
	elif(OnGrid): position = floor(get_global_mouse_position()/GridSizeSmall)*GridSizeSmall
	else: position = get_global_mouse_position()

func _change_subtile(amount : int = 0) -> void:
	SelectedSubTile += amount
	if(SelectedSubTile >= LevelEditor.SelectableAutotiles.size()):
		SelectedSubTile = 0
	if(SelectedSubTile < 0):
		SelectedSubTile = LevelEditor.SelectableAutotiles.size()-1
	_update_tilemap_layer()

func _update_tilemap_layer(layer : int = LevelEditor.AutotileTilemapLayers[SelectedSubTile]) -> void:
	#print("TILESET LAYERS: " + str(LevelEditor.TilesetLayers))
	EditorPlace.SelectedTilemap = LevelEditor.TilesetLayers[layer]
	EditorPlace.CollidingBody = EditorPlace.SelectedTilemap
	EditorPlace.LastCollidedBody = EditorPlace.SelectedTilemap
	#print(EditorPlace.SelectedTilemap)

func _change_selected_node_next() -> void:
	SelectedNode += 1
	if(SelectedNode > LevelEditor.SelectableObjects.size()):
		SelectedNode = 0

func _change_selected_node_prev() -> void:
	SelectedNode -= 1
	if(SelectedNode < 0):
		SelectedNode = LevelEditor.SelectableObjects.size()

func _ready() -> void:
	pass

func _alt_element(Element : int):
	if(Element > LevelEditor.SelectableObjects.size() && Element != 9): return
	if(Element == 9):
		SelectedNode = Element
		TooltipUi._update_view()
		return
	if(Element != SelectedNode):
		SelectedNode = Element
		SelectedSubNode = 0
		TooltipUi._update_view()
		return
	else:
		if(SelectedNode == 0):
			SelectedSubNode += 1
			if(SelectedSubNode > TileTools.size()-1):
				SelectedSubNode = 0
		else:
			SelectedSubNode += 1
			if(SelectedSubNode > LevelEditor.SelectableObjects[Element-1].size()-1):
				SelectedSubNode = 0
	TooltipUi._update_view()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("Element: " + str(SelectedNode))
	#print("Sub-Element: " + str(SelectedSubNode))
	if(Input.is_action_just_pressed("ui_editor_alt_grid")):
		OnGrid = !OnGrid
	
	if(EditorPlace.CollidingBody):
		$Sprite.play("Select")
	elif(EditorPlace.ExpandYSelected):
		$Sprite.play("SizeY")
	elif(EditorPlace.ExpandXSelected):
		$Sprite.play("SizeX")
	elif(SelectedNode == 0): $Sprite.play("0")
	elif(SelectedNode == 9): $Sprite.play("9")
	else: $Sprite.play(str(SelectedNode) + "_" + str(SelectedSubNode))
	if(Input.is_action_just_pressed("editor_element1")): _alt_element(0)
	if(Input.is_action_just_pressed("editor_element2")): _alt_element(1)
	if(Input.is_action_just_pressed("editor_element3")): _alt_element(2)
	if(Input.is_action_just_pressed("editor_element4")): _alt_element(3)
	if(Input.is_action_just_pressed("editor_element5")): _alt_element(4)
	if(Input.is_action_just_pressed("editor_element6")): _alt_element(5)
	if(Input.is_action_just_pressed("editor_element7")): _alt_element(6)
	if(Input.is_action_just_pressed("editor_element8")): _alt_element(7)
	if(Input.is_action_just_pressed("editor_element9")): _alt_element(8)
	if(Input.is_action_just_pressed("editor_element10")): _alt_element(9)
	_tick_position(delta)


func _on_button_tile_tooltip_0_pressed() -> void:
	_change_subtile(1)


func _on_button_tile_tooltip_1_pressed() -> void:
	_change_subtile(-1)
