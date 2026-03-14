extends Control

func _ready() -> void:
	$VBoxContainer/Button.pressed.connect(_on_start_pressed)
	print("Menu ready, button connected")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://node_2d.tscn")
