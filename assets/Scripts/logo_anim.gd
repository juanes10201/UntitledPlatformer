extends Sprite2D

@onready var Player = SaveGame.get_player()

func _ready():
	if(Player && Player.PlayIntro):
		Edition.DoneIntro = true
		$AnimationPlayer.play("Start")
