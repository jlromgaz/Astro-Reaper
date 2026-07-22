extends Area2D
## Demon summon icon — a menacing red rune. Touching it summons an XP-rich
## mini-boss near the icon (never on top of the player). High risk, high
## reward: ignore it and it fades away after MAX_LIFETIME.

const MAX_LIFETIME := 25.0
const SPAWN_DISTANCE := 100.0

const MINIBOSS_SCENE := preload("res://scenes/enemies/enemy_miniboss.tscn")

var _lifetime: float = 0.0
## Set by enemy_spawner.gd — each repeated summon must be tougher than the last.
var _miniboss_scale: float = 1.0


func set_miniboss_scale(value: float) -> void:
	_miniboss_scale = value


func _ready() -> void:
	add_to_group("demon_icons")
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if not GameManager.is_playing():
		return
	_lifetime += delta
	if _lifetime >= MAX_LIFETIME:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_summon_miniboss()
	queue_free()


func _summon_miniboss() -> void:
	var miniboss: CharacterBody2D = MINIBOSS_SCENE.instantiate()
	var offset := Vector2(SPAWN_DISTANCE, 0).rotated(randf() * TAU)
	miniboss.position = position + offset
	# Apply before entering the tree so _ready()'s health bar init already
	# sees the scaled max_hp/current_hp.
	if miniboss.has_method("apply_difficulty_scale"):
		miniboss.apply_difficulty_scale(_miniboss_scale)
	get_parent().add_child.call_deferred(miniboss)
	DebugLog.log_info("DEMON", "Demon icon summoned mini-boss near %s" % global_position)
	EventBus.enemy_spawned.emit(miniboss)
