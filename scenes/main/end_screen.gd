extends CanvasLayer

@onready var button: Button = $Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time_label = $TimeLabel


func _ready() -> void:
    button.pressed.connect(on_button_pressed)

func _process(delta: float) -> void:
    if visible:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func on_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/main/main.tscn")
    
func show_end_screen(time: float) -> void:
    var minutes = int(time / 60)
    var seconds = time - (minutes*60)
    time_label.text = str(minutes) + ":" + "%06.3f" %seconds
    animation_player.play("fadein")
