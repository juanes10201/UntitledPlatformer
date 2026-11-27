extends Node2D
@onready var clock = preload("res://assets/Nodes/Obj/Gameplay/Boss/Slimo/clock_rigid_body.tscn")
@export var SpawnRange : float = 400.0
var CountClock : int = 0
@export var CountToClock : int = 9

@onready var Player = SaveGame.get_player()
@export var BombSamplesNode : Node2D
@export var BombSampleNode : Node2D
@export var AmountBombSamples : int = 20
@export var RayNode : Node2D

var Phase2 : bool = false 

func setup_samples() -> void:
	if(!BombSampleNode):
		print("ERROR AL CLONAR LOS SAMPLES DE LAS BOMBAS...")
		return
	for i in range(AmountBombSamples):
		var bomb_instance = BombSampleNode.duplicate()
		BombSamplesNode.add_child(bomb_instance)

func get_bomb() -> Node2D:
	for _bomb in BombSamplesNode.get_children():
		if(!_bomb.Enabled):
			_bomb.start()
			return _bomb
	return null

func _ready() -> void:
	print("SELF: ", get_path())
	print("BombSamplesNode: ", BombSamplesNode)
	print("BombSampleNode: ", BombSampleNode)
	setup_samples()

@onready var initial_godray_ray_alpha : float = RayNode.material.get_shader_parameter("color") if RayNode else 0.0
func _process(delta: float) -> void:
	var _color = RayNode.material.get_shader_parameter("color")
	if(clock_instance):
		global_position.x = clock_instance.global_position.x
		_color.a = lerpf(_color.a, initial_godray_ray_alpha, delta)
	else:
		_color.a = lerpf(_color.a, 0.0, delta)
	RayNode.material.set_shader_parameter("color", _color)

func spawn_bomb(MoveToPlayer : bool = true, Pos : Vector2  = Vector2(0.0,0.0)) -> void:
	#for child in get_children():
	#	if child.is_in_group("BossBomb"):
	#		return
	if(clock):
		var bomb_instance = get_bomb()
		if(bomb_instance):
			bomb_instance.Phase2 = Phase2
			if(MoveToPlayer): bomb_instance.global_position = Player.global_position
			else: bomb_instance.global_position = Pos

var clock_instance : Node2D
func spawn_clock(SpawnAlways : bool = false) -> void:
	CountClock += 1
	#print(CountClock)
	if(CountClock % CountToClock == 0 || SpawnAlways):
		for child in get_children():
			if child is RigidBody2D:
				return
		if(clock):
			clock_instance = clock.instantiate()
			add_child(clock_instance)
			clock_instance.global_position = global_position
			clock_instance.global_position.x = get_tree().get_nodes_in_group("Boss")[0].global_position.x if get_tree().get_nodes_in_group("Boss").size() else Vector2(0.0,0.0)
			clock_instance.get_node("Key").Despawn = true
	
