extends Node2D

var SelectedTilemap : TileMapLayer
@export var EditorCursor : Node2D

@onready var LevelEditor = get_parent()

@export var SpriteFill1 : Sprite2D
@export var SpriteFill2 : Sprite2D

var LastCollidedBody : Node2D

var SelectingMultiple : bool = false

var AreaSelectOriginalPositions : Array[Vector2] = []
var AreaSelectOriginalPos : Vector2 = Vector2(0.0, 0.0)
@export var AreaSelectMultiple : Area2D

@export var TilesetTempCopy : TileMapLayer

@export var EditorDataParser : Node2D

func _reset_select_multiple() -> void:
	SpriteFill1.hide()
	SpriteFill2.hide()
	SelectingMultiple = false
	SelectedNodes = []
	MultipleMovingSelecting = false
	MultipleMadeSelection = false
	AreaSelectOriginalPositions = []
	AreaSelectOriginalPos = Vector2(0.0, 0.0)

var MultipleMadeSelection : bool = false
var MultipleMovingSelecting : bool = false

func _select_area_tick() -> void:
	var box_x : float = abs(SpriteFill1.global_position.x - SpriteFill2.global_position.x)/2
	var box_y : float = abs(SpriteFill1.global_position.y - SpriteFill2.global_position.y)/2
	AreaSelectMultiple.Collision_Shape.shape.extents = Vector2(box_x, box_y)
	
	AreaSelectMultiple.global_position.x = SpriteFill1.global_position.x - (SpriteFill1.global_position.x-SpriteFill2.global_position.x)/2
	AreaSelectMultiple.global_position.y = SpriteFill1.global_position.y - (SpriteFill1.global_position.y-SpriteFill2.global_position.y)/2

func _multiple_moving_select_visuals() -> void:
	SpriteFill1.show()
	SpriteFill2.show()
	
	SpriteFill1.global_position = AreaSelectMultiple.global_position
	SpriteFill1.global_position.x -= AreaSelectMultiple.Collision_Shape.shape.extents.x
	SpriteFill1.global_position.y -= AreaSelectMultiple.Collision_Shape.shape.extents.y
	
	SpriteFill2.global_position = AreaSelectMultiple.global_position
	SpriteFill2.global_position.x += AreaSelectMultiple.Collision_Shape.shape.extents.x
	SpriteFill2.global_position.y += AreaSelectMultiple.Collision_Shape.shape.extents.y
	
	AreaSelectMultiple.global_position = EditorCursor.global_position

func _selecting_multiple() -> void:
	#print(SelectedNodes)
	AreaSelectMultiple.monitoring = SelectingMultiple
	AreaSelectMultiple.Collision_Shape.disabled = !SelectingMultiple
	if(Input.is_action_just_pressed("ui_editor_erase")):
		if(MultipleMadeSelection):
			for node in SelectedNodes:
				_delete_node(node)
				_reset_select_multiple()
	if(Input.is_action_just_pressed("ui_editor_place")):
		if(MultipleMadeSelection && CollidingBody && CollidingBody.is_in_group("AreaSelectMultiple")):
			MultipleMovingSelecting = true
		else:
			_reset_select_multiple()
	if(Input.is_action_pressed("ui_editor_place")):
		if(MultipleMovingSelecting):
			_multiple_moving_select_visuals()
			var Dif_pos : Vector2 = AreaSelectMultiple.global_position-AreaSelectOriginalPos
			for i in range(SelectedNodes.size()):
				SelectedNodes[i].global_position = AreaSelectOriginalPositions[i]+Dif_pos
	if(Input.is_action_pressed("ui_editor_multiple_select")):
		if(Input.is_action_just_pressed("ui_editor_place")):
			SelectingMultiple = true
			RectanglePos1 = EditorCursor.global_position
			SpriteFill1.global_position = RectanglePos1
			SpriteFill2.global_position = EditorCursor.global_position
			SpriteFill1.show()
			SpriteFill2.show()
		if(Input.is_action_pressed("ui_editor_place")):
			SpriteFill2.global_position = EditorCursor.global_position
			#AreaSelectMultiple.global_position = SpriteFill1.global_position
			
			_select_area_tick()
		elif(Input.is_action_just_released("ui_editor_place")):
			MultipleMadeSelection = true
			AreaSelectOriginalPos = AreaSelectMultiple.global_position
			for Selected in SelectedNodes:
				AreaSelectOriginalPositions.append(Selected.global_position)

func _convert_coordinates_to_local(pos : Vector2) -> Vector2i:
	var _pos_local = SelectedTilemap.to_local(pos)
	var tile_pos: Vector2i = SelectedTilemap.local_to_map(_pos_local)
	return tile_pos

func _place_tile_terrain_local_pos(pos : Vector2i, tilemap : TileMapLayer = SelectedTilemap, terrainset : int = EditorCursor.SelectedSubTile, subset : int = 0):
	if(SelectedTilemap.get_cell_source_id(pos) == -1):
		GlobalFunctions.record_action(GlobalFunctions.FUNCTIONS.Create_tile_local, pos, pos, SelectedTilemap)
	tilemap.set_cells_terrain_connect([pos], terrainset, subset, false)

func _place_tile_terrain_global_pos(pos : Vector2):
	var _pos_local = SelectedTilemap.to_local(pos)
	var tile_pos: Vector2i = SelectedTilemap.local_to_map(_pos_local)
	_place_tile_terrain_local_pos(tile_pos)

func _erase_tile_terrain_local_pos(pos : Vector2i):
	SelectedTilemap.set_cells_terrain_connect([pos], EditorCursor.SelectedSubTile, -1)

func _erase_tile_terrain_global_pos(pos : Vector2i):
	var _pos_local = SelectedTilemap.to_local(pos)
	var tile_pos: Vector2i = SelectedTilemap.local_to_map(_pos_local)
	_erase_tile_terrain_local_pos(tile_pos)

var PreparingRectangle : bool = false
var PreparingRemoveRectangle : bool = false
var RectanglePos1 : Vector2 = Vector2(0.0, 0.0)
var RectanglePos2 : Vector2 = Vector2(0.0, 0.0)

func _fill_slope_global_tileset(pos1 : Vector2, pos2 : Vector2, RemoveTiles : bool = false, CalcAngleY : float = PreCalcAngleY, AutotileTerrain : int = 1) -> void:
	var _pos_local1 = SelectedTilemap.to_local(pos1)
	var tile_pos1: Vector2i = SelectedTilemap.local_to_map(_pos_local1)
	
	var _pos_local2 = SelectedTilemap.to_local(pos2)
	var tile_pos2: Vector2i = SelectedTilemap.local_to_map(_pos_local2)
	
	_fill_slope_local_tileset(tile_pos1, tile_pos2, RemoveTiles, CalcAngleY, AutotileTerrain)

func _fill_slope_local_tileset(pos1 : Vector2, pos2 : Vector2, RemoveTiles : bool = false, CalcAngleY : float = PreCalcAngleY, AutotileTerrain : int = 1) -> void:
	var Cells : Array[Vector2i]
	#print("pos1: " + str(pos1))
	#print("pos2: " + str(pos2))
	#print(PreCalcAngleY)
	for x in range(pos1.x, pos2.x):
		var _posY : float = ceil(pos1.y - CalcAngleY*(x-pos1.x))
		var Cell : Vector2i = Vector2i(x, _posY)
		#var UpperCell : Vector2i = Vector2i(x, _posY-1)
		Cells.append(Cell)
		#Cells.append(UpperCell)
	#if(Cells.size() > 0):
	#	Cells.append(Vector2i(Cells[0].x+1, Cells[0].y) )
	if(!RemoveTiles):
		SelectedTilemap.set_cells_terrain_connect(Cells, 0,  AutotileTerrain, false)
	else:
		SelectedTilemap.set_cells_terrain_connect(Cells, 0, -1)

func _fill_rectangle_global_tileset(pos1 : Vector2, pos2 : Vector2, RemoveTiles : bool = false) -> void:
	#Convertir las 2 posiciones a posiciones locales que entienda el tilemap
	var _pos_local1 = SelectedTilemap.to_local(pos1)
	var tile_pos1: Vector2i = SelectedTilemap.local_to_map(_pos_local1)
	
	var _pos_local2 = SelectedTilemap.to_local(pos2)
	var tile_pos2: Vector2i = SelectedTilemap.local_to_map(_pos_local2)
	
	_fill_rectangle_local_tileset(tile_pos1, tile_pos2, RemoveTiles)

func _fill_rectangle_local_tileset(pos1 : Vector2i, pos2 : Vector2i, RemoveTiles : bool = false) -> void:
	var min_pos : Vector2i = pos1 if pos1 < pos2 else pos2
	var max_pos : Vector2i = pos1 if pos1 > pos2 else pos2
	print("Pos1: " + str(pos1))
	print("Pos2: " + str(pos2))
	#Poner cada tile en la lista para luego enviarlo a pintar
	var Cells : Array[Vector2i]
	
	for x in range(min_pos.x, max_pos.x+1):
		for y in range(min_pos.y, max_pos.y+1):
			var Cell : Vector2i = Vector2i(x, y)
			Cells.append(Cell)
	if(!RemoveTiles):
		SelectedTilemap.set_cells_terrain_connect(Cells, EditorCursor.SelectedSubTile, 0)
	else:
		SelectedTilemap.set_cells_terrain_connect(Cells, EditorCursor.SelectedSubTile, -1)

#Angulo de la rampa
var SlopeAngle : float = 22.5
var PreCalcAngleY = .5#tan(deg_to_rad(SlopeAngle))
var HalfSlopeSlopeAngle : float = 22.5
var HalfSlopePreCalcAngleY = 1.0

var TilesetSelection : Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.0, 0.0)]

func _copy_ranged_tiles_to_temp(ReferencePos : Vector2i, pos1 : Vector2i, pos2 : Vector2i, Tilemap : TileMapLayer):
	var TilePos : Array[Vector2i]
	for x in range(pos1.x, pos2.x):
		for y in range(pos1.y, pos2.y):
			TilePos.append(Vector2i(x, y))
	_copy_tiles_to_temp(ReferencePos, TilePos, Tilemap)

func _copy_cell(FromPos : Vector2i, ToPos : Vector2i,  TileMapFrom : TileMapLayer, TileMapTo : TileMapLayer):
	#TileMapTo.set_cell(ToPos, TileMapFrom.get_cell_source_id(FromPos), TileMapFrom.get_cell_atlas_coords(FromPos), TileMapFrom.get_cell_alternative_tile(FromPos))
	_place_tile_terrain_local_pos(ToPos, TileMapTo)

func _copy_back_tiles(ToPos : Vector2i):
	if(TilesetTempCopy):
		var TilesPos : Array[Vector2i] = TilesetTempCopy.get_used_cells() 
		for Pos in TilesPos:
			_copy_cell(Pos, ToPos+Pos, TilesetTempCopy, SelectedTilemap)
		TilesetTempCopy.clear()

func _copy_tiles_to_temp(ReferencePos : Vector2i, TilePos : Array[Vector2i], Tilemap : TileMapLayer):
	TilesetTempCopy.clear()
	for Pos in TilePos:
		var Tile = Tilemap.get_cell_tile_data(Pos)
		var NewPos = Vector2i(Pos.x - ReferencePos.x, Pos.y - ReferencePos.y)
		if(Tilemap.get_cell_tile_data(Pos)):
			_copy_cell(Pos, NewPos, Tilemap, TilesetTempCopy)
			_erase_tile_terrain_local_pos(Pos)
	#debe copiar datos de tiles contenidos en la posicion local dada, y
	#pegarlos en base a la posicion 0 local del tilemap temp
	#TilesetTempCopy

func _select_multiple_tileset(delta: float):
	#copy tiles
	if(SelectingMultiple && Input.is_action_just_pressed("ui_copy")):
		var TilePos : Array[Vector2i] = []
		var Pos1 : Vector2i = _convert_coordinates_to_local(SpriteFill1.global_position)
		var Pos2 : Vector2i = _convert_coordinates_to_local(SpriteFill2.global_position)
		for x in range(Pos1.x, Pos2.x):
			for y in range(Pos1.y, Pos2.y):
				if(SelectedTilemap.get_cell_tile_data(Vector2i(x,y) )):
					TilePos.append(Vector2i(x, y))
		#print(TilePos)
		EditorDataParser.SaveDataTileToClipboard(TilePos, SelectedTilemap, EditorDataParser.Clipboard)
	if(Input.is_action_pressed("ui_editor_place")):
		if(MultipleMadeSelection && CollidingBody && CollidingBody.is_in_group("AreaSelectMultiple")):
			if(!MultipleMovingSelecting):
				MultipleMovingSelecting = true
				print("Selecting multiple tiles")
				_copy_ranged_tiles_to_temp(_convert_coordinates_to_local(SpriteFill1.global_position), _convert_coordinates_to_local(SpriteFill1.global_position), _convert_coordinates_to_local(SpriteFill2.global_position), SelectedTilemap)
			TilesetTempCopy.global_position = SpriteFill1.global_position
			_multiple_moving_select_visuals()
	elif(MultipleMovingSelecting):
		_copy_back_tiles(_convert_coordinates_to_local(SpriteFill1.global_position))
		MultipleMovingSelecting = false
	if(Input.is_action_pressed("ui_editor_multiple_select") && Input.is_action_just_pressed("ui_editor_place")):
		AreaSelectMultiple.Collision_Shape.disabled = false
		MultipleMadeSelection = false
		SelectingMultiple = false
		#if(!SelectingMultiple):
		SpriteFill1.show()
		SpriteFill2.show()
		SpriteFill1.global_position = EditorCursor.global_position
		SelectingMultiple = true
	if(Input.is_action_pressed("ui_editor_multiple_select") && SelectingMultiple):
		SpriteFill2.global_position = EditorCursor.global_position
		_select_area_tick()
	else:
		if(SelectingMultiple):
			MultipleMadeSelection = true
			TilesetSelection[0] = SpriteFill1.global_position
			TilesetSelection[1] = SpriteFill2.global_position
		else: SelectingMultiple = false

func _tick_tileset(delta: float):
	if(Input.is_action_just_pressed("ui_paste")):
		EditorDataParser.LoadDataTiles(SelectedTilemap, EditorDataParser.Clipboard)
	if(Input.is_action_just_pressed("ui_editor_cancel_action")):
		SelectingBody = false
		CollidingBody = null
		SelectingMultiple = false
		MultipleMadeSelection = false
		MultipleMovingSelecting = false
		_reset_select_multiple()
	
	_select_multiple_tileset(delta)
	if(SelectingMultiple || Input.is_action_pressed("ui_editor_multiple_select")): return
	if(EditorCursor.SelectedSubNode == EditorCursor.TileTools.Pencil):
		if(Input.is_action_pressed("ui_editor_place") ):
			_place_tile_terrain_global_pos(get_global_mouse_position())
		elif(Input.is_action_pressed("ui_editor_erase") ):
			_erase_tile_terrain_global_pos(get_global_mouse_position())
	elif(EditorCursor.SelectedSubNode == EditorCursor.TileTools.Rectangle):
		#Visuales
		if(PreparingRectangle || PreparingRemoveRectangle):
			SpriteFill1.global_position = RectanglePos1
			SpriteFill2.global_position = EditorCursor.global_position
			SpriteFill1.show()
			SpriteFill2.show()
		
		#Iniciar forma de rectangulo
		if(Input.is_action_just_pressed("ui_editor_place") ):
			PreparingRectangle = true
			#Posicion 1 del rectangulo, la posicion 2 sera la final
			RectanglePos1 = EditorCursor.global_position
		#Al soltar crear el rectangulo
		elif(PreparingRectangle && !Input.is_action_pressed("ui_editor_place") ):
			RectanglePos2 = EditorCursor.global_position
			PreparingRectangle = false
			_fill_rectangle_global_tileset(RectanglePos1, RectanglePos2, false)
			SpriteFill1.hide()
			SpriteFill2.hide()
		
		#Lo mismo pero para eliminar
		if(Input.is_action_just_pressed("ui_editor_erase") ):
			PreparingRemoveRectangle = true
			#Posicion 1 del rectangulo, la posicion 2 sera la final
			RectanglePos1 = EditorCursor.global_position
		#Al soltar crear el rectangulo
		elif(PreparingRemoveRectangle && !Input.is_action_pressed("ui_editor_erase") ):
			RectanglePos2 = EditorCursor.global_position
			PreparingRemoveRectangle = false
			_fill_rectangle_global_tileset(RectanglePos1, RectanglePos2, true)
			SpriteFill1.hide()
			SpriteFill2.hide()
	elif(EditorCursor.SelectedSubNode == EditorCursor.TileTools.Slope || EditorCursor.SelectedSubNode == EditorCursor.TileTools.HalfSlope):
		if(PreparingRectangle || PreparingRemoveRectangle):
			SpriteFill1.global_position = RectanglePos1
			SpriteFill2.global_position.x = EditorCursor.global_position.x
			if(EditorCursor.SelectedSubNode == EditorCursor.TileTools.Slope):
				SpriteFill2.global_position.y = SpriteFill1.global_position.y - PreCalcAngleY*abs(SpriteFill1.global_position.x - SpriteFill2.global_position.x)
			else:
				SpriteFill2.global_position.y = SpriteFill1.global_position.y - HalfSlopePreCalcAngleY*abs(SpriteFill1.global_position.x - SpriteFill2.global_position.x)
			SpriteFill1.show()
			SpriteFill2.show()
		if(Input.is_action_just_pressed("ui_editor_place") ):
			PreparingRectangle = true
			#Posicion 1 del rectangulo, la posicion 2 sera la final
			RectanglePos1 = EditorCursor.global_position
		elif(PreparingRectangle && !Input.is_action_pressed("ui_editor_place") ):
			#RectanglePos2 = EditorCursor.global_position
			PreparingRectangle = false
			#print("Filling slope")
			if(EditorCursor.SelectedSubNode == EditorCursor.TileTools.Slope):
				_fill_slope_global_tileset(SpriteFill1.global_position, SpriteFill2.global_position, false)
			else:
				_fill_slope_global_tileset(SpriteFill1.global_position, SpriteFill2.global_position, false, HalfSlopePreCalcAngleY, 2)
			SpriteFill1.hide()
			SpriteFill2.hide()
		
		if(Input.is_action_just_pressed("ui_editor_erase") ):
			PreparingRemoveRectangle = true
			#Posicion 1 del rectangulo, la posicion 2 sera la final
			RectanglePos1 = EditorCursor.global_position
		elif(PreparingRemoveRectangle && !Input.is_action_pressed("ui_editor_erase") ):
			#RectanglePos2 = EditorCursor.global_position
			PreparingRemoveRectangle = false
			#print("Filling slope")
			_fill_slope_global_tileset(SpriteFill1.global_position, SpriteFill2.global_position, true)
			SpriteFill1.hide()
			SpriteFill2.hide()

func _delete_node(node : Node2D):
	if(node && !node.is_in_group("CantBeDeletedInEditor") && !node.is_in_group("Player") && !node.is_in_group("YExpandEditor") && !node.is_in_group("XExpandEditor")):
		node.queue_free()

var LastPositionSelectedBody : Vector2 = Vector2(0.0, 0.0)

func _tick_nodes(delta: float):
	if(EditorCursor.SelectedNode == 0): return
	if(CollidingBody && (CollidingBody is TileMap || CollidingBody is TileMapLayer)): CollidingBody = null
	
	if(Input.is_action_just_pressed("ui_editor_cancel_action")):
		SelectingBody = false
		CollidingBody = null
		_reset_select_multiple()
	
	_selecting_multiple()
	if(SelectingMultiple): return
	#print(CollidingBody)
	if(Input.is_action_pressed("ui_editor_place")):
		if(CollidingBody):
			if(!SelectingBody): LastPositionSelectedBody = CollidingBody.global_position
			LastCollidedBody = CollidingBody
			ExpandingY = false
			ExpandingX = false
			ExpandingOriginalPos = Vector2(0.0,0.0)
			#Selecting a node
			SelectingBody = true
			CollidingBody.global_position = EditorCursor.global_position
			#print("moving")
		elif(ExpandYSelected):
			if(ExpandYSelected.is_in_group("Killbox")):
				ExpandYSelected.Sprite.material.set_shader_parameter("tile_size", ExpandYSelected.scale)
			ExpandingY = true
			ExpandYSelected.scale.y = ExpandingOriginalSize+abs(ExpandingOriginalPos.y-EditorCursor.global_position.y)/14
			#if(EditorCursor.OnGrid):
				#ExpandXSelected.scale.y = floor(ExpandXSelected.scale.y/EditorCursor.GridSizeSmall)*EditorCursor.GridSizeSmall
			if(!ExpandingOriginalPos):
				ExpandingOriginalPos = EditorCursor.global_position
		elif(ExpandXSelected):
			if(ExpandXSelected.is_in_group("Killbox")): ExpandXSelected.Sprite.material.set_shader_parameter("tile_size", ExpandXSelected.scale)
			ExpandingX = true
			ExpandXSelected.scale.x = ExpandingOriginalSize+abs(ExpandingOriginalPos.x-EditorCursor.global_position.x)/14
			#if(EditorCursor.OnGrid):
			#	ExpandXSelected.scale.x = floor(ExpandXSelected.scale.x/EditorCursor.GridSizeSmall)*EditorCursor.GridSizeSmall
			if(!ExpandingOriginalPos):
				ExpandingOriginalPos = EditorCursor.global_position
		#Create node
		elif(Input.is_action_just_pressed("ui_editor_place") && EditorCursor.SelectedNode != 9):
			ExpandingY = false
			ExpandingX = false
			ExpandingOriginalPos = Vector2(0.0,0.0)
			
			create_node(EditorCursor.SelectedNode-1, EditorCursor.SelectedSubNode)
	#Selecting Node
	elif(Input.is_action_pressed("ui_editor_erase") && CollidingBody):
		_delete_node(CollidingBody)
	elif(CollidingBody && SelectingBody):
		SelectingBody = false
		GlobalFunctions.record_action(GlobalFunctions.FUNCTIONS.Move_node, LastPositionSelectedBody, CollidingBody.global_position, CollidingBody)
	if(!Input.is_action_pressed("ui_editor_place") && ExpandingY):
		#print("yes")
		ExpandingY = false
		ExpandYSelected = null
		ExpandingOriginalPos = Vector2(0.0,0.0)
	if(!Input.is_action_pressed("ui_editor_place") && ExpandingX):
		ExpandingX = false
		ExpandXSelected = null
		ExpandingOriginalPos = Vector2(0.0,0.0)
	#print("Expanding y: " + str(ExpandYSelected))
	#print("Expanding X: " + str(ExpandXSelected))
	#print("SelectingBody: " + str(SelectingBody))

const NewNodeMetaNumber : String = "EditorNodeNumber"
const NewNodeMetaSubNumber : String = "EditorSubNodeNumber"

var SelectableNodesLoaded: Array[Array] = []

func _initial_instatiate_nodes() -> void:
	var category_n : int = 0
	for category in LevelEditor.SelectableObjects:
		SelectableNodesLoaded.append([])
		for _path in category:
			var _loadednode = load(_path)
			if(_loadednode):
				SelectableNodesLoaded[category_n].append(_loadednode)
		category_n += 1
	#print("Cache in memory of nodes: " + str(SelectableNodesLoaded))

func create_node(NodeNumber : int, SubNodeNumber : int) -> void:
	var _node = SelectableNodesLoaded[NodeNumber][SubNodeNumber]
	#var NewNode = GlobalFunctions.Copy_and_Instatiate_node2d(_node, LevelEditor.get_level_data_gameplay_objects_node())
	var NewNode = GlobalFunctions.Create_node2d(LevelEditor.SelectableObjects[NodeNumber][SubNodeNumber], LevelEditor.get_level_data_gameplay_objects_node())
	
	if(NewNode):
		NewNode.global_position = EditorCursor.global_position
		NewNode.set_meta(NewNodeMetaNumber, NodeNumber)
		NewNode.set_meta(NewNodeMetaSubNumber, SubNodeNumber)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initial_instatiate_nodes()
	EditorCursor._update_tilemap_layer()

var ExpandingY : bool = false
var ExpandYSelected : Node2D = null
var ExpandingX : bool = false
var ExpandXSelected : Node2D = null
var ExpandingOriginalPos : Vector2 = Vector2(0.0, 0.0)
var ExpandingOriginalSize : float = 0.5

@export var RewindTimer : Timer
const RewindTimerWait : float = .3
const RewindTimerWaitLess : float = .05

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(ImGui.IsWindowHovered(ImGui.HoveredFlags_AnyWindow) || LevelEditor.ButtonHovered): return
	
	if(Input.is_action_just_pressed("ui_editor_load_file")):
		EditorDataParser.LoadData("res://assets/Saved/LevelEditor/saveleveltest.json", SelectedTilemap)
	#if(Input.is_action_just_pressed("ui_editor_save")):
		#print(TilePos)
	
	#print(EditorCursor.SelectedNode)
	LevelEditor.IsTileMapSelected = (EditorCursor.SelectedNode == 0)
	#print(CollidingBody)
	if(LevelEditor.IsTileMapSelected): _tick_tileset(delta)
	else: _tick_nodes(delta)
	if(Input.is_action_pressed("ui_editor_rewind")):
		if(RewindTimer.is_stopped()):
			GlobalFunctions.rewind_action()
			RewindTimer.start()
		RewindTimer.wait_time = lerp(RewindTimer.wait_time, RewindTimerWaitLess, 3*delta)
	elif(!Input.is_action_pressed("ui_editor_rewind")):
		RewindTimer.wait_time = RewindTimerWait

var CollidingBody : Node2D = null
var SelectingBody : bool = false

func _on_editor_cursor_body_entered(body: Node2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		CollidingBody = body
		#LastCollidedBody = CollidingBody


func _on_editor_cursor_body_exited(body: Node2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		#if(CollidingBody == body): CollidingBody = null
		CollidingBody = null


func _on_editor_cursor_area_entered(area: Area2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		if(area.is_in_group("YExpandEditor")):
			ExpandYSelected = area.get_parent().get_parent()
		if(area.is_in_group("XExpandEditor")):
			ExpandXSelected = area.get_parent().get_parent()
		if(!area.is_in_group("XExpandEditor") && !area.is_in_group("YExpandEditor")):
			CollidingBody = area
			#LastCollidedBody = CollidingBody


func _on_editor_cursor_area_exited(area: Area2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		#if(CollidingBody != area && ExpandYSelected != area && ExpandXSelected != area ): return
		if(area.is_in_group("YExpandEditor")):
			ExpandYSelected = null
		if(area.is_in_group("XExpandEditor")):
			ExpandXSelected = null
		elif(CollidingBody == area): CollidingBody = null 


#region Selecting Area body
var SelectedNodes : Array[Node2D]

func _on_editor_ui_selecting_multiple_body_entered(body: Node2D) -> void:
	if(SelectingMultiple && !MultipleMadeSelection):
		SelectedNodes.append(body)


func _on_editor_ui_selecting_multiple_body_exited(body: Node2D) -> void:
	#print("sample: " + str(body.name))
	if(SelectingMultiple && !MultipleMadeSelection):
		for i in range(SelectedNodes.size()):
			#print("i: " + str(SelectedNodes[i].name))
			if(i >= SelectedNodes.size()): return
			if(body.name == SelectedNodes[i].name):
				#print("yes")
				SelectedNodes.remove_at(i)

func _on_editor_ui_selecting_multiple_area_entered(area: Area2D) -> void:
	if(SelectingMultiple && !MultipleMadeSelection):
		SelectedNodes.append(area)


func _on_editor_ui_selecting_multiple_area_exited(area: Area2D) -> void:
	#print("sample: " + str(area.name))
	if(SelectingMultiple && !MultipleMadeSelection):
		for i in range(SelectedNodes.size()):
			#print("i: " + str(SelectedNodes[i].name))
			if(area.name == SelectedNodes[i].name):
				SelectedNodes.remove_at(i)

#endregion
