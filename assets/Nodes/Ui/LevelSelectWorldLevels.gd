extends Node2D

@export var CurrentWorldLabel : RichTextLabel
@export var PreviousButton : Button
@export var NextButton : Button

@export var AmountLevelsLabel : RichTextLabel

@export var Transition : Node2D

@export var BossLevelSelectButton : Button

@export var ReplayButton : Button

@onready var ReplayText : String = AmountLevelsLabel.text
@export var ReplayEnabled : bool = true

var Page : int = 0
var CurrentWorld : int = 0
#The amount of buttons per page
var AmountButtons : int = 0

var Bside : bool = false

var LoadedReplay : String = ""

func replay_tick() -> void:
	if(ReplayEnabled && Input.is_action_just_pressed("ui_load_replay")):
		LevelManager.play_replay_level_string(LoadedReplay)

func change_replay_path(level : int, world : String) -> void:
	if(ReplayEnabled && ReplayButton):
		LoadedReplay = LevelManager.get_level_path(level, world, Bside)

func _switch_bside() -> void:
	if(!Bside):
		_bside_start()
	else:
		_bside_end()

func _bside_start() -> void:
	Transition.Anim.play("BSide_start")
	Page = 0
	CurrentWorld = 0
	Bside = true
	_reload_page()

func _bside_end() -> void:
	Transition.Anim.play("BSide_end")
	Page = 0
	CurrentWorld = 0
	Bside = false
	_reload_page()

func _ready() -> void:
	AmountButtons = get_child_count()
	_reload_page()

var HasBossInPage : bool = false 

func _reload_page() -> void:
	var AmountWorlds = LevelManager.get_world_order(Bside).size()-1
	if(Edition.LimitWorlds):
		AmountWorlds = Edition.AmountLimitedWorlds-1
	if(Page < 0):
		CurrentWorld -= 1
		#Page = floor(LevelManager.get_amount_levels_in_world(CurrentWorld, Bside)/AmountButtons
		if(CurrentWorld < 0): CurrentWorld = 0
		Page = LevelManager.get_amount_levels_in_world(CurrentWorld, Bside)/AmountButtons
	if(Page*AmountButtons > LevelManager.get_amount_levels_in_world(CurrentWorld, Bside)):
		Page = 0
		CurrentWorld += 1
	
	CurrentWorld = clamp(CurrentWorld, 0, LevelManager.get_world_order(Bside).size()-1)
	
	var LastPageInWorld : bool = Page*AmountButtons+AmountButtons > floor(LevelManager.get_amount_levels_in_world(CurrentWorld, Bside))
	var PlacedBossButton : bool = false
	HasBossInPage = CurrentWorld < LevelManager.BossesLevelPath.size() && LastPageInWorld && !Bside
	
	PreviousButton.visible = !(CurrentWorld == 0 && Page == 0)
	NextButton.visible = !(CurrentWorld == AmountWorlds && LastPageInWorld)
	
	#print(CurrentWorld == LevelManager.WorldOrder.size()-1)
	#print(Page*AmountButtons)
	#print(LevelManager.get_amount_levels_in_world(CurrentWorld))
	
	if(CurrentWorldLabel):
		CurrentWorldLabel.text = "WORLD " + str(CurrentWorld+1)
		if(Bside):
			CurrentWorldLabel.text = "?" + CurrentWorldLabel.text
	
	var _count : int = Page*AmountButtons
	var _internal_count : int = 0
	for button in get_children():
		if(button is not Button): continue
		button.ADITIONAL_ARGUMENT = LevelManager.get_world_order(Bside)[CurrentWorld]
		if(_count >= LevelManager.get_amount_levels_in_world(CurrentWorld, Bside) ):
			button.hide()
			button.disabled = true
			if(HasBossInPage && !PlacedBossButton):
				PlacedBossButton = true
				if(BossLevelSelectButton):
					BossLevelSelectButton.global_position = button.global_position
					BossLevelSelectButton.ADITIONAL_ARGUMENT = LevelManager.BossesLevelPath[CurrentWorld]
		else:
			button.show()
			button.disabled = false
			if(AmountLevelsLabel):
				AmountLevelsLabel.text = str(LevelManager.get_total_number_level(Page*AmountButtons+_internal_count+1, CurrentWorld, Bside) ) + "/" + str(LevelManager.get_amount_total_levels(Bside)+1)
				if(ReplayEnabled):
					AmountLevelsLabel.text = ReplayText + " " + AmountLevelsLabel.text
		button.text = str(_count+1)
		
		_internal_count += 1
		_count += 1
	BossLevelSelectButton.visible = PlacedBossButton
	Global.BSide = Bside

const ChallengesPath : String = "res://assets/Nodes/Ui/ui_challenges.tscn"

func _process(delta: float) -> void:
	replay_tick()
	if(Input.is_action_just_pressed("ui_load_challenge")):
		Transition.Anim.play("fade_movement")
		await get_tree().create_timer(1.5).timeout
		LevelManager.change_scene(ChallengesPath)

func _change_buttons_anim() -> void:
	if(Transition): Transition.Anim.play("change_select_buttons")

func _change_page(_page : int) -> void:
	Page = _page
	_change_buttons_anim()
	_reload_page()

#Next world
func _on_pause_menu_button_2_button_down() -> void:
	_change_page(Page+1)

#Previous world
func _on_pause_menu_button_3_button_down() -> void:
	_change_page(Page-1)
