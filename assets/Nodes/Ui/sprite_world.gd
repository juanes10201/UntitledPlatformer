extends AnimatedSprite2D
@export var LevelSelectorNode : Node2D

func _process(delta: float) -> void:
	frame = LevelSelectorNode.CurrentWorld
