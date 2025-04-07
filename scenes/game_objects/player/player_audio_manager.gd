extends Node3D

@onready var console_interact: AudioStreamPlayer3D = $ConsoleInteract
@onready var sfx_player: AudioStreamPlayer3D = $SFXPlayer
@onready var scuba: AudioStreamPlayer3D = $ScubaBreathing

var soundsDict = {
    "zip": preload("res://assets/sfx/zip-sfx-322244.mp3")
}

func _ready() -> void:
    GameEvents.connect("interact_console", Callable(self, "_on_console_interact"))

func _on_console_interact() -> void:
    console_interact.play()
    
func playSound(text: String) -> void:
    if soundsDict[text]:
        sfx_player.stream = soundsDict[text]
        sfx_player.play()

func StartScuba() -> void:
    scuba.play()
    
func StopScuba() -> void:
    scuba.stop()
    
    
    
