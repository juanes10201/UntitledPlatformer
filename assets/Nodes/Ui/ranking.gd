extends Control

@export var Users : Array[RichTextLabel]

@export var UserPlayer : RichTextLabel
@export var PlacePlayer : RichTextLabel
const amount_load_scores : int = 4

func _round_time_number(time : float) -> float:
	#La idea es redondear a un punto de decimal de minimo 3 unidades, si esta empatadado con otro incluir las decimales hasta que no este
	var q : int = 100
	return floor(time*q)/q

func _set_text_pos(Name : String, time : float) -> String:
	return str(Name)+": "+str(time)+" seg"

func _set_data(Username : String, UserTime : float, TextUser : RichTextLabel):#, TextPlace : RichTextEffect):
	#Si no esta vacio
	TextUser.text = _set_text_pos(Username, UserTime)

var scoreboard_process_thread : Thread
func _update_best_scores(Level : int, World : int) -> void:
	scoreboard_process_thread = Thread.new()
	scoreboard_process_thread.start(_update_best_scores_thread.bind(Level,World) )

func _exit_tree() -> void:
	if(scoreboard_process_thread):
		scoreboard_process_thread.wait_to_finish()

func _update_best_scores_thread(Level : int, World : int) -> void:
	print("STEAM: " + str(SteamIntegration.DidSteamInitialize))
	if(!SteamIntegration.DidSteamInitialize):
		for i in range(Users.size()):
			Users[i].visible = false
			Users[i].get_parent().visible = false
		Users[0].visible = true
		Users[0].get_parent().visible = true
		Users[0].get_parent().text = ""
		Users[0].text = "Scores Disabled"
		UserPlayer.hide()
		PlacePlayer.hide()
		return
	
	
	var PlayerTime : float = _round_time_number(SaveGame.GetLevelTime(Level-1, World))
	if(UserPlayer): UserPlayer.text = _set_text_pos(SaveGame.GetPlayerUserName(), PlayerTime)
	
	#obtenemos el resultado del savegame, la idea es que ya esta previamente cacheado
	#esto se hace con un await, lo cual no es una buena idea
	#se tendria que hacer en paralelo de alguna forma
	#TODO: investigar sobre como hacer en paralelo esto
	var res : Array = await SaveGame.leaderboard_load_level_parse_to_ingame_ui(Level, World, amount_load_scores)
	
	var PlayerData = await SaveGame.leaderboard_get_user_parsed_ui(Level, World)
	print(res)
	if(PlayerData && PlayerData.has("rank") && PlayerData["rank"] > 3):
		PlacePlayer.text = " " + str(PlayerData["rank"]) + "."
		PlacePlayer.show()
		UserPlayer.show()
	elif(res.size() >= 4):
		_set_data(res[3]["name"], res[3]["score"], UserPlayer)
		PlacePlayer.text = "4. "
		PlacePlayer.show()
		UserPlayer.show()
	else:
		PlacePlayer.hide()
		UserPlayer.hide()
	
	for i in range(Users.size()):
		if(i < res.size()):
			Users[i].visible = true
			Users[i].get_parent().visible = true
			Users[i].get_parent().text = str(i+1)
			_set_data(res[i]["name"], res[i]["score"], Users[i])
		else:
			Users[i].visible = false
			Users[i].get_parent().visible = false
	if(res.size() <= 0):
		Users[0].visible = true
		Users[0].get_parent().visible = true
		Users[0].get_parent().text = ""
		Users[0].text = "No scores submitted yet"
	
func _ready() -> void:
	_update_best_scores(0, 0)

func _process(delta: float) -> void:
	pass
