extends CharacterBody2D


@onready var Collar = preload("res://assets/Nodes/Obj/Gameplay/Boss/Slimo/SlimeBossCollar.tscn")
#region Setup variables
@export_group("Custom")
@export var DestroyTile : TileMapLayer
@export var CameraPlayer : Camera2D
@export var AudienceSprite : Sprite2D
var InFinalAttack : bool = false
@export var FinalAttackMarkers : Array[Node2D]
var FinalAttackNumber : int = 0
@export var FinalAttackPlayerPos : Marker2D
@export var FinalAttackPos : Marker2D
@export var FinalAttackFastBombTime : float = 1.0
@export var FinalAttackFastBombQuantity : float = 4.0
@export var BossSpawner : Node2D
@export var RetroStyle : bool = false
@export var Activate_on_color : Global.LASER_COLORS = Global.LASER_COLORS.NONE
@export var EnemyDirection : Directions = Directions.RIGHT
@export var distance : float = 100
@export var GravityDirection : Global.GravityDirections = Global.GravityDirections.MAIN
@export var TimeAttack : float = 1.0
@export var DistanceSlam : float = 200.0
@export var DistanceStopMovSlam : float = 45.0
@export var DistanceSlide : float = 350.0
@export var DistanceWallJump : float = 200.0
@export var VelSlideX : float = 500.0
@export var InitialLife : int = 15
@export var LifeThrowbombs : int = 10
var Phase2 : bool = false
@export var SpawnBombTimePhase2 : float = 4.0
@export var Phase2Life : int = 5
@export var Phase2SlamTime : float = .7
@export var Phase2MoveTime : float = .7
@export var FinalAttackBombTime : float = .5
var Slide : bool = false
var WallJump : bool = false
var WallJumped : bool = false
var SlamNearPlayer : bool = false
var Dead : bool = false

@export_group("Physics")
@export var Enemy_burst_speed : float = 300.0
@export var SPEED : float = 150.0
@export var JUMP_VELOCITY : float = -370.0
@export var SPECIAL_ENEMY_JUMP_VELOCITY : float = -50.0
@export var MAX_FALL_SPEED : float = 300.0
@export var MAX_SPEED : float = 500.0
@export var Cancel_speed : float = 200.0
@export var Max_groundsmash_distance = 300.0
@export var Can_BeGroundSmash : bool = true
var CountSpecialAttack : int = 0
var WasOnFloor : bool = false

#For editor
enum Directions{
	RIGHT,
	LEFT,
	NONE
}

var OriginalX : float = position.x

var Move : bool = true

var direction = 0 

@onready var Player : ClassPlayer = SaveGame.get_player()
@onready var MoveTimer : Timer = $"MoveTimer"
@onready var Sprite : AnimatedSprite2D = $"Sprite2D"
@onready var SlamTimer : Timer = $SlamTimer

@onready var MoveSound : AudioStreamPlayer = Player.AudioSlimeMove if Player else null
@onready var SlideSound : AudioStreamPlayer = Player.AudioSlimeKill if Player else null
@onready var AudioMove : AudioStreamPlayer = Player.AudioSlimeMove if Player else null
@onready var AudioGroundsmash : AudioStreamPlayer = Player.AudioSlimeGroundsmash if Player else null

@onready var ShootBulletTimer : Timer = $ShootBulletTimer
@onready var CooldownFastTimer : Timer = $CooldownFastTimer
@onready var CooldownHitTimer : Timer = $CooldownHitTimer

@onready var BulletObject = preload("res://assets/Nodes/Obj/Gameplay/bullets.tscn")# if enemy_type == 2 else null

@export var Enabled : bool = true

var Slam : bool = false

var OriginalPos = Vector2(0, 0)

var was_on_floor : bool = false
var was_on_wall : bool = false

var StatePlaying : bool = false

@export var Particles : bool = true

@onready var PrevGravityDirection : Global.GravityDirections = GravityDirection

@onready var _Position = self.position 

@onready var AttackLight = $AttackLight

@onready var WallJumpTimer = $WallJumpTimer
@export var SlamTime : float = 1.0
@export var GroundSmashVelocity : float = 600

var Jumped : bool = false

var InteractPlayer : bool = true

@onready var EnemyLife : int = InitialLife
var Physics : bool = true
var Sleep : bool = false

var SpawnedCollar : bool = false
@onready var ExplodeBombExplode = $ExplodeBombExplode
#endregion

#region Killed by Slide or Groundsmash Sound
func _killed_by_player_sound() -> void:
	#if(!SlideSound.playing):
	if(Player):
		Player._play_sound(SlideSound, true)
func _groundsmash_player_sound() -> void:
	if(Player):
		Player._play_sound(AudioGroundsmash, true)
#endregion

#region Jumping
func _jump(_jump_velocity, ignore : bool = false, Reg : bool = true, Replace : bool = true) -> void:
	Player._play_sound($AudioGrunt1, true)
	#The idea is for the enemies to jump when the player does a ground-smash
	if(velocity.y != 0 && !Replace): return
	if(_is_on_floor() || ignore):
		velocity.y = _jump_velocity * GravityDirection*Player.GlobalGravityDirection# * randf_range(1, 1.2)
		if(Reg): Jumped = true
#endregion

#region Player GroundSmash 
func _on_player_ground_smash_signal() -> void:
	if(Player):
		if(_is_on_floor() && Player.GravityDirection == GravityDirection && global_position && global_position && Player.position && Max_groundsmash_distance && global_position.distance_to(Player.position) <= Max_groundsmash_distance):
			_jump(JUMP_VELOCITY if Can_BeGroundSmash else SPECIAL_ENEMY_JUMP_VELOCITY)
			if(Can_BeGroundSmash):
				LevelManager.AddStyle(0, "GroundSmash enemy")
				if(Particles): $HitParticles.emitting = true
				#Player.FrameFreeze(0.05, 0.4)
				velocity.x = Enemy_burst_speed if Player.position.x < position.x else Enemy_burst_speed*-1
				Move = false
				Player.Controller_Vibrate_Player_Movement(1)
				_groundsmash_player_sound()
#endregion

func start_cooldown_timer() -> void:
	CooldownHitTimer.start()
	Move = false
	_set_sleep(true)

func play_anim(anim : String) -> void:
	$Anim.play(anim)

#region Player Slide 
func _on_player_slide_signal() -> void:
	if(_is_on_floor() && Can_BeGroundSmash && Player.GravityDirection == GravityDirection):
		LevelManager.AddStyle(0, "Slide enemy")
		if(Particles): $HitParticles.emitting = true
		#Player.FrameFreeze(0.05, 0.4)
		_jump(-400)
		Player.Camera.Shake(1.0, 5.0)
		velocity.x = Enemy_burst_speed if  Player.Sliding == Player.Sides.RIGHT else Enemy_burst_speed*-1
		Player.Controller_Vibrate_Player_Movement(1)
		Move = false
		_killed_by_player_sound()
#endregion

func set_dialogue_portrait(Portrait : String) -> void:
	_Play_Animation(Portrait, false, false, false, true, false)
	print("Changed boss portrait to " + Portrait)
 
func _ready():
	SongPlayer.MusicState = SongPlayer.MusicStates.boss1
	if(RetroStyle):
		$Moveparticles.fixed_fps = 10
		$Moveparticles.interpolate = false
		$HitParticles.fixed_fps = 15
		$HitParticles.interpolate = false
		$HitFlyParticles.fixed_fps = 10
		$HitFlyParticles.interpolate = false
	if(SaveGame.get_config_value("Particles") != null):
		Particles = SaveGame.get_config_value("Particles")
	if(SlamTimer): SlamTimer.wait_time = SlamTime
	if(EnemyDirection == Directions.RIGHT): direction = 1
	elif(EnemyDirection == Directions.LEFT): direction = -1
	else: direction = 0
	if(MoveTimer): MoveTimer.wait_time = TimeAttack
	if(Activate_on_color != Global.LASER_COLORS.NONE):
		Enabled = false
		_Play_Animation("Laser")

var editable = preload("res://assets/Scripts/default_object.gd").new()
var Hovering : bool = false
@export var CanHover : bool = false

func _update_direction() -> void:
	if(self.position.x-70 > Player.position.x):
		direction = -1
	elif(self.position.x+70 < Player.position.x):
		direction = 1
	#print("Direction: " + str(direction))

func _input(event):
	if(Edition.Is_in_editor && CanHover):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if(event.pressed && editable.Editor_Hover_Check(self.position.x, self.position.y, get_global_mouse_position())):
					$"../".Is_Hovering = true
					Hovering = true
				else:
					$"../".Is_Hovering = false
					Hovering = false

func _Enemie_Shoot_Sprite_Shader() -> void:
	Sprite.material.set_shader_parameter("progress", 1-(ShootBulletTimer.time_left/ShootBulletTimer.wait_time))

@export var grab_grid : float = 8.0

var SlamJump : bool = false

func _physics_process(delta: float) -> void:
	if(Sleep && !Sprite.is_playing()):
		_Play_Animation("Sleep", false, false, false, true, false)
	
	#print(velocity.x)
	if(Dead):
		CameraPlayer.offset.x = lerpf(CameraPlayer.offset.x, 100.0, 5*delta)
	if($DebugText):
		$DebugText.text = "life: " + str(EnemyLife)
	if(Sprite.animation == "Big"):
		strech_size(1.0, 1.0)
		#print(round(position.distance_to(Player.position)/60))
		Sprite.frame = position.distance_to(Player.position)/60
		if(position.x < Player.position.x):
			Sprite.frame += 5
		else:
			Sprite.frame = 5-Sprite.frame
	if(!Physics):
		return
	#print($SpawnBomb.time_left)
	if(Slam && SlamNearPlayer):
		Player._play_sound($AudioNear, true, true, -10, 1, .7, .15, 1.2)
	if(EnemyLife <= LifeThrowbombs):
		if($SpawnBomb.is_stopped()):
			$SpawnBomb.start()
			_Play_Animation("Button", false, false, false, true)
		if(EnemyLife <= Phase2Life && !BossSpawner.Phase2):
			BossSpawner.Phase2 = true
			Phase2 = true
			$SpawnBomb.wait_time = SpawnBombTimePhase2
	if(!WallJumpTimer.is_stopped()):
		velocity.x = lerpf(velocity.x, -600.0*direction, 5*delta)
		Slam = false
	
	if(Player && Player.Time_Left && Player.Time_Left.time_left <= 5.0):
		BossSpawner.spawn_clock(true)
	if(RetroStyle):
		position = _Position
		position.x /= 8
		position.x = round(global_position.x)
		position.x *= 8
	if(!Enabled && Activate_on_color != Global.LASER_COLORS.NONE && SaveGame.get_player().LASERS_ENABLED[Activate_on_color]):
		Enabled = true
		Player._set_time_state(true, false)
	
	if(Player && Player.GlobalGravityDirection != PrevGravityDirection*GravityDirection):
		PrevGravityDirection = Player.GlobalGravityDirection * GravityDirection
		velocity.y = 100 * PrevGravityDirection*GravityDirection
	
	#
	#if(enemy_type == 2.0): _Enemie_Shoot_Sprite_Shader()
	if(Edition.Is_in_editor && Edition.Is_playing_in_editor != StatePlaying):
		OriginalPos = self.position
	if(Edition.Is_in_editor && CanHover && Hovering):
		if(Edition.IsErasingInEditor):
			self.queue_free()
		position = get_global_mouse_position()
		self.position.x = (floor(self.position.x/grab_grid)*grab_grid)+16.0
		self.position.y = (floor(self.position.y/grab_grid)*grab_grid)+10.0
	#region Physics
	if(Edition.Is_in_editor):
		if(Edition.Is_playing_in_editor):
			Enabled = true
		else:
			Enabled = false
			self.position = OriginalPos
			strech_size(1, 1)
			$Moveparticles.emitting = false
			$HitFlyParticles.emitting = false
	if(Enabled):
		if(is_on_floor()):
			Jumped = false
			SlamJump = false
		if(Jumped && !Slam && !WallJump && Move):
			if(!SlamJump && abs(position.x-Player.position.x) <= DistanceSlam && SlamTimer.is_stopped()):
				SlamTimer.start()
				Player._play_sound($AudioSlamWait)
				Player._play_sound($AudioGrunt2, true)
			if(velocity.y > 0 && !SlamTimer.is_stopped()):
				if(abs(position.x-Player.position.x) <= DistanceStopMovSlam):
					velocity.x = 0
					velocity.y = 0
					_Play_Animation("Slam_Wait", false, true, true, true)
					print("ye")
		if(Slam || (WallJump && WallJumpTimer.is_stopped())):
			if(Move):
				if(!WallJump && Slam):
					velocity.y = GroundSmashVelocity
					velocity.x = 0
					if(is_on_floor()):
						if(Jumped):
							Player._play_sound($AudioGrunt2, true)
						if(WallJump && WallJumpTimer.is_stopped()): WallJump = false
						if(Slam && !SlamJump):
							Slam = false
							Player._play_sound($AudioCrashSlam, true, true, -5, 1, .7, .15, 1.2)
							BossSpawner.spawn_clock()
							Player.Camera.Shake(20.0, 20.0)
							if(WallJumped):
								velocity.x = direction * SPEED * .4
								SlamJump = true
								_jump(JUMP_VELOCITY*.7)
								WallJumped = false
		AttackLight.enabled = (CountSpecialAttack+1) % 3 == 0
		if(Slide && Move):
			velocity.x = VelSlideX * direction
			if(is_on_wall()):
				_end_slide()
		
		#if(Player):
		if(Particles && _is_on_floor() && velocity.x > 0):
			$Moveparticles.emitting = true
		else:
			$Moveparticles.emitting = false
		#if(Particles && !_is_on_floor() && enemy_type == 0):
			$HitFlyParticles.emitting = true
		#else:
		#	$HitFlyParticles.emitting = false
		
		if(Player && Player.EnemiesPhysics):
			#if(Slam):
			#	_Play_Animation("Slam", false, true, true, true) 
			_update_sprite()
			
			#if(is_on_wall() && !was_on_wall): direction *= -1
			
			#if(is_on_ceiling()): queue_free()
			
			#var _def_x = 0.6/MAX_FALL_SPEED*velocity.y
			#var _def_y = 1.4/MAX_FALL_SPEED*velocity.y
			#strech_size(_def_x, _def_y)
			
			if(velocity.y < 0): strech_size(0.7, 1.4)
			#if(velocity.y >= MAX_FALL_SPEED): strech_size(0.4, 1.8)
			
			if(_is_on_floor() && was_on_floor == false):
				_Play_Animation("Fall", true, true)
				strech_size(1.8, 0.5)
			
			_strech_tick(delta)
			
			
			#region Trigger Player GroundSmash
			if(Player && !Player.EnemyGroundSlamTimer.is_stopped()): _on_player_ground_smash_signal()
			#endregion
			#region Gravity
			if (!_is_on_floor() &&  velocity.y < MAX_FALL_SPEED):
				velocity += get_gravity() * delta * GravityDirection*Player.GlobalGravityDirection
			#endregion
			if(direction && ChangeDir):
				Sprite.flip_h = false if direction >= 0 else true
				print(Sprite.flip_h)
			else: Sprite.flip_h = false
			Sprite.scale.y = abs(Sprite.scale.y)*GravityDirection*Player.GlobalGravityDirection
			#region Horizontal Movement
			#Enemy Movement
			if(Move && Player && !Slam && !WallJump):
				if (!Jumped && direction && SPEED < MAX_SPEED && SPEED > MAX_SPEED*-1 && MoveTimer.is_stopped()):
					if(!Slide):
						velocity.x = direction * SPEED# * randf_range(1, 1.2)
					if(abs(position.x-Player.position.x) >= DistanceSlide && !Jumped):
						Slide = true
						_Play_Animation("Roll", true, true, false)
					else:
						strech_size(1.7, 0.5)
						MoveTimer.start()
						Player._play_sound($AudioMove, true, true, 1, 1, .7, .15, 1.2)
						Player._play_sound(AudioMove, false)
						CountSpecialAttack += 1
						#Special Attack and Groundsmash
						_update_direction()
						if(CountSpecialAttack % 3 == 0):
							Player._play_sound($AudioMoveJump, true, true, 1, 1, .7, .15, 1.2)
							_jump(JUMP_VELOCITY)
							if(!Slide): velocity.x = direction * SPEED
						else:
							_jump(JUMP_VELOCITY*.3, false, false, false)
				elif(!MoveTimer.is_stopped()):
					if(direction > 0): velocity.x -= Cancel_speed*delta
					elif(direction < 0): velocity.x += Cancel_speed*delta
				#if( (direction == 1 && position.x-OriginalX >= distance) || (direction == -1 && position.x-OriginalX < distance*-1) ):
				#	direction *= -1
			else:
				if(velocity.x > 0): velocity.x -= Cancel_speed*delta
				elif(velocity.x < 0): velocity.x += Cancel_speed*delta
			#endregion
			was_on_floor = _is_on_floor()
			was_on_wall = is_on_wall()
			if(RetroStyle):
				var _pos = position
				position = _Position
				move_and_slide()
				_Position = position
				position = _pos
			else:
				move_and_slide()
	else:
		pass
#endregion

#region Scaling
@onready var original_scale = Sprite.scale
func strech_size(X, Y, Override : bool = true):
	if(InFinalAttack):
		Sprite.scale = original_scale
		return
	if(Override || (Sprite.scale.x == original_scale.x && Sprite.scale.y == original_scale.y) ):
		Sprite.scale = Vector2(original_scale.x*X, original_scale.y*Y)
		Sprite.scale.y = abs(Sprite.scale.y)*GravityDirection*Player.GlobalGravityDirection

func _strech_tick(delta : float):
	if(InFinalAttack): Sprite.scale = original_scale
	Sprite.scale.x += (original_scale.x - Sprite.scale.x) * 15 * delta
	Sprite.scale.y += (original_scale.y*GravityDirection*Player.GlobalGravityDirection - Sprite.scale.y) * 15 * delta
#endregion

#region toggle collision
func enable_collision() -> void:
	#Enable
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)
	
	set_collision_mask_value(2, false)
	set_collision_layer_value(2, false)

func disable_collision() -> void:
	#Disable
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
		
	set_collision_mask_value(2, true)
	set_collision_layer_value(2, true)

func toggle_collision() -> void:
	#Disable
	if(get_collision_mask_value(1)):
		set_collision_mask_value(1, false)
		set_collision_layer_value(1, false)
		
		set_collision_mask_value(2, true)
		set_collision_layer_value(2, true)
	else:
		#Enable
		set_collision_mask_value(1, true)
		set_collision_layer_value(1, true)
		
		set_collision_mask_value(2, false)
		set_collision_layer_value(2, false)
#endregion
#region Check collision
func check_collision() -> bool:
	if(get_collision_mask_value(1)): return true
	else: return false
#endregion

func _Spawn_Collar():
	if(Collar && !SpawnedCollar):
		SpawnedCollar = true
		var Collar_instance = Collar.instantiate()
		add_sibling(Collar_instance)
		print($CollarPositionSpawn.position)
		Collar_instance.position = $CollarPositionSpawn.position
		print(Collar_instance.position)

#region Enemie Death
func On_Death():
	if(Dead): return
	Dead = true
	#region Create destroy particles
	_Play_Animation("Explode", false, false, false, true, false)
	Player._set_time_state(false)
	$Anim.play("Explode")
	await get_tree().create_timer(3.0).timeout
	AudienceSprite._play_stage_anim("explode")
	_Spawn_Collar()
	DestroyTile.queue_free()
	CameraPlayer.limit_right += 10000
	#if(Particles):
	#	var DestroyParticles = preload("res://assets/Levels/Particles/destroy_enemy.tscn")
	#	var InstanceParticles = DestroyParticles.instantiate()
	#	get_tree().current_scene.add_child(InstanceParticles)
	#	InstanceParticles.position = self.position
	#	if(RetroStyle):
	#		InstanceParticles.RetroStyle()
	#endregion
	#self.queue_free()
#endregion

#Diferencia maxima para considerar que no se mueva
const dif_max_move = 0
func _update_sprite() -> void:
	#if Y mov > 0 then play Jump
	#If moving horizontally Walking
	#Else idle
	if(velocity.y != 0): _Play_Animation("Air")
	elif( abs(velocity.x-dif_max_move) > 0 && !is_on_wall() ): _Play_Animation("Right") if direction > 0.0 else _Play_Animation("Left") 
	elif(Sprite.animation != "Slam_Wait" && Sprite.animation != "Slam"): _Play_Animation("Idle")

func _is_on_floor() -> bool:
	if(GravityDirection*Player.GlobalGravityDirection == 1):
		return is_on_floor()
	else:
		return is_on_ceiling()


func _on_damage_jump_body_entered(body: Node2D) -> void:
	if(!InteractPlayer): return
	if(body.is_in_group("Player") && Player.GroundSmash):
		Player.Reset_Groundsmash()
		Player.velocity.y = -50
		Player.Dashed = false


func _on_slam_timer_timeout() -> void:
	print("Done Slam")
	if(!Slam):
		Player._play_sound($AudioGrunt4, true)
	Slam = true
	Player._play_sound(AudioGroundsmash, true, true, 20, .7)
	Player.Camera.Shake(7.0, 7.0)


func _on_stop_slide_area_2d_body_entered(body: Node2D) -> void:
	if(Sleep): return
	if(Jumped):
		_update_direction()
		velocity.x = direction * SPEED * 1.2
	if(!body.is_in_group("Tileset") || !(body is TileMap)): pass
	if(WallJump):
		_update_direction()
		_jump(JUMP_VELOCITY*.8, true)
		velocity.x = direction * SPEED * 1.5
		Slam = false
		WallJump = false
		WallJumped = true
	elif(Slide && !WallJump && abs(Player.position.x-position.x) >= DistanceWallJump):
		print("Walljump")
		Player._play_sound($AudioWalljump, true, true, .6, 1, .7, .15, 1.2)
		WallJumpTimer.start()
		_update_direction()
		_jump(JUMP_VELOCITY, true)
		velocity.x = direction * SPEED * 1.8
		WallJump = true
	if(Slide):
		#Done Slide and touched wall
		_end_slide()


func _end_slide() -> void:
	Player._play_sound($AudioCrashWall, true, true, -5, 1, .7, .15, 1.2)
	_update_direction()
	Slide = false
	_Play_Animation("Air", true, true, true, true)
	BossSpawner.spawn_clock()
	_jump(JUMP_VELOCITY)
	MoveTimer.start()

func _on_wall_jump_timer_timeout() -> void:
	if(!is_on_wall() and WallJump and is_on_floor()):
		WallJump = false
	#print("Ended Walljump")


func _on_damage_boss_body_entered(body: Node2D) -> void:
	if(!InteractPlayer): return
	if(body.is_in_group("Player")):
		_set_sleep(false)
		if(Player.global_position.x <= $DamagePlayerMarker.global_position.x):
			Player.kicked_boss(-1.0)
		else:
			Player.kicked_boss(1.0)
		if(CooldownFastTimer.is_stopped()):
			Player.KickTimer.start()
			CooldownFastTimer.start()
			Move = false
			EnemyLife -= 1
			LevelManager.AddStyle(1, "Damaged Boss")
			print("ATTACKED BOSS: " + str(EnemyLife))
			UpdateLife()
			Player.InvencibilityTimer.start()

func FinalAttack():
	Player._play_sound($AudioScream, true, false, 8.0)
	InFinalAttack = true
	_set_sleep(false)
	if(FinalAttackPos):
		position = FinalAttackPos.position
	#Player.position = FinalAttackPlayerPos.position
	strech_size(1.0, 1.0, true)
	Phase2 = true
	BossSpawner.Phase2 = true
	$SpawnBomb.stop()
	Physics = false
	velocity = Vector2(0.0, 0.0)
	$Anim.play("ScapeFinalAttack")
	Sprite.play("Air")
	InteractPlayer = false
	$Moveparticles.emitting = false
	$HitFlyParticles.emitting = false
	$HitParticles.emitting = false
	$FinalAttackTimer.start()
	Player.Time_Left.wait_time = 20.0
	Player.Time_Left.start()
	#$SpawnBomb.wait_time = FinalAttackBombTime
	#$SpawnBomb.start()

func _set_sleep(State: bool = true):
	if(State && InFinalAttack): return
	Sleep = State
	$ZAnim1.emitting = State
	$ZAnim2.emitting = State
	if(State):
		if(Sprite.animation != "Sleep" && Sprite.animation != "Sleep-Initial"):
			_Play_Animation("Sleep-Initial", false, false, false, true, false)
		if(Sprite.animation == "Sleep-Initial" && !Sprite.is_playing()):
			_Play_Animation("Sleep", false, false, false, true, false)
		CountSpecialAttack = 0
		Player._play_sound($AudioSnooring, true, true, -5, 1, .9, .15, 1.1)
	else:
		_Play_Animation("Idle", false, true, true, true, false)
		Player._stop_sound($AudioSnooring)

func _on_cooldown_hit_timer_timeout() -> void:
	Move = true

func UpdateLife() -> void:
	Player._play_sound($AudioHit, true, true, -10, 1, .7, .15, 1.2)
	AudienceSprite.strech_size(.9, 1.2, true)
	_Play_Animation("Damage", false, true, false, true)
	if(!CooldownHitTimer.is_stopped()): Player._play_sound($AudioPop, true, true, .6, 1, .7, .15, 1.2)
	if(EnemyLife <= Phase2Life):
		print("Entered phase 2")
		MoveTimer.wait_time = Phase2MoveTime
		SlamTimer.wait_time = Phase2SlamTime
	#if(EnemyLife <= 0):
	#	On_Death()
	if(EnemyLife <= 1):
		FinalAttack()

var CurrentAnimBeOverrided : bool = true

var ChangeDir : bool = false
func _Play_Animation(Anim : String, ChangeDirection : bool = false, Phase : bool = true, CanBeOverrided : bool = true, Override : bool = false, StopPlayer : bool = false) -> void:
	ChangeDir = ChangeDirection
	if(StopPlayer):
		Player.EnableMovement = !StopPlayer
		Physics = false
	if(!Override && !CurrentAnimBeOverrided && Sprite.is_playing()): return
	CurrentAnimBeOverrided = CanBeOverrided
	if(!Phase || EnemyLife > Phase2Life):
		Sprite.play(Anim)
	else:
		Sprite.play("Phase2_" + Anim)
	print("Played boss anim: " + Anim)

func _spawn_bomb(MoveToPlayer : bool = true, Pos : Vector2  = Vector2(0.0,0.0), KeepTimer : bool = true) -> void:
	Player._play_sound($AudioIntroBomb, true, true, -5, 1, .7, .15, 1.2)
	BossSpawner.spawn_bomb(MoveToPlayer, Pos)
	if(KeepTimer): $SpawnBomb.start()

func _on_spawn_bomb_timeout() -> void:
	_spawn_bomb()

func _on_area_near_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")): SlamNearPlayer = true

func _on_area_near_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")): SlamNearPlayer = false


func _on_sprite_2d_animation_finished() -> void:
	if(Sprite.animation == "Button"):
		_spawn_bomb()
		Player._play_sound($AudioSlimeButtonPress, true, true, -5)
		Player.EnableMovement = true
		Physics = true

func _spawn_final_attack_bomb() -> void:
	if(FinalAttackNumber >= FinalAttackMarkers.size()):
		On_Death()
		return
		#FinalAttackNumber = FinalAttackMarkers.size()-1
	if(!FinalAttackMarkers): return
	if(FinalAttackNumber >= FinalAttackFastBombQuantity):
		$FinalAttackTimer.wait_time = FinalAttackBombTime
		$FinalAttackTimer.start()
	if(FinalAttackMarkers[FinalAttackNumber].get_children().size() <= 0):
		$FinalAttackTimer.wait_time =  2.0
		$FinalAttackTimer.start()
		FinalAttackNumber += 1
		return
	for Mark in FinalAttackMarkers[FinalAttackNumber].get_children():
		if(Mark is Marker2D):
			_spawn_bomb(false, Mark.global_position, false)
	FinalAttackNumber += 1
	await get_tree().create_timer(1.0).timeout
	Player._play_sound($AudioHit)

func _on_final_attack_timer_timeout() -> void:
	_spawn_final_attack_bomb()


func _on_anim_animation_finished(anim_name: StringName) -> void:
	if(InFinalAttack):
		$Anim.play("FinalAttackIdle")
