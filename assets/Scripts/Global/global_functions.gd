#@tool
extends Node

#Instrucciones:
#Para crear una nueva funcion, agregarla a la lista aca de funciones, y crearla abajo de todo
enum FUNCTIONS{
	none,
	switch_killbox_type,
	MoveLava,
	Switch_Player_Gravity,
	Switch_Gravity_Remix,
	Restart_Time,
	Move_Water_level,
	Set_Water_Level,
	Move_node,
	Create_node2d,
	Delete_node2d,
	Create_tile_local, #TODO
	Delete_tile_local,
	Change_Railed_Nodes_Speed,
	Set_Falling_Sand_Max_Velocity,
	Set_Enemy_Time_To_Shoot
}

const EditorPrefix : String = "EditorTooltip"
enum EDITOR_TOOLTIP_FUNCTIONS{
	none = 0,
	Save,
	SaveAs,
	Open,
	Exit,
	Undo,
	Redo,
	Copy,
	Paste
}

#Uso un array de array, donde el primer sub-elemento de cada elemento contendra el nombre, el resto los valores cambiados
var DoneActions : Array[Array] = []

var LastOriginalvalue = 0
var OpenedFileDialog : bool = false

func Change_Railed_Nodes_Speed(Speed : float) -> void:
	for Rail in get_tree().current_scene.get_children():
		if(Rail.is_in_group("RailNodes")):
			Rail.Speed = Speed
			print("Changed rail speed")

func record_action(FUNC : FUNCTIONS = FUNCTIONS.none, FinalValue = 0, InitialValue = LastOriginalvalue, OptionalValue = null) -> void:
	var _action : Array = [FUNC, InitialValue, FinalValue]
	if(OptionalValue): _action.append(OptionalValue)
	DoneActions.append(_action)
	print("Recorded function " + FUNCTIONS.keys()[FUNC] + " to " + str(FinalValue))
	#print(DoneActions)

func rewind_action() -> void:
	if(DoneActions.size() <= 0): return
	var _action : Array = DoneActions[DoneActions.size()-1]
	
	#Special cases
	if(_action[0] == FUNCTIONS.Create_node2d):
		#For example in the case a node was create it would be deleted
		Delete_node2d(_action[1])
	elif(_action[0] == FUNCTIONS.Create_tile_local):
		#print(_action[1])
		#print(_action[2])
		Delete_tile_local(_action[1], _action[3])
	else:
		if(_action.size() > 3):
			call(FUNCTIONS.keys()[_action[0]], _action[2], _action[3])
		else:
			call(FUNCTIONS.keys()[_action[0]], _action[2])
	DoneActions.pop_back()
	DoneActions.pop_back()
	print("Reverted function " + str(FUNCTIONS.keys()[_action[0]]) + " to value " + str(_action[2]))

func play_function(FUNC : FUNCTIONS = FUNCTIONS.none, Argument = null) -> void:
	var Player : Node2D = _get_player()
	if(!Player): return
	if(FUNC == FUNCTIONS.none): return
	if(Argument == null):
		call(FUNCTIONS.keys()[FUNC])
	else:
		call(FUNCTIONS.keys()[FUNC], Argument)

func _get_player() -> CharacterBody2D:
	return SaveGame.get_player() 

func switch_killbox_type(Type : Global.KillBoxTypes = Global.KillBoxTypes.None) -> void:
	#if(Type == Global.KillBoxTypes.None): return
	var Player : Node2D = _get_player()
	LastOriginalvalue = Player.EnabledKillBox
	Player.EnabledKillBox *= -1
	print("changed")

func Set_Enemy_Time_To_Shoot(Arg : float = 80.0) -> void:
	for Enemie in get_tree().current_scene.get_children():
		if(Enemie.is_in_group("Enemie") && Enemie.enemy_type == 2.0):
			Enemie.ShootBulletTimer.wait_time = Arg
			Enemie.TimeToShoot = Arg

func Set_Falling_Sand_Max_Velocity(Arg : float = 80.0) -> void:
	for Sand in get_tree().current_scene.get_children():
		if(Sand.is_in_group("sand") && Sand.is_falling):
			Sand.MAX_SPEED = Arg

func MoveLava(Arg : int = 1) -> void:
	var Player : Node2D = _get_player()
	LastOriginalvalue = Player.MoveLava
	Player.MoveLava = true

func Switch_Player_Gravity(Dir = null) -> void:
	var Player : Node2D = _get_player()
	LastOriginalvalue = Player.MoveLava
	if(Dir):
		Player._invert_gravity(Dir)
	else:
		Player._invert_gravity()

func Switch_Gravity_Remix(Dir = null) -> void:
	var Player : Node2D = _get_player()
	Player._invert_gravity_remix()

func Restart_Time(Arg = null) -> void:
	var Player : Node2D = _get_player()
	Player._set_time_state(true)
	Player.CountTime = true
	Player.Time_Left.start()
	Player.Dashed = false

func Move_Water_level(WaterLevel : int) -> void:
	var WaterTileset = SaveGame.get_group_node("WaterTileset")
	if(WaterTileset):
		WaterTileset.WaterLevelGoTo = WaterLevel

func Set_Water_Level(WaterLevel : int) -> void:
	var WaterTileset = SaveGame.get_group_node("WaterTileset")
	if(WaterTileset):
		WaterTileset.WaterLevel = WaterLevel
		WaterTileset.WaterLevelGoTo = WaterLevel

func Move_node(pos : Vector2 = Vector2(0.0, 0.0), node : Node2D = null):
	print("Moved node " + str(node) + " to position " + str(pos))
	LastOriginalvalue = pos
	node.global_position = pos
	
	record_action(FUNCTIONS.Move_node, pos, LastOriginalvalue, node)

func Copy_and_Instatiate_node2d(InitialNode : PackedScene, father) -> Node2D:
	var NewNode = InitialNode.duplicate()
	var InstanceNewNode = NewNode.instantiate()
	father.add_child(InstanceNewNode)
	return InstanceNewNode

func Create_node2d(Location : String, father) -> Node2D:
	var NewNode = load(Location)
	var InstanceNode = NewNode.instantiate()
	father.add_child(InstanceNode)
	
	record_action(FUNCTIONS.Create_node2d, InstanceNode, InstanceNode, InstanceNode)
	return InstanceNode

func Delete_node2d(node : Node) -> void:
	if(node): node.queue_free()
	
	record_action(FUNCTIONS.Delete_node2d, node, null)

func Delete_tile_local(Pos : Vector2, Tilemap : TileMapLayer):
	Tilemap.set_cells_terrain_connect([Pos], 0, -1)
	record_action(FUNCTIONS.Delete_tile_local, Pos, Pos, Tilemap)
