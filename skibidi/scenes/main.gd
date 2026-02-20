extends CharacterBody2D
# Movement constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 800.0
const DASH_DURATION = 0.2
var is_dashing = false
var dash_timer = 0.0
var dash_direction = 1.0
# Adjust this if needed
const DEATH_Y = 1000.0
# Spawn position
var spawn_position: Vector2
# Drag DeadUI here in the Inspector!
@export var death_ui: Control
func _ready() -> void:
	spawn_position = position
	if death_ui == null:
		print("❌ death_ui NOT assigned!")
	else:
		print("✅ death_ui assigned")
		death_ui.visible = false
		var button = death_ui.get_node("Button")
		button.pressed.connect(_on_button_pressed)
func _physics_process(delta: float) -> void:
	# Dash input
	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION
		var direction := Input.get_axis("ui_left", "ui_right")
		dash_direction = direction if direction != 0 else dash_direction
	# Dash timer
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		if dash_timer <= 0:
			is_dashing = false
	if not is_dashing:
		# Gravity
		if not is_on_floor():
			velocity += get_gravity() * delta
		# Jump
		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		# Movement
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			velocity.x = direction * SPEED
			dash_direction = direction  # track last direction
			$Sprite2D.flip_h = direction < 0
			$Sprite2D.play("run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$Sprite2D.play("afk")
	move_and_slide()
	check_death()
func check_death() -> void:
	if position.y > DEATH_Y:
		die()
func die() -> void:
	print("💀 Player died at Y =", position.y)
	if death_ui == null:
		print("❌ death_ui is NULL (NOT CONNECTED IN INSPECTOR)")
	else:
		print("✅ Showing death UI")
		death_ui.visible = true
	set_physics_process(false)
	velocity = Vector2.ZERO
func restart() -> void:
	print("🔄 Restarting...")
	if death_ui:
		death_ui.visible = false
	position = spawn_position
	velocity = Vector2.ZERO
	set_physics_process(true)
func _on_button_pressed() -> void:
	restart()
