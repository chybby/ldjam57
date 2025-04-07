extends CanvasLayer

@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var continue_button: Button = %ContinueButton
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var effects_volume_slider: HSlider = %EffectsVolumeSlider
@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var music_bus_index = AudioServer.get_bus_index("Music")
@onready var effects_bus_index = AudioServer.get_bus_index("SFX")

func _ready() -> void:
    continue_button.pressed.connect(close)
    music_volume_slider.value_changed.connect(_on_music_volume_slider_changed)
    effects_volume_slider.value_changed.connect(_on_effects_volume_slider_changed)
    sensitivity_slider.value_changed.connect(_on_sensitivity_slider_changed)

    music_volume_slider.value = AudioServer.get_bus_volume_linear(music_bus_index)
    effects_volume_slider.value = AudioServer.get_bus_volume_linear(effects_bus_index)
    sensitivity_slider.value = player.mouse_sensitivity


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        close()


func close() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    get_tree().paused = false
    visible = false
    get_viewport().set_input_as_handled()


func _on_music_volume_slider_changed(value: float) -> void:
    print('setting music volume to %d' % value)
    AudioServer.set_bus_volume_linear(music_bus_index, value)


func _on_effects_volume_slider_changed(value: float) -> void:
    print('setting effects volume to %d' % value)
    AudioServer.set_bus_volume_linear(effects_bus_index, value)


func _on_sensitivity_slider_changed(value: float) -> void:
    print('setting mouse_sensitivity to %d' % value)
    player.mouse_sensitivity = value
