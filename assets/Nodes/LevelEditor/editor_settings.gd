extends Node2D

enum BgNames{
	World1,
	World2,
	World1Bside
}

@export_group("Settings")
@export var SelectedBg : BgNames = 0

var EditorUnusedVariables : Array[String] = []
var EditorHasGeneralVariables : bool = false
