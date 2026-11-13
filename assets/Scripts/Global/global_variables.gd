extends Node

enum ReplayStates{
	REPLAY,
	RECORD,
	STOPPED
}
enum ConfigCategories{
	audio,
	input,
	video,
	gameplay
}
enum KillBoxTypes{
	None = 0,
	Red = 1,
	Blue = -1
}
enum BUTTON_ACTIONS{
	none,
	resume_game,
	restart_level,
	config_menu,
	move_to_scene,
	move_to_level_starting_with,
	quit,
	move_to_level_number_in_world,
	play_replay_from_scene,
	change_to_next_level,
	change_to_prev_level
}
enum GravityDirections{
	INVERTED = -1,
	MAIN = 1
}
enum Directions{
	INVERTED = -1,
	MAIN = 1
}
enum LASER_COLORS{
	NONE = 0,
	RED = 1,
	BLUE = 2,
	ORANGE = 3,
	GREEN = 4,
	YELLOW = 5
}

enum LIGHT_ANIMATION_TYPES{
	none,
	flickering,
	slow_burn,
	fast_burn
}

enum CHALLENGES{
	none = 0,
	inverted_gravity,
	no_restart,
	speedrun
}
enum ALL_DIRECTIONS{
	up,
	down,
	right,
	left,
	center,
	determine,
	none
}
var Selected_Challenge : CHALLENGES = CHALLENGES.none

var Player = null

#Order of levels
@export var LevelOrder: Array[PackedScene]

var DebugLevelVal : int = -99
@onready var Level : int = DebugLevelVal
var World : int = 0
var BSide : bool = false

var LoadingReplay : bool = false
var ReplayLocation : String = ""

var WorldTimeSec : float = 0.0
var WorldTimeMult : float = 1.0
var WorldTimeMin : Vector2 = Vector2(0.0, 0.0) 
var TextAvgStyle : float = 0
var TextSumStyle : int = 0

func get_level() -> int:
	return Level

func change_to_level(Lvl : int) -> void:
	get_tree().change_scene_to_packed(LevelOrder[Lvl])

func _ready():
	var Player = SaveGame.get_player()

#func Play_Global_Action(Action : OBJECT_ACTIONS, AdditionalParam : float = 0.0):
	#Player = SaveGame.get_player() 
	#if(!Player): return
	#if(Action == Global.OBJECT_ACTIONS.switch_killbox_type):
	#	Player.EnabledKillBox *= -1
	#elif(Action == Global.OBJECT_ACTIONS.MoveLava):
	#	Player.MoveLava = true
	#elif(Action == OBJECT_ACTIONS.Switch_Player_Gravity):
	#	Player._invert_gravity()
	#elif(Action == OBJECT_ACTIONS.Switch_Gravity_Remix):
	#	Player._invert_gravity_remix()
	#elif(Action == OBJECT_ACTIONS.Restart_Time):
	#	Player.CountTime = true
	#	Player.Time_Left.start()
	#	Player.Dashed = false
	#elif(Action == OBJECT_ACTIONS.Move_Water_level):
	#	var WaterTileset = SaveGame.get_group_node("WaterTileset")
	#	if(WaterTileset):
	#		WaterTileset.WaterLevelGoTo = AdditionalParam
	#elif(Action == OBJECT_ACTIONS.Set_Water_Level):
	#	var WaterTileset = SaveGame.get_group_node("WaterTileset")
	#	if(WaterTileset):
	#		WaterTileset.WaterLevel = AdditionalParam
	#		WaterTileset.WaterLevelGoTo = AdditionalParam
