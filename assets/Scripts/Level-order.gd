extends Node

#Order of levels

@export var LevelsCsvPath : String
@export var LevelsBsideCsvPath : String
@export var BossesLevelPath : Array[String]

var LevelPaths : Dictionary 
var LevelPathsBside : Dictionary
var WorldOrder : Array[String]
var WorldOrderBside : Array[String]

var AmountLevels : int = 0
var AmountLevelsBSide : int = 0

@onready var ExpoTimer = $ExpoTimer
var PlayedExpo : bool = false
var ReturnAfterTimerInExpo : bool = true
@onready var StyleTimer = $StyleTimer

@onready var ExpoMoveTimeout : Timer = $ExpoMoveTimeout

var PreviousStyle : String = "D"
var PreviousScore : String = ""

var Prefix : String = "res://assets/Nodes/Levels/"

#X: Minutes
#Y: Seconds
func get_times(time : float) -> Vector2:
	#Hours
	return Vector2(time/60.0, int(time)%60)

func reset_world_timer() -> void:
	Global.WorldTimeSec = 0.0

func world_timer_tick(delta: float) -> void:
	Global.WorldTimeSec += delta
	var new_times : Vector2 = get_times(Global.WorldTimeSec)
	#print("Stylemetter: " + str(StyloMetter))
	#print("avg: " + str(Global.TextAvgStyle))
	#print("total: " + str(Global.TextSumStyle))
	#print("time: " + str(Global.WorldTimeMin))
	if(floor(Global.WorldTimeMin.x) != floor(new_times.x)):
		Global.TextSumStyle += StyloMetter
		Global.TextAvgStyle = Global.TextSumStyle/new_times.x
	Global.WorldTimeMin = new_times

var InitialWorldTimerMult : float = 1.5
var MinWorldTimerMult : float = .7

func calc_world_timer_mult() -> void:
	Global.WorldTimeMult = InitialWorldTimerMult - 0.05*Global.WorldTimeMin.x
	Global.WorldTimeMult = clamp(Global.WorldTimeMult, MinWorldTimerMult, InitialWorldTimerMult)

func get_level_world_with_complete_level_path(Path : String) -> Vector2:
	Path = Path.replace(Prefix, "")
	var string_world = Path.get_slice("/", 0)
	var result : Vector2 = Vector2(0.0,0.0)
	if(get_level_paths(Global.BSide).has(string_world)):
		result.y = get_world_number(string_world, Global.BSide)
		result.x = get_level_paths(Global.BSide)[string_world].find(Path.get_slice("/", 1))
	return result

func set_global_with_complete_level_path(Path : String) -> void:
	Path = Path.replace(Prefix, "")
	var string_world = Path.get_slice("/", 0)
	if(get_level_paths(Global.BSide).has(string_world)):
		Global.World = get_world_number(string_world, Global.BSide)
		Global.Level = get_level_paths(Global.BSide)[string_world].find(Path.get_slice("/", 1))
	print("!Debug")
	print("Global.World: "+str(Global.World))
	print("Global.Level: "+str(Global.Level))

func set_global_with_level_path(Path : String) -> void:
	for World in LevelPaths:
		if(Path in LevelPaths[World]):
			Global.World = get_world_order(Global.BSide).find(World)
			Global.Level = LevelPaths[World].find(Path)
			print("!Debug")
			print("Global.World: "+str(Global.World))
			print("Global.Level: "+str(Global.Level))

func get_current_world_number() -> int:
	return Global.World

func _ready() -> void:
	reload_all_level_csv()
	#print(LevelPaths)

func reload_all_level_csv() -> void:
	load_regular_level_csv()
	load_bside_level_csv()

func load_bside_level_csv() -> void:
	load_level_csv(LevelsBsideCsvPath, LevelPathsBside, WorldOrderBside, true)

func load_regular_level_csv() -> void:
	load_level_csv(LevelsCsvPath, LevelPaths, WorldOrder, false)

func load_level_csv(csv : String, levelpaths : Dictionary, worldorder : Array[String], BSide: bool = false):
	var filecsv = FileAccess.open(csv, FileAccess.READ)
	var filetxt = filecsv.get_as_text()
	levelpaths.clear()
	worldorder.clear()
	if(!BSide):
		AmountLevels = 0
	else:
		AmountLevelsBSide = 0
	#Iterate throught every line
	for i in range(filetxt.get_slice_count("\n") ):
		var _line = filetxt.get_slice("\n", i)
		for l in range(_line.get_slice_count(",")):
			var _value = _line.get_slice(",", l)
			if(_value == "" || _value == ","): continue
			#If the value is in the first line, then use it to create the dictionaries
			#estoy gaga no se pq a veces escribo en ingles y otras en español. ups
			if(i == 0):
				levelpaths.set(_value, [])
				worldorder.append(_value)
			elif(l < worldorder.size()):
				if(!BSide):
					AmountLevels += 1
				else:
					AmountLevelsBSide += 1
				levelpaths[worldorder[l]].append(_value)
	print("Reloaded level paths csv file")
	#print("Does file exists: ")
	#print(str(FileAccess.file_exists(csv)))
	#print(filetxt)
	#print(LevelPaths)

func get_world_name_by_number(Number : int) -> String:
	if(Number >= get_world_order().size()): return "world1"
	return get_world_order()[Number]

func get_amount_total_levels(BSide : bool = false) -> int:
	if(BSide): return AmountLevelsBSide
	return AmountLevels

func get_world_order(BSide : bool = false) -> Array:
	if(BSide): return WorldOrderBside
	return WorldOrder

func get_level_paths(BSide : bool = false) -> Dictionary:
	if(BSide): return LevelPathsBside
	return LevelPaths

func get_world_by_number(world : int,  BSide : bool = false) -> Array:
	return get_level_paths(BSide)[get_world_order(BSide)[world]]

func get_total_number_level(level : int, world : int, BSide : bool = false) -> int:
	var PrevWorldsSize : int = 0
	for i in range(world):
		if(i < 0): break
		PrevWorldsSize += get_level_paths(BSide)[get_world_order(BSide)[i]].size()
	return PrevWorldsSize+level

func get_world_number(world : String, BSide : bool = false) -> int:
	return get_world_order(BSide).find(world)

func get_amount_levels_in_world(world : int, BSide : bool = false) -> int:
	return get_level_paths(BSide)[get_world_order(BSide)[world]].size()

func get_level_time(BSide : bool = false):
	var Player = get_tree().get_nodes_in_group("GameTimer")[0] if get_tree().get_nodes_in_group("GameTimer").size() else null
	return Player

func change_to_next_level_with_completion_ui() -> void:
	print("Global level: " + str(Global.Level))
	print("Bside: " + str(Global.BSide))
	if(Global.Level+1 >= get_level_paths(Global.BSide)[get_world_order(Global.BSide)[Global.World]].size() ):
		var _player = SaveGame.get_player()
		if(_player):
			_player.spawn_next_world_ui()
	else:
		change_to_next_level()

func change_to_next_level() -> void:
	if(Global.Level+1 >= get_level_paths(Global.BSide)[get_world_order(Global.BSide)[Global.World]].size() ):
		if(Global.World < BossesLevelPath.size()):
			change_scene(BossesLevelPath[Global.World])
			Global.Level += 1
		else:
			change_to_level(0, Global.World + 1, Global.BSide)
	else:
		change_to_level(Global.Level+1, Global.World, Global.BSide)

func change_to_prev_level() -> void:
	if(Global.Level-1 < 0):
		change_to_level(get_world_by_number(Global.World-1).size()-1, Global.World-1, Global.BSide)
	else:
		change_to_level(Global.Level-1, Global.World, Global.BSide)

func get_level() -> int:
	return Global.Level

func change_to_level(Level : int , World : int, BSide : bool = false) -> void:
	if(World < get_world_order(BSide).size()):
		var CurrentWorld : String = get_world_order(BSide)[World]
		Global.World = World
		change_to_level_world_string(Level, CurrentWorld, BSide)

func get_level_path(Level : int, World : String, BSide : bool) -> String:
	if(Edition.Is_in_editor): return ""
	var _world_array : Array = get_level_paths(BSide)[World]
	if(Level > 0 && Level < _world_array.size()):
		return Prefix + str(World) + "/" + str(_world_array[Level])
	return ""

func change_to_level_world_string(Level : int, World : String, BSide : bool = false) -> void:
	Global.Level = Level
	Global.World = get_world_number(World, BSide)
	if(Level < 0): Global.Level = 1
	if(Level >= get_level_paths(BSide)[World].size()):
		Level = 0
		World = get_world_order(BSide)[get_world_number(World, BSide)+1]
	var SceneString : String = get_level_path(Level, World, BSide)
	var Scene = ResourceLoader.load_threaded_get(SceneString)
	print("Changing to level " + str(Level) + " World: " + str(World))
	print("Path: " + SceneString)
	if(Scene):
		get_tree().change_scene_to_packed(Scene)
	else:
		change_scene(SceneString)

func change_scene(Scene : String) -> void:
	get_tree().change_scene_to_file(Scene)

#func get_level_and_world_number_from_path(path : String) -> Vector2:
#	var _level = -1
#	var _world = -1
#	for world in get_level_paths(Global.BSide):
#		var _find = get_level_paths(Global.BSide)[world].find(path)
#		if(_find != -1):
#			_level = _find
#			_world = get_world_number(world, Global.BSide)
#			break
#	return Vector2(_level, _world)

func play_replay_level_string(Level : String):
	var _level_world = get_level_world_with_complete_level_path(Level)
	print(_level_world)
	play_replay(_level_world.x, _level_world.y)

const ReplaySaveLocation = "res://assets/Replays/"

func get_level_record_replay_pos(level : int, world : int) -> String:
	return ReplaySaveLocation + "local/local_best_time_level" + str(level) + "_world" + str(world) + ".json"

func play_replay(Level : int, World : int):
	var WorldString = get_level_path(Level, get_world_name_by_number(World), false)
	var _path : String = get_level_record_replay_pos(Level, World)
	#if(_player):
	print("Loading replay...")
	if(ResourceLoader.exists(_path)):
		Global.LoadingReplay = true
		Global.ReplayLocation = _path
		Global.World = World
		Global.Level = Level
		change_scene(WorldString)
	else:
		print("Replay file doesn't exist")
	#	var _replay_path = _player.get_level_record_replay_pos(Level, World)
	print("Path: " + str(Global.ReplayLocation))
	#	_player._load_replay(_replay_path)
	#	print()

var StyloMetter : int = 5 
var StyloString : String = "B"

enum Styles{
	P = 1500,
	SSS = 1000,
	SS = 900,
	S = 500,
	A = 400,
	B = 250,
	C = 100,
	D = 0
}

@export var StyleAmounts: Array[int] = [10, 20, 100, 200, 400, 600]

var StyleMoto : String = ""

var ScoreMult : int = 1

var StylePlayedHideAnimation : bool = true

var LastScore : int = 0

var PointsLeftMult = 5

@onready var StyleMultiplierTimer = $StyleMultiplierTimer 

func RemoveStyle(Qt : int, Moto : String = ""):
	var _player = SaveGame.get_player()
	if(_player && !_player.Styleometter): return
	StyloMetter -= Qt
	if(StyloMetter < 0): StyloMetter = 0
	ScoreMult = 1

func AddStyle(Qt : int, Moto : String = "", Mult : float = 1.0):
	#Score Multiplier
	var _player = SaveGame.get_player()
	if(_player && !_player.Styleometter): return
	StyleMultiplierTimer.start()
	if(Moto == StyleMoto):#!=1
		PointsLeftMult -= 1
		#if(PointsLeftMult <= 0):
		if(ScoreMult < 3):
			ScoreMult += 1
			#PointsLeftMult = 5
			if(ScoreMult == 3):
				#SaveGame.get_player().FrameFreeze(.3, .2)
				var Player = SaveGame.get_player()
				if(Player):
					#Player._play_sound(Player.AudioUpgrade)
					if(Player.Camera && "Shake" in Player.Camera):
						Player.Camera.Shake(12.0, 12.0, true)
	StyloMetter += StyleAmounts[Qt] * ScoreMult * Mult
	StyleMoto = Moto
	if(StyloMetter < 0): StyloMetter = 0
	StyleTimer.start()
	LastScore = StyleAmounts[Qt] * ScoreMult * Mult

func GetStyle(Style : int = StyloMetter) -> String:
	#The styles are sorted from biggest to lowest
	#So we search for the first one that the Style >=, and return the name
	for i in range(Styles.values().size()):
		if Style >= Styles.values()[i]:
			StyloString = Styles.keys()[i]
			break
	return StyloString

var StyleTimeOut : int = 40

func _on_style_timer_timeout() -> void:
	StyleMoto = ""
	RemoveStyle(StyleTimeOut)


func _on_style_multiplier_timer_timeout() -> void:
	ScoreMult = 1
