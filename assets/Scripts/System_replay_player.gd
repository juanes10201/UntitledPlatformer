extends Node2D

@export var State = Global.ReplayStates.STOPPED

var CurrentTime : float = 0
var ReplayCurrentAction : int = 0

@onready var Player = get_parent()


var Actions : Array[String] = ["player_jump", "player_slide", "player_dash", "ui_left", "ui_right", "player_reset"]

var TimeMargin : float = 10.0

var CurrentPositionIndex = 1

var RecordCatchupPositionTime : int = 1000

var ReplayActions = {
	"player_jump": false,
	"player_slide": false,
	"player_dash": false,
	"ui_left": false,
	"ui_right": false,
	"player_reset": false
	}

func _ready() -> void:
	ReplayCurrentAction = 0
	CurrentTime = 0.0

func Reset() -> void:
	InitialTime = 0.0
	Player.position = Player.OriginalPos
	Player.reset_dead()
	ReplayCurrentAction = 0
	CurrentTime = -0.5
	for i in ReplayActions:
		ReplayActions[i] = false

func Play_action(A : String, Press : int):
	print("Simulating Press of Action of type: " + str(A) + ", Condition: " + str(Press))
	if(A == "player_reset"):
		Reset()
		return
	if(Press == 1):
		ReplayActions[A] = true
	else:
		ReplayActions[A] = false

var PressedActions : Array[String] = []

func Record_Actions() -> void:
	for i in range(Actions.size()):
		var PressedAction : bool = PressedActions.has(Actions[i])
		if(Input.is_action_pressed(Actions[i]) && !PressedAction ):
			PressedActions.append(Actions[i])
			var RecordedAction : Vector3 = Vector3(CurrentTime, i, 1)
			Player.RecordedActions.append(RecordedAction)
			#print("Vector3" +str(RecordedAction) + ",")
		elif(!Input.is_action_pressed(Actions[i]) && PressedAction ):
			PressedActions.erase(Actions[i])
			var RecordedAction : Vector3 = Vector3(CurrentTime, i, 0)
			Player.RecordedActions.append(RecordedAction)
			#print("Vector3" +str(RecordedAction) + ",")
	#print(Player.RecordedPositions)
	#print(RecordCatchupPositionTime)
	#print(CurrentTime)
	if(CurrentTime >= CurrentPositionIndex*RecordCatchupPositionTime):
		Player.RecordedPositions.append(Vector3(Player.global_position.x, Player.global_position.y, CurrentTime) )
		CurrentPositionIndex += 1

func Replay_Actions() -> void:
	#Check if the action time is the same(Or less) as the current
	var _CurrentTime = CurrentTime - Player.ReplayMilisecDelay
	if(_CurrentTime < 0.0): return
	while(ReplayCurrentAction < Player.RecordedActions.size()):
		var _action_id = Player.RecordedActions[ReplayCurrentAction].y
		if(!_action_id < Actions.size()): break
		var _time_action = Player.RecordedActions[ReplayCurrentAction].x
		var _action = Actions[_action_id]
		var _state = Player.RecordedActions[ReplayCurrentAction].z
		if(abs(_CurrentTime-_time_action) <= TimeMargin || _CurrentTime >= _time_action ):
			if(_action == "player_reset"):
				Play_action(_action, _state)
				return
			Play_action(_action, _state)
			ReplayCurrentAction += 1
		else:
			break
	if(CurrentPositionIndex < Player.RecordedPositions.size() && _CurrentTime >= Player.RecordedPositions[CurrentPositionIndex].z):
		Player.global_position = Vector2(Player.RecordedPositions[CurrentPositionIndex].x, Player.RecordedPositions[CurrentPositionIndex].y)
		CurrentPositionIndex += 1

@onready var InitialTime = Time.get_ticks_msec()

func _physics_process(delta: float) -> void:
	#print(CurrentTime)
	if(!Player): return
	if("ReplayAction" in Player): State = Player.ReplayAction
	#print(Input.is_action_pressed("replay_player_jump"))
	CurrentTime += 1000*delta
	#CurrentTime = Time.get_ticks_msec()-InitialTime
	if(State == Global.ReplayStates.RECORD): Record_Actions()
	elif(State == Global.ReplayStates.REPLAY): Replay_Actions()
