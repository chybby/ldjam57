extends Area3D
class_name Interactable

signal was_interacted_by(source: Node)

@export var label: String
@export var oneshot: bool = false

func interact(source: Node) -> void:
    print("%s was interacted with by %s" % [label, source.name])
    was_interacted_by.emit(source)

    if oneshot:
        disable.call_deferred()

func disable() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED
