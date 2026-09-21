extends AnimatedSprite2D

@export var ReadFromReplay : bool = false
@export var ButtonToPress : String = "player_jump"

@onready var ReplayPlayer : Node2D = SaveGame.get_player_replay()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(ReadFromReplay):
		if(ReplayPlayer && ReplayPlayer.Replay.ReplayActions[ButtonToPress]):
			self.play("pressed")
		else:
			self.play("default")
	else:
		if(Input.is_action_pressed(ButtonToPress)):
			self.play("pressed")
		else:
			self.play("default")
