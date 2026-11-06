extends Node

var config = ConfigFile.new()
const SAVE_GAME_PATH = "user://savegame.save"

var PlayedIntroBool : bool = false

var CurrentRespawnId : int = 0
var RespawnLevelId : int = 0

var DialoguesIdEnabled : Array[bool] = []
var DialogueLevelId : int = 0
#Random bullshit go!
func PlayedIntro() -> bool:
	return PlayedIntroBool

func IfPlayedFirstTime() -> bool:
	loadgamedata()
	var playedbefore = get_value("Game", "PlayedBefore")
	if(playedbefore == "true"):
		return true
	else:
		config.set_value("Game", "PlayedBefore", "true")
	return false

func set_save_value(Category : String, id : String, Val):
	print("Set " + str(Category) + " id: " + id + " to val: " + str(Val))
	config.set_value(Category, id, Val)
	writegamedata()

func set_config_value(id : String, Val) -> void:
	set_save_value("Config", id, Val)

func get_value(sc: String, id : String):
	if(config.has_section_key(sc, id) && config.get_value(sc, id) != null):
		return config.get_value(sc, id)
	else: return null

func get_config_value(id : String):
	return get_value("Config", id)

func writegamedata() -> void:
	config.save(SAVE_GAME_PATH)
	print("Saved game data!")

func _setup_default_value(sc : String, id : String, val) -> void:
	if(get_value(sc, id) == null):
		print("Setup var " + id + " to " + str(val))
		config.set_value(sc, id, val)

func setup_default_values() -> void:
	#Si fuese un buen programador(boe), aca lo que haria es automatizar esto d alguna forma
	#pero me da paja asi q se queda asi.
	_setup_default_value("Config", "AudioMusic", 1)
	_setup_default_value("Config", "AudioSfx", 1)
	_setup_default_value("Config", "Fullscreen", 0)
	_setup_default_value("Config", "Shake", 1)
	_setup_default_value("Config", "PixelPerfect", 0)
	_setup_default_value("Config", "Juice", 1)
	_setup_default_value("Config", "Particles", 1)
	_setup_default_value("Config", "CrtShader", 1)
	_setup_default_value("Config", "Cheats", 0)
	_setup_default_value("Config", "DisableTimer", 0)
	_setup_default_value("Config", "GodMode", 0)
	_setup_default_value("Config", "UnlockAll", 0)
	_setup_default_value("Config", "ShowHitboxes", 0)
	writegamedata()

#La idea es parsear un json a un diccionario en godot.
func SaveLevelPersonalRecord(Level : int = 1, World : int = 1, RealTime : float = 0) -> void:
	if(Global.Selected_Challenge != Global.CHALLENGES.none): return
	loadgamedata()
	setup_default_values()
	
	print("Saved personal record, " + " Level: " + str(Level) + " World: " + str(World) + " Time: " + str(RealTime))
	
	var _world_name = LevelManager.get_world_name_by_number(World)
	var CurrentBest = get_value(_world_name, str(Level))
	var _player = SaveGame.get_player()
	if(SteamIntegration.DidSteamInitialize == true):
		#print("yes it did")
		leaderboard_submit_level_time(RealTime, Level, World)
	#_player._save_level_replay()
	if(!CurrentBest || RealTime < CurrentBest):
		if(_player && _player.ReplayAction == Global.ReplayStates.RECORD):
			#TODO: se tiene que subir a steam el replay, d forma d q se pueda acceder por el sistema d leaderboards
			pass
			#_player._save_level_replay()
		set_save_value(_world_name, str(Level), RealTime/1000.0)

func SaveLevelRecord(Level : int = 1, World : int = 0, RealTime : float = 0) -> void:
	SaveLevelPersonalRecord(Level, World, RealTime)
	#var CurrentBest : float = get_value("Level", str(Level))
	writegamedata()

func GetLevelTime(Level : int, World : int) -> float:
	var _world_name = LevelManager.get_world_name_by_number(World)
	var CurrentBest = get_value(_world_name, str(Level))
	print("Got time:" + str(CurrentBest) + " of level: " + str(Level) + " and World: " + str(World))
	if(CurrentBest): return CurrentBest
	else: return 0.0

#Los tiempos son de esta forma:
# users: {
#	{
#		time:"", name:"", uuid:""
#	}
#
#}

var Cache_Leaderboard_Handles : Dictionary[String, int] = {}

func _process(delta: float) -> void:
	if(SteamIntegration.initialize_steam):
		Steam.run_callbacks()

#tener en cuenta que la funcion get_leaderboard_handle es de tipo coroutine
#hay que agregar un await al usarla
func get_leaderboard_handle(key : String) -> int:
	if(!SteamIntegration.initialize_steam): return 0 
	if(key in Cache_Leaderboard_Handles):
		return Cache_Leaderboard_Handles[key]
	Steam.findOrCreateLeaderboard(key, Steam.LEADERBOARD_SORT_METHOD_ASCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)
	var result = await Steam.leaderboard_find_result
	var handle : int = result[0]
	var was_found : bool = result[1]
	if(!was_found):
		print("Leadeboard named " + key + " wasn't found")
		return -1
	print("Leadeboard named " + key + " was found with handle id: " + str(handle))
	Cache_Leaderboard_Handles[key] = handle
	return handle

func _ready() -> void:
	pass
	#Espero a que se inicie steam
	
	#await get_tree().create_timer(1.0).timeout
	#print(await leaderboard_load_level_parse_to_ingame_ui(7, 0, 3))
	
	#print("DEBUGGING")
	#print(await SaveGame.leaderboard_load_level_top_3(7, 0))

func get_leaderboard_key_name(level : int, world : int) -> String:
	return "world" + str(world) + "_level" + str(level)

func leaderboard_submit_level_time(sec : int, level : int, world : int) -> void:
	if(!SteamIntegration.initialize_steam): return
	var key = get_leaderboard_key_name(level, world)
	var handle : int = await get_leaderboard_handle(key)
	if(handle == -1): return
	#var handle = get_leaderboard_handle(key)
	#Steam.findOrCreateLeaderboard(key, Steam.LEADERBOARD_SORT_METHOD_DESCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)
	
	#TODO: me parece que lo mas logico es agregar los datos "ghost" del jugador como dato extra al leaderboard. quedaria clean si se puede
	#await Steam.leaderboard_find_result
	Steam.uploadLeaderboardScore(sec, true, [], handle)
	Steam.downloadLeaderboardEntries(0, 2, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL, handle)

func leaderboard_load_level_time(level : int, world : int, amount : int) -> Array:
	if(!SteamIntegration.initialize_steam): return []
	var key = get_leaderboard_key_name(level, world)
	#se agrega el await porque la puta funcion es coroutine
	var handle : int = await get_leaderboard_handle(key)
	print("HANDLE:")
	print(handle)
	if(handle == -1): return []
	Steam.downloadLeaderboardEntries(0, amount-1, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL, handle)
	var result = await Steam.leaderboard_scores_downloaded
	#Agrego variables debug que no se usan por las dudas: message y this_handle
	var message : String = result[0]
	var this_handle : int = result[1]
	var entries : Array = result[2]
	return entries

#func leaderboard_load_level_top_3(level : int, world : int) -> Array:
#	return await leaderboard_load_level_time(level, world, 3)

#El tipo de dato es un diccionario, que dentro guarda una lista que contiene diccionarios
#Osea: Dictionary[String, Array[Dictionary] ]
var leaderboard_level_worlds_cache : Dictionary = {}

func leaderboard_check_if_caches_is_stored(path : String) -> Array:
	if(!SteamIntegration.initialize_steam): return []
	if(path in leaderboard_level_worlds_cache):
		return leaderboard_level_worlds_cache[path]
	return []
func leaderboard_store_cache_res(res : Array, path : String) -> void:
	if(!SteamIntegration.initialize_steam): return
	leaderboard_level_worlds_cache[path] = res

func _on_leaderboard_scores_downloaded(message: String, this_handle: int, results: Array) -> void:
	if(!SteamIntegration.initialize_steam): return
	for entry in results:
		#me gusta como se usa el %d con la onda de c. igual me da paja codear asi
		print("#%d - %s - score: %d" % [
			entry["global_rank"],
			Steam.getFriendPersonaName(entry["steam_id"]),
			entry["score"]
		])

func get_username_from_uuid(uuid : int) -> String:
	if(!SteamIntegration.initialize_steam): return ""
	#1ro me fijo si esta el nombre ya cacheado como parte de los amigos u otro
	var name := Steam.getFriendPersonaName(uuid)
	if(name != ""): return name
	#Si no lo pido al servidor
	Steam.requestUserInformation(uuid, true)
	#Esto puede crashear el juego
	#Es una solucion temporal, para evitar usar señales
	#TODO: cambiar un while true infinito. es muy mala practica
	while true:
		var result = await Steam.persona_state_change
		var changed_id : int = result[0]
		if(changed_id == uuid):return Steam.getFriendPersonaName(uuid)
	return ""

#Convierto los tiempos a segundos
#Convierto los uuid de los usuarios a los nombres
#Los ordeno por puesto de forma ascendente
func leaderboard_parse_to_ingame_ui(steam_leaderboard : Array, path : String) -> Array:
	if(!SteamIntegration.initialize_steam): return []
	var parse_res : Array = []
	if(!steam_leaderboard): return []
	#1ro itero por cada usuario
	for User in steam_leaderboard:
		var _dicc = await leaderboard_parse_user_to_ingame_ui(User)
		parse_res.append(_dicc)
	leaderboard_store_cache_res(parse_res, path)
	return parse_res

func leaderboard_parse_user_to_ingame_ui(User : Dictionary) -> Dictionary:
	if(!SteamIntegration.initialize_steam): return {}
	var _dicc : Dictionary = {}
	_dicc["name"] = await get_username_from_uuid(User["steam_id"])
	_dicc["score"] = User["score"]/1000.0
	_dicc["rank"] = User["global_rank"]
	return _dicc

func leaderboard_load_level_parse_to_ingame_ui(level : int, world : int, amount : int) -> Array:
	if(!SteamIntegration.initialize_steam): return []
	#se fija si esta cacheado el res y lo devuelve si es el caso
	var _cache : Array = leaderboard_check_if_caches_is_stored(get_leaderboard_key_name(level, world) )
	if(_cache): return _cache
	
	var _leaderboard = await leaderboard_load_level_time(level, world, amount)
	if(_leaderboard): return await leaderboard_parse_to_ingame_ui(_leaderboard, get_leaderboard_key_name(level, world))
	return []

func leaderboard_get_user_parsed_ui(level : int, world : int) -> Dictionary:
	if(!SteamIntegration.initialize_steam): return {}
	if(level < 0 || world < 0): return {}
	var Username : String = GetPlayerUserName()
	var LevelKeyName : String = get_leaderboard_key_name(level, world)
	if(leaderboard_level_worlds_cache.has(LevelKeyName) ):
		for User in leaderboard_level_worlds_cache[LevelKeyName]:
			if(User.has("name") && User["name"] == Username):
				return User
		var Steam_UserData = await get_leaderboard_user_position(level, world)
		if(Steam_UserData):
			var Parsed_UserData = await leaderboard_parse_user_to_ingame_ui(Steam_UserData)
			leaderboard_level_worlds_cache[LevelKeyName].append(Parsed_UserData)
			print("Parsed userdata: " + str(Parsed_UserData))
			return Parsed_UserData
	return {}

func get_leaderboard_user_position(level : int, world : int) -> Dictionary:
	if(!SteamIntegration.initialize_steam): return {}
	var key = get_leaderboard_key_name(level, world)
	#se agrega el await porque la puta funcion es coroutine
	var handle : int = await get_leaderboard_handle(key)
	print("HANDLE:")
	print(handle)
	if(handle == -1): return {}
	Steam.downloadLeaderboardEntries(0, 0, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER, handle)
	var result = await Steam.leaderboard_scores_downloaded
	#Agrego variables debug que no se usan por las dudas: message y this_handle
	var message : String = result[0]
	var this_handle : int = result[1]
	var entries : Array = result[2]
	if(entries.is_empty()):
		print("Player hasn't submitted yet to the Scoreboard: " + str(level) + ", world: " + str(world))
		return {}
	return entries[0]

#func leaderboard_get_level_time(level : int, world : int) -> void:
#	

#func get_leaderboard_handle(key: String) -> void:
#	Steam.findOrCreateLeaderboard(key, Steam.LEADERBOARD_SORT_METHOD_DESCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)

#Asumimos que estan sorteados en tiempo
#var UserTimes : Dictionary = {
#	"level0" : {
#		"users" : [
#			{
#				"time": 0.05,
#				"name": "pla1",
#				"uuid": ""
#			},
#			{
#				"time": 1.00,
#				"name": "pla2",
#				"uuid": ""
#			}
#		]
#	}
#}

#func GetLevelTimeDiccionary(level : int) -> Dictionary:
#	var s : String = "level"+str(level)
#	if(UserTimes.has(s)): return UserTimes[s]
#	return {}

#func GetUserLevelDiccionary(level : int, index : int) -> Dictionary:
#	var LevelDic : Dictionary = GetLevelTimeDiccionary(level)
#	if(LevelDic.has("users") && LevelDic["users"].size()-1 >= index):
#		return LevelDic["users"][index]
#	return {}

func GetPlayerUserName() -> String:
	if(!SteamIntegration.initialize_steam): return "Player: "
	var name = Steam.getPersonaName()
	if(!name): name = "Player: "
	return name

func boss_slime_play_anim(anim : String) -> void:
	get_boss().play_anim(anim)

func boss_slime_change_portrait(portrait : String) -> void:
	get_boss().set_dialogue_portrait(portrait)
	
func get_boss():
	var Boss = get_tree().get_nodes_in_group("Boss")[0] if get_tree().get_nodes_in_group("Boss").size() else null
	return Boss

var _cache_player : CharacterBody2D
func get_player():
	#if(_cache_player): return _cache_player
	if(get_tree()):
		var Players = get_tree().get_nodes_in_group("Player") if get_tree().get_nodes_in_group("Player").size() else null
		if(Players):
			for Player in Players:
				if("IsMainPlayer" in Player && Player.IsMainPlayer):
					_cache_player = Player
					return Player
	else:
		print("WARNING: Tried loading Player before the scene is loaded.")

func get_level_editor_node() -> Node2D:
	return get_group_node("LevelEditor")

func get_group_node(Group : String):
	if(get_tree()):
		var GroupTile = get_tree().get_nodes_in_group(Group)[0] if get_tree().get_nodes_in_group(Group).size() else null
		return GroupTile
	else:
		print("WARNING: Tried loading Group Node '" + Group + "' before the scene is loaded.")

func get_player_replay():
	var Player = get_tree().get_nodes_in_group("PlayerReplay")[0] if get_tree().get_nodes_in_group("PlayerReplay").size() else null
	return Player

func loadgamedata() -> void:
	var err = config.load(SAVE_GAME_PATH)
	if(err == OK):
		#Here put values given savefile
		pass
	setup_default_values()
	print("loaded game saved data!")

func SaveJsonFile(Location : String, Data) -> void:
	var file := FileAccess.open(Location, FileAccess.WRITE)
	file.store_string(JSON.stringify(Data, "\t"))

func SetDialogue(Id : int, Level : int = LevelManager.get_level()) -> void:
	print("Set Dialogue")
	if(Level != DialogueLevelId):
		DialoguesIdEnabled = []
		DialogueLevelId = Level
	if(Id > DialoguesIdEnabled.size()-1): DialoguesIdEnabled.resize(Id+1)
	DialoguesIdEnabled[Id] = true

func GetRespawn(Id : int) -> bool:
	print("Get respawn")
	return RespawnLevelId == LevelManager.get_level() && CurrentRespawnId == Id

func GetDialogue(Id : int) -> bool:
	#print("Get dialogue Id: " + str(Id) + " to " + str(DialoguesIdEnabled[Id]))
	return (DialogueLevelId == LevelManager.get_level() && DialoguesIdEnabled.size()-1 >= Id && DialoguesIdEnabled[Id] == true)

func SetRespawn(Id : int, Level : int = LevelManager.get_level()) -> void:
	CurrentRespawnId = Id
	RespawnLevelId = Level
