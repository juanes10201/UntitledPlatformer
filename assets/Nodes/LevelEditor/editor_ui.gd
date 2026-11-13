extends CanvasLayer

@export var LevelEditor : Node2D
@export var NodePages : Array[Node]
@export var EditorPlace : Node2D

@export var TilesetSelectorButton : TextureButton
@export var RegularSelectorButton : TextureButton

func _process(delta: float) -> void:
	LevelEditor.CurrentUiPage = clamp(LevelEditor.CurrentUiPage, 0, NodePages.size()-1)
	for i in range(NodePages.size()):
		NodePages[i].visible = i == LevelEditor.CurrentUiPage
	NodePages[LevelEditor.CurrentUiPage].visible = true

func _change_to_tileset_selector() -> void:
	LevelEditor.set_page_editor(1)
	EditorPlace.change_to_tileset_custom()

func _change_to_regular_selector() -> void:
	LevelEditor.set_page_editor(0)
	EditorPlace.change_to_tileset_regular()

func _change_to_lights_selector() -> void:
	LevelEditor.set_page_editor(2)
	EditorPlace.change_to_lightning_mode()
