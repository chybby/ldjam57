extends CanvasLayer

@onready var button: Button = %Button
@onready var menuMusic = %MenuMusic


func _ready() -> void:
    button.pressed.connect(on_button_pressed)
    menuMusic.play()

func on_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/main/main.tscn")
