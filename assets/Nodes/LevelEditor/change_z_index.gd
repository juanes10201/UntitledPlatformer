extends Sprite2D
@export var EditorPlace : Node2D
@export var LevelEditor : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _next_z_index() -> void:
	EditorPlace.go_next_custom_tileset()
	$TextZIndex.text = str(LevelEditor.CurrentAddedTileLayer)

func _previous_z_index() -> void:
	EditorPlace.go_previous_custom_tileset()
	$TextZIndex.text = str(LevelEditor.CurrentAddedTileLayer)
