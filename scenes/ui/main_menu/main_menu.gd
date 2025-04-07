extends CanvasLayer

@onready var button: Button = %Button


func _ready() -> void:
    button.pressed.connect(on_button_pressed)


func on_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/main/main.tscn")
