extends Button

@export var BUTTON_ACTION = Global.BUTTON_ACTIONS.none
@export var ADITIONAL_ARGUMENT : String = ""

@export var Tag : String = ""

@export var DiscShader : bool = false

@export var HoverDif : float = 30
@export var PressedDif : float = -20

@onready var original_size : Vector2 = self.size
@onready var ControlNode = $"../../pause_menu"
@onready var SelectedSprite = $SelectedSprite
@onready var Player : ClassPlayer = SaveGame.get_player()
@export var IsPixelartButton : bool = false

@export var FadeTransition : bool = false

@export var tex_selected : Texture = preload("res://assets/Sprites/Ui/Button/Pixelart/levelnote-selected.png") if IsPixelartButton else null
@onready var tex_unselected : Texture = self.icon

@onready var hover_size : Vector2 = Vector2(original_size.x+HoverDif, original_size.y+HoverDif)
@onready var press_size : Vector2 = Vector2(original_size.x+PressedDif, original_size.y+PressedDif)

@export var ShowOnExpo : bool = true

@export var BSide : bool = false

enum BoxSize{
	Mini,
	Regular
}

@export var MobileBoxSize : BoxSize = BoxSize.Regular

var touching_mouse : bool = false

var PressedAnim : bool = false

var tween_hover = null
var tween_press = null
var tween_normal = null

@export var LevelBg : AnimatedSprite2D
@export var LevelRanking : Control

@onready var Parent = get_parent()

@export var WaitTime : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(Tag == "Editor"):
		disabled = !Edition.IncludeLevelEditor
	#if(text == "1"):
	#	grab_focus()
	
	if(Edition.Mobile):
		var TouchButton
		if(MobileBoxSize == BoxSize.Mini): TouchButton = load("res://assets/Levels/TouchScreenButtonMini.tscn")
		elif(MobileBoxSize == BoxSize.Regular): TouchButton = load("res://assets/Levels/TouchScreenButtonBig.tscn")
		if(TouchButton):
			add_child(TouchButton.instantiate())
		
	if(!ShowOnExpo && Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo):
		queue_free()
	_set_text_size(original_size.y)

@onready var DiscShaderInitialTilt : float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(disabled):
		modulate = Color(1.0, 1.0, 1.0, .8)
		return
	if(DiscShader):
		if(!DiscShaderInitialTilt):
			DiscShaderInitialTilt = material.get_shader_parameter("max_tilt")
		if(touching_mouse):
			var tilt_val : float = lerp(material.get_shader_parameter("max_tilt"), 0.0, 5*delta)
			material.set_shader_parameter("max_tilt", tilt_val)
		else:
			var tilt_val : float = lerp(material.get_shader_parameter("max_tilt"), DiscShaderInitialTilt, 5*delta)
			material.set_shader_parameter("max_tilt", tilt_val)
		
		material.set_shader_parameter("mouse_position",get_global_mouse_position())
		material.set_shader_parameter("sprite_position",global_position)
	if(!Edition.Mobile):
		#region Press Controller
		if(Input.is_action_just_pressed("ui_click_controller") &&  has_focus()):
			_on_pressed()
		#endregion
		#region Button anims
		if(!PressedAnim):
			var Mouse_pos = get_global_mouse_position()
			#Checks if mouse is touching button or if has focused(For controller support)
			if(has_focus() || (Mouse_pos.x >= self.position.x && Mouse_pos.x <= self.position.x + self.size.x && Mouse_pos.y >= self.position.y && Mouse_pos.y <= self.position.y + self.size.y+20)):
				if(IsPixelartButton && !touching_mouse):
					if(LevelBg):
						LevelBg.animation == ADITIONAL_ARGUMENT
						if(Parent.is_in_group("LevelSelector")):
							Parent.change_replay_path(int(text)-1, ADITIONAL_ARGUMENT)
						LevelBg.frame = int(text)-1
					if(LevelRanking): LevelRanking._update_best_scores(float(text), LevelManager.get_world_number(ADITIONAL_ARGUMENT, Global.BSide))
				touching_mouse = true
				if(IsPixelartButton): icon = tex_selected
				#region On pressed
				if(Input.is_action_pressed("ui_click") && self.size.x < original_size.x+PressedDif):
					var tween_button = get_tree().create_tween()
					tween_button.tween_property(self, "size", press_size, .2)
					tween_button.play()
					#_set_size_button(lerpf(self.size.x, original_size.x+PressedDif, 5*delta),  lerpf(self.size.y, original_size.y+PressedDif, 5*delta))
				#region Hover
				elif(!tween_press):
					var tween_button = get_tree().create_tween()
					tween_button.tween_property(self, "size", hover_size, 1)\
					.set_ease(Tween.EASE_OUT)\
					.set_trans(Tween.TRANS_ELASTIC)
					tween_button.play()
					#_set_size_button(lerpf(self.size.x, original_size.x+HoverDif, 5*delta), lerpf(self.size.y, original_size.y+HoverDif, 5*delta))
				#endregion
			#region Return to normal state
			elif(self.size != original_size):
				if(touching_mouse):
					if(IsPixelartButton): icon = tex_unselected
				touching_mouse = false
				var tween_button = get_tree().create_tween()
				tween_button.tween_property(self, "size", original_size, 1)\
				.set_ease(Tween.EASE_OUT)\
				.set_trans(Tween.TRANS_ELASTIC)
				tween_button.play()
				#_set_size_button(lerpf(self.size.x, original_size.x, 10*delta), lerpf(self.size.y, original_size.y, 10*delta))
			#endregion
		#endregion
		_set_text_size(self.size.x)

func _set_text_size(X : float):
	var tosize = X-140
	#if(get_theme_font_size("font_size") < tosize && get_theme_font_size("font_size") < 140):
	#	add_theme_font_size_override('font_size', X-140)
@export var ExpoButton : bool = true

func _on_pressed() -> void:
	LevelManager.ExpoMoveTimeout.start()
	print("Button pressed!")
	if(FadeTransition):
		var Transition = $"../Transition" if $"../Transition" else $"../../Transition"
		if(Transition):
			Transition.Anim.play("fade_movement")
			if(BUTTON_ACTION == Global.BUTTON_ACTIONS.move_to_scene):
				ResourceLoader.load_threaded_request(ADITIONAL_ARGUMENT)
			if(BUTTON_ACTION == Global.BUTTON_ACTIONS.move_to_level_number_in_world):
				var _path = LevelManager.get_level_path(int(text)-1, ADITIONAL_ARGUMENT, get_parent().Bside)
				ResourceLoader.load_threaded_request(_path)
			await get_tree().create_timer(1.4).timeout
	if(WaitTime):
		await get_tree().create_timer(WaitTime).timeout
	if(BUTTON_ACTION == Global.BUTTON_ACTIONS.resume_game && Player):
		Player._pause_game()
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.move_to_level_starting_with):
		#LevelManager.Level = int(text)-1
		#deprecated. q codigo d mrd xdios. se nota q mejore(algo)
		#ya me da paja rehacer tds estos enums pero bn muy triste el q tenga q entender esto. rip
		LevelManager.change_to_level(int(text)-1, 0)
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.change_to_next_level):
		LevelManager.change_to_next_level()
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.change_to_prev_level):
		LevelManager.change_to_prev_level()
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.move_to_level_number_in_world):
		LevelManager.change_to_level_world_string(int(text)-1, ADITIONAL_ARGUMENT, get_parent().Bside)
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.play_replay_from_scene):
		LevelManager.play_replay_level_string(ADITIONAL_ARGUMENT)
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.restart_level):
		Player.TransitionOut.show()
		Player.TransitionOut.fade_out()
		await(get_tree().create_timer(Player.TimeDeath).timeout)
		if get_tree(): get_tree().reload_current_scene()
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.config_menu):
		Edition.CrtFilter = !Edition.CrtFilter
		#print("TO-DO: Lazy developer didn't implement config menu...")
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.move_to_scene):
		var Scene = ResourceLoader.load_threaded_get(ADITIONAL_ARGUMENT)
		if(Scene):
			get_tree().change_scene_to_packed(Scene)
		else:
			var _scene_string : String = ADITIONAL_ARGUMENT
			get_tree().change_scene_to_file(_scene_string)
		#if(ExpoButton && Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo):
		#	var _scene_string : String = "res://assets/Levels/world1/level1.tscn"
		#	get_tree().change_scene_to_file(_scene_string)
		#if(Edition.Mobile):
		#	var _scene_string : String = "res://assets/Levels/world1/level1.tscn"
		#	get_tree().change_scene_to_file(_scene_string)
		#else:
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.quit):
		get_tree().quit()


func _on_button_down() -> void:
	_on_pressed()
