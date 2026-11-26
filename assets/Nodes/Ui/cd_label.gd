extends Sprite2D
@export var ButtonDiscBside : Button
@export var ButtonDiscRegular : Button

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if($Cd.animation != "open_fast" && (ButtonDiscBside.touching_mouse || ButtonDiscRegular.touching_mouse)):
		var _old_frame = $Cd.frame
		$Cd.play("open_fast")
		$Cd.frame = (6-_old_frame)/2
	elif($Cd.animation != "close_slow" && (!ButtonDiscBside.touching_mouse && !ButtonDiscRegular.touching_mouse)):
		var _old_frame = $Cd.frame
		$Cd.play("close_slow")
		$Cd.frame = (3-_old_frame)*2
