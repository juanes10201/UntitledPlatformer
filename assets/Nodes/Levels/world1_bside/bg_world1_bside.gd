extends Parallax2D

@export var Show : bool = true

func _process(delta: float) -> void:
	$Bg.Show = Show
	if(Edition.Is_in_editor):
		$Bg.visible = visible
