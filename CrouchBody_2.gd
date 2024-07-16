extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CROUCH_SPEED: float = 2
const MIN_SCALE_Y: float = 0.2
const MAX_SCALE_Y: float = 1.0

@export var root: Marker3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	handle_crouch()
	move_and_slide()

func handle_crouch():
	var delta_time = get_process_delta_time()
	var is_crouching = Input.is_action_pressed("crouch")

	if is_crouching:
		# Crouch: Decrease the scale.y value gradually
		root.scale.y -= CROUCH_SPEED * delta_time
		root.scale.y = clamp(root.scale.y, MIN_SCALE_Y, MAX_SCALE_Y)
	else:
		# Uncrouch: Increase the scale.y value gradually, but check for collisions
		var new_scale_y = min(MAX_SCALE_Y, root.scale.y + CROUCH_SPEED * delta_time)
		
		# Temporarily update the scale for collision checking
		var original_scale_y = root.scale.y
		root.scale.y = new_scale_y
		
		# Use a small upward velocity for collision checking
		var _velocity = Vector3(0, 0.1, 0)
		# we don't want to move with move_and_collide so we set 'test_collision' to true
		var collision = move_and_collide(_velocity * delta_time, true)
		
		if collision:
			# If there is a collision, revert the scale
			root.scale.y = original_scale_y
		else:
			# If no collision, apply the new scale
			root.scale.y = new_scale_y

	# Ensure the scale is within bounds
	root.scale.y = clamp(root.scale.y, MIN_SCALE_Y, MAX_SCALE_Y)
