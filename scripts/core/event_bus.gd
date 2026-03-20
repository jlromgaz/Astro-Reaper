extends Node
## Central signal hub for cross-system communication.
## Use instead of direct references between systems.

signal game_started
signal game_ended(reason: String)
signal game_paused
signal game_resumed

signal player_spawned(player: Node2D)
signal player_damaged(amount: float, source: Node)
signal player_died
signal player_healed(amount: float)

signal enemy_spawned(enemy: Node2D)
signal enemy_killed(enemy: Node2D, position: Vector2)
signal enemy_damaged(enemy: Node2D, amount: float)

signal xp_dropped(position: Vector2, amount: int)
signal xp_collected(amount: int)
signal xp_total_changed(current: int, to_next_level: int)

signal player_leveled_up(new_level: int)
signal upgrade_choices_offered(choices: Array)
signal upgrade_selected(upgrade_data: Resource)

signal wave_started(wave: int)
signal wave_ended(wave: int)
signal boss_spawned(boss: Node2D)
