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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(!Edition.LightsEnabled): queue_free()
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
