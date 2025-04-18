extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect
@onready var fade_animator: AnimationPlayer = $FadeAnimator

func _ready() -> void:
    fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    GameEvents.connect("trigger_fade", Callable(self, "start_fade_cycle"))
    GameEvents.connect("end", Callable(self, "end"))


func start_fade_cycle():
    fade_animator.play("fadeout")


func start_fade_cycle_from_black():
    fade_animator.play_section_with_markers("fadeout", "full_black")


func end():
    fade_animator.play("end")
