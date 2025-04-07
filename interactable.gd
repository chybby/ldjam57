extends Area3D
class_name Interactable

signal was_interacted_by(source: Node)

@export var label: String
@export var oneshot: bool = false
@export var audio_stream: AudioStream

@onready var audio_stream_player = $AudioStreamPlayer3D

var disabled: bool = false

func _ready():
    if audio_stream != null:
        audio_stream_player.stream = audio_stream

func interact(source: Node) -> void:
    if disabled:
        return

    print("%s was interacted with by %s" % [label, source.name])
    was_interacted_by.emit(source)

    if audio_stream_player.stream != null:
        audio_stream_player.play(0)

    if oneshot:
        print('disabling oneshot interactable')
        disable()

func disable() -> void:
    disabled = true
    set_collision_layer_value(3, false)

func enable() -> void:
    disabled = false
    set_collision_layer_value(3, true)
