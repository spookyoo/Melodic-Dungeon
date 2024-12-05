extends Node3D

@export var bgMusicOn: bool = true

func _ready():
	playBgMusic()

func playBgMusic():
	var bgMusic = get_node("bgMusic")
	if bgMusicOn:
		if not bgMusic.playing:
			bgMusic.play()
	else:
		if bgMusic.playing:
			bgMusic.stop()
