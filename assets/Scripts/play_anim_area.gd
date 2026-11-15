extends Area2D
@export var PlayInitialAnim : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(PlayInitialAnim): $AnimationPlayer.play("Intro")

func _on_body_entered(body: Node2D) -> void:
	$AnimationPlayer.play("BodyEntered")
