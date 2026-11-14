extends Button

@onready var LevelEditor = $"../../../../"
enum types{
	add_point,
	remove_point
}
@export var type : types = types.add_point

func _ready() -> void:
	if(!Edition.Is_in_editor): queue_free()

#func _process(delta: float) -> void:
#	print("works!")

func _add_point() -> void:
	get_parent().editor_add_point()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Hovered: ", get_viewport().gui_get_hovered_control())
		print("Soy: ", self, " | rect global: ", get_global_rect())
		print("Mouse: ", get_global_mouse_position())

func _remove_point() -> void:
	get_parent().editor_remove_point()

func _mouse_entered_button_ui() -> void:
	print("Mouse entered")
	if(LevelEditor):LevelEditor.ButtonHovered = true
	#pass # Replace with function body.

func _mouse_exited_button_ui() -> void:
	if(LevelEditor): LevelEditor.ButtonHovered = false

func _pressed() -> void:
	print("Pressed add/remove rail point")
	if(type == types.add_point): _add_point()
	elif(type == types.remove_point): _remove_point()
