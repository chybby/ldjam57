extends CanvasLayer

@onready var text_box = %Textbox
@onready var text_label = %Textbox/TextField
@onready var timer = $Timer

var current_text = ""
var text_speed = 0.03
var text_stay_time = 3
var is_active = false
var text_queue = []
var text_index = 0
var init = false

func _ready():
    text_box.visible = false
    timer.wait_time = text_speed
    GameEvents.connect("trigger_monologue", Callable(self, "show_text"))
    text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    var font = SystemFont.new()
    font.font_names = ["Courier New"]
    font.generate_mipmaps = false
    font.antialiasing = false
    
    text_label.add_theme_font_override("normal_font", font)
    text_label.add_theme_font_size_override("normal_font_size", 8)
    
    timer.timeout.connect(initialise)
    timer.start(2)
    

    
func show_text(text):
    print(text)

    if is_active: 
        text_queue.append(text)
        return
        
    is_active = true
    current_text = text
    text_label.text = ""
    text_index = 0
    text_box.visible = true
    timer.timeout.connect(_on_timer_timeout)
    
    timer.wait_time = text_speed
    timer.start()
    
func _on_timer_timeout():
    if current_text.length() > text_index:
        text_label.text += current_text[text_index]
        text_index += 1
        timer.start()
    else:
        timer.wait_time = text_stay_time
        timer.start()
        timer.timeout.disconnect(_on_timer_timeout)
        timer.timeout.connect(_hide_text)
        
func _hide_text():
    timer.timeout.disconnect(_hide_text)
    timer.wait_time = text_speed
    
    text_box.visible = false
    is_active = false
    
    if text_queue.size() > 0:
        var next_text = text_queue.pop_front()
        show_text(next_text)
        
func initialise():
    timer.timeout.disconnect(initialise)
    show_text("Ah...another quiet day over")
    show_text("Time to hit the hay...")
    
