extends Node2D

@onready var Player = SaveGame.get_player()

func _on_key_picked_by_player() -> void:
	Player.FrameFreeze(.4, 2.0)
