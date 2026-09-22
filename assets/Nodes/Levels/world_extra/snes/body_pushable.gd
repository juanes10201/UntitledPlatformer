extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var throwed : bool = false
var physics_with_player : bool = false

@onready var TimerEnablePhysics = $TimerEnablePhysics
@onready var TimerMaxTimeBreak = $TimerMaxTimeBreak
@onready var Player = SaveGame.get_player()
@onready var CollisionShape = $CollisionShape2D

@export var AddedVel : float = 50.0
@export var MaxVel : Vector2 = Vector2(0.0, 0.0)
var enabled : bool = true

func _physics_process(delta: float) -> void:
	if(enabled):
		#print(Player.velocity)
		#if(!is_on_floor()):
		#	velocity += get_gravity() * delta
		#else:
		#	velocity.y = 0.0
		
		if(abs(velocity.x) > MaxVel.x): velocity.x = MaxVel.x*sign(velocity.x)
		if(abs(velocity.y) > MaxVel.y): velocity.y = MaxVel.y*sign(velocity.y)
		
		set_collision_layer_value(24, physics_with_player)
		
		move_and_slide()

func _start_cooldown_enable_physics() -> void:
	TimerEnablePhysics.start()

func _throw(_player : Node2D) -> void:
	Player.Reset_Groundsmash(false, false, false)
	#Player.Reset_Slide()
	if(physics_with_player): return
	velocity = Player.velocity
	_start_cooldown_enable_physics()
	print("Throwed: " + str(velocity))
	#if(Player.velocity.y > Player.velocity.x): physics_with_player = true	
	if(abs(Player.velocity.x) > 50.0):
		Player.velocity.x += AddedVel*sign(velocity.x)
	if(abs(Player.velocity.y) > 50.0):
		Player.velocity.y += AddedVel*sign(velocity.y)

func _set_physics_state(state : bool) -> void:
	physics_with_player = state

func _enable_physics() -> void:
	print("Enabled Physics")
	_set_physics_state(true)

func set_state_enabled(state : bool) -> void:
	print("Set state of BodyPushable to: " + str(state))
	visible = state
	enabled = state
	if(CollisionShape):
		CollisionShape.disabled = !state

func _on_area_detect_player_body_entered(body: Node2D) -> void:
	TimerMaxTimeBreak.start()
	_throw(body)

func _on_area_detect_player_area_entered(area: Area2D) -> void:
	TimerMaxTimeBreak.start()
	_throw(area)

func _on_timer_enable_physics_timeout() -> void:
	_enable_physics()


func _on_timer_max_time_break_timeout() -> void:
	set_state_enabled(false)


func _on_area_detect_player_area_exited(area: Area2D) -> void:
	TimerMaxTimeBreak.stop()

func _on_area_detect_player_body_exited(body: Node2D) -> void:
	TimerMaxTimeBreak.stop()
