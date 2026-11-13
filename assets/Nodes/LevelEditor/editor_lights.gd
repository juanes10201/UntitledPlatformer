extends Node2D

@onready var Light = get_parent()

const MaxEnergy = 3.0
const MaxEnergyWidth = 5.0
const MinEnergy = .2
const MinEnergyWidth = 1.0

@onready var CollisionShape : CollisionShape2D = $CollisionShape2D
var ColorOpacity : float = .4
var ColorOpacityUnused : float = .1

@onready var LevelEditor : Node2D = SaveGame.get_level_editor_node()

func _ready() -> void:
	if(!Edition.Is_in_editor): queue_free()
	_setup_lights()

func _process(delta: float) -> void:
	_tick_debug_lights()

func _tick_debug_lights():
	pass

func _setup_lights():
	pass

func _draw() -> void:
	var Size : Vector2 = Light.texture.get_size() * Light.texture_scale
	var InitialPoint : Vector2 = -Size/2
	#var FinalPoint : Vector2 = -Size/2
	#var Point : Rect2 = Rect2(InitialPoint.x, InitialPoint.y, Size.x, Size.y)
	
	var Width = Light.energy/(MaxEnergy-MinEnergyWidth)*MaxEnergyWidth+MinEnergyWidth
	var DrawColor : Color = Light.color
	if(LevelEditor):
		DrawColor.a *= ColorOpacity if LevelEditor.CurrentUiPage == 2 else ColorOpacityUnused
	else: DrawColor.a *= ColorOpacityUnused
	
	draw_arc(Vector2(0.0, 0.0), Size.x/2, 0.0, TAU, 64, DrawColor, Width)
	#draw_rect(Point, Color.GREEN, false, 5.0)
	print("Size: " + str(Size))
