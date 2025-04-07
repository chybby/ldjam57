extends Node

signal example
signal trigger_monologue(text)
signal trigger_lights(text)
signal trigger_fade()
signal get_scuba()
signal interact_console()
signal toggle_move()

func emit_example() -> void:
    example.emit()
