extends Node2D

@export var Show : bool = true

func _process(delta: float) -> void:
	$ParallaxBg/Bg.Show = Show
	visible = Show
	if(Edition.Is_in_editor):
		$Bg.visible = visible
