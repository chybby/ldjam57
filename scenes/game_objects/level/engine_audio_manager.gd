extends Node3D

@onready var explosion_audio: AudioStreamPlayer3D = $ExplosionAudioSource
@onready var engine_audio: AudioStreamPlayer3D = $EngineAudioSource

var clunky_engine = preload("res://assets/sfx/gear-spinning-loop-6981.mp3")
var ship_groan = preload("res://assets/sfx/ship_groan.wav")

func Explode() -> void: 
    explosion_audio.play()
    
func StartEngine() -> void:
    engine_audio.play()
    
func StopEngine() -> void:
    engine_audio.stop()
    
func StartClunkyEngine() -> void:
    engine_audio.stream = clunky_engine
    engine_audio.volume_db = 0.0
    engine_audio.play()

func ShipGroan() -> void:
    engine_audio.stream = ship_groan
    engine_audio.volume_db = 10
    engine_audio.play()
