extends Sprite2D

@onready var tile_size = 16*scale
@export var EditorPlace : Node2D
@export var LevelEditor : Node2D
var Enabled : bool = false

func _get_initial_pos() -> Vector2:
	var _center : Vector2 = global_position
	var _size : Vector2 = texture.get_size()*scale
	return _center - _size/2 + tile_size/2

func _get_final_pos() -> Vector2:
	var _center : Vector2 = global_position
	var _size : Vector2 = texture.get_size()*scale
	return _center + _size/2 + tile_size/2

func _cursor_is_in_pos() -> bool:
	var _pos_cursor : Vector2 = get_global_mouse_position()
	var _fst_pos = _get_initial_pos()
	var _snd_pos = _get_final_pos()
	var _is_in_x : bool = _pos_cursor.x >= _fst_pos.x && _pos_cursor.x <= _snd_pos.x 
	var _is_in_y : bool = _pos_cursor.y >= _fst_pos.y && _pos_cursor.y <= _snd_pos.y 
	return _is_in_x && _is_in_y

var Hovering : bool = false
var SelectingInitialIndex : Vector2i
var SelectingIndex : Vector2i

func _update_pos() -> void:
	#if(!LevelEditor.ButtonHovered || Hovering):
	if(_cursor_is_in_pos()):
		Hovering = true
		LevelEditor.ButtonHovered = true
		var _pos_cursor : Vector2 = get_global_mouse_position()
		var _pivot : Vector2 = _get_initial_pos() 
		
		var _pos = floor((_pos_cursor-_pivot)/tile_size)*tile_size+_pivot
		var _index : Vector2i = round((_pos-_pivot)/tile_size)
		
		$Select.global_position = _pos
		$Select.show()
		if(Input.is_action_pressed("ui_click")):
			$SelectDownRight.global_position = _pos
			$SelectDownRight.show()
			SelectingIndex = _index
			EditorPlace.CustomTilesSelected.clear()
			EditorPlace.CustomTilesSelected.append(SelectingInitialIndex)
			EditorPlace.CustomTilesSelected.append(SelectingIndex)
		if(Input.is_action_just_pressed("ui_click")):
			$SelectUpperLeft.show()
			$SelectUpperLeft.global_position = $SelectDownRight.global_position
			SelectingInitialIndex = _index
			EditorPlace.CustomTileSelected = true
		#print("Index: " + str(EditorPlace.CustomTilesSelected))
		
	else:
		$Select.hide()
		#$SelectUpperLeft.hide()
		#$SelectDownRight.hide()
		if(Hovering): LevelEditor.ButtonHovered = false
		Hovering = false

func _process(delta: float) -> void:
	Enabled = LevelEditor.CurrentUiPage == 1
	visible = Enabled
	if(Enabled):
		_update_pos()

func _ready() -> void:
	pass
