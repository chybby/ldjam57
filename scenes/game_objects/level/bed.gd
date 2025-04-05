extends CSGBox3D

signal sleepy_time

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
    interactable.was_interacted_by.connect(_on_interacted_by)

func _on_interacted_by(source: Node3D) -> void:
    print("going to sleep")
    sleepy_time.emit()
