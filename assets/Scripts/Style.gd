extends Node2D
@onready var StyleText = $StyleText
@onready var StyleBar = $StyleBar
@onready var StylePoints = $Points
@onready var StyleMoto = $Moto 
@onready var StyleSprite = $StyleSprite
@onready var Anim = $AnimationPlayer
@onready var MultText = $"Mult/MultText"
@onready var MultDiagonalBG = $"Mult/MultDiagonalBg"

@onready var ParticlesPerfectRank = $"ParticlesPerfectRank"

var PlayedHideAnimation : bool = false

@export var CanHide : bool = false

@onready var extra_points_particle = preload("res://assets/Nodes/Obj/extra_points_particle.tscn")
var Particle_Points_Preload_Amount : int = 20
var PointsParticlePool = []

var Player : CharacterBody2D

func _ready() -> void:
	_setup_point_particles()
	Player = SaveGame.get_player()
	if((Player && !Player.Styleometter) || Global.LoadingReplay): queue_free()

func _setup_point_particles() -> void:
	for i in range(Particle_Points_Preload_Amount):
		var ScoreParticle = extra_points_particle.instantiate()
		ScoreParticle.visible = false
		add_child(ScoreParticle)
		ScoreParticle.position = $NewScoreReference.position
		ScoreParticle.position.x += randf_range(-80, 30)
		ScoreParticle.OriginalY = $NewScoreReference.position.y
		PointsParticlePool.append(ScoreParticle)

func _get_free_point_particle():
	for Particle in PointsParticlePool:
		if(Particle.visible == false): return Particle
	return null

func _create_point_particles(score: int):
	if(score <= 0): return
	var _particle = _get_free_point_particle()
	if(!_particle): return
	_particle.visible = true
	_particle.DespawnTimer.start()
	_particle.text = "+" + str(score)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if(Edition.Is_in_editor): hide()
	else: show()
	#StyleText.text = " " + LevelManager.GetStyle()
	
	if(LevelManager.GetStyle() == "P"):
		ParticlesPerfectRank.emitting = true
	else:
		ParticlesPerfectRank.emitting = false
	
	if(!Anim.is_playing() && !PlayedHideAnimation): Anim.play("Idle")
	
	MultText.text = str(LevelManager.ScoreMult)
	MultDiagonalBG.animation = str(LevelManager.ScoreMult)
	if(LevelManager.ScoreMult > 1):
		MultDiagonalBG.material.set_shader_parameter("progress", LevelManager.StyleMultiplierTimer.time_left/LevelManager.StyleMultiplierTimer.wait_time)
	else:
		MultDiagonalBG.material.set_shader_parameter("progress", 0)
		
	
	
	StyleSprite.animation = LevelManager.GetStyle()
	if(LevelManager.PreviousStyle != StyleSprite.animation):
		if(CanHide && LevelManager.PreviousStyle == "D"):
			Anim.play("Show")
			LevelManager.StylePlayedHideAnimation = false
		elif(!Anim.is_playing()):
			Anim.play("ChangeRank")
		#Player._play_sound(SongPlayer.AudioStyleNewLevel, false, false, 5)
		LevelManager.PreviousStyle = StyleSprite.animation
	#Añadir score
	if(LevelManager.PreviousScore != StylePoints.text):# && !PlayedHideAnimation && !Anim.is_playing()):
		LevelManager.PreviousScore = StylePoints.text
		Anim.play("ChangeScore")
		_create_point_particles(LevelManager.LastScore*10)
		
	if(CanHide && StyleSprite.animation == "D"):
		if(LevelManager && !LevelManager.StylePlayedHideAnimation):
			LevelManager.StylePlayedHideAnimation = true
			Anim.play("Hide")
		elif(Anim.current_animation != "Hide" || !Anim.is_playing()):
			Anim.play("Hiden")
	else:
		PlayedHideAnimation = false
	
	StyleBar.value = LevelManager.StyleTimer.time_left
	StylePoints.text = "X" + str(LevelManager.StyloMetter*10) + " Style"
	
	StyleMoto.text = str(LevelManager.ScoreMult) + "X " if LevelManager.ScoreMult > 1 else ""
	StyleMoto.text += LevelManager.StyleMoto
