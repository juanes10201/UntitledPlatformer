extends Area2D

enum Directions{
	Horizontal,
	Vertical
}

@export var Direction : Directions = Directions.Horizontal

@onready var LeftShape : CollisionShape2D = $LeftShape
@onready var RightShape : CollisionShape2D = $RightShape
@onready var Parent = get_parent().get_parent()
var ParentCollisionShape : CollisionShape2D

@export var BorderMargin : float = 2.0
@export var BorderSize : float = 1.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(ParentCollisionShape && Edition.Is_in_editor):
		ParentCollisionShape = get_parent().ParentCollisionShape


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(ParentCollisionShape && Edition.Is_in_editor && LeftShape && RightShape):
		global_position = Parent.global_position
		var _base_shape_size : Vector2 = ParentCollisionShape.shape.size*ParentCollisionShape.scale
		LeftShape.global_position = global_position
		RightShape.global_position = global_position
		if(Direction == Directions.Horizontal):
			LeftShape.global_position.x -= Parent.scale.x/2 * _base_shape_size.x + BorderMargin
			LeftShape.scale.y = Parent.scale.y
			LeftShape.scale.x = BorderSize
			RightShape.global_position.x += Parent.scale.x/2 * _base_shape_size.x + BorderMargin
			RightShape.scale.x = BorderSize
			RightShape.scale.y = Parent.scale.y
		else:
			LeftShape.global_position.y -= Parent.scale.y/2 * _base_shape_size.y + BorderMargin
			LeftShape.scale.x = Parent.scale.x
			LeftShape.scale.y = BorderSize
			RightShape.global_position.y += Parent.scale.y/2 * _base_shape_size.y + BorderMargin
			RightShape.scale.x = Parent.scale.x
			RightShape.scale.y = BorderSize
		visible = Edition.Is_in_editor
		LeftShape.disabled = !Edition.Is_in_editor
		RightShape.disabled = !Edition.Is_in_editor
