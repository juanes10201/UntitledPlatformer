extends Node2D

@export var Energy : float = 1.0
@export var Height : int = 13
@export var TextureScale : float = 3.0
@onready var Light = get_parent()

const MaxEnergy = 7.0
const MaxEnergyWidth = 7.0
const MinEnergy = .2
const MinEnergyWidth = 1.0

@onready var CollisionShape : CollisionShape2D = $CollisionShape2D
var ColorOpacity : float = .4
var ColorOpacityUnused : float = .1
var CollisionOpacity : float = .3
@onready var LevelEditor : Node2D = SaveGame.get_level_editor_node()

var LastPageRender : int = 0

const UnusedZIndex = -1
const UsedZIndex = 0

func _ready() -> void:
	Energy = Light.energy
	Height = Light.height
	TextureScale = Light.texture_scale
	#if(!Edition.Is_in_editor): queue_free()
	_setup_lights()

func _process(delta: float) -> void:
	_tick_debug_lights()

func _tick_debug_lights():
	if(LastPageRender != LevelEditor.CurrentUiPage):
		queue_redraw()
	if(LevelEditor && LevelEditor.EditorPlace.CollidingBody == self):
		if(global_position != Light.global_position && LevelEditor.EditorPlace.SelectingBody):
			Light.global_position = global_position
	if(Light.energy != Energy || Light.texture_scale != TextureScale || Light.height != Height):
		Light.energy = Energy
		Light.texture_scale = TextureScale
		Light.height = Height
		queue_redraw()
		
func _setup_lights():
	pass

func _draw() -> void:
	var Size : Vector2 = Light.texture.get_size() * Light.texture_scale
	var InitialPoint : Vector2 = -Size/2
	#var FinalPoint : Vector2 = -Size/2
	#var Point : Rect2 = Rect2(InitialPoint.x, InitialPoint.y, Size.x, Size.y)
	var CollisionSize : Vector2 = CollisionShape.shape.size
	var PointCollision : Rect2 = Rect2(-CollisionSize/2, CollisionSize)
	
	var Width = Light.energy/(MaxEnergy-MinEnergyWidth)*MaxEnergyWidth+MinEnergyWidth
	Width = clamp(Width, MinEnergyWidth, MaxEnergyWidth)
	var DrawColor : Color = Light.color
	var DrawColorCollision : Color = Light.color
	
	if(LevelEditor && Edition.Is_in_editor && !Edition.Is_playing_in_editor):
		LastPageRender = LevelEditor.CurrentUiPage
		if(LevelEditor.CurrentUiPage == 2):
			z_index = UsedZIndex
			DrawColor.a *= ColorOpacity
			DrawColorCollision.a *= CollisionOpacity
			draw_rect(PointCollision, DrawColorCollision, false, Width)
		else:
			z_index = UnusedZIndex
			DrawColor.a *= ColorOpacityUnused
	else: DrawColor.a *= ColorOpacityUnused
	
	draw_arc(Vector2(0.0, 0.0), Size.x/2, 0.0, TAU, 64, DrawColor, Width)
	#draw_rect(Point, Color.GREEN, false, 5.0)
	
	print("Size: " + str(Size))
