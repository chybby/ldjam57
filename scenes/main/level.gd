extends Node3D
class_name Level

signal respawn_player

@export var rotation_speed: float = 0.0#0.2

@onready var bed: CSGBox3D = %Bed
@onready var bilge_controls: CSGBox3D = %"Bilge Controls"

@onready var after_sleep_spawn_point: Marker3D = $AfterSleepSpawnPoint
@onready var respawn_point: Marker3D = $InitialSpawnPoint

@onready var tube: CSGCombiner3D = $Geometry/Tube
@onready var water: Area3D = $Water

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
    bed.sleepy_time.connect(_on_sleep)
    bilge_controls.bilge_time.connect(_on_bilge)

    tube.visible = true
    water.visible = false

    # TODO: uncomment for debugging
    #_on_sleep()



func _physics_process(delta: float) -> void:
    if not is_zero_approx(rotation_speed):
        rotate_x(rotation_speed * delta)


func _on_sleep() -> void:
    rotate_x(deg_to_rad(-90))
    water.visible = true
    water.monitorable = true
    respawn_point = after_sleep_spawn_point

    await get_tree().physics_frame
    await get_tree().physics_frame # bruh
    respawn_player.emit()

func _on_bilge() -> void:
    animation_player.play("bilge")
