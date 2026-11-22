extends Node2D

@export var Show : bool = true
@export var ShowSecond : bool = false
@export var RetroStyle : bool = false
var RetroTime : float = 0.0

func _process(delta: float) -> void:
	$ParallaxBg/Bg.Show = Show
	visible = Show
	$ParallaxBg/Bg2.Show = Show if ShowSecond else false
	if(Edition.Is_in_editor):
		$Bg.visible = visible
	if(RetroStyle):
		$ParallaxBg/Bg.global_position = round($ParallaxBg/Bg.global_position/4)*4
		if($ParallaxBg/Bg2):
			$ParallaxBg/Bg2.global_position = round($ParallaxBg/Bg2.global_position/4)*4
