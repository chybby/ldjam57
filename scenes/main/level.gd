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
@onready var scuba_interactable: Interactable = %ScubaInteractable
@onready var glass_breaker_interactable: Interactable = %GlassBreakerInteractable
@onready var fell_off_pipe_trigger: Trigger = %FellOffPipe
@onready var finished_pipe: Trigger = %FinishedPipeSection
@onready var first_see_water: Trigger = %FirstSeeWater
@onready var through_the_pipe: Trigger = %ThroughThePipe

@onready var tube: CSGCombiner3D = $Geometry/Tube
@onready var water: Area3D = $Water
@onready var the_sequel_to_water: Area3D = $TheSequelToWater
@onready var timer = $Timer

@onready var pipe_cover: AnimatableBody3D = %PipeCover
@onready var ladder_cover: AnimatableBody3D = %LadderCover

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var stop_once_oriented: bool = false
var has_scuba: bool = false
var said_the_pipe_line: bool = false

var fall_off_pipe_lines = [
    "Well, at least I know which way is down",
    "I meant to do that...",
    "Maybe if I stay on top of the pipe...",
    "Guess I'm not cut out for plumbing.",
    "The pipe moved I swear. Or was it me...",
    "The room is spinning...",
    "Oops."
    ]

var falls = 0

func _ready() -> void:
    bed_interactable.was_interacted_by.connect(_on_bed_interacted)
    start_bilge_main_console_interactable.was_interacted_by.connect(_on_start_bilge_main_console)
    bilge_manual_override_interactable.was_interacted_by.connect(_on_bilge_manual_override)
    entered_central_deck_trigger.was_triggered_by.connect(_on_entered_central_deck)
    stop_spinning_interactable.was_interacted_by.connect(_on_stop_spinning)
    go_to_surface_interactable.was_interacted_by.connect(_on_go_to_surface)
    emergency_exit_interactable.was_interacted_by.connect(_on_escape)
    scuba_interactable.was_interacted_by.connect(_on_scuba_interacted)
    glass_breaker_interactable.was_interacted_by.connect(_on_glass_breaker_interacted)
    fell_off_pipe_trigger.was_triggered_by.connect(_on_fell_off_pipe)
    finished_pipe.was_triggered_by.connect(_on_finished_pipe)
    first_see_water.was_triggered_by.connect(_on_first_see_water)

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
        GameEvents.emit_signal("trigger_monologue", "Yeah...I don't think the stabilisers are gonna hold...")
        GameEvents.emit_signal("trigger_monologue", "Let's unlock the exit hatch from the terminal and get outta here")

        rotation.x = 0
        rotation_speed = 0
        go_to_surface_interactable.process_mode = Node.PROCESS_MODE_INHERIT
        stop_once_oriented = false


func _on_bed_interacted(source: Node3D) -> void:
    print('Good night sleep tight')
    pipe_cover.rotation_degrees.y = 180
    ladder_cover.rotation_degrees.z = 90
    
    GameEvents.emit_signal("trigger_fade")
    GameEvents.emit_signal("trigger_monologue", "Time for a good nights sleep...")

    timer.timeout.connect(wakeup)
    timer.start(1)


func _on_start_bilge_main_console(source: Node3D) -> void:
    #TODO: show that bilge needs manual override
    print('Bilge needs manual override')
    GameEvents.emit_signal("trigger_monologue", "Yep. Water inside bad.")
    GameEvents.emit_signal("trigger_monologue", "I'll need to get to the back to pump out the water.")
    GameEvents.emit_signal("trigger_monologue", "I'll need to get the scuba gear further down first...")
    
    pass


func _on_bilge_manual_override(source: Node3D) -> void:
    print('Bilge manual override enabled')
    GameEvents.emit_signal("trigger_lights", "deactivate")
    GameEvents.emit_signal("trigger_monologue", "Bilge manual override enabled")
    GameEvents.emit_signal("trigger_monologue", "I also activated the stabilisers.")
    GameEvents.emit_signal("trigger_monologue", "Wow, that wasnt so bad...")

    animation_player.play("bilge")


func _on_entered_central_deck(source: Node3D) -> void:
    print('Shit gets crazy?')
    GameEvents.emit_signal("trigger_monologue", "That doesn't sound good...")
    
    timer.timeout.connect(start_rotation)
    timer.start()


func _on_stop_spinning(source: Node3D) -> void:
    print('Waiting for correct orientation')
    GameEvents.emit_signal("trigger_monologue", "Ok! Managed to hit the switch!")
    GameEvents.emit_signal("trigger_monologue", "Just gotta wait for these stabilisers to...")
    GameEvents.emit_signal("trigger_monologue", "Stabilise")

    ladder_cover.rotation_degrees.z = 0
    stop_once_oriented = true


func _on_go_to_surface(source: Node3D) -> void:
    print('Going to surface')
    GameEvents.emit_signal("trigger_lights", "exit")
    GameEvents.emit_signal("trigger_monologue", "Done. Now just to get to the tip.")
    
    timer.timeout.connect(panic)
    timer.start(3)


func _on_escape(source: Node3D) -> void:
    print('Escaping')
    GameEvents.emit_signal("trigger_monologue", "FREEEDOM!!")
    GameEvents.emit_signal("trigger_fade")
    
    timer.timeout.connect(freedom)
    timer.start(3)

    
    
func _on_scuba_interacted(source: Node3D) -> void:
    GameEvents.emit_signal("trigger_monologue", "Ok got the gear.")
    GameEvents.emit_signal("trigger_monologue", "Time to head to the back of the sub...")
    scuba_interactable.queue_free()
    has_scuba = true
    
func _on_glass_breaker_interacted(source: Node3D) -> void:
    GameEvents.emit_signal("trigger_monologue", "Break in case of emergencies...")
    GameEvents.emit_signal("trigger_monologue", "I think this counts right?")
    glass_breaker_interactable.queue_free()
    
func _on_fell_off_pipe(source: Node3D) -> void:
    falls += 1
    var index = (falls - 1) % fall_off_pipe_lines.size()
    GameEvents.emit_signal("trigger_monologue", fall_off_pipe_lines[index])
    
func _on_finished_pipe(source: Node3D) -> void:
    GameEvents.emit_signal("trigger_monologue", "I hope I never need to do that again....")
    GameEvents.emit_signal("trigger_monologue", "To the main deck. So we can stop this madness.")

func _on_first_see_water(source: Node3D) -> void:
    GameEvents.emit_signal("trigger_monologue", "Hmm...I think we may have a leak...")

func _through_the_pipe(source: Node3D) -> void:
    if(has_scuba && !said_the_pipe_line):
        GameEvents.emit_signal("trigger_monologue", "Looks like I'll need to go through the pipe to get to the back right now...")
        said_the_pipe_line = true
        
func wakeup() -> void:
    timer.timeout.disconnect(wakeup)
    GameEvents.emit_signal("trigger_lights", "wakeup")
    rotate_x(deg_to_rad(-90))

    water.visible = true
    water.monitorable = true
    start_bilge_main_console_interactable.process_mode = Node.PROCESS_MODE_INHERIT

    respawn_point = after_sleep_spawn_point

    await get_tree().physics_frame
    await get_tree().physics_frame # bruh

    respawn_player.emit()
    GameEvents.emit_signal("trigger_monologue", "Whoa...Why's everything sideways???")
    GameEvents.emit_signal("trigger_monologue", "Better get to the command terminal to see what's going on...")
    
    
func start_rotation() -> void:
    timer.timeout.disconnect(start_rotation)
    rotation_speed = -0.2
    pipe_cover.rotation_degrees.y = -90
    stop_spinning_interactable.process_mode = Node.PROCESS_MODE_INHERIT
    GameEvents.emit_signal("trigger_lights", "panic")
    GameEvents.emit_signal("trigger_monologue", "Just when I thought I fixed it all...")
    GameEvents.emit_signal("trigger_monologue", "Better hurry back to the main command and try fix this...")

func freedom() -> void:
    timer.timeout.disconnect(freedom)
    get_tree().quit()
    
func panic() -> void:
    timer.timeout.disconnect(panic)
    animation_player.play("go_to_surface")
    emergency_exit_interactable.process_mode = Node.PROCESS_MODE_INHERIT
    GameEvents.emit_signal("trigger_lights", "panic")
    GameEvents.emit_signal("trigger_monologue", "Ok that's not normal better find something to hold onto")
    GameEvents.emit_signal("trigger_monologue", "Just gotta get to the top and we'll be free...")
    
