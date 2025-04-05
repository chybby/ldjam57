extends Node3D

@onready var player: Player = $Player
@onready var level: Level = $Level


func _ready() -> void:
    level.respawn_player.connect(_on_respawn_player)
    # TODO: comment for debugging
    respawn_player()

func _on_respawn_player() -> void:
    respawn_player()


func respawn_player() -> void:
    player.global_position = level.respawn_point.global_position
