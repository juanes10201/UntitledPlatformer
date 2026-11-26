extends Sprite2D
@export var ButtonDiscBside : Button
@export var ButtonDiscRegular : Button

var SelectedBside : bool = true

func _ready() -> void:
	$Cd.play("default")

func _process(delta: float) -> void:
	var _bside_touching_mouse : bool = ButtonDiscBside.touching_mouse && !ButtonDiscBside.PressedAnim && SelectedBside
	var _regular_touching_mouse : bool = ButtonDiscRegular.touching_mouse && !ButtonDiscRegular.PressedAnim && !SelectedBside
	if($Cd.animation != "open_fast" && (_bside_touching_mouse || _regular_touching_mouse)):
		var _old_frame = $Cd.frame
		$Cd.play("open_fast")
		$Cd.frame = (6-_old_frame)/2
	elif($Cd.animation != "close_slow" && (!_bside_touching_mouse && !_regular_touching_mouse)):
		var _old_frame = $Cd.frame
		$Cd.play("close_slow")
		$Cd.frame = (3-_old_frame)*2
	if((_bside_touching_mouse || _regular_touching_mouse) && Input.is_action_pressed("ui_click") ):
		SelectedBside = !SelectedBside
