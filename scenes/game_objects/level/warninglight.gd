extends OmniLight3D

@export var intensity = 2.0
@export var blink_speed = 1.0
@export var exit_light = false

var time = 0.0
var panicmode = 2
var in_intensity = 0.0

func _ready() -> void:
    GameEvents.connect("trigger_lights", Callable(self, "trigger_event"))
    in_intensity = 0.0

func _process(delta):
    time += delta * blink_speed
    light_energy = in_intensity * abs(sin(time))
    
func trigger_event(text):
    if(text == "wakeup"):
        if(!exit_light):
            in_intensity = intensity
            
    elif(text == "deactivate"):
        if(!exit_light):
            in_intensity = 0
            
    elif(text == "panic"):
        if(!exit_light):
            in_intensity = intensity * panicmode
            blink_speed = intensity * panicmode
        
    elif(text == "exit"):
        if(exit_light):
            in_intensity = intensity
        else:
            in_intensity = 0
        
    
