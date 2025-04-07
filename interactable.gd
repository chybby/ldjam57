extends Area3D
class_name Interactable

signal was_interacted_by(source: Node)

@export var label: String
@export var oneshot: bool = false
@export var audio_stream: AudioStream

@onready var audio_stream_player = $AudioStreamPlayer3D

func _ready():
    if audio_stream != null:
        audio_stream_player.stream = audio_stream

func interact(source: Node) -> void:
    print("%s was interacted with by %s" % [label, source.name])
    was_interacted_by.emit(source)

    if audio_stream_player.stream != null:
        audio_stream_player.play(0)

    if oneshot:
        if audio_stream_player.stream != null:
            audio_stream_player.finished.connect(disable)
        else:
            disable.call_deferred()

func disable() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED
