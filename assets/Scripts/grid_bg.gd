extends Sprite2D

@onready var first_pos : Vector2 = self.position

enum Directions{
	LEFT,
	RIGHT
}
var move_direction : Directions = Directions.LEFT

@onready var objetive_move : Vector2 = Vector2(first_pos.x+difference_move, first_pos.y+difference_move)
@export var difference_move : int = 500
@export var move : int = 100
@export var PlayAnimation : String = "move"

@export var Show : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(get_parent() is Parallax2D): get_parent().show()
	z_index = -5
	if($AnimationPlayer): $AnimationPlayer.play(PlayAnimation)
	if(Show):
		self.show()
	else:
		self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if(objetive_move.x != first_pos.x && objetive_move.y != first_pos.y):
	position.x = move_toward(first_pos.x, objetive_move.x, move*delta)
	position.y = move_toward(first_pos.y, objetive_move.y, move*delta)
	#else:
	#	move_direction == Directions.LEFT if move_direction == Directions.RIGHT else Directions.RIGHT
	#	objetive_move = Vector2(first_pos.x*-1+difference_move, first_pos.y*-1+difference_move)
  


func _on_style_add_box_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_dialogue_trigger_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
