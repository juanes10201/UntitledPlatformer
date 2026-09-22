extends RichTextLabel

@export var Animate : bool = false
@onready var OgText : String = text 
@export var TextDelay : Timer
@export var VoiceDelay : Timer
@export var Voice : AudioStreamPlayer
@export var CutOnDistance : bool = true
@onready var Player = SaveGame.get_player()

func _ready() -> void:
	text = ""
	if(!VoiceDelay): VoiceDelay = TextDelay

func animate() -> void:
	Animate = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Animate && text != OgText && TextDelay.is_stopped()):
		text = text + OgText[text.length()]
		if(text[text.length()-1] != ' ' && VoiceDelay.is_stopped()):
			Voice.stop()
			Voice.pitch_scale = randf_range(.9, 1.1)
			Voice.play()
			VoiceDelay.start()
		if(CutOnDistance && Player && self.global_position.distance_to(Player.global_position) > 250):
			Animate = false
			text = OgText
		TextDelay.start()
