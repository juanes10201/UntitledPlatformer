extends Node2D

func enter() -> void:
	$AudioLights.play()
	show()

func exit() -> void:
	hide()
