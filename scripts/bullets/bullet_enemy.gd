extends Area2D
## Enemy projectile. Hits player.
## A miss must not fly forever — no lifetime here meant missed shots
## accumulated without bound over a long run (screen "full of enemy
## missiles" plus a real perf cost, since ORB bullets redraw every frame).

const LIFETIME := 5.0

var damage: float = 4.0
var speed: float = 180.0
var _direction := Vector2.RIGHT
var _lifetime_left: float = LIFETIME


func setup(dmg: float, spd: float, dir: Vector2) -> void:
	damage = dmg
	speed = spd
	_direction = dir.normalized()
func _ready() -> void:
	add_to_group("enemies")
	add_to_group("enemy_projectiles")
	rotation = _direction.angle()
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_lifetime_left -= delta
	if _lifetime_left <= 0.0:
		queue_free()
		return
	position += _direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage, self)
		queue_free()
