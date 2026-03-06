extends Node

var music: AudioStreamPlayer

func _ready() -> void:
	music = AudioStreamPlayer.new()
	music.stream = load("res://MEGALOVANIA.mp3")
	music.volume_db = 0.0
	add_child(music)
	music.play()
