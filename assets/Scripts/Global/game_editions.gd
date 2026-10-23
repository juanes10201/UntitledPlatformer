extends Node

enum ALL_GAME_STATUS{
	retail,
	expo,
	demo
}
var GAME_STATUS_CHARACTERISTICS : Array = [
	{
		"Name" : "Retail-Steam",
		"Id" : ALL_GAME_STATUS.retail,
		"Variables" : {
			"IncludeLevelEditor" : true,
			"LimitWorlds" : false,
			"SteamEnabled" : true
		}
	},
	{
		"Name" : "Retail-Expo",
		"Id" : ALL_GAME_STATUS.expo,
		"Variables" : {
			"IncludeLevelEditor" : true,
			"LimitWorlds" : true,
			"AmountLimitedWorlds" : 2,
			"SteamEnabled" : false
		}
	},
	{
		"Name" : "Demo-Itch",
		"Id" : ALL_GAME_STATUS.demo,
		"Variables" : {
			"IncludeLevelEditor" : true,
			"LimitWorlds" : true,
			"AmountLimitedWorlds" : 1,
			"SteamEnabled" : false
		}
	}
	
	]
var GAME_STATUS = ALL_GAME_STATUS.demo
var IncludeLevelEditor = true

var ExpoLimitedTime : bool = true

var CrtFilter : bool = true


var Is_in_editor : bool = false

var Is_playing_in_editor : bool = false

var DoneIntro = false

var IsErasingInEditor = false

var LimitWorlds : bool = false
var AmountLimitedWorlds : int = 1

var SteamEnabled : bool = true

@onready var Mobile : bool = true if OS.get_name() == "Android" else false

func _ready() -> void:
	load_game_status(GAME_STATUS)

func load_game_status(GAME_STATUS : ALL_GAME_STATUS) -> void:
	#itera y establece las variables acorde a lo que dice la edicion correspondiente del juego
	print("GAME STATUS: " + str(GAME_STATUS))
	for _status_char in GAME_STATUS_CHARACTERISTICS:
		if(_status_char["Id"] == GAME_STATUS):
			for _var in _status_char.Variables:
				print("Changed: " + _var + " to: " + str(_status_char.Variables[_var]))
				set(_var, _status_char.Variables[_var])

func reset_expo() -> void:
	LevelManager.ExpoTimer.start()
	LevelManager.PlayedExpo = false
	LevelManager.ExpoTimer.paused = true
