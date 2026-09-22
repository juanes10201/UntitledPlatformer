extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var throwed : bool = false
var physics_with_player : bool = false

@onready var TimerEnablePhysics = $TimerEnablePhysics
@onready var Player = SaveGame.get_player()

@export var MaxVel : float = 100.0

func _physics_process(delta: float) -> void:
	#print(Player.velocity)
	if(!is_on_floor()):
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0
	
	if(abs(velocity.x) > MaxVel): velocity.x = MaxVel*sign(velocity.x)
	if(abs(velocity.y) > MaxVel): velocity.y = MaxVel*sign(velocity.y)
	
	set_collision_layer_value(4, physics_with_player)
	
	move_and_slide()

func _start_cooldown_enable_physics() -> void:
	TimerEnablePhysics.start()

func _throw(_player : Node2D) -> void:
	if(physics_with_player): return
	velocity = Player.velocity
	_start_cooldown_enable_physics()
	print("Throwed: " + str(velocity))

func _set_physics_state(state : bool) -> void:
	physics_with_player = state

func _enable_physics() -> void:
	print("Enabled Physics")
	_set_physics_state(true)

func _on_area_detect_player_body_entered(body: Node2D) -> void:
	_throw(body)
func _on_area_detect_player_area_entered(area: Area2D) -> void:
	_throw(area)

func _on_timer_enable_physics_timeout() -> void:
	_enable_physics()
