extends Node2D

@export var LevelEditor : Node2D
var ExportedLevel : bool = false
@export var LevelPath : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if(Input.is_action_just_pressed("ui_editor_save")): save_level_data()
	pass
