class_name HitBox extends Area2D


@export var attacker_stats: Stats
@export var hitbox_lifetime: float = 0.5
@export var shape: Shape2D
#add hitbox logging?

func _init(_attacker_stats, _hitbox_lifetime, _shape) -> void:
	#set the initial values of the object
	attacker_stats = _attacker_stats
	hitbox_lifetime = _hitbox_lifetime
	shape = _shape
	
func _ready() -> void:
	monitorable = false
	#(detecable) shape can be detected set it to false
	area_entered.connect(_on_area_entered) #what?
	
	if hitbox_lifetime > 0.0:
		var new_timer = Timer.new()
		add_child(new_timer)
		new_timer.timeout.connect(queue_free)
		new_timer.call_deferred("start", hitbox_lifetime) #idk what call_deferred is?
		
	if shape:
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = shape
		add_child(collision_shape)
		
		
	#don't forget to save layer values in the constants script and project settings  (C37)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	match attacker_stats.team: #don't make the t in team uppercase
		Stats.Team.blueteam1:
			set_collision_mask_value(5, true)
		Stats.Team.redteam2:
			set_collision_mask_value(4, true)
		

func _on_area_entered(area :Area2D) -> void:
	if not area.has_method("receive_hit"): #it check if the area has the function "receive_hit"
		return
	
	area.receive_hit(attacker_stats.characher_base_damage)
	
