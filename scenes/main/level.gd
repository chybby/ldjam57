extends Node3D
class_name Level

signal respawn_player
signal rotation_upright

@export var water_surface_y: float = 0.0

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
@onready var top_glass_interactable: Interactable = $"Glass/TopGlassInteractable"

@onready var water: Area3D = $Water
@onready var the_sequel_to_water: Area3D = $TheSequelToWater
@onready var timer = $Timer
@onready var engine_manager = $EngineAudioManager

@onready var pipe_cover: AnimatableBody3D = %PipeCover
@onready var ladder_cover: AnimatableBody3D = %LadderCover

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var has_scuba: bool = false
var has_hammer: bool = false
var said_the_pipe_line: bool = false
var can_move = true

var fall_off_pipe_lines = [
    "Well, at least I know which way is down.",
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
    top_glass_interactable.was_interacted_by.connect(_on_glass_interacted)

    glass_breaker_interactable.disable()
    scuba_interactable.disable()
    start_bilge_main_console_interactable.disable()
    stop_spinning_interactable.disable()
    go_to_surface_interactable.disable()
    emergency_exit_interactable.disable()

    water.visible = false
    water.monitorable = false
    the_sequel_to_water.visible = false
    the_sequel_to_water.monitorable = false

    # TODO: uncomment for debugging
    #_on_sleep()


func _on_bed_interacted(source: Node3D) -> void:
    print('Good night sleep tight')
    
    pipe_cover.rotation_degrees.y = 180
    ladder_cover.rotation_degrees.z = 90

    GameEvents.emit_signal("trigger_fade")
    GameEvents.emit_signal("toggle_move")
    GameEvents.emit_signal("trigger_monologue", "Time for a good night's sleep...")
    engine_manager.StopEngine()

    timer.timeout.connect(wakeup)
    timer.start(3)


func wakeup() -> void:
    timer.timeout.disconnect(wakeup)
    GameEvents.emit_signal("trigger_lights", "wakeup")
    rotate_x(deg_to_rad(-90))

    water.visible = true
    water.monitorable = true
    start_bilge_main_console_interactable.enable()

    respawn_point = after_sleep_spawn_point

    await get_tree().physics_frame
    await get_tree().physics_frame # bruh
    await get_tree().physics_frame

    respawn_player.emit()

    GameEvents.emit_signal("toggle_move")
    glass_breaker_interactable.enable()
    scuba_interactable.enable()

    await get_tree().create_timer(5).timeout
    GameEvents.emit_signal("trigger_monologue", "Whoa... Why's everything sideways???")
    GameEvents.emit_signal("trigger_monologue", "Better get to the command terminal to see what's going on...")


func _on_first_see_water(source: Node3D) -> void:
    GameEvents.emit_signal("trigger_monologue", "Hmm...I think we may have a leak...")


func _on_glass_breaker_interacted(source: Node3D) -> void:
    GameEvents.emit_signal("trigger_monologue", "Break in case of emergencies... this counts, right?")
    glass_breaker_interactable.get_node("AudioStreamPlayer3D").finished.connect(glass_breaker_interactable.queue_free)


func _on_start_bilge_main_console(source: Node3D) -> void:
    print('Bilge needs manual override')
    GameEvents.emit_signal("interact_console")
    GameEvents.emit_signal("trigger_monologue", "Yep. Water inside bad.")
    GameEvents.emit_signal("trigger_monologue", "The bilge pump needs a manual override. It's at the back in the engine room.")
    GameEvents.emit_signal("trigger_monologue", "I'll need to get the scuba gear from opposite the stairs first...")


func _through_the_pipe(source: Node3D) -> void:
    if (has_scuba && !said_the_pipe_line):
        GameEvents.emit_signal("trigger_monologue", "Looks like I'll need to go through the pipe to get to the back right now...")
        said_the_pipe_line = true


func _on_bilge_manual_override(source: Node3D) -> void:
    print('Bilge manual override enabled')
    GameEvents.emit_signal("trigger_lights", "deactivate")
    GameEvents.emit_signal("interact_console")
    GameEvents.emit_signal("trigger_monologue", "Bilge manual override enabled!")
    GameEvents.emit_signal("trigger_monologue", "The sub should stabilise once the water is drained.")
    GameEvents.emit_signal("trigger_monologue", "Wow, that wasn't so bad...")

    start_bilge_main_console_interactable.disable()

    engine_manager.StartEngine()
    animation_player.play("bilge")


func _on_entered_central_deck(source: Node3D) -> void:
    print('Shit gets crazy?')
    GameEvents.emit_signal("trigger_monologue", "That doesn't sound good...")

    engine_manager.Explode()
    engine_manager.StopEngine()

    timer.timeout.connect(start_rotation)
    timer.start(3)


func start_rotation() -> void:
    timer.timeout.disconnect(start_rotation)
    animation_player.play("rotate")
    pipe_cover.rotation_degrees.y = -90
    stop_spinning_interactable.enable()
    GameEvents.emit_signal("trigger_lights", "panic")
    GameEvents.emit_signal("trigger_monologue", "Just when I thought I'd fixed it all...")
    GameEvents.emit_signal("trigger_monologue", "Better hurry back to main command and fix this...")


func _on_fell_off_pipe(source: Node3D) -> void:
    falls += 1
    var index = (falls - 1) % fall_off_pipe_lines.size()
    GameEvents.emit_signal("trigger_monologue", fall_off_pipe_lines[index])


func _on_finished_pipe(source: Node3D) -> void:
    GameEvents.emit_signal("trigger_monologue", "I hope I never need to do that again....")
    GameEvents.emit_signal("trigger_monologue", "To the main deck. So we can stop this madness.")


func _on_stop_spinning(source: Node3D) -> void:
    print('Waiting for correct orientation')
    ladder_cover.rotation_degrees.z = 0

    GameEvents.emit_signal("interact_console")
    GameEvents.emit_signal("trigger_monologue", "Ok! Managed to hit the switch!")
    GameEvents.emit_signal("trigger_monologue", "Just gotta wait for these stabilisers to... stabilise.")

    await rotation_upright
    animation_player.stop()

    GameEvents.emit_signal("trigger_monologue", "I'm not waiting around for that to happen again...")
    GameEvents.emit_signal("trigger_monologue", "I need to get out of here, I can unlock the escape pod from the same terminal.")
    go_to_surface_interactable.enable()

    engine_manager.StartClunkyEngine()


func _on_go_to_surface(source: Node3D) -> void:
    print('Going to surface')
    GameEvents.emit_signal("interact_console")
    GameEvents.emit_signal("trigger_lights", "exit")
    GameEvents.emit_signal("trigger_monologue", "Done. The escape pod is right at the front.")

    timer.timeout.connect(panic)
    timer.start(3)


func panic() -> void:
    timer.timeout.disconnect(panic)
    animation_player.play("go_to_surface")

    GameEvents.emit_signal("trigger_lights", "panic")
    GameEvents.emit_signal("trigger_monologue", "Ok, that's not normal. Better find something to hold onto.")
    GameEvents.emit_signal("trigger_monologue", "I need to climb my way to the top and escape this nightmare...")


func _on_escape(source: Node3D) -> void:
    print('Escaping')
    GameEvents.emit_signal("toggle_move")
    GameEvents.emit_signal("trigger_monologue", "FREEEDOM!!")
    GameEvents.emit_signal("trigger_fade")

    timer.timeout.connect(freedom)
    timer.start(4)


func _on_scuba_interacted(source: Node3D) -> void:
    GameEvents.emit_signal("trigger_monologue", "Ok got the gear.")
    GameEvents.emit_signal("trigger_monologue", "Time to head to the back of the sub...")
    scuba_interactable.get_node("AudioStreamPlayer3D").finished.connect(scuba_interactable.queue_free)
    GameEvents.emit_signal("get_scuba")
    has_scuba = true

func _on_glass_interacted(source: Node3D) -> void:
    if(!has_hammer):
        return
    print("glass")

func freedom() -> void:
    timer.timeout.disconnect(freedom)
    get_tree().quit()


func emit_rotation_upright() -> void:
    rotation_upright.emit()


func fully_tilted() -> void:
    emergency_exit_interactable.enable()
