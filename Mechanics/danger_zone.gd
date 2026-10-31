class_name DangerZone extends Area2D
# timer is expermetal(gotta set inscript timer later)
@export var damage: int = 1
@export var shape: Shape2D

func _ready() -> void:
	
	area_entered.connect(_on_area_entered)
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	set_collision_mask_value(5, true)
	set_collision_mask_value(4, true)
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	add_child(collision_shape)
	

func _on_timer_timeout() -> void:
	print("timer timeout")
	if monitoring:
		monitoring = false
	else:
		monitoring = true
		
func _on_area_entered(area :Area2D) -> void:
	if not area.has_method("receive_hit"): #it check if the area has the function "receive_hit"
		return
	
	area.receive_hit(damage)
