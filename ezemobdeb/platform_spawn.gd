extends Node
@export var platforms: Array[PackedScene]
@onready var marker: Marker2D = $Marker2D
@onready var timer: Timer = $Timer

func _on_timer_timeout() -> void:
	if platforms.is_empty():
		print("❌ No platforms assigned!")
		return
	var random_platform: PackedScene = platforms.pick_random()
	var instance = random_platform.instantiate()
	add_child(instance)
	instance.position = marker.position
	var random_y_position: float = randf_range(500, 800)
	instance.position.y = random_y_position

func stop_all() -> void:
	timer.stop()
	for child in get_children():
		if child is StaticBody2D:
			child.stop()

func restart_all() -> void:
	for child in get_children():
		if child is StaticBody2D:
			child.queue_free()
	timer.start()
