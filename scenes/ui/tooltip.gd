extends Control

@onready var label = $Label

func _ready() -> void:
    visible = false
    GameEvents.connect("show_tooltip", Callable(self, "show_tooltip"))
    GameEvents.connect("hide_tooltip", Callable(self, "hide_tooltip"))
    
func show_tooltip(text: String) -> void:
    label.text = text + ": LMB"
    visible = true
    
func hide_tooltip() -> void:
    visible = false
