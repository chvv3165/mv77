extends Node

@export var quick_damage: int = 10
@export var heavy_damage: int = 25
@export var special_damage: int = 50

@export var quick_cooldown: float = 0.3
@export var heavy_cooldown: float = 1.0
@export var special_cooldown: float = 5.0

var quick_timer: float = 0.0
var heavy_timer: float = 0.0
var special_timer: float = 0.0

func _process(delta: float) -> void:
	if quick_timer > 0:
		quick_timer -= delta
	if heavy_timer > 0:
		heavy_timer -= delta
	if special_timer > 0:
		special_timer -= delta

func quick_attack() -> void:
	if quick_timer <= 0:
		quick_timer = quick_cooldown
		print("Quick attack dealing %d damage" % quick_damage)

func heavy_attack() -> void:
	if heavy_timer <= 0:
		heavy_timer = heavy_cooldown
		print("Heavy attack dealing %d damage" % heavy_damage)

func special_attack() -> void:
	if special_timer <= 0:
		special_timer = special_cooldown
		print("Special attack dealing %d damage" % special_damage)
