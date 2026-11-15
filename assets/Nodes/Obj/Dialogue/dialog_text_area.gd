extends Area2D
@export var Text : RichTextLabel
@export var ShowObject : Node2D
@export var HideObject : Node2D
@export var AutoActivate : bool = false
@export var AutoTime : float = 1.0

func _ready() -> void:
	if(AutoActivate):
		await get_tree().create_timer(AutoTime).timeout
		_on_body_entered(SaveGame.get_player())

func _on_body_entered(body: Node2D) -> void:
	if(body && body.is_in_group("Player")):
		if(Text):
			Text.animate()
		if(ShowObject): ShowObject.enter()
		await get_tree().create_timer(.5).timeout
		if(HideObject): HideObject.exit()
		if($Hologram && $Hologram.animation != "show"): $Hologram.play("show")


func _on_erase_text_body_entered(body: Node2D) -> void:
	if(body && body.is_in_group("Player")):
		if(Text):
			Text.Animate = false
			Text.text = ""
		if($Hologram):
			$Hologram.play("hide")
