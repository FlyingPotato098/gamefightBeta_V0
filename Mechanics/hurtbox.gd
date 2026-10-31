class_name HurtBox extends Area2D

@export var owner_stats: Stats

func _ready() -> void:
	monitoring = false
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	match owner_stats.team:
		Stats.Team.blueteam1:
			set_collision_layer_value(4, true)
		Stats.Team.redteam2:
			set_collision_layer_value(5, true)

func receive_hit(damage: int) -> void:
	owner_stats.damage_recevied(damage)
