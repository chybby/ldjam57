extends Node3D
class_name Level

signal respawn_player

@export var rotation_speed: float = 0.0

@onready var after_sleep_spawn_point: Marker3D = $AfterSleepSpawnPoint
@onready var respawn_point: Marker3D = $InitialSpawnPoint

@onready var bed_interactable: Interactable = %BedInteractable
@onready var start_bilge_main_console_interactable: Interactable = %StartBilgeMainConsoleInteractable
@onready var bilge_manual_override_interactable: Interactable = %BilgeManualOverrideInteractable
@onready var entered_central_deck_trigger: Trigger = %EnteredCentralDeckTrigger
@onready var stop_spinning_interactable: Interactable = %StopSpinningInteractable
@onready var go_to_surface_interactable: Interactable = %GoToSurfaceInteractable
@onready var emergency_exit_interactable: Interactable = %EmergencyExitInteractable

@onready var tube: CSGCombiner3D = $Geometry/Tube
@onready var water: Area3D = $Water
@onready var the_sequel_to_water: Area3D = $TheSequelToWater

@onready var animation_player: AnimationPlayer = $AnimationPlayer


var stop_once_oriented: bool = false


func _ready() -> void:
    bed_interactable.was_interacted_by.connect(_on_bed_interacted)
    start_bilge_main_console_interactable.was_interacted_by.connect(_on_start_bilge_main_console)
    bilge_manual_override_interactable.was_interacted_by.connect(_on_bilge_manual_override)
    entered_central_deck_trigger.was_triggered_by.connect(_on_entered_central_deck)
    stop_spinning_interactable.was_interacted_by.connect(_on_stop_spinning)
    go_to_surface_interactable.was_interacted_by.connect(_on_go_to_surface)
    emergency_exit_interactable.was_interacted_by.connect(_on_escape)

    tube.visible = true
    water.visible = false
    water.monitorable = false
    the_sequel_to_water.visible = false
    the_sequel_to_water.monitorable = false

    # TODO: uncomment for debugging
    #_on_sleep()


func _physics_process(delta: float) -> void:
    if not is_zero_approx(rotation_speed):
        rotate_x(rotation_speed * delta)

    if stop_once_oriented and abs(rotation_degrees.x) < 1.0:
        print('Orientation fixed')
        rotation.x = 0
        rotation_speed = 0
        go_to_surface_interactable.process_mode = Node.PROCESS_MODE_INHERIT
        stop_once_oriented = false


func _on_bed_interacted(source: Node3D) -> void:
    print('Good night sleep tight')
    rotate_x(deg_to_rad(-90))

    water.visible = true
    water.monitorable = true
    start_bilge_main_console_interactable.process_mode = Node.PROCESS_MODE_INHERIT

    respawn_point = after_sleep_spawn_point

    await get_tree().physics_frame
    await get_tree().physics_frame # bruh


    respawn_player.emit()


func _on_start_bilge_main_console(source: Node3D) -> void:
    #TODO: show that bilge needs manual override
    print('Bilge needs manual override')
    pass


func _on_bilge_manual_override(source: Node3D) -> void:
    print('Bilge manual override enabled')
    animation_player.play("bilge")


func _on_entered_central_deck(source: Node3D) -> void:
    print('Shit gets crazy?')
    rotation_speed = -0.2
    stop_spinning_interactable.process_mode = Node.PROCESS_MODE_INHERIT


func _on_stop_spinning(source: Node3D) -> void:
    print('Waiting for correct orientation')
    stop_once_oriented = true


func _on_go_to_surface(source: Node3D) -> void:
    print('Going to surface')
    animation_player.play("go_to_surface")
    emergency_exit_interactable.process_mode = Node.PROCESS_MODE_INHERIT


func _on_escape(source: Node3D) -> void:
    print('Escaping')
    get_tree().quit()
