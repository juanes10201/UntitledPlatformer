extends Area2D
@export var PlayInitialAnim : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(PlayInitialAnim): $AnimationPlayer.play("Intro")

func _on_body_entered(body: Node2D) -> void:
	$AnimationPlayer.play("BodyEntered")

func play_anim_boss_preview() -> void:
	$AnimationPlayer.play("BossPreview")

func play_anim_end_boss_preview() -> void:
	$AnimationPlayer.play("EndBossPreview")

func play_anim_low_light() -> void:
	$AnimationPlayer.play("LowLight")

func play_anim_end_dialog() -> void:
	$AnimationPlayer.play("EndDialog")
