extends Node2D

@export var PlayMusic : bool = true
enum MusicStates{
	ingame,
	menu,
	boss1
}
var MusicState = MusicStates.ingame

@onready var SongBoss1 = $SongBoss1
@onready var SongInGame = $SongInGame
@onready var SongMenu = $SongMenu
@onready var AudioDeath = $AudioDeathPlayer
@onready var AudioCompleteLevel = $AudioCompleteLevel
@onready var AudioStyleNewLevel = $AudioNewLevel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_song_tick()

#region Play song
func _play_song(Song):
	if(Song && !Song.playing):
		for Child in get_children():
			if(Child != Song && Child is AudioStreamPlayer || Child is AudioStreamPlayer2D || Child is AudioStreamPlayer3D):
				Child.stop()
		Song.play()
#endregion

func _play_sound_end_level():
	_play_global_sound(AudioCompleteLevel)

#region Play Sound
func _play_global_sound(Sound):
	if(Sound && !Sound.playing):
		Sound.play()
#endregion

#region Songs

func _song_tick() -> void:
	if(PlayMusic):
		match MusicState:
			MusicStates.boss1:
				_play_song(SongBoss1)
			MusicStates.ingame:
				_play_song(SongInGame)
			MusicStates.menu:
				_play_song(SongMenu)
#endregion
