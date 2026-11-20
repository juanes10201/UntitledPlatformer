extends PointLight2D
@onready var InitialEnergy = energy
@export var MinEnergy : float = 0.0

var Step : int = 0
@export var CurrentAnimation : Global.LIGHT_ANIMATION_TYPES = Global.LIGHT_ANIMATION_TYPES.none

@onready var EditorLights : Node2D = $EditorLights

func _process_anim_random() -> void:
	energy = randf_range(MinEnergy, InitialEnergy)

func _ready() -> void:
	if(!Edition.LightsEnabled && !Edition.Is_in_editor):
		queue_free()
	if(CurrentAnimation == Global.LIGHT_ANIMATION_TYPES.flickering):
		_process_anim_random()

func _process(delta: float) -> void:
	#if(Edition.Is_in_editor && !Edition.Is_playing_in_editor): return
	if(CurrentAnimation == Global.LIGHT_ANIMATION_TYPES.slow_burn || CurrentAnimation == Global.LIGHT_ANIMATION_TYPES.fast_burn):
		if(Step == 0):
			energy = lerpf(energy, 0, 1*delta if CurrentAnimation == Global.LIGHT_ANIMATION_TYPES.fast_burn else .5*delta)
			if(energy <= .1): Step = 1
		elif(Step == 1):
			energy = lerpf(energy, InitialEnergy, 1*delta if CurrentAnimation == Global.LIGHT_ANIMATION_TYPES.fast_burn else .5*delta)
			if(energy >= InitialEnergy-.1): Step = 0
	elif(CurrentAnimation == Global.LIGHT_ANIMATION_TYPES.flickering):
		if(Time.get_ticks_usec() % 20 == 0):
			_process_anim_random()
	elif(CurrentAnimation == Global.LIGHT_ANIMATION_TYPES.none):
		energy = InitialEnergy
