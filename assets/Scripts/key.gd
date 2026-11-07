extends Area2D

@onready var Player : ClassPlayer = SaveGame.get_player()
@export var AditionalAction : GlobalFunctions.FUNCTIONS = GlobalFunctions.FUNCTIONS.none
@export var AditionalActionArgument : float
@export var AnotherAction : GlobalFunctions.FUNCTIONS = GlobalFunctions.FUNCTIONS.none

@onready var Sprite : AnimatedSprite2D = $"AnimatedSprite2D"
@onready var Light : PointLight2D = $"PointLight2D"

@onready var TimerRespawn : Timer = $"TimerRespawn"

@export var Respawn : bool = false
@export var RespawnTime : float = 1.0

@export var TakeKey : bool = true

@export var Despawn : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if($PointLight2D): $PointLight2D.show()
	if(AditionalAction == GlobalFunctions.FUNCTIONS.Switch_Player_Gravity):
		$AnimatedSprite2D.play("orb")
	elif(AditionalAction == GlobalFunctions.FUNCTIONS.Restart_Time):
		$AnimatedSprite2D.play("clock")
	else:
		$AnimatedSprite2D.play("default")
	if(TimerRespawn):
		TimerRespawn.wait_time = RespawnTime

var editable = preload("res://assets/Scripts/default_object.gd").new()
var Hovering : bool = false
@export var CanHover : bool = false
var done = false


@export var grab_grid : float = 8.0
func _process(delta: float) -> void:
	if(Edition.Is_in_editor && !Edition.Is_playing_in_editor):
		done = false
		set_key_state(false, false)
	elif(Respawn):
		if(done):
			Sprite.self_modulate.a = lerpf(Sprite.self_modulate.a, 0.6, 15*delta)
		else:
			Sprite.self_modulate.a = lerpf(Sprite.self_modulate.a, 1, 5*delta)
			if($AnimatedSprite2D.animation == "get_orb"):
				$AnimatedSprite2D.play("respawn_orb")
			elif(!$AnimatedSprite2D.is_playing()):
				$AnimatedSprite2D.play("orb")

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") && !done):
		set_key_state(true, true)
		if(AditionalAction == GlobalFunctions.FUNCTIONS.Switch_Player_Gravity):
			LevelManager.AddStyle(0, "Changed Gravity", 1.0, global_position, Global.ALL_DIRECTIONS.up)
		elif(AditionalAction == GlobalFunctions.FUNCTIONS.Restart_Time):
			LevelManager.AddStyle(1, "Got Clock", 1.0, global_position, Global.ALL_DIRECTIONS.up)
		else: LevelManager.AddStyle(0, "Got Key", 1.0, global_position, Global.ALL_DIRECTIONS.up)

func set_key_state(state : bool, PlayAction : bool):
	if(!Respawn):
		Sprite.visible = !state
	elif(state):
		Sprite.self_modulate.a = 0.3
	if(Light): Light.enabled = !state
	if(TakeKey):
		Player.HaveKey = state
	if(PlayAction):
		#print("Play action!")
		done = true
		if(AditionalAction == GlobalFunctions.FUNCTIONS.Restart_Time):
			Player._play_sound(Player.AudioClockBreak, true)
			$ParticleDestroy1.emitting = true
			$ParticleDestroy2.emitting = true
			$ParticleDestroy3.emitting = true
			$ParticleDestroy4.emitting = true
		else:
			if(AditionalAction != GlobalFunctions.FUNCTIONS.Switch_Player_Gravity):
				Player._play_sound(Player.AudioSwitch, false)
			if(AditionalAction == GlobalFunctions.FUNCTIONS.none):
				Player._play_sound(Player.AudioKey, false)
		if(AditionalAction == GlobalFunctions.FUNCTIONS.Switch_Player_Gravity):
			$AnimatedSprite2D.play("get_orb")
		if(Respawn):
			TimerRespawn.start() 
		GlobalFunctions.play_function(AditionalAction, AditionalActionArgument)
		GlobalFunctions.play_function(AnotherAction)
	if(state && Despawn):
		var Boss = get_tree().get_nodes_in_group("Boss")[0] if get_tree().get_nodes_in_group("Boss").size() else null
		if(Boss):
			Boss.start_cooldown_timer()
			Boss.Move = false
		if(get_parent().is_in_group("ClockRigidBody")): get_parent().queue_free()
		queue_free()


func _on_timer_respawn_timeout() -> void:
	done = false
	set_key_state(false, false)
