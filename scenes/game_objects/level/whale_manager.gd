extends Node3D

var sound_list = [
    preload("res://assets/sfx/whale1.wav"),
    preload("res://assets/sfx/whale2.wav"),
    preload("res://assets/sfx/whale3.wav"),
    preload("res://assets/sfx/whale-sound-type-4-235993.mp3"),
    preload("res://assets/sfx/haunting-whale-song-323611.mp3"),
    preload("res://assets/sfx/creepy-whale-song-323612.mp3")
]

@onready var timer = $Timer
@onready var audio_player = $WhaleNoise

var min_interval = 5.0
var max_interval = 10.0
var min_volume_db = -30.0
var max_volume_db = -20.0
var distance_from_player = 50.0

func _ready():
    timer.timeout.connect(_on_wait_timeout)
    timer.start()
    
func _on_wait_timeout(): 
    timer.timeout.disconnect(_on_wait_timeout)
    var random_index = randi() % sound_list.size()
    var random_sound = sound_list[random_index]
    
    var random_volume = randf_range(min_volume_db, max_volume_db)
    
    var offset = Vector3(
        randfn(0.0,1.0),
        randfn(0.0,1.0),
        randfn(0.0,1.0)
    )
    
    audio_player.global_position = offset.normalized() * distance_from_player
    
    audio_player.stream = random_sound
    audio_player.volume_db = random_volume
    audio_player.play()
    print("Playing index: ", random_index)
    
    timer.timeout.connect(_on_sound_finished)
    timer.start(random_sound.get_length())
    
func _on_sound_finished():
    timer.timeout.disconnect(_on_sound_finished)    
    var random_duration = randf_range(min_interval, max_interval)
    
    timer.timeout.connect(_on_wait_timeout)
    timer.start(random_duration)
