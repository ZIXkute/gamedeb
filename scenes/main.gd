extends CharacterBody2D
const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const DASH_SPEED = 800.0
const DASH_DURATION = 0.2
var is_dashing = false
var dash_timer = 0.0
var dash_direction = 1.0
const DEATH_Y = 1000.0
var spawn_position: Vector2
var health = 20
const MAX_HEALTH = 20
@export var death_enabled: bool = true
@export var death_ui: Control
@export var win_ui: Control
@export var platform_spawner: Node
@export var portal: Area2D
@export var attack_area: Area2D

func take_damage(amount: int) -> void:
	health -= amount
	print("❤️ Player health:", health)
	if health <= 0:
		die()

func _ready() -> void:
	add_to_group("player")
	spawn_position = position
	if death_ui == null:
		print("❌ death_ui NOT assigned!")
	else:
		death_ui.visible = false
		var button = death_ui.get_node("Button")
		button.pressed.connect(_on_button_pressed)
	if win_ui == null:
		print("❌ win_ui NOT assigned!")
	else:
		win_ui.visible = false
		var button = win_ui.get_node("Button")
		button.pressed.connect(_on_button_pressed)
	if portal:
		portal.body_entered.connect(_on_portal_entered)
	if attack_area:
		attack_area.monitoring = true
	$Sprite2D.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if $Sprite2D.animation == "atak":
		if Input.is_action_pressed("attack"):
			$Sprite2D.play("atak")
		else:
			$Sprite2D.play("afk")
			$Sprite2D.scale = Vector2(0.29, 0.30)

func _on_portal_entered(body: Node) -> void:
	if body == self:
		win()

func win() -> void:
	print("🏆 Level complete!")
	set_physics_process(false)
	velocity = Vector2.ZERO
	if platform_spawner:
		platform_spawner.stop_all()
	get_tree().change_scene_to_file("res://level_2.tscn")

func _physics_process(delta: float) -> void:
	# Flip attack area with player direction
	if attack_area:
		attack_area.scale.x = -1 if $Sprite2D.flip_h else 1

	if Input.is_action_just_pressed("attack"):
		$Sprite2D.play("atak")
		$Sprite2D.scale = Vector2(0.2, 0.2)
		if attack_area:
			print("Attack area monitoring:", attack_area.monitoring)
			print("Attack area mask:", attack_area.collision_mask)
			print("Overlapping bodies:", attack_area.get_overlapping_bodies())
			for body in attack_area.get_overlapping_bodies():
				print("🎯 Hit:", body.name)
				if body.has_method("take_damage"):
					body.take_damage(1)

	if Input.is_action_just_released("attack"):
		$Sprite2D.stop()
		$Sprite2D.play("afk")
		$Sprite2D.scale = Vector2(0.29, 0.30)

	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION
		var direction := Input.get_axis("ui_left", "ui_right")
		dash_direction = direction if direction != 0 else dash_direction

	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		if dash_timer <= 0:
			is_dashing = false

	if not is_dashing:
		if not is_on_floor():
			velocity += get_gravity() * delta

		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if Input.is_action_just_pressed("ui_down") and is_on_floor():
			position.y += 5

		var direction := Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			velocity.x = direction * SPEED
			dash_direction = direction
			$Sprite2D.flip_h = direction < 0
			if $Sprite2D.animation != "atak":
				$Sprite2D.play("run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if $Sprite2D.animation != "atak":
				$Sprite2D.play("afk")

	move_and_slide()
	check_death()

func check_death() -> void:
	if not death_enabled:
		return
	if position.y > DEATH_Y:
		die()

func die() -> void:
	print("💀 Player died at Y =", position.y)
	if death_ui:
		death_ui.visible = true
	if platform_spawner:
		platform_spawner.stop_all()
	set_physics_process(false)
	velocity = Vector2.ZERO

func restart() -> void:
	print("🔄 Restarting...")
	health = MAX_HEALTH
	if death_ui:
		death_ui.visible = false
	if win_ui:
		win_ui.visible = false
	if platform_spawner:
		platform_spawner.restart_all()
	position = spawn_position
	velocity = Vector2.ZERO
	set_physics_process(true)

func _on_button_pressed() -> void:
	restart()
