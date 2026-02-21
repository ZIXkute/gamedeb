extends StaticBody2D
var speed = 300
var active = true

func _physics_process(delta: float) -> void:
	if not active:
		return
	constant_linear_velocity = Vector2(-speed, 0)
	position.x -= speed * delta
	if position.x < -500:
		queue_free()

func stop() -> void:
	active = false
	constant_linear_velocity = Vector2.ZERO

func resume() -> void:
	active = true
