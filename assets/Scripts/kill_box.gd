extends Area2D

@export_group("General")
@export var Visible : bool = true
@onready var Sprite = $AnimatedSprite2D

@export_group("Lava")
@export var AditionalAction = Actions.none
@export var lavaMovDif : float = 10
@export var LavaMoveDirection : LavaDirections = LavaDirections.Up
@export var LavaGoBack : bool = true

@export_group("Internal")
@onready var Player = $"../Player" if $"../Player" else $"../../Player"
@export var Type = Global.KillBoxTypes.Red
@export var CanChange = true

var TweenMove = null

enum Actions{
	none,
	raise_up_on_key
}

var posygoto : float = position.y - lavaMovDif
@onready var LavaTimer = $LavaTimer
enum LavaDirections{
	Up = 1,
	Down = -1
}

@onready var OriginalZIndex = z_index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(!Visible): hide()
	
	var shader = load("res://assets/Shader/kill_box.gdshader")
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	Sprite.material = shader_material
	
	Sprite.material.set_shader_parameter("tile_size", scale)


var WasLavaEnabled : bool = false

@export var grab_grid : float = 8.0
func _process(delta: float) -> void:
	if(!Visible && Edition.Is_in_editor):
		modulate.a = .3
		show()
	if($CollisionShape2D.disabled):
		z_index = -1
	else: z_index = OriginalZIndex
	#print(scale)
	#Sprite.material.set_shader_parameter("tile_size", scale)
	if(Edition.Is_in_editor && !Edition.Is_playing_in_editor):
		$CollisionShape2D.disabled = false
	else:
		#If current killbox
		if(Player && Player.EnabledKillBox == Type && CanChange):
			Sprite.play("default")
			$CollisionShape2D.hide()
			$CollisionShape2D.disabled = false
		elif(CanChange && AditionalAction != Actions.raise_up_on_key):
			#if(AditionalAction.raise_up_on_key):
			Sprite.play("disabled")
			$CollisionShape2D.disabled = true
		if(AditionalAction == Actions.raise_up_on_key && Player.MoveLava):
			if(Player.EnabledKillBox == Type):
				WasLavaEnabled = true
				position.y = lerpf(position.y, posygoto, 2 * delta)
				position.y -= lavaMovDif/10*LavaMoveDirection
			elif(WasLavaEnabled && LavaGoBack):
				position.y = lerpf(position.y, posygoto, 2 * delta)
				position.y += lavaMovDif/10*LavaMoveDirection
			if(LavaTimer.is_stopped()):
				if(Player.EnabledKillBox == Type):
					posygoto = position.y - lavaMovDif*LavaMoveDirection
					LavaTimer.start()
				elif(WasLavaEnabled && LavaGoBack):
					posygoto = position.y + lavaMovDif*LavaMoveDirection*1.5
					LavaTimer.start()
		
func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player") || body.is_in_group("Enemie")):
		if(!body.is_in_group("Boss") && (Player.EnabledKillBox == Type || !CanChange)):
			body.On_Death()
		
