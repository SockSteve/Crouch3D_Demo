extends Node3D
class_name CrouchComponent

const CROUCH_SPEED: float = 0.1
const MIN_HEIGHT: float = 0.2

@export var capsule_or_cylinder_collision_shape: CollisionShape3D
@export var mesh_instance: MeshInstance3D
@export var print_debug: bool = false

@onready var collision_max_height = capsule_or_cylinder_collision_shape.shape.height
@onready var mesh_max_height = mesh_instance.mesh.height

var crouching: bool = false
var can_uncrouch: bool = true

var grow_dir: Vector3 = Vector3.ZERO

func _process(delta):
	if print_debug: print(grow_dir)
	
	if Input.is_action_pressed("crouch"):
		crouching = true
	else:
		crouching = false
	
	if crouching:
		decrease_height()
		return
	
	if can_uncrouch:
		increase_height()
		grow_dir = Vector3.ZERO
		return

# Function to set the height of the capsule shape
func set_capsule_height(collision_height: float, mesh_height: float) -> void:
	# Set the height of the capsule shape
	collision_height = clamp(collision_height,MIN_HEIGHT, collision_max_height)
	mesh_height = clamp(mesh_height,MIN_HEIGHT, mesh_max_height)
	
	capsule_or_cylinder_collision_shape.shape.height = collision_height
	mesh_instance.mesh.height = mesh_height

	# Adjust the position to ensure it grows from the bottom
	var parent_position = capsule_or_cylinder_collision_shape.position
	parent_position.y = collision_height / 2.0
	capsule_or_cylinder_collision_shape.position = parent_position
	
	var mesh_parent_position = mesh_instance.position
	mesh_parent_position.y = mesh_height / 2.0
	mesh_instance.position = mesh_parent_position

# Example function to increase the height
func increase_height() -> void:
	var new_collision_height = capsule_or_cylinder_collision_shape.shape.height + CROUCH_SPEED
	var new_mesh_height = mesh_instance.mesh.height + CROUCH_SPEED
	set_capsule_height(new_collision_height, new_mesh_height)
	# The CROUCH_SPEED is multiplicated with 2 because we cant to test the future grow direction
	# for collision. otherwise the objects collision would bump into the ceiling an is unable to move
	grow_dir = Vector3(0,CROUCH_SPEED * 2, 0)

# Example function to decrease the height
func decrease_height() -> void:
	var new_collision_height = capsule_or_cylinder_collision_shape.shape.height - CROUCH_SPEED # Ensure height does not go below 1
	var new_mesh_height = mesh_instance.mesh.height - CROUCH_SPEED
	set_capsule_height(new_collision_height, new_mesh_height)
