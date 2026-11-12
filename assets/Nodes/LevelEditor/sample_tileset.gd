extends Sprite2D

@onready var tile_size = 16*scale

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

func _update_pos() -> void:
	if(_cursor_is_in_pos()):
		var _pos_cursor : Vector2 = get_global_mouse_position()
		var _pivot : Vector2 = _get_initial_pos() 
		
		var _pos = floor((_pos_cursor-_pivot)/tile_size)*tile_size+_pivot
		var _index : Vector2i = round((_pos-_pivot)/tile_size)
		$SelectUpperLeft.global_position = _pos
		$SelectUpperLeft.show()
	else:
		$SelectUpperLeft.hide()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_update_pos()
