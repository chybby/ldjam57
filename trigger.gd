extends Area3D
class_name Trigger

@export var oneshot: bool = false

signal was_triggered_by(source: Node3D)


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
    print("Trigger was entered")
    was_triggered_by.emit(body)

    if oneshot:
        disable.call_deferred()


func disable() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED

func enable() -> void:
    process_mode = Node.PROCESS_MODE_INHERIT
