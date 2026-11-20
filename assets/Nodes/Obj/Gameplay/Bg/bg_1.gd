extends Node2D

@export var Show : bool = true
@export var ShowSecond : bool = false

func _process(delta: float) -> void:
	$ParallaxBg/Bg.Show = Show
	visible = Show
	$ParallaxBg/Bg2.Show = Show if ShowSecond else false
	if(Edition.Is_in_editor):
		$Bg.visible = visible
