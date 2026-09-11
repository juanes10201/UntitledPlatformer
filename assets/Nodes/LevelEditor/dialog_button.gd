extends Button
@export var Type : GlobalFunctions.EDITOR_TOOLTIP_FUNCTIONS = GlobalFunctions.EDITOR_TOOLTIP_FUNCTIONS.none
@export var LevelData : Node2D
@export var LevelDataParser : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	play_editor_tooltip_function(Type)

@export var EditorSaveFileDialog : FileDialog
@export var EditorLoadFileDialog : FileDialog

func EditorTooltipOpen() -> void:
	print("Loading file...")
	GlobalFunctions.OpenedFileDialog = true
	EditorLoadFileDialog.popup()

func EditorTooltipSaveAs() -> void:
	print("Saving file...")
	GlobalFunctions.OpenedFileDialog = true
	EditorSaveFileDialog.popup()

func EditorTooltipSave() -> void:
	if(LevelData.LevelPath == ""):
		EditorTooltipSaveAs()
	else:
		LevelDataParser.SaveEverythingToFile(LevelData.LevelPath)

func play_editor_tooltip_function(FUNC : GlobalFunctions.EDITOR_TOOLTIP_FUNCTIONS = GlobalFunctions.EDITOR_TOOLTIP_FUNCTIONS.none, Argument = null) -> void:
	print("Editor tooltip function: " + str(FUNC))
	if(FUNC == GlobalFunctions.EDITOR_TOOLTIP_FUNCTIONS.none): return
	if(Argument == null):
		call(GlobalFunctions.EditorPrefix + GlobalFunctions.EDITOR_TOOLTIP_FUNCTIONS.keys()[FUNC])
	else:
		call(GlobalFunctions.EditorPrefix + GlobalFunctions.EDITOR_TOOLTIP_FUNCTIONS.keys()[FUNC], Argument)
