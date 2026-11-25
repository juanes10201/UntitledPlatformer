extends Node2D
@export var UserNumber : int = 1
@export var UserName : String
@export var TimeSec : float = 0.0

func set_user_data(Name : String, Num : int, time : float) -> void:
	UserName = Name
	UserNumber = Num
	TimeSec = time
	reload_user_data()

func reload_user_data() -> void:
	$UserText.text = str(UserNumber)+". " + UserName
	$TimeText.text = str(TimeSec) + " sec"
