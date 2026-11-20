extends Node2D
@export var ShadowLight : PointLight2D

func enter() -> void:
	$AudioLights.play()
	ShadowLight.hide()
	show()

func exit() -> void:
	hide()
