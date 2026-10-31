class_name Player1
extends CharacterBody2D
## Base platformer character. Player 2 (and every other character) should
## `extends Player1` and only override the input action names / sprite / stats.

## Emitted when the down input is pressed (drop through platforms, crouch, etc.)
signal p1_down

enum State {
	IDLE,
	MOVE,
	UP,    # in the air, rising
	DOWN,  # in the air, falling
	PASSIVE_ATTACK,
	ABILITY_ATTACK,
	PARRY,
	CHARGING,
}

## Assign the AnimatedSprite2D in the inspector. Animation names must match
## the state names in lowercase: idle, move, up, down, passive_attack,
## ability_attack, parry, charging.
@export var sprite: AnimatedSprite2D
@export var owner_stats: Stats

@export_group("Movement")
@export var speed := 300.0
@export var acceleration := 1500.0
@export var friction := 1800.0
@export var jump_velocity := -550.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_group("Input Actions")
@export var action_left := "p1_left"
@export var action_right := "p1_right"
@export var action_jump := "jump" 
@export var action_up := "up"      
@export var action_down := "p1_down"
@export var action_passive_attack := "p1_passive_attack"
@export var action_ability_attack := "p1_ability_attack"
@export var action_parry := "p1_parry"
@export var action_charge := "p1_charge"

var state: State = State.IDLE
var is_locked := false  # true while an attack/parry animation is playing

# Filled every frame by read_input()
var move_axis := 0.0
var wants_jump := false
var wants_down := false
var wants_passive_attack := false
var wants_ability_attack := false
var wants_parry := false
var wants_charge := false


func _ready() -> void:
	if sprite:
		sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	read_input()
	update_state()
	handle_movement(delta)
	handle_animation()


# ---------------------------------------------------------------- INPUT
func read_input() -> void:
	move_axis = Input.get_axis(action_left, action_right)
	wants_jump = Input.is_action_just_pressed(action_jump)
	wants_down = Input.is_action_just_pressed(action_down)
	wants_passive_attack = Input.is_action_just_pressed(action_passive_attack)
	wants_ability_attack = Input.is_action_just_pressed(action_ability_attack)
	wants_parry = Input.is_action_just_pressed(action_parry)
	wants_charge = Input.is_action_pressed(action_charge)

	if wants_down:
		p1_down.emit()


# ---------------------------------------------------------- STATE MACHINE
func update_state() -> void:
	if is_locked:
		return  # wait for the action animation to finish

	if wants_parry :
		start_action(State.PARRY)
		if is_on_floor() and Input.is_action_pressed("shield"):
			sprite.play("shield")
		if not is_on_floor():
			sprite.play("doge")
			velocity.y = 0
			if Input.is_action_pressed("up"):
				velocity.y = -500
			if Input.is_action_pressed("p1_right"):
				velocity.x = 800 
			if Input.is_action_pressed("p1_left"):
				velocity.x = -800 
	elif wants_ability_attack:
		start_action(State.ABILITY_ATTACK)
		sprite.play("attack")
	elif wants_passive_attack:
		start_action(State.PASSIVE_ATTACK)
		sprite.play("attack2")
	elif wants_charge and is_on_floor():
		state = State.CHARGING
	elif not is_on_floor():
		state = State.UP if velocity.y < 0.0 else State.DOWN
	elif move_axis != 0.0:
		state = State.MOVE
	else:
		state = State.IDLE


func start_action(new_state: State) -> void:
	state = new_state
	is_locked = sprite != null  # no sprite = nothing to wait for


func _on_animation_finished() -> void:
	# Attack/parry animations must NOT loop, or this never fires.
	if is_locked:
		is_locked = false
		state = State.IDLE


# --------------------------------------------------------------- MOVEMENT
func handle_movement(delta: float) -> void:
	# Gravity always applies
	if not is_on_floor():
		velocity.y += gravity * delta

	var can_act := state in [State.IDLE, State.MOVE, State.UP, State.DOWN]

	# Jump (the "up" input)
	if can_act and wants_jump and is_on_floor():
		velocity.y = jump_velocity

	# Horizontal
	if can_act and move_axis != 0.0:
		velocity.x = move_toward(velocity.x, move_axis * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()

func handle_knockback(_knockback_score):
	pass
# -------------------------------------------------------------- ANIMATION
func handle_animation() -> void:
	if sprite == null:
		return

	if move_axis != 0.0:
		sprite.flip_h = move_axis < 0.0

	var anim: String = State.keys()[state].to_lower()

	# Skips animations you haven't made yet instead of erroring.
	if not sprite.sprite_frames.has_animation(anim):
		return

	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
