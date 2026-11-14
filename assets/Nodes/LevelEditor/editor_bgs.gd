extends Node2D

@export var LevelEditor : Node2D
@export var ConfigVar : Node2D

func reload_bg() -> void:
	set_bg(ConfigVar.SelectedBg)
	print("Loaded BG: " + str(ConfigVar.SelectedBg))

func set_bg(id : int) -> void:
	for _bg in LevelEditor.BgNodes:
		_bg.hide()
		if("Show" in _bg):
			_bg.Show = false
	LevelEditor.BgNodes[id].show()
	if("Show" in LevelEditor.BgNodes[id]):
			LevelEditor.BgNodes[id].Show = true
