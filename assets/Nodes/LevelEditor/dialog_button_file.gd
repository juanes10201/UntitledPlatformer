extends Button
const ButtonPadding : float = 35
@onready var UiTopButton : Node2D = get_parent()
@export var Options : Array[GlobalFunctions.EDITOR_TOOLTIP_FUNCTIONS] = []
@export var SampleButton : Node
@export var Buttons : Array[Node] = []
@export var LevelEditor : Node

var Visible : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(Options.size()):
		var NewButton = SampleButton.duplicate()
		add_child(NewButton)
		Buttons.append(NewButton)
		NewButton.position.y += ButtonPadding*i
		NewButton.text = GlobalFunctions.EDITOR_TOOLTIP_FUNCTIONS.keys()[Options[i]]
		NewButton.visible = Visible
		NewButton.Type = Options[i]

func set_visible_button(state : bool) -> void:
	for _Button in Buttons:
		_Button.visible = state
	if(state):
		UiTopButton.SelectedButton = self
	elif(UiTopButton.SelectedButton == self):
		UiTopButton.SelectedButton = null
	Visible = state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Visible && UiTopButton.SelectedButton != self):
		set_visible_button(false)


func _on_pressed() -> void:
	set_visible_button(!Visible)


func _on_dialog_button_sample_pressed() -> void:
	set_visible_button(false)


func _on_mouse_entered() -> void:
	LevelEditor.ButtonHovered = true

func _on_mouse_exited() -> void:
	LevelEditor.ButtonHovered = false
