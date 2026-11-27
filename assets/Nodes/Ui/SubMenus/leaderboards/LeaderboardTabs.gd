extends Button

@onready var MainUiLeaderboards : CanvasLayer = get_parent().get_parent()
@export var id : int = 0

func _process(delta: float) -> void:
	if(MainUiLeaderboards.World == id):
		modulate.a = 1.0
	else:
		modulate.a = 0.0

func _on_pressed() -> void:
	print("Changing world to: " + str(id))
	MainUiLeaderboards.World = id
	MainUiLeaderboards.Level = 0
	MainUiLeaderboards.CurrentPage = 0
	MainUiLeaderboards._update_best_scores()
