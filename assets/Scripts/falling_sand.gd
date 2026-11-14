extends RigidBody2D
@export_group("General")
@export var Activate_on_color : Global.LASER_COLORS = Global.LASER_COLORS.NONE
@export var is_falling : bool = false
@export var MAX_SPEED : float = 300.0
@export var GravityDirection : Global.GravityDirections = Global.GravityDirections.MAIN

@export_group("Physics variables")
#@export var push_force : float = 80.0
@export var wait_time : float = 0.1

@onready var CurrentGravityDirection : Global.GravityDirections = GravityDirection

@onready var MoveParticles = $MoveParticles
var was_falling : bool = is_falling

var is_playing : bool = false

@onready var SandTimer = $SandTimer

@export var RetroStyle : bool = false

var OriginalPos = Vector2(0, 0)

var editable = preload("res://assets/Scripts/default_object.gd").new()
var Hovering : bool = false
var StatePlaying : bool = false
@onready var Player = SaveGame.get_player()

@onready var Sprite = $Sprite2D

@onready var RetroTimer = $RetroTimer
@onready var RetroTimerMove = $RetroTimerMove
var paused : bool = false
@export var Enabled : bool = true
@export var CanKillPlayer : bool = true

#region Editor
var EditorInitialPos : Vector2 = Vector2(0.0,0.0)
var EditorIsFalling : bool = false
func cache_values_editor() -> void:
	EditorInitialPos = position
	_ready()
	EditorIsFalling = is_falling
	set_falling(EditorIsFalling)

func editor_reset() -> void:
	set_falling(false)
	position = EditorInitialPos
	MoveParticles.emitting = false
	is_falling = EditorIsFalling

#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(RetroStyle):
		linear_damp = 6.0
		angular_damp = 10.0
	if(!is_falling):
		set_deferred("freeze", true)
	else:
		set_deferred("freeze", false)
	SandTimer.wait_time = wait_time
	if(RetroStyle):
		$Sprite2D2.hide()
		$SpriteRetro.show()


@export var grab_grid : float = 8.0
func _process(delta: float) -> void:
	if(!is_falling && Activate_on_color != Global.LASER_COLORS.NONE && Player.LASERS_ENABLED[Activate_on_color]):
		set_falling(true)
	if(Player):
		CurrentGravityDirection = GravityDirection * Player.GlobalGravityDirection
	if(CurrentGravityDirection == Global.GravityDirections.INVERTED):
		set_falling(true)
		#Sprite.play("inverted")
	#if(CurrentGravityDirection == Global.GravityDirections.MAIN):
		#Sprite.play("default")
		
	gravity_scale = CurrentGravityDirection
	
	if(Edition.Is_in_editor && Edition.Is_playing_in_editor != is_playing):
		self.position = OriginalPos
	elif(Edition.Is_in_editor && !Edition.Is_playing_in_editor):
		OriginalPos = self.position
	is_playing = Edition.Is_playing_in_editor
	#if(is_falling && Edition.Is_in_editor && !Edition.Is_playing_in_editor):
	#	set_falling(false)
	#	self.position = OriginalPos
	if(!Edition.Is_in_editor && Player):
		if(Player.Paused && !paused):
			was_falling = is_falling
			paused = true
			set_falling(false)
		elif(!Player.Paused && paused):
			paused = false
			set_falling(was_falling)
		#else:
			#if(was_falling && !is_falling):
			#	set_falling(true)
		#set_falling(false)

var OldVel = null

func _integrate_forces(state):
	var velocity = state.linear_velocity
	var speed = velocity.length()
	if(!OldVel): OldVel = velocity
	
	if(!RetroTimerMove.is_stopped() || !RetroStyle):
		if(RetroStyle):
			state.linear_velocity.y = MAX_SPEED * 1.5
		elif (speed > MAX_SPEED):
			state.linear_velocity = velocity.normalized() * MAX_SPEED
	else:
		state.linear_velocity = Vector2(0.0, 0.0)

#var SlamAdd : int = 1000

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") || body.is_in_group("Enemie") || body.is_in_group("Boss")):
		if (body.is_in_group("Player")):
			if(body.ReplayStyle): return
			#Player.GravitySandFallDirection = Player.GlobalGravityDirection
			#if(body.GroundSmash):
			#	MAX_SPEED *= SlamAdd
			#GravityDirection = Player.GravityDirection
			body.OnSand = true
			if(!body.GroundSmash):
				await get_tree().create_timer(wait_time).timeout
		if(body.is_in_group("Boss")):
			$BossDestroy.start()
		Player._play_sound(Player.AudioSandFall, true, true, 1, 1, .6)
		set_falling(true)

func set_falling(falling : bool) -> void:
	if(!Enabled): return
	print("Changing sand fall to " + str(falling))
	if(falling && RetroStyle && !is_falling):
		RetroTimer.start()
		print("Started" )
		MoveParticles.fixed_fps = 10
		MoveParticles.interpolate = false
		MoveParticles.emitting = true
	is_falling = falling
	set_deferred("freeze", !falling)
	self.set_deferred("sleeping", !falling)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		#Player.GravitySandFallDirection = Global.GravityDirections.MAIN
		body.OnSand = false


func _on_area_2d_crush_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") && Player.GravityDirection != Global.GravityDirections.INVERTED && CurrentGravityDirection != Global.GravityDirections.INVERTED):
		if(CanKillPlayer):
			body.On_Death()


func _on_retro_timer_timeout() -> void:
	RetroTimerMove.start()
	print(1)


func _on_retro_timer_move_timeout() -> void:
	RetroTimer.start()
	print(2)


func _on_boss_destroy_timeout() -> void:
	queue_free()


func _on_boss_destroy_2_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Boss")):
		_on_area_2d_body_entered(body)
