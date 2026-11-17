extends Area2D

@export var BSide : bool = false
@export var Gb : bool = false

@onready var InitialTime = Time.get_ticks_msec()

var NextScene : String = ""

var progress : Array[float] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if($AnimatedSprite2D):
		$AnimatedSprite2D.play("default")
	self.body_entered.connect(_on_body_entered)
	if($PointLight2D): $PointLight2D.show()
	if(Global.Level == Global.DebugLevelVal || Global.Level == Global.DebugLevelVal+1):
		var scene_path = get_tree().current_scene.scene_file_path
		LevelManager.set_global_with_complete_level_path(scene_path)
	
	if(!Edition.Is_in_editor):
		NextScene = LevelManager.get_next_level_path()
		if(NextScene != ""):
			ResourceLoader.load_threaded_request(NextScene)
	#print("NextScene" + str(NextScene) )


var editable = preload("res://assets/Scripts/default_object.gd").new()
var Hovering : bool = false
@export var CanHover : bool = false

func _input(event):
	if(Edition.Is_in_editor && CanHover):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if(event.pressed && editable.Editor_Hover_Check(self.position.x, self.position.y, get_global_mouse_position())):
					$"../".Is_Hovering = true
					Hovering = true
				else:
					$"../".Is_Hovering = false
					Hovering = false

@export var grab_grid : float = 8.0

var CompletedLevel : bool = false

@onready var FadeOut = $"../CanvasLayer/TransitionOut" if $"../CanvasLayer/TransitionOut" else $"../../CanvasLayer/TransitionOut"  
var ChangedToNextScene : bool = false

func _process(delta: float) -> void:
	if(!Edition.Is_in_editor && !ChangedToNextScene):
		var status = ResourceLoader.load_threaded_get_status(NextScene, progress)
		if(NextScene != "" && CompletedLevel && !Edition.Is_in_editor):
			if(status == ResourceLoader.THREAD_LOAD_LOADED):
				#var scene = ResourceLoader.load_threaded_get(NextScene)
				LevelManager.change_to_next_level_with_completion_ui()
				ChangedToNextScene = true
				#get_tree().change_scene_to_file(NextScene)
		
	
	if(Edition.Is_in_editor && CanHover && Hovering):
		if(Edition.IsErasingInEditor):
			self.queue_free()
		position = get_global_mouse_position()
		self.position.x = (floor(self.position.x/grab_grid)*grab_grid)+16.0
		self.position.y = (floor(self.position.y/grab_grid)*grab_grid)+10.0

func _on_body_entered(body):
	if(body.is_in_group("Player") && !body.Dead):# && body.ReplayAction == Global.ReplayStates.STOPPED):
		var completed_time = Time.get_ticks_msec()-InitialTime
		var StyleRatio : float = 1.0
		
		if(body.ReplayStyle): return
		if(LevelManager.get_level_time()):
			StyleRatio = LevelManager.get_level_time().time_left/LevelManager.get_level_time().wait_time
		#print(StyleRatio)
		LevelManager.AddStyle(3, "Finished level", 1/3+StyleRatio*2/3)
		body._play_sound(SongPlayer.AudioCompleteLevel, true, true, 1, 1, .9, 0.0, 1.2)
		var _lvl = LevelManager.get_level()
		var _world = LevelManager.get_current_world_number()
		if(_lvl <= 0): _lvl = 0
		#region Save level
		#endregion
		#region Change level
		if(!Edition.Is_in_editor):
			if(!Global.LoadingReplay):
				#var _completed_time : float = $"../Time_Left".wait_time - $"../Time_Left".time_left if $"../Time_Left" else 0.00
				#print(_completed_time)
				
				#print("A")
				SaveGame.SaveLevelRecord(_lvl, _world, completed_time)
				#print("Going to next level")
				if(FadeOut):
					FadeOut.FadeOut = true
				CompletedLevel = true
				#LevelManager.change_to_next_level_with_completion_ui()
		else:
			var _leveleditor = SaveGame.get_level_editor_node()
			if(_leveleditor):
				_leveleditor.set_play_state(false)
		#endregion
