extends Area2D
## Comet — Yellow triangle that flies across the screen.
## Shooting it triggers an upgrade selection (like a level-up).

const SPEED := 100.0
const HP := 30.0

var current_hp: float = HP
var _direction: Vector2 = Vector2.ZERO
var _lifetime: float = 0.0
const MAX_LIFETIME := 15.0


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("comets")
	body_entered.connect(_on_body_entered)


func setup(dir: Vector2) -> void:
	_direction = dir.normalized()
	rotation = _direction.angle()


func _process(delta: float) -> void:
	if not GameManager.is_playing():
		return
	position += _direction * SPEED * delta
	_lifetime += delta
	if _lifetime >= MAX_LIFETIME:
		queue_free()


func take_damage(amount: float) -> void:
	current_hp -= amount
	EventBus.enemy_damaged.emit(self, amount)
	if current_hp <= 0:
		_die()


func _die() -> void:
	DebugLog.log_info("COMET", "Comet destroyed at %s — triggering upgrade" % global_position)
	EventBus.enemy_killed.emit(self, global_position)
	# Deferred: comets die inside bullet physics callbacks — pausing there is unreliable
	EventBus.comet_bonus.emit.call_deferred()
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(5.0, self)
