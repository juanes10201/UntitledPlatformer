extends Button

@export var Challenge : Global.CHALLENGES = Global.CHALLENGES.none

@export var ColorTextSelected : Color = Color(Color.CORNFLOWER_BLUE)
@onready var ColorTextUnselected = get("theme_override_colors/font_color")

func _ready() -> void:
	pass
	#text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Global.Selected_Challenge == Challenge):
		set("theme_override_colors/font_color", ColorTextSelected)
	else:
		set("theme_override_colors/font_color", ColorTextUnselected)


func _on_pressed() -> void:
	if(Global.Selected_Challenge == Challenge):
		Global.Selected_Challenge = Global.CHALLENGES.none
	else:
		Global.Selected_Challenge = Challenge
