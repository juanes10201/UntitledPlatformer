extends PointLight2D
@onready var InitialEnergy = energy

enum AnimationTypes{
	none,
	flickering,
	slow_burn,
	fast_burn
}
var Step : int = 0
@export var CurrentAnimation : AnimationTypes = AnimationTypes.none

@onready var EditorLights : Node2D = $EditorLights

func _ready() -> void:
	if(!Edition.LightsEnabled && !Edition.Is_in_editor):
		queue_free()

func _process(delta: float) -> void:
	if(Edition.Is_in_editor && !Edition.Is_playing_in_editor): return
	if(CurrentAnimation == AnimationTypes.slow_burn || CurrentAnimation == AnimationTypes.fast_burn):
		if(Step == 0):
			energy = lerpf(energy, 0, 1*delta if CurrentAnimation == AnimationTypes.fast_burn else .5*delta)
			if(energy <= .1): Step = 1
		elif(Step == 1):
			energy = lerpf(energy, InitialEnergy, 1*delta if CurrentAnimation == AnimationTypes.fast_burn else .5*delta)
			if(energy >= InitialEnergy-.1): Step = 0
	elif(CurrentAnimation == AnimationTypes.flickering):
		if(Time.get_ticks_usec() % 20 == 0):
			#print(Time.get_ticks_usec())
			energy = randf_range(0, InitialEnergy)
