extends CharacterBody2D
var health = 3
const ATTACK_DAMAGE = 1
const DETECTION_RANGE = 200.0
var player = null
var attack_cooldown = 0.0
const ATTACK_RATE = 1.0

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	attack_cooldown -= delta
	var distance = position.distance_to(player.position)
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
	var remaining = get_tree().get_nodes_in_group("enemy")
	if remaining.size() <= 1:
		var portal = get_tree().get_first_node_in_group("portal")
		if portal:
			portal.visible = true
	# Always heal player on any enemy death
	var p = get_tree().get_first_node_in_group("player")
	if p:
		p.heal_full()
	queue_free()
