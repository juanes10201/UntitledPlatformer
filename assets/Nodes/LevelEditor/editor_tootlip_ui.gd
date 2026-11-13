extends Node2D

@export var SampleButton : Button
@export var LevelEditor : Node2D
@export var EditorCursor : Node2D
@export var EditorPlace : Node2D

var Buttons : Array[Array] = []

var ButtonXDif = 80.0
var ButtonYDif = 80.0

func _update_view() -> void:
	#print("Update view")
	for i in range(Buttons.size()):
		for y in range(Buttons[i].size()):
			Buttons[i][y].ButtonNode = i
			Buttons[i][y].ButtonSubNode = y
			
			Buttons[i][y].Icon.play(str(i) + "_" + str(y))
			#print(Buttons[i][y])
			if(y == 0 || i == EditorCursor.SelectedNode): Buttons[i][y].show()
			else: Buttons[i][y].hide()
			if(i == EditorCursor.SelectedNode && y == EditorCursor.SelectedSubNode ):
				Buttons[i][y].grab_focus()

func _add_new_button(i: int, y: int) -> void:
	#print(i)
	var New := SampleButton.duplicate()
	add_child(New)
	Buttons[i].append(New)
	New.position.x += ButtonXDif*(i)
	New.position.y += ButtonYDif*y
	New.ButtonNode = i
	New.ButtonSubNode = y

func _setup_button() -> void:
	Buttons.append([])
	for i in range(EditorCursor.TileTools.size()):
		var New := SampleButton.duplicate()
		add_child(New)
		Buttons[0].append(New)
		New.position.y += ButtonYDif*i
	#print(Buttons.size()-1)
	Buttons.append([])
	for i in range(LevelEditor.SelectableObjects.size()):
		Buttons.append([])
		for y in range(LevelEditor.SelectableObjects[i].size()):
			_add_new_button(i+1, y)
			#print(Buttons.size()-1)
	#print(Buttons)

func _ready() -> void:
	if(SampleButton):
		SampleButton.hide()
	_setup_button()
	_update_view()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = LevelEditor.CurrentUiPage == 0
