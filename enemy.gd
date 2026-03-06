extends CharacterBody2D

var health = 3
const ATTACK_DAMAGE = 1
const DETECTION_RANGE = 200.0
var player = null
var attack_cooldown = 0.0
const ATTACK_RATE = 1.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

	if player == null:
		return
	attack_cooldown -= delta
	var distance = position.distance_to(player.position)

	# Face the player
	if player.position.x < position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

	if distance < DETECTION_RANGE:
		if attack_cooldown <= 0 and player.health > 0:
			attack_cooldown = ATTACK_RATE
			player.take_damage(ATTACK_DAMAGE)
			print("👊 Enemy attacked player!")
		$AnimatedSprite2D.play("atak")
	else:
		$AnimatedSprite2D.play("default")

func take_damage(amount: int) -> void:
	health -= amount
	print("💥 Enemy hit! Health:", health)
	if health <= 0:
		die()

func die() -> void:
	print("💀 Enemy died!")
	queue_free()
