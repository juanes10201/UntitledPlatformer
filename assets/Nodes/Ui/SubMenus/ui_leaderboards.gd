extends CanvasLayer

@export var NodeTextUsers : Node2D
@export var TabTitleText : RichTextLabel
@export var TabTitle : String = "BEST TIMES -"
@export var CurrentPage : int = 0
@onready var PageSize : int = NodeTextUsers.get_child_count()
@export var Level : int = 0
@export var World : int = 0 

@export var ButtonNextLevel : TextureButton
@export var ButtonPrevLevel : TextureButton
@export var ButtonNextPage : TextureButton
@export var ButtonPrevPage : TextureButton

var CurrentAmountPages : int = 1

var scoreboard_process_thread : Thread
func _update_best_scores(_level : int = Level, _world : int = World) -> void:
	TabTitleText.text = TabTitle + " Level " + str(_level) + " World " + str(_world)
	#scoreboard_process_thread = Thread.new()
	#scoreboard_process_thread.start(_update_scoreboards_thread.bind(_level,_world) )
	update_visibility_buttons()
	_update_scoreboards_thread(_level,_world)

func _update_scoreboards_thread(_level : int = Level, _world : int = World) -> void:
	print(TabTitleText.text)
	NodeTextUsers.hide()
	var _initial_range = CurrentPage*PageSize
	var _end_range = _initial_range+PageSize
	var results = await SaveGame.leaderboard_load_level_parse_to_ingame_ui_ranged(_level, _world, _initial_range, _end_range, CurrentPage)
	print("results: ")
	print(str(results))
	CurrentAmountPages = ceil(results.size()/PageSize)
	for i in range(PageSize):
		var Usertext : Node2D = NodeTextUsers.get_child(i)
		Usertext.visible = i < results.size()
		if(i < results.size()):
			var Userdata : Dictionary = results[i]
			Usertext.set_user_data(Userdata.name, Userdata.rank, Userdata.score)
	NodeTextUsers.show()

func _ready() -> void:
	_update_best_scores()
	update_visibility_buttons()

func update_visibility_buttons() -> void:
	ButtonNextPage.disabled = CurrentPage+1 >= CurrentAmountPages
	ButtonPrevPage.disabled = CurrentPage <= 1
	ButtonPrevLevel.disabled = Level <= 0
	var _amount_levels = LevelManager.get_amount_levels_in_world(World)
	ButtonNextLevel.disabled = Level+1 >= _amount_levels

func change_next_page() -> void:
	CurrentPage += 1
	_update_best_scores()
	
func change_prev_page() -> void:
	CurrentPage -= 1
	_update_best_scores()

func change_prev_level() -> void:
	CurrentPage = 0
	Level -= 1
	_update_best_scores()

func change_next_level() -> void:
	var _amount_levels = LevelManager.get_amount_levels_in_world(World)
	CurrentPage = 0
	Level += 1
	_update_best_scores()
