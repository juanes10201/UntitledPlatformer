extends CanvasLayer

@export var NodeTextUsers : Node2D

func _ready() -> void:
	var _i := 0
	for Usertext in NodeTextUsers.get_children():
		_i += 1
		Usertext.set_user_data("test", _i, 1.0)
	
