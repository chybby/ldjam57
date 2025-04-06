extends Node

signal example
signal trigger_monologue(text)
signal trigger_lights(text)
signal trigger_fade()

func emit_example() -> void:
    example.emit()
