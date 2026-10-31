class_name Stats extends Node


enum Team {
	blueteam1,
	redteam2,
}

@export var character : CharacterBody2D
@export var team : Team = Team.blueteam1 # this team var I addied for the hitbox from the tutorial. to select what hurtbox layer is targted. (C37)
@export var characher_base_damage: int = 3
@export var character_weight : int = 1
@export var knockback_initial: int = 0




var current_knockback_score = knockback_initial
var var_damage_recevied: int = 0

func damage_recevied(_damage) -> void:
	var_damage_recevied = _damage
	knockback_calculate(var_damage_recevied,current_knockback_score)

func knockback_calculate(_damage :int, _current_score) -> void:
	var new_knockback_score: float = 0
	new_knockback_score = sqrt(_current_score * _current_score + _damage) * (_damage + character_weight)/character_weight
	current_knockback_score = new_knockback_score
	print(current_knockback_score)
	#add the movement function later
