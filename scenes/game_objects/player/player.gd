extends CharacterBody3D
class_name Player

@export_range(0.0, 100.0, 0.1, "or_greater", "suffix:px/s") var walk_speed: float = 3.0
@export_range(0.0, 100.0, 0.1, "or_greater", "suffix:px/s") var sprint_speed: float = 5.0
@export var mouse_sensitivity: float = 0.005
@export var jump_strength: float = 7.5
@export var water_jump_strength: float = 11.0
@export var dive_speed: float = 2.0
@export var gravity_multiplier: float = 2.0
@export var water_dampening: float = 5.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var interact_ray: RayCast3D = $CameraPivot/InteractRay
@onready var water_collider: Area3D = $WaterCollider
@onready var uncrouch_collider: Area3D = $UncrouchCollider
@onready var standing_collision_shape_3d: CollisionShape3D = $StandingCollisionShape3D
@onready var crouching_collision_shape_3d: CollisionShape3D = $CrouchingCollisionShape3D
@onready var swimming_collision_shape_3d: CollisionShape3D = $SwimmingCollisionShape3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_submerged_collider: Area3D = $CameraPivot/CameraSubmerged

var mouse_movement: Vector2 = Vector2.ZERO
var jumped: bool = false
var sprinting: bool = false
var focused_interactable: Interactable = null
var swimming: bool = false
var wants_to_crouch: bool = false
var crouching: bool = false
var is_underwater = false

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event.is_action_pressed("left_click"):
        if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        else:
            if focused_interactable != null:
                focused_interactable.interact(self)
    elif event.is_action_pressed("jump"):
        jumped = true
    elif event.is_action_pressed("crouch"):
        wants_to_crouch = true
    elif event.is_action_released("crouch"):
        wants_to_crouch = false
    elif event.is_action("sprint"):
        sprinting = event.is_pressed()
    elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        mouse_movement = event.relative


func _process(delta: float) -> void:
    # Movement
    camera_pivot.rotation.x = clamp(camera_pivot.rotation.x - mouse_movement.y * mouse_sensitivity, deg_to_rad(-90), deg_to_rad(90))
    rotation.y -= mouse_movement.x * mouse_sensitivity
    mouse_movement = Vector2.ZERO

    # Interacting
    var interactable := interact_ray.get_collider() as Interactable
    if interactable != focused_interactable:
        var old_label := focused_interactable.label if focused_interactable != null else "nothing"
        var new_label := interactable.label if interactable != null else "nothing"
        print("Stopped looking at %s and started looking at %s" % [old_label, new_label])
        focused_interactable = interactable


func _physics_process(delta: float) -> void:
    var movement_vector := get_movement_vector().rotated(-rotation.y)
    var move_speed := sprint_speed if sprinting and not crouching else walk_speed
    velocity.x = movement_vector.x * move_speed
    velocity.z = movement_vector.y * move_speed

    standing_collision_shape_3d.disabled = swimming or crouching
    swimming_collision_shape_3d.disabled = not swimming
    crouching_collision_shape_3d.disabled = not crouching

    if water_collider.has_overlapping_areas() and not swimming:
        print('entered water')
        # Simulate surface tension.
        velocity.y = -1.2
        swimming = true
        
    elif not water_collider.has_overlapping_areas() and swimming:
        print('exited water')
        swimming = false
    
    if camera_submerged_collider.has_overlapping_areas() and not is_underwater:
        is_underwater = true
    elif not camera_submerged_collider.has_overlapping_areas() and is_underwater:
        is_underwater = false

    if swimming:
        motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
                        
        if jumped:
            velocity.y = water_jump_strength
        if wants_to_crouch:
            velocity.y = -dive_speed
        velocity.y = lerp(velocity.y, 0.0, 1.0 - exp(-water_dampening * delta))
    else:
        motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED

        # Crouching
        if wants_to_crouch and not crouching and is_on_floor():
            set_crouching(true)

        if crouching and not wants_to_crouch:
            # Check if enough space above to uncrouch.
            if not uncrouch_collider.has_overlapping_bodies():
                set_crouching(false)

        # Gravity
        if is_on_floor():
            velocity.y = 0
        else:
            set_crouching(false)
            velocity.y += get_gravity().y * gravity_multiplier * delta

        # Jumping
        if jumped and is_on_floor() and not crouching:
            velocity.y = jump_strength

    jumped = false
    move_and_slide()


func set_crouching(new_crouching: bool) -> void:
    if crouching == new_crouching:
        return
    if new_crouching:
        animation_player.play("crouch")
    else:
        animation_player.play_backwards("crouch")
    crouching = new_crouching    
    
func get_movement_vector() -> Vector2:
    return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
