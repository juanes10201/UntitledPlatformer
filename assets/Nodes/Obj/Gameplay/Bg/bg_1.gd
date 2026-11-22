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
	$ParallaxBg/Bg.position = $ParallaxBg/BgRefPos.position
	$ParallaxBg/Bg2.position = $ParallaxBg/Bg2RefPos.position
	if(RetroStyle):
		$ParallaxBg/Bg.position = round($ParallaxBg/Bg.position/1.5)*1.5
		if($ParallaxBg/Bg2):
			$ParallaxBg/Bg2.position = round($ParallaxBg/Bg2.position/1.5)*1.5
