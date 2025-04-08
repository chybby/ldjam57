extends Node3D

@onready var player: Player = $Player
@onready var level: Level = $Level
@onready var waterLayer = $WaterLayer
@onready var settings: CanvasLayer = %Settings
@onready var fade_layer: CanvasLayer = $FadeLayer

@onready var scuba_interactable: Interactable = $Level/ScubaInteractable
@onready var scuba_icon: PanelContainer = %ScubaIcon
@onready var glass_breaker_interactable: Interactable = $Level/GlassBreakerInteractable
@onready var glass_breaker_icon: PanelContainer = %GlassBreakerIcon

@onready var timer = $Timer

var is_underwater = false
var start_time = 0
var end_time = 0


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        get_tree().paused = true
        settings.visible = true
    elif event.is_action_pressed("left_click"):
        if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
    start_time = Time.get_ticks_msec()
    level.respawn_player.connect(_on_respawn_player)
    scuba_interactable.was_interacted_by.connect(_on_scuba_interacted)
    glass_breaker_interactable.was_interacted_by.connect(_on_glass_breaker_interacted)
    GameEvents.connect("end", Callable(self, "on_end_time"))

    fade_layer.start_fade_cycle_from_black()

    # TODO: comment for debugging
    respawn_player()


func _process(delta: float) -> void:
    waterLayer.visible = player.is_underwater


func _on_respawn_player() -> void:
    respawn_player()


func respawn_player() -> void:
    player.global_position = level.respawn_point.global_position
    player.velocity = Vector3.ZERO


func _on_scuba_interacted(source: Node3D) -> void:
    scuba_icon.visible = true


func _on_glass_breaker_interacted(source: Node3D) -> void:
    glass_breaker_icon.visible = true
    
func on_end_time() -> void:
    end_time = Time.get_ticks_msec()
    print((end_time - start_time) / 1000.0)
    
