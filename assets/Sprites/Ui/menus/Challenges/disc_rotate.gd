extends AnimatedSprite2D
@export var SpeedRotate : float = .5

func _process(delta: float) -> void:
	frame = 0 if !Global.BSide else 1
	rotation += SpeedRotate*delta
