extends CharacterBody2D 
class_name ClassPlayer

func enemy_jump():
	pass

#region Variable defining
enum Sides{
	LEFT = -1,
	RIGHT = 1,
	NONE,
	UP
}

var SlidingInAir : bool = false
var EnableMovement : bool = true

var MoveLava : bool = false

var SlidingDirection: Sides = Sides.NONE
var WasSliding : bool = false
var Slide : bool = false

var GroundSmashMultiplier : int = 1
var GroundSmashMultiplierLimit : int = 2
@onready var SlamStorageTimer : Timer = $SlamStorageTimer
var GroundSmash : bool = false
var WasGroundSmash : bool = false
var PressingGroundSmash : bool = false

var WallJump : bool = false
var WallJumpSide: Sides = Sides.NONE
var WallJumpPreviousSide : Sides = Sides.NONE

var Speed : Vector2 = Vector2(10, 1)
var Acc : Vector2 = Vector2(500, 1)
var MaxAcc : Vector2 = Vector2(12000, 400)

var Dashed : bool = false
var DashAcc : Vector2 = Vector2(600, 400)
var DashMove : Vector2 = Vector2(0, 0) 
var DashWithJump : bool = false
var DashedWithJump : bool = false

var LASERS_ENABLED : Array[bool] = [false, false, false, false, false]

var HaveKey : bool = false

var SnappedOnRail : bool = false

var OnWaterTile : bool = false
var OnWater : bool = false
var OnWaterClampMax : float = 0
var OnWaterClampMaxDown : float = 120
var OnWaterClampMin : float = -500
var OnWaterJumpMult : float = 1.1
var OnWaterMultX : float = 1.0
var OnWaterSlamMult : float = .7
var OnWaterInitialSlide : bool = false
var OnWaterInitialSlideTile : bool = false

var DoubleJumpEnabled : bool = false
var DoubleJumped : bool = false

#region Export variables
@export var IsMainPlayer : bool = true
@export var EnableParticles : bool = true
@export var RetroStyle : bool = false
@export var PlayIntro : bool = false
var juice : bool = true
@export var Styleometter : bool = true 
@export var CountTime : bool = true
@export_group("Physics")
@export var Physics : bool = true
@export var Acc_Multiplier : float = 1.0
@export var Max_Velocity_Multiplier : float = 1.0
@onready var InvencibilityTimer : Timer = $InvencibilityTimer
@export var MoveShadowSprite : AnimatedSprite2D

@export_subgroup("Jump")
@export_range(0, 7000.0, .5, "or_greater", "or_less") var WallJumpVelocity : float = 7000.0
@export_range(0, 100, .5, "or_greater", "or_less") var jump_height : float = 70.0
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_peak : float = 0.5
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_descent : float = 0.4

@export_subgroup("Groundsmash || Slide")
@export var GroundSmashVelocity = 600

@export_range(0, 25000.0, .5, "or_greater", "or_less") var SlideInitialVelocity : float = 25000.0
@export var SlideAcc = 6000
var SlideVelocity = 0

@export_range(0, 25.0, .5, "or_greater", "or_less") var JumpCancelAcc : float = 25.0

@export_subgroup("Death")
@export_range(0, 1.5, .25, "or_greater", "or_less") var TimeDeath : float = 1.5

@export_group("Level")
@export var EnemiesPhysics : bool = true

@export_group("Music")
@export var PlayMusic : bool = true
#endregion

var Paused : bool = false

@onready var ReturnToGameTime = $ReturnToGameTime


var LastDirection : float = 1
var direction = get_axis()

@onready var DashCooldownTimer : Timer = $DashCooldownTimer
@onready var CeilingMovementMultiplierTimer : Timer = $CeilingMovementMultiplierTimer
@onready var JumpGroundsmashMultiplier : Timer = $JumpGroundsmashMultiplier
@onready var DashTime : Timer = $DashTime
@onready var PreJumpTime : Timer = $PreJumpTime
@onready var CoyoteTimer : Timer = $CoyoteTimer
@onready var Sprite : AnimatedSprite2D = $Sprite2D
@onready var EnemyGroundSlamTimer : Timer = $EnemyGroundSlamTimer
@onready var PreWallJumpTimer : Timer = $PreWallJumpTimer
@onready var Camera : Camera2D = $Camera2D
@onready var ParticlesLanding : AnimatedSprite2D = $ParticlesLanding
@onready var ParticlesSlide : GPUParticles2D = $ParticlesSlide
@onready var ParticlesJump : GPUParticles2D = $ParticlesJump
@onready var ParticlesDeathFloor : GPUParticles2D = $ParticlesDeathFloor
@onready var ParticlesDeathAir : GPUParticles2D = $ParticlesDeathAir
@onready var SlidingOnRamp : bool = false
@onready var CeilingRaycast : RayCast2D = $CeilingRaycast

@onready var AudioRail : AudioStreamPlayer = $AudioRail
@onready var AudioDash : AudioStreamPlayer = $AudioDash
@onready var AudioWalk : AudioStreamPlayer = $AudioWalk
@onready var AudioSlide : AudioStreamPlayer = $AudioSlide
@onready var AudioGroundsmash : AudioStreamPlayer = $AudioGroundsmash
@onready var AudioWind : AudioStreamPlayer = $AudioWind
@onready var AudioJump : AudioStreamPlayer = $AudioJump
@onready var AudioWalkSand : AudioStreamPlayer = $AudioWalkSand
@onready var AudioSwitch : AudioStreamPlayer = $AudioSwitch
@onready var AudioKey : AudioStreamPlayer = $AudioKey
@onready var AudioDeath : AudioStreamPlayer = SongPlayer.AudioDeath
@onready var AudioOrbGravity : AudioStreamPlayer = $AudioOrbGravity
@onready var AudioSandFall : AudioStreamPlayer = $AudioSandFall
@onready var AudioUpgrade : AudioStreamPlayer = $AudioUpgrade
@onready var AudioWaterSplash : AudioStreamPlayer = $AudioWaterSplash

@onready var AudioClockBreak : AudioStreamPlayer = $AudioClockBreak

@onready var AudioSlimeKill : AudioStreamPlayer = $AudioSlimeGroundsmash #AudioSlimeKill
@onready var AudioSlimeMove : AudioStreamPlayer = $AudioSlimeMove
@onready var AudioSlimeGroundsmash : AudioStreamPlayer = $AudioSlimeGroundsmash

@onready var TransitionOut : Node2D = $"../CanvasLayer/TransitionOut"
@onready var TransitionIn : Node2D = $"../CanvasLayer/TransitionIn"

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var UI : CanvasLayer = $"../CanvasLayer/"

@onready var DashParticles1 = $"DashParticles1"
@onready var SlamParticles1 = $"SlamParticles1"

@onready var SlideDestroyTiles = $"SlideDestroyTiles"
@onready var SlamDestroyTiles = $"SlamDestroyTiles"
@onready var UmbrellaDestroyTiles = $"UmbrellaDestroyTiles"
@onready var RailDestroyTiles = $"RailDestroyTiles"

#@onready var OriginalCameraY : float = Camera.offset.y if Camera else 0

var StickOnPlatform : bool = false

var Pause_fadeout : bool = false
var OnSand : bool = false
var was_on_floor : bool = true
var was_on_floor_raycast : bool = true
var Dead : bool = false

var JumpedUmbrella : bool = false

var VelXChangingSide : bool = false

var CanJump : bool = true

var EnabledKillBox : Global.KillBoxTypes = Global.KillBoxTypes.Red

@onready var OriginalPos : Vector2 = self.position

var GravityDirection : Global.GravityDirections = Global.GravityDirections.MAIN
var GravitySandFallDirection : Global.GravityDirections = Global.GravityDirections.MAIN

var SwitchedGravity : bool = false
var PlayedSwitchedGravityAnimation : bool = false

@export var Particles : bool = true

@onready var Time_Left : Timer = $"../Time_Left"

var KickSpeed : Vector2 = Vector2(0.0,0.0)
@onready var KickTimer : Timer = $KickTimer



enum AirSides{
	Jumping = 1,
	Falling = 2,
	NONE = 0
}

var AirState : AirSides = AirSides.NONE

#endregion

func _play_dash_particles():
	if(Particles):
		DashParticles1.emitting = true
func _stop_dash_particles():
	DashParticles1.emitting = false

func _play_slam_particles():
	if(Particles):
		SlamParticles1.emitting = true
func _stop_slam_particles():
	SlamParticles1.emitting = false

@export_group("Recording")
@onready var Replay = $System_replay
@export var ReplayAction : Global.ReplayStates = Global.ReplayStates.RECORD
@export var ReplayStyle : bool = false
@export var ReplayMilisecDelay : float = 0.0
var RecordedActions : Array[Vector3] = []
var RecordedPositions : Array[Vector3] = []
@export var RecordedLocation : String = "res://assets/Replays/tutorial_level1_1.json"

var Moved : bool = false

var PositionDifference : Vector2
@onready var LastPosition : Vector2 = global_position
@onready var InvincibleSlimeCooldown : Timer = $InvincibleSlimeCooldown

#region Editor
var EditorInitialPos : Vector2 = Vector2(0.0,0.0)

const CornerCorrectionAmount : int = 3


func _corner_correction_tick(amount : int, delta : float) -> void:
	#El punto es si al moverse verticalmente con la velocidad que tiene toca algo
	
	#Deberia de implementarlo para el Slam? Si este el caso, entonces cambiar
	#velocity.y < 0 a abs(velocity.y) > 0
	
	###Para el salto
	if(velocity.y < 0.0 && test_move(global_transform, Vector2(0.0, velocity.y*delta))):
		for i in range(1, amount+1):
			for j in [-1.0, 1.0]:
				if !test_move(global_transform.translated(Vector2(i*j, 0.0)) , Vector2(0.0, velocity.y*delta)):
					translate( Vector2(i*j, 0.0) )
					print("Corner Corrected Jump")
					#global_position.x = round(global_position.x*16)*16 - 1.99*j
					return
	###Para el dash
	if(!DashTime.is_stopped() && test_move(global_transform, Vector2(velocity.x*delta, 0.0)) ):
		for i in range(1, amount*2+1):
			for j in [-1.0, 1.0]:
				if !test_move(global_transform.translated(Vector2(0.0, i*j)) , Vector2(velocity.x*delta, 0.0)):
					translate( Vector2(0.0, i*j) )
					print("Corner Corrected Dash")
					#global_position.x = round(global_position.x*16)*16 - 1.99*j
					return

func cache_values_editor() -> void:
	EditorInitialPos = position
	_ready()

func editor_reset() -> void:
	for Child in get_children():
		if(Child is Timer):
			Child.stop()
		if(Child is GPUParticles2D || Child is CPUParticles2D):
			Child.emitting = false
	position = EditorInitialPos
	velocity = Vector2(0.0, 0.0)
	Speed = Vector2(0.0, 0.0)
#endregion

func reset_dead() -> void:
	strech_size(1.0, 1.0, true)
	Sprite.play("Idle")
	Reset_Slide()
	Reset_Groundsmash(false, false, true)
	Dead = false
	Sprite.show()
	EnabledKillBox = Global.KillBoxTypes.Red
	MoveLava = false
	Dashed = false

func array_to_vec3(arr: Array) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for a in arr:
		out.append(Vector3(a[0], a[1], a[2]))
	return out

func array_to_vec2(arr: Array) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for a in arr:
		out.append(Vector2(a[0], a[1]))
	return out

var ResUiReplay = preload("res://assets/Nodes/Ui/ui_replay.tscn")

func _load_replay_ui() -> void:	
	if (ResUiReplay != null):
		var ResUiReplayInstance = ResUiReplay.instantiate()
		if(ResUiReplayInstance != null): UI.add_child(ResUiReplayInstance)

func _load_replay(Location : String) -> void:
	if(Global.LoadingReplay): _load_replay_ui()
	var file = FileAccess.open(Location, FileAccess.READ)
	print("Loaded Replay from path: " + Location)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_ARRAY:
			RecordedActions = array_to_vec3(data)
		elif typeof(data) == TYPE_DICTIONARY:
			RecordedActions = array_to_vec3(data["actions"])
			RecordedPositions = array_to_vec3( data["positions"] )
		else:
			push_error("Invalid JSON structure")
	else:
		print("File not found")
	ReplayAction = Global.ReplayStates.REPLAY

func _save_level_replay() -> void:
	_save_replay(LevelManager.get_level_record_replay_pos(Global.Level, Global.World))

func _save_replay(Location : String) -> void:
	var json_data : Dictionary = {
		"actions": RecordedActions.map(func(v): return [v.x, v.y, v.z]),
		"positions": RecordedPositions.map(func(v): return [v.x, v.y, v.z])
	}
	
	SaveGame.SaveJsonFile(Location, json_data)
	#var file := FileAccess.open(Location, FileAccess.WRITE)
	#file.store_string(JSON.stringify(json_data, "\t"))
	print("Saved Replay Json; Location: " + str(Location))

#region Debug
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			LevelManager.change_to_next_level()
		elif event.keycode == KEY_R:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_F2:
			expo_did_action()
			LevelManager.ExpoMoveTimeout.paused = true
			var _scene_string = "res://assets/Nodes/Ui/main_menu_w_level_preview.tscn"
			get_tree().change_scene_to_file(_scene_string)
		elif event.keycode == KEY_F3:
			expo_did_action()
			LevelManager.ExpoMoveTimeout.paused = true
			var _scene_string = "res://assets/Nodes/Ui/select_level_world1.tscn"
			get_tree().change_scene_to_file(_scene_string)
		elif event.keycode == KEY_F4:
			LevelManager.ExpoTimer.wait_time -= 60.0
			Edition.reset_expo()
		elif event.keycode == KEY_F5:
			LevelManager.ExpoTimer.wait_time += 60.0
			Edition.reset_expo()
		elif event.keycode == KEY_F6:
			if(ReplayAction != Global.ReplayStates.STOPPED):
				_save_replay("res://assets/Replays/saved_replay.json")
		elif event.keycode == KEY_F9:
			Edition.ExpoLimitedTime = !Edition.ExpoLimitedTime
		elif event.keycode == KEY_F10:
			if(Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.retail):
				Edition.GAME_STATUS = Edition.ALL_GAME_STATUS.expo
			else:
				Edition.GAME_STATUS = Edition.ALL_GAME_STATUS.retail
			Edition.reset_expo()
		elif event.keycode == KEY_F11:
			Edition.reset_expo()
		elif event.keycode == KEY_F12:
			Edition.LimitWorlds = !Edition.LimitWorlds
		elif event.keycode == KEY_F7:
			if(ReplayAction != Global.ReplayStates.STOPPED):
				_save_replay("res://assets/Replays/saved_replay.json")
#endregion

const MinShadowAlpha : float = .2
const MaxShadowAlpha : float = 0.7
const MaxShadowSpeed : float = 10.0

var PreviousCanvasPos : Vector2

func _get_canvas_position() -> Vector2:
	var canvas_position = get_canvas_transform().origin
	return canvas_position + global_position

func _shadow_tick() -> void:
	var _CanvasPosition = _get_canvas_position()
	var _CanvasVel = PreviousCanvasPos-_CanvasPosition
	if(!MoveShadowSprite): return
	var _speed_val : float = sqrt(_CanvasVel.x*_CanvasVel.x+_CanvasVel.y*_CanvasVel.y)
	var _shadow_alpha : float = _speed_val/MaxShadowSpeed*MaxShadowAlpha
	_shadow_alpha = clampf(_shadow_alpha, MinShadowAlpha, MaxShadowAlpha )
	
	MoveShadowSprite.material.set_shader_parameter("max_alpha", _shadow_alpha)
	#print(_shadow_alpha)
	#print("Speed: " + str(_speed_val))
	PreviousCanvasPos = _get_canvas_position() #_get_camera_distance()

@export var TimerIntroSlam : Timer

func _ready() -> void:
	#Time_Left.paused = true
	MaxAcc.x *= Max_Velocity_Multiplier
	if(!Edition.Is_in_editor):
		_set_time_state(CountTime)
	if(RetroStyle):
		ParticlesSlide.fixed_fps = 15
		ParticlesSlide.interpolate = false
		ParticlesJump.fixed_fps = 15
		ParticlesJump.interpolate = false
		ParticlesDeathFloor.fixed_fps = 15
		ParticlesDeathFloor.interpolate = false
		ParticlesDeathAir.fixed_fps = 15
		ParticlesDeathAir.interpolate = false
	if(ReplayAction == Global.ReplayStates.REPLAY):
		_load_replay(RecordedLocation)
	if(SaveGame.get_config_value("Particles") != null):
		Particles = SaveGame.get_config_value("Particles")
	if(juice && SaveGame.get_config_value("Juice") != null):
		juice = SaveGame.get_config_value("Juice")
	Engine.time_scale = 1
	if(LevelManager.StyleTimer.is_stopped()): 
		LevelManager.ExpoMoveTimeout.paused = false
		LevelManager.StyleTimer.start()
	if(Global.LoadingReplay && ReplayAction != Global.ReplayStates.REPLAY):
		print("Loading replay from local Player movement:")
		_load_replay(LevelManager.get_level_record_replay_pos(Global.Level, Global.World))
		#print(RecordedActions)
	
	if(Physics && Edition.Mobile):
		var MobileControls = preload("res://assets/Nodes/Obj/Ui/ui_android_control.tscn")
		if (MobileControls != null):
			var MobileControlsInstance = MobileControls.instantiate()
			if(MobileControlsInstance != null): UI.add_child(MobileControlsInstance)
	#if(SaveGame.PlayedIntro() && Edition.GAME_STATUS != Edition.ALL_GAME_STATUS.expo): PlayIntro = false
	if(PlayIntro):
		#If level is not identified search for it
		#SaveGame.PlayedIntroBool = true
		Global.Level = 0
		Physics = false
		Sprite.hide()
		TimerIntroSlam.start()
		LevelManager.ExpoMoveTimeout.start()
	
	if(TransitionOut): TransitionOut.hide()
	if(TransitionIn): TransitionIn.show()
	if(TransitionIn): TransitionIn.fade_out()
	
	if(PlayIntro):
		$Camera2D/AnimationPlayer.play("Start")
		#Camera.offset.y = $Camera2D/InitialPoint.global_position.y
		FrameFreeze(.4, 2)
	
	#region Change music style to ingame
	if(PlayMusic && SongPlayer.MusicState != SongPlayer.MusicStates.boss1):
		SongPlayer.MusicState = SongPlayer.MusicStates.ingame
	#endregion
	
#region Physics proccess
func _physics_process(delta: float) -> void:
	if(!Paused):
		LevelManager.world_timer_tick(delta)
		LevelManager.calc_world_timer_mult()
	
	PositionDifference = global_position - LastPosition
	#print(velocity)s
	if(!Moved):
		if(velocity != Vector2(0.0,0.0) || Input.is_action_just_pressed("player_dash") || Input.is_action_just_pressed("player_jump") || Input.is_action_just_pressed("player_jump") || Input.is_action_just_pressed("player_slide") || Input.is_action_just_pressed("player_move")):
			Moved = true
			if(CountTime):
				Time_Left.paused = false
	
	#print(OnWaterInitialSlideTile)
	if($MovingPlatformRay):
		$MovingPlatformRay.enabled = StickOnPlatform
		if($MovingPlatformRay.is_colliding()):
			position.x = $MovingPlatformRay.get_collision_point().x
	SlideDestroyTiles.target_position.x = abs(SlideDestroyTiles.target_position.x)
	if(LastDirection < 0): SlideDestroyTiles.target_position.x *= -1
	if(ReplayStyle):
		Sprite.modulate.a = 0.7
		Particles = false
	if($WaterParticles):
		$WaterParticles.emitting = OnWater
		$WaterParticles2.emitting = OnWater
	#if(Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo_cbb):
	#	print("time left: " + str(LevelManager.ExpoMoveTimeout.time_left))
	if(Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo && LevelManager.ExpoMoveTimeout.is_stopped()):
		expo_did_action()
		LevelManager.ExpoMoveTimeout.paused = true
		var _scene_string = "res://assets/Levels/world1/main_menu_w_level_preview.tscn"
		get_tree().change_scene_to_file(_scene_string)
	
	if(_is_on_floor()):
		if(!KickTimer.is_stopped()):
			KickSpeed = Vector2(0.0, 0.0)
			KickTimer.stop()
		DashedWithJump = false
		SlidingInAir = false
		SwitchedGravity = false
		PlayedSwitchedGravityAnimation = false
	#region Set direction
	#Sprite direction
	if(Sprite.FlipHAnim): Sprite.flip_h = false if LastDirection >= 0 else true
	else:
		Sprite.flip_h = false
	$Wallchecker.rotation_degrees = 90 if LastDirection < 0 else -90
	_pause_menu_end_tick()
	#endregion
	#if(PlayIntro):
	#	Camera.offset.y = lerpf(Camera.offset.y, OriginalCameraY, .6*delta)
	_shadow_tick()
	if(Physics && !SnappedOnRail):
		LevelManager.ExpoMoveTimeout.paused = false
		if(velocity.y > 0):
			AirState = AirSides.Falling
		elif(velocity.y < 0):
			AirState = AirSides.Jumping
		else:
			AirState = AirSides.NONE
		
		WasSliding = false
		var direction = get_axis()
		
		if(GroundSmash):
			_play_slam_particles()
		else:
			_stop_slam_particles()
		
		if(SlidingOnRamp && !_is_on_floor()): velocity.y = GroundSmashVelocity * GravityDirection
		
		if(Input.is_action_just_pressed("menu_pause")): _pause_game()
		
		if(!DashTime.is_stopped()):
			_play_dash_particles()
		else:
			_stop_dash_particles()
		
		if(SwitchedGravity && !PlayedSwitchedGravityAnimation ):
			if(!Sprite.is_playing() && Sprite.animation == "Switch_gravity"):
				PlayedSwitchedGravityAnimation = true
			Sprite.offset_play("Switch_gravity")
		elif(!DashTime.is_stopped()):
			Sprite.offset_play("Dash")
		elif(WallJump):
			Sprite.offset_play("Wall_jump")
		elif(GroundSmash):
			Sprite.offset_play("Groundsmash")
		elif(AirState == AirSides.Falling && !_is_on_floor_raycast()):
			if(OnWater):
				#if(Sprite.animation != Water_Fall)
				if(direction>0):
					Sprite.offset_play("Water_Fall_Right",false)
				elif(direction<0):
					Sprite.offset_play("Water_Fall_Left",false)
				else:
					Sprite.offset_play("Water_Fall")
			elif(!Sprite.animation == "Jump"):
				Sprite.offset_play("Jump")
		elif(AirState == AirSides.Jumping && !_is_on_floor_raycast()):
			if(OnWater):
				if(direction>0):
					Sprite.offset_play("Water_Right",false)
				elif(direction<0):
					Sprite.offset_play("Water_Left",false)
				else:
					Sprite.offset_play("Water")
			if(!Sprite.animation == "Jump_start"):
				Sprite.offset_play("Jump_start")
		elif(!Slide):
			#if(OnWater):
			#	Sprite.offset_play("Water")
			#elif(VelXChangingSide):
			#	Sprite.offset_play("Change_Walk")
			if(direction):
				Sprite.offset.y = -1.605
				Sprite.offset_play("Walking")
			else:
				Sprite.offset_play("Idle")
		if(Sprite.offset.y != -0.58 && Sprite.animation != "Walking"):
			Sprite.offset.y = -0.58
		
		#region Particles
		#region Jump initial particles
		if(!_is_on_floor_raycast() && was_on_floor_raycast):
			Reset_Slide()
			if(!ParticlesLanding.is_playing()):
				ParticlesLanding.position = self.position
				ParticlesLanding.position.y -= 5
				ParticlesLanding.set_as_top_level(true)
				ParticlesLanding.play("default")
				ParticlesLanding.show()
			if(!ParticlesLanding.is_playing()):
				ParticlesLanding.hide()
		#endregion  
		
		if(_is_on_floor_raycast() && !was_on_floor_raycast):
			strech_size(1.7, 0.5)
			ParticlesJump.emitting = false
			ParticlesLanding.hide()
		if(!_is_on_floor_raycast() && Particles):
			ParticlesJump.emitting = true
		#endregion
		_strech_tick(delta)
		_corner_correction_tick(CornerCorrectionAmount, delta)
		_physics_water(delta)
		_physics_walljump(delta) 
		_physics_jump(delta)
		_physics_apply_gravity(delta)
		_physics_h_movement(delta)
		_physics_dash(delta)
		_physics_slide_and_groundsmash(delta)

		#region Apply horizontal movement
		# Update velocity based on Speed and Dash status
		if(DashTime.is_stopped()): velocity.x = Speed.x*delta
		else: velocity.x = DashMove.x
		if(abs(velocity.x) <= MinXVelocity): velocity.x = 0.0
		#endregion
		
		#region Prevent overflow
		if(OnWater):
			if(Acc.x * GravityDirection > MaxAcc.x*OnWaterMultX): Acc.x = MaxAcc.x * GravityDirection * GravitySandFallDirection * OnWaterMultX
		else:
			if(Acc.x * GravityDirection > MaxAcc.x): Acc.x = MaxAcc.x * GravityDirection * GravitySandFallDirection
		if(velocity.y * GravityDirection > MaxAcc.y && !GroundSmash): velocity.y = MaxAcc.y * GravityDirection * GravitySandFallDirection
		#endregion
		
		#region Apply movement	
		if(direction != 0): LastDirection = direction
		
		was_on_floor = _is_on_floor()
		was_on_floor_raycast = _is_on_floor_raycast()
		
		#region Sand Sound
		if(OnSand && !Slide): _play_sound(AudioWalkSand, false)
		else: _stop_sound(AudioWalkSand)
		#endregion
		
		#When touching ceiling granted to player *1.3 multiplier in x movement, so that the player doesn't get stuck
		if(_is_on_ceiling()):
			CeilingMovementMultiplierTimer.start()
		if(!CeilingMovementMultiplierTimer.is_stopped()): velocity.x *= 1.3
		
		if(DashTime.is_stopped() && !GroundSmash):
			velocity.x += KickSpeed.x * delta
		if(KickTimer.is_stopped()):
			KickSpeed.x = lerpf(KickSpeed.x, 0, delta*7)
			KickSpeed.y = lerpf(KickSpeed.y, 0, delta*7)
		elif(KickSpeed.y != 0.0): velocity.y = KickSpeed.y
		
		# Move the character
		LastPosition = global_position
		move_and_slide()
		#endregion
	elif(SnappedOnRail):
		_physics_water(delta)
		_play_sound(AudioRail, false, true, .3)
		Sprite.play("Rail")
		_Destroy_Tiles_Slide()
		_Destroy_Tiles_Rail()
		#_physics_jump(delta)
		#move_and_slide()
		
#endregion

#region Walking sound
func _play_sound(body, override : bool = true, pitch_scale: bool = true, gain : float = 1, pitch : float = 1, min_pitch : float = .8, min_time_change : float = 0.0, max_pitch : float = 1.0):
	if(body):
		if(override && body.playing && body.get_playback_position() >= min_time_change):
			body.stop()
		if(!body.playing):
			if(body == AudioSlide): body.volume_db = -10
			body.volume_db = gain
			if(pitch_scale): body.pitch_scale = randf_range(min_pitch, max_pitch)*pitch
			body.play()
func _stop_sound(body):
	if(body.playing):
		body.stop()
func _fade_sound(body):
	var tween_fade_sound = get_tree().create_tween()
	tween_fade_sound.tween_property(body, "volume_db", -80, 0.5)
	tween_fade_sound.tween_callback(body.stop)
#endregion

@onready var OriginalWaitTime : float = Time_Left.wait_time
const MaxWaitTime : float = 999999.0

func _set_time_state(State : bool, ChangeWaitTime : bool = true):
	if(State):
		Time_Left.paused = false
		if(Time_Left.wait_time > OriginalWaitTime):
			Time_Left.wait_time = OriginalWaitTime
			Time_Left.start()
	elif(Global.Selected_Challenge != Global.CHALLENGES.speedrun):
		if(ChangeWaitTime):
			Time_Left.wait_time = MaxWaitTime
			Time_Left.start()
		else:
			Time_Left.paused = true

#region Pause and menu
func _pause_menu_end_tick() -> void:
	if(Pause_fadeout && ReturnToGameTime.is_stopped()):
		var pause = get_node("../CanvasLayer/pause_menu")
		if(pause):
			pause.queue_free()
			
		#Get timer and pause
		Time_Left.paused = false	
		#Stop player movement
		Physics = true
		#Stop enemie movement
		EnemiesPhysics = true
		Pause_fadeout = false
		Paused = false
		SongPlayer.MusicState = SongPlayer.MusicStates.ingame

var pause_menu_instance = null

func _pause_game() -> void:
	if(Edition.Is_in_editor): return
	if(!Paused):
		_spawn_pause_menu()
		#Get timer and pause
		_pause_game_no_menu()
	else: 
		_unpause_game()
	

func _pause_game_no_menu(State : bool = true) -> void:
	print("Pause: " + str(State))
	LevelManager.ExpoMoveTimeout.start()
	Time_Left.paused = State
	#Stop player movement
	Physics = !State
	#Stop enemie movement
	EnemiesPhysics = !State
	Paused = State

func _unpause_game() -> void:
	pause_menu_instance.Transition.Anim.play("fade_movement")
	ReturnToGameTime.start()
	Pause_fadeout = true

const pause_menu_path : String = "res://assets/Nodes/Obj/Ui/pause_menu.tscn"
const next_world_ui_path : String = "res://assets/Nodes/Obj/Ui/next_world_menu.tscn"

func spawn_next_world_ui() -> void:
	_pause_game_no_menu(true)
	spawn_ui_element(next_world_ui_path)

func spawn_ui_element(path : String) -> void:
	var load_node = load(path)
	if (load_node):
		var load_node_instance = load_node.instantiate()
		UI.add_child(load_node_instance)

func _spawn_pause_menu() -> void:
	var pause_menu = preload(pause_menu_path)
	if (pause_menu):
		pause_menu_instance = pause_menu.instantiate()
		UI.add_child(pause_menu_instance)
#endregion

@onready var WaterTileset = SaveGame.get_group_node("WaterTileset")
#region Water
func _physics_water(delta: float) -> void:
	if(!WaterTileset && Edition.Is_in_editor):
		WaterTileset = get_parent().get_node("TileMapLayerWater")
	if(OnWaterTile && WaterTileset && position.y >= WaterTileset.WaterLevel):
		if(Slide): OnWaterInitialSlideTile = true
		if(!OnWater): Dashed = false
		OnWaterInitialSlide = OnWaterInitialSlideTile
		#if(!OnWater):
			#_play_sound(AudioWaterSplash, true)
		OnWater = true
		#DoubleJumpEnabled = true
	else:
		OnWaterInitialSlide = false
		OnWater = false
		#DoubleJumpEnabled = false
#endregion

#region Gravity
func _physics_apply_gravity(delta: float) -> void:
	#print(velocity.y)
	if (!_is_on_floor()):
		if(OnWaterInitialSlide):
			velocity.y = 0.0
		if(OnWater):
			#velocity.y = clamp(velocity.y, OnWaterClampMin, OnWaterClampMax)
			if(is_action_pressed("player_down")):
				velocity.y = lerpf(velocity.y, OnWaterClampMaxDown, 12*delta)
			elif(velocity.y*GravityDirection > OnWaterClampMax*GravityDirection):
				velocity.y = lerpf(velocity.y, OnWaterClampMax, 10*delta)
			elif(velocity.y*GravityDirection < OnWaterClampMin*GravityDirection):
				velocity.y = lerpf(velocity.y, OnWaterClampMin, 20*delta)
		if(was_on_floor): CoyoteTimer.start()
		if(!WallJump && DashTime.is_stopped()):
			velocity.y += get_gravity_player() * Acc.y * delta * GravityDirection * GravitySandFallDirection
			if(!WallJump):
				if(velocity.y*GravityDirection < 0 && !_is_on_floor_raycast()): 
					strech_size(0.7, 1.2, true)
				elif(velocity.y*GravityDirection >= MaxAcc.y && !_is_on_floor_raycast()):
					strech_size(0.7, 1.3, true)
					#_play_sound(AudioWind, false)
		#else: velocity.y += Speed.y * delta
	if (_is_on_floor()):
		DoubleJumped = false
		Dashed = false
		_stop_sound(AudioWind)
		#DashWithJump = false
		DashWithJump = false
		if(GroundSmash):
			Reset_Groundsmash()
		if(SlidingInAir):
			SlidingDirection = Sides.NONE
			Slide = false
			Reset_Slide()
#endregion

#region Invert Gravity
func _change_gravity_decal() -> void:
	SwitchedGravity = true
	velocity.y = 100 * GravityDirection
	Dashed = false
	strech_size(1.5, 1.2)
	if(Particles): $ParticlesOrb.emitting = true
	_play_sound(AudioOrbGravity, true)

func _invert_gravity(Dir : int = GravityDirection*-1) -> void:
	GravityDirection = Dir
	JumpedUmbrella = false
	_change_gravity_decal()

var GlobalGravityDirection = Global.GravityDirections.MAIN

func _invert_gravity_remix() -> void:
	GlobalGravityDirection *= -1

#endregion

#region jump
func _physics_jump(delta: float) -> void:
	#print(Speed.x)
	# Handle jump.
	#print(PositionDifference)
	DashWithJump = false
	if(KickTimer.is_stopped()): JumpedUmbrella = false
	if(is_on_floor()):
		WallJumped = false
		if(JumpedUmbrella):
			set_collision_mask_value(4, true)
			set_collision_mask_value(3, true)
		JumpedUmbrella = false
		CanJump = true
	if ((!PreJumpTime.is_stopped() && (_is_on_floor() || WallJump || !CoyoteTimer.is_stopped() || OnWaterInitialSlide || (!DoubleJumped && DoubleJumpEnabled && $DoubleJumpCooldownTimer.is_stopped())) ) || (!PreWallJumpTimer.is_stopped() && is_action_pressed("player_jump")) ):
		if($DoubleJumpCooldownTimer):
			if($DoubleJumpCooldownTimer.is_stopped() && !_is_on_floor() && !DoubleJumped && DoubleJumpEnabled):
				DoubleJumped = true
			if($DoubleJumpCooldownTimer.is_stopped()): $DoubleJumpCooldownTimer.start()
		if(CanJump):
			SnappedOnRail = false
			DoJump(delta)
		expo_did_action()
	#Cancel jump
	if(CanJump && ( velocity.y < 0 && !is_action_pressed("player_jump") && !DashWithJump)):
		velocity.y += JumpCancelAcc * GravityDirection
	if(!CanJump):
		velocity.y += JumpCancelAcc * GravityDirection * .5
	if(is_action_pressed("player_jump")):
		SnappedOnRail = false
		expo_did_action()
		PreJumpTime.start()
	
	#Pre-detect jump
#endregion

func expo_did_action() -> void:
	if(ReplayAction != Global.ReplayStates.REPLAY):
		LevelManager.ExpoMoveTimeout.start()
		LevelManager.ExpoMoveTimeout.paused = false

var WallJumped : bool = false

func DoJump(delta : float = 1/60) -> void:
	#Slide + Jump combo
	#if(Sliding != Sides.NONE):
	#	SlidingInAir = true
	#	Speed.x = Acc.x*3 * ceil(LastDirection)
	velocity.y = jump_velocity * GravityDirection
	if(OnWater): velocity.y *= OnWaterJumpMult
	if(!DashTime.is_stopped() || DashWithJump):
		DashWithJump = true
		if(!DashedWithJump):
			LevelManager.AddStyle(0, "Dash with Jump Combo")
		DashedWithJump = true
		velocity.y *= .5
		DashMove *= 2
	#En caso de haber aplicado antes un groundsmash hacer un multiplicador de velocidad
	if(!JumpGroundsmashMultiplier.is_stopped()):
		JumpGroundsmashMultiplier.start()
		velocity.y *= 1.2
	Controller_Vibrate_Player_Movement(0.2)
	_play_sound(AudioJump, false)
	#region WallJump case
	if(WallJump || !PreWallJumpTimer.is_stopped()):
		if(GroundSmash):
			GroundSmash = false
			DidSlamStorage = false
			SlamStorageTimer.start()
			velocity.y = 0
			PressingGroundSmash = false
			if(GroundSmashMultiplier < GroundSmashMultiplierLimit):
				GroundSmashMultiplier += 1.1
		var _vel_walljump = WallJumpVelocity*-1 if WallJumpPreviousSide == Sides.RIGHT else WallJumpVelocity 
		if(!WallJumped && abs(PositionDifference.x) > 1.0):
			WallJumped = true
			Speed.x = _vel_walljump
			var _vel_dif = PositionDifference.x/delta/60
			if((WallJumpPreviousSide == Sides.RIGHT && _vel_dif < 0) || (WallJumpPreviousSide == Sides.LEFT && _vel_dif > 0)):
				Speed.x += _vel_dif*.4
			else: Speed.x += _vel_dif
			#print(PositionDifference.x/delta)
			#print("walljump")
		elif(abs(Speed.x) < abs(_vel_walljump)):
			Speed.x = _vel_walljump
		#print("wall")
		PreWallJumpTimer.stop()
		#print(PositionDifference.x)
		velocity.y -= 50 * GravityDirection
		if($ParticleWalljump && !$ParticleWalljump/ParticleWallJumpAnim.is_playing()):
			#print(WallJumpSide)
			$ParticleWalljump.position = position
			$ParticleWalljump.position.x -= 6.0
			#if(WallJumpSide == 1):
			#	$ParticleWalljump.position.x -= 8.0
			$ParticleWalljump/ParticleWallJumpAnim.play("Walljump")
			$ParticleWalljump/ParticleWalljump1.play("default")
			$ParticleWalljump/ParticleWalljump2.play("default")
	#endregion

var MinXVelocity : float = 9.0

#region Horizontal movement
func _physics_h_movement(delta: float) -> void:
	var direction = get_axis()
	if(abs(direction) > 0.4): expo_did_action()
	# Fix the Movement Speed accumulating in the side touching a wall
	if(WallJump && WallJumpSide == Sides.RIGHT && Speed.x > 0): Speed.x = 0
	if(WallJump && WallJumpSide == Sides.LEFT && Speed.x < 0): Speed.x = 0
	
	# Get the input direction and handle the movement/deceleration.
	if (!WallJump && direction && Speed.x < MaxAcc.x && Speed.x > MaxAcc.x*-1):
		#_play_sound(AudioWalk, false)
		if((direction > 0 && Speed.x < 0) || (direction < 0 && Speed.x > 0)): Speed.x += Acc.x * direction
		#Move faster if coming from Walljump
		if((WallJumpPreviousSide == Sides.LEFT && direction < 0) || (WallJumpPreviousSide == Sides.RIGHT && direction > 0) && !PreWallJumpTimer.is_stopped()):
			Speed.x += Acc.x * direction *2
		
		Speed.x += Acc.x * direction * Acc_Multiplier  # Adjust speed based on input direction
	else:
		if(Speed.x > 0):
			#VelXChangingSide = true
			Speed.x -= Acc.x
		elif(Speed.x < 0):
			#VelXChangingSide = true
			Speed.x += Acc.x
		#else:
			#VelXChangingSide = false
		#_stop_sound(AudioWalk)
#endregion

var PressedSlide : bool = false
var DidSlamStorage : bool = false
var DidDiagonalSlam : bool = false

#region Slide and Ground Smash
func _physics_slide_and_groundsmash(delta: float) -> void:
	#if(OnWater && Slide):
	#	Reset_Slide()
	if(!JumpGroundsmashMultiplier.is_stopped()):
		_Destroy_Tiles_SlamJump()
	if(JumpedUmbrella):
		_Destroy_Tiles_Umbrella()
	if(GroundSmash):
		_Destroy_Tiles_Slam()
	if(!is_action_pressed("player_slide")):
		SlidingInAir = false
		SlideVelocity = 0
		#expo_did_action()
	set_collision_mask_value(4, !(GroundSmash || !JumpGroundsmashMultiplier.is_stopped() || JumpedUmbrella ) )
	if((is_action_pressed("player_slide") || PressingGroundSmash || PressedSlide)):
		expo_did_action()
		#Groundsmash/Slam
		if(!_gravity_is_on_floor_raycast() && !Slide && !SlidingInAir && !PressedSlide ):# || velocity.y < jump_height+10)):
			if(!GravityDirection): GravityDirection = Global.GravityDirections.MAIN
			if(GroundSmashVelocity && GravityDirection): velocity.y = GroundSmashVelocity * GravityDirection
			if(OnWater): velocity *= OnWaterSlamMult
			#Slam Storage
			if(!SlamStorageTimer.is_stopped()):
				if(!DidSlamStorage):
					DidSlamStorage = true
					LevelManager.AddStyle(1, "Slam Storage")
				velocity.y *= GroundSmashMultiplier
			GroundSmash = true
			JumpedUmbrella = false
			if(!DashTime.is_stopped() && !DidDiagonalSlam):
				LevelManager.AddStyle(0, "Diagonal Groundsmash")
				DidDiagonalSlam = true
			PressingGroundSmash = true
		#Slide
		elif(!SlidingInAir && !PressingGroundSmash):
			if(!PressedSlide):
				SlidingDirection = Sides.RIGHT if LastDirection > 0  else Sides.LEFT
				SlideVelocity = SlideInitialVelocity
			_Destroy_Tiles_Slide()
			SlideVelocity += SlideAcc * delta
			PressedSlide = true
			
			_play_sound(AudioSlide, false)
			Controller_Vibrate_Player_Movement(0.2)
			Speed.x = SlideVelocity * SlidingDirection
			#if(SlidingOnRamp): Speed.x *= 1.2
			Slide = true
			if(Particles): ParticlesSlide.emitting = true
			strech_size(1, .9)
			Sprite.play("Slide")
			set_collision_mask_value(3, false)
		#elif(Slide && velocity.y < 0):
		#	Speed.x = SlideVelocity * Sliding
	if(PressedSlide && !is_action_pressed("player_slide")):
		Reset_Slide()
		Speed.x = 0
		PressedSlide = false
		print("reseted")
	
	#if(!SlidingInAir):
		#strech_size(1, 1)
	if(!Slide && !JumpedUmbrella): set_collision_mask_value(3, true)
	#if(!GroundSmash && !JumpedUmbrella): set_collision_mask_value(4, true)
	if(!is_action_pressed("player_slide") && _is_on_floor() ):
		PressingGroundSmash = false

func Reset_Slide():
	_fade_sound(AudioSlide)
	#SlidingDirection = Sides.NONE
	ParticlesSlide.emitting = false
	Slide = false
	OnWaterInitialSlideTile = false
	if(InvincibleSlimeCooldown): InvincibleSlimeCooldown.start()
	#if(!SlidingInAir):
		#Speed.x = 0
	#SlideVelocity = 0

	#endregion

#region Dash
func _physics_dash(delta: float) -> void:
	#Dash
	if(is_action_pressed("player_dash") && !Dashed && DashCooldownTimer.is_stopped()):
		DashCooldownTimer.start()
		if(Slide): LevelManager.AddStyle(0, "Slide Dash")
		expo_did_action()
		velocity.y = 0
		Dashed = true
		AudioDash.pitch_scale = randf_range(0.8, 1.2)
		AudioDash.play()
		strech_size(2.5, 0.5)
		DashTime.start()
		DashMove = DashAcc
		if(LastDirection != 0): DashMove *= ceil(LastDirection)
		if(OnWater):
			DashMove *= OnWaterMultX
		Controller_Vibrate_Player_Movement(0.7)
	#Dash movement
	if(DashWithJump): DashMove = DashAcc * LastDirection
	if(DashTime.is_stopped()):
		if(DashMove.x > 250): DashMove.x -= Acc.x * LastDirection
		else: DashMove.x = 0
		if(DashMove.y > 250): DashMove.y -= Acc.y * LastDirection
		else: DashMove.y = 0
	#La idea es que al ejecutar un dash el movimiento vertical este suspendido
	elif(SwitchedGravity): velocity.y = 0
#endregion


#region WallJump
var WalljumpVel : float = 0.0
func _physics_walljump(delta: float) -> void:
	#print(velocity.y)
	#The idea is to mantain some vertical movement, but still be able to jump more than before, like SuperMeatBoy
	#print(velocity.y)
	direction = get_axis()
	if(is_near_wall() && direction && !Slide):
		CanJump = true 
		Dashed = false
		WallJumped = false
		#print("walljump")
		if(!GroundSmash):
			if($Wallchecker.get_collider() is not StaticBody2D || $Wallchecker.get_collider().collision_layer != 65536):
				#print("walljump")
				WalljumpVel += 50* delta * GravityDirection
				if(!WallJump):
					WalljumpVel = 50 * GravityDirection
				if(OnWater): WalljumpVel = lerpf(velocity.y, OnWaterClampMaxDown, .01*delta)
				velocity.y = WalljumpVel
			else:
				velocity.y = 0.0
		WallJump = true
		if(direction > 0):
			WallJumpSide = Sides.RIGHT
			if(WallJumpPreviousSide == Sides.NONE): WallJumpPreviousSide = Sides.RIGHT
		else:
			WallJumpSide = Sides.LEFT
			if(WallJumpPreviousSide == Sides.NONE):  WallJumpPreviousSide = Sides.LEFT
	else:
		#print("no walljump")
		if(WallJump):
			PreWallJumpTimer.start()
			DoubleJumped = false
		if(PreWallJumpTimer.is_stopped()): WallJumpPreviousSide = Sides.NONE
		WallJump = false
	#endregion

#region Controller vibration
func Controller_Vibrate_Player_Movement(Force):
	Input.start_joy_vibration(0, 0.3 * Force, 0.4 * Force, 0.2)
#endregion


#region Juice

#region Streching and scaling
@onready var original_scale = Sprite.scale
var Stretch_speed : float = 20
func strech_size(X : float, Y : float, Override : bool = true, Speed : float = 20):
	Stretch_speed = Speed
	if(juice):
		if(Override || (Sprite.scale.x == original_scale.x && Sprite.scale.y == original_scale.y) ):
			Sprite.scale = Vector2(original_scale.x*X, original_scale.y*Y*GravityDirection)

func _strech_tick(delta : float):
	if(juice):
		Sprite.scale.x += (original_scale.x - Sprite.scale.x) * Stretch_speed * delta
		Sprite.scale.y += ((original_scale.y*GravityDirection) - Sprite.scale.y) * Stretch_speed * delta
#endregion
#andino was here
#region FrameFreeze
var FrameFreezeEnabled : bool = false
func FrameFreeze(TimeScale, duration):
	if(!FrameFreezeEnabled):
		FrameFreezeEnabled = true
		Engine.time_scale = TimeScale
		await(get_tree().create_timer(duration * TimeScale).timeout)
		Engine.time_scale = 1
		FrameFreezeEnabled = false
#endregion
#endregion

func get_gravity_player() -> float:
	if(GravityDirection == Global.GravityDirections.INVERTED):
		return fall_gravity if velocity.y < 0.0 else jump_gravity
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func kicked_boss(mult : float = 1.0) -> void:
	DashTime.stop()
	GroundSmash = false
	Reset_Groundsmash()
	velocity.y = -200
	velocity.y *= 2
	KickSpeed.x = 25000.0 * mult
	Dashed = false

#region Death
func On_Death():
	if(Physics && InvencibilityTimer.is_stopped()):
		LevelManager.RemoveStyle(100)
		if(_is_on_floor_raycast() && Particles): ParticlesDeathFloor.emitting = true
		elif(Particles): ParticlesDeathAir.emitting = true
		Sprite.hide()
		Physics = false
		Dead = true
		_play_sound(AudioDeath, true)
		#TransitionOut.show()
		#TransitionOut.fade_out()
		if(Edition.Is_in_editor):
			await(get_tree().create_timer(TimeDeath).timeout)
			#Dead = false
			#Sprite.show()
			ParticlesDeathAir.emitting = false
			ParticlesDeathFloor.emitting = false
			#get_parent()._play_state_tick(true)
		if(!Edition.Is_in_editor && !ReplayStyle && !Global.LoadingReplay && ReplayAction != Global.ReplayStates.REPLAY):# && ReplayAction == Global.ReplayStates.STOPPED):
			await(get_tree().create_timer(TimeDeath).timeout)
			if get_tree():
				get_tree().reload_current_scene() 
#endregion

@onready var SlamJumpDestroyTiles : RayCast2D = $SlamJumpDestroyTiles
func _Destroy_Tiles_SlamJump() -> void:
	if(!SlamJumpDestroyTiles): return
	SlamJumpDestroyTiles.target_position.y = abs(SlamJumpDestroyTiles.target_position.y)*GravityDirection*(-1)
	_Raycast_Destroy_Tiles(SlamJumpDestroyTiles)

func _Destroy_Tiles_Rail() -> void:
	_Raycast_Destroy_Tiles(RailDestroyTiles)

func _Destroy_Tiles_Slide() -> void:
	_Raycast_Destroy_Tiles(SlideDestroyTiles)

func _Destroy_Tiles_Slam() -> void:
	_Raycast_Destroy_Tiles(SlamDestroyTiles)

func _Destroy_Tiles_Umbrella() -> void:
	_Raycast_Destroy_Tiles(UmbrellaDestroyTiles)

func _Raycast_Destroy_Tiles(Raycaster : RayCast2D) -> void:
	if(ReplayStyle): return
	Raycaster.enabled = true
	if(Raycaster.is_colliding()):
		var hit_collider = Raycaster.get_collider()
		if hit_collider.get_class() == "TileMapLayer":
			var tilemap = hit_collider
			var hit_pos_global = Raycaster.get_collision_point()
			var hit_pos_local = tilemap.to_local(hit_pos_global)
			var tile_pos: Vector2i = tilemap.local_to_map(hit_pos_local)
			tilemap.set_cell(tile_pos, -1)
			
			print("Destroyed tile: " + str(tile_pos))
			
			var DestroyParticles = preload("res://assets/Nodes/Obj/Gameplay/Player/ParticleBreakGlass.tscn")
			var InstanceParticles = DestroyParticles.instantiate()
			get_tree().current_scene.add_child(InstanceParticles)
			InstanceParticles.position = self.position
			print(tile_pos)
			if(randf() > .7):
				_play_sound($AudioGlassBreak_part1, true, true, -5, 1, .9, .1)
			if(randf() > .4):
				_play_sound($AudioGlassBreak_part2, true, true, -5, 1, .7, 0.0)
			_play_sound($AudioGlassBreak_part3, true, true, -5, 1, .7, 0.2)
			_play_sound($AudioGlassBreak_part4, true, true, -5, 1, .7, .1)
			_play_sound($AudioGlassBreak_part5, true, true, -5, 1, .8, .1)
			LevelManager.AddStyle(0, "Broke Glass")


@onready var GroundRaycast : RayCast2D = $GroundRaycast
func _gravity_is_on_floor_raycast() -> bool:
	if(GravityDirection == Global.GravityDirections.INVERTED): return _is_on_ceiling_raycast()
	return _is_on_floor_raycast()

func _is_on_floor_raycast() -> bool:
	GroundRaycast.enabled = true
	#if(is_on_wall()): return _is_on_floor()
	return GroundRaycast.is_colliding()

func _is_on_ceiling_raycast() -> bool:
	if(CeilingRaycast):
		CeilingRaycast.set_collision_mask_value(4, !GroundSmash)
		CeilingRaycast.enabled = true
		return CeilingRaycast.is_colliding()
	return is_on_ceiling()

func _is_on_floor() -> bool:
	#print("Is on floor: " + str(is_on_floor()))
	#print("Is on Ceiling: " + str(is_on_ceiling()))
	if(GravityDirection == Global.GravityDirections.MAIN):
		return is_on_floor()
	else:
		return _is_on_ceiling_raycast()

func _is_on_ceiling() -> bool:
	if(GravityDirection == Global.GravityDirections.INVERTED):
		return is_on_floor()
	else:
		return _is_on_ceiling_raycast()

#region Wall Checker
func is_near_wall() -> bool:
	return $Wallchecker.is_colliding()
#endregion

func is_action_pressed(Action : String):
	if(!EnableMovement): return
	if(ReplayAction != Global.ReplayStates.REPLAY):
		return Input.is_action_pressed(str(Action))
	elif(Replay):
		return Replay.ReplayActions[Action]

func get_axis():
	if(!EnableMovement): return 0
	if(ReplayAction != Global.ReplayStates.REPLAY):
		return Input.get_axis("ui_left", "ui_right")
	elif(Replay):
		if(Replay.ReplayActions["ui_left"]): return -1
		if(Replay.ReplayActions["ui_right"]): return 1
		else: return 0

func Reset_Groundsmash(ThrowEnemies : bool = true, Visuals: bool = true, ResetVel : bool = true) -> void:
	if(Visuals):
		ParticlesLanding.position = self.position
		ParticlesLanding.position.y -= 10
		ParticlesLanding.set_as_top_level(true)
		ParticlesLanding.play("groundsmash")
		ParticlesLanding.show()
		AudioGroundsmash.play()
		if(Camera && "Shake" in Camera): Camera.Shake(10.0, 10.0)
	PressingGroundSmash = Input.is_action_pressed("player_slide")
	GroundSmash = false
	DidSlamStorage = false
	DidDiagonalSlam = false
	GroundSmashMultiplier = 1
	JumpGroundsmashMultiplier.start()
	if(InvincibleSlimeCooldown): InvincibleSlimeCooldown.start()
	if(ThrowEnemies):
		throw_enemies()
	if(ResetVel): velocity.y = 0

var GroundsmashNeedEnemiesOnGround = true
func throw_enemies(NeedOnGround : bool = true):
	GroundsmashNeedEnemiesOnGround = NeedOnGround
	enemy_jump()
	EnemyGroundSlamTimer.start()

func _on_timer_intro_slam_timeout() -> void:
	Physics = true
	Sprite.show()
	Input.action_press("player_slide")
	await get_tree().create_timer(.5).timeout
	Input.action_release("player_slide")
	LevelManager.ExpoMoveTimeout.start()


func _on_water_area_area_entered(area: Area2D) -> void:
	OnWaterTile = true
	if(Slide):
		CoyoteTimer.start()
		OnWaterInitialSlideTile = true


func _on_water_area_area_exited(area: Area2D) -> void:
	OnWaterTile = false
	OnWaterInitialSlideTile = false


func _on_water_area_body_entered(body: Node2D) -> void:
	OnWaterTile = true
	print(body)
	#WaterTileset = body
	if(Slide):
		CoyoteTimer.start()
		OnWaterInitialSlideTile = true


func _on_water_area_body_exited(body: Node2D) -> void:
	#WaterTileset = body
	if(body.is_in_group("WaterTileset")):
		WaterTileset = body
	OnWaterTile = false
	OnWaterInitialSlideTile = false


func _dialog_intro_end() -> void:
	pass
	#if(PlayIntro):
	#	TimerIntroSlam.start()
	#	$Camera2D/AnimationPlayer.play("End")
