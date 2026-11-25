extends CanvasLayer

@export var NodeTextUsers : Node2D
@export var CurrentPage : int = 0
@onready var PageSize : int = NodeTextUsers.get_child_count()
@export var Level : int = 1
@export var World : int = 0 

var scoreboard_process_thread : Thread
func _update_best_scores(_level : int = Level, _world : int = World) -> void:
	scoreboard_process_thread = Thread.new()
	scoreboard_process_thread.start(_update_scoreboards_thread.bind(_level,_world) )

func _update_scoreboards_thread(_level : int = Level, _world : int = World) -> void:
	NodeTextUsers.hide()
	var _initial_range = CurrentPage*PageSize
	var _end_range = _initial_range+PageSize
	var results = await SaveGame.leaderboard_load_level_parse_to_ingame_ui_ranged(_level, _world, _initial_range, _end_range)
	print("results: ")
	print(str(results))
	for i in range(PageSize):
		var Usertext : Node2D = NodeTextUsers.get_child(i)
		Usertext.visible = i < results.size()
		if(i < results.size()):
			var Userdata : Dictionary = results[i]
			Usertext.set_user_data(Userdata.name, Userdata.rank, Userdata.score)
	NodeTextUsers.show()

func _ready() -> void:
	_update_best_scores()
