extends AnimatedSprite2D

var FlipHAnim : bool = true

@onready var JuiceStretchLogic : Node2D = $JuiceStretchLogic

@export var positions: Dictionary[String, Vector2] = {
	"Idle": Vector2(0, -0.58)
}

func offset_play(animation: String = "", flipH : bool = true):
	FlipHAnim = flipH
	if(animation in positions):
		offset = positions[animation]
		JuiceStretchLogic.Offset = offset
	play(animation)
