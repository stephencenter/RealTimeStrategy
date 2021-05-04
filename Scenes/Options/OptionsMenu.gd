extends Control

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.OPTIONS]

onready var aspect_node : Control = $AspectRatio
onready var resolution_node : Control = $Resolution
onready var windowed_node : Control = $DisplayMode/Windowed
onready var fullscreen_node : Control = $DisplayMode/Fullscreen
onready var borderless_node : Control = $DisplayMode/Borderless
onready var apply_node : Control = $Apply
onready var resume_node : Control = $Resume
onready var enablepan_node : Control = $EdgePan/Enable
onready var panspeed_node : Control = $EdgePan/Speed

# These arrays specify which node you go to when you press each direction
# First element is Up, second is Down, then Left, the Right
onready var navigation_map : Dictionary = {
    aspect_node: [null, windowed_node, null, resolution_node],
    resolution_node: [null, borderless_node, aspect_node, null],
    windowed_node: [aspect_node, enablepan_node, null, fullscreen_node],
    fullscreen_node: [aspect_node, panspeed_node, windowed_node, borderless_node],
    borderless_node: [resolution_node, panspeed_node, fullscreen_node, null],
    enablepan_node: [windowed_node, apply_node, null, panspeed_node],
    panspeed_node: [borderless_node, apply_node, enablepan_node, null],
    resume_node: [enablepan_node, null, null, apply_node],
    apply_node: [enablepan_node, null, resume_node, null]
}

onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var slider_delay_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var slider_repeat_timer = timer_class.new(ACTIVE_STATES, the_game)
const SLIDER_REPEAT_DELAY : float = 0.25
const SLIDER_REPEAT_SPEED : float = 0.01
var slider_repeating_left : bool = false
var slider_repeating_right : bool = false

var current_node : Control
var using_option_button : bool = false
var using_slider : bool = false
var original_ob_selection : int
var original_slider_selection : int

func _process(_delta):    
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
        
    if using_option_button:
        handle_option_buttons()
        
    elif using_slider:
        handle_sliders()
        
    else:
        navigate_menu()

func _input(event):
    if event is InputEventMouseMotion and using_option_button:            
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        set_using_ob(false)
        
func navigate_menu():
    if Input.is_action_just_pressed("ui_up"):
        if current_node == null:
            current_node = aspect_node
            
        elif navigation_map[current_node][0] != null:
            current_node = navigation_map[current_node][0]
        
        place_cursor_on_current_node()
            
    if Input.is_action_just_pressed("ui_down"):
        if current_node == null:
            current_node = aspect_node
            
        elif navigation_map[current_node][1] != null:
            current_node = navigation_map[current_node][1]
        
        place_cursor_on_current_node()
            
    if Input.is_action_just_pressed("ui_left"):
        if current_node == null:
            current_node = aspect_node
            
        elif navigation_map[current_node][2] != null:
            current_node = navigation_map[current_node][2]
        
        place_cursor_on_current_node()
            
    if Input.is_action_just_pressed("ui_right"):            
        if current_node == null:
            current_node = aspect_node
            
        elif navigation_map[current_node][3] != null:
            current_node = navigation_map[current_node][3]
        
        place_cursor_on_current_node()
            
    if Input.is_action_just_pressed("ui_accept"):            
        if current_node == null:
            current_node = aspect_node
            place_cursor_on_current_node()
        
        else:
            press_current_node_button()
        
func handle_option_buttons():
    var button : Button = current_node.get_node("Clickable")
    var arrow_left = current_node.get_node("ArrowLeft")
    var arrow_right = current_node.get_node("ArrowRight")
    
    var max_index = button.get_item_count() - 1
    var current_index = button.get_selected_id()
    
    if Input.is_action_just_pressed("ui_left"):
        if current_index > 0:
            button.select(current_index - 1)
            
    if Input.is_action_just_pressed("ui_right"):
        if current_index < max_index:
            button.select(current_index + 1)
            
    if current_index > 0:
        arrow_left.visible = true
    else:
        arrow_left.visible = false
    
    if current_index < max_index:
        arrow_right.visible = true
    else:
        arrow_right.visible = false
    
    if Input.is_action_just_pressed("ui_accept"):
        set_using_ob(false)
        
    if Input.is_action_just_pressed("ui_cancel"):
        button.select(original_ob_selection)
        set_using_ob(false)
        
func handle_sliders():
    var slider : Slider = current_node.get_node("Clickable")
        
    if Input.is_action_pressed("ui_left"):
        if not slider_repeating_left:
            slider_repeating_left = true
            slider_delay_timer.start(SLIDER_REPEAT_DELAY)
            
            if slider.value > slider.min_value:
                slider.value -= slider.step
                
        elif slider_delay_timer.is_stopped() and slider_repeat_timer.is_stopped():
            slider_repeat_timer.start(SLIDER_REPEAT_SPEED)
            if slider.value > slider.min_value:
                slider.value -= slider.step
    else:
        slider_repeating_left = false
            
    if Input.is_action_pressed("ui_right"):
        if not slider_repeating_right:
            slider_repeating_right = true
            slider_delay_timer.start(SLIDER_REPEAT_DELAY)
            
            if slider.value < slider.max_value:
                slider.value += slider.step
                
        elif slider_delay_timer.is_stopped() and slider_repeat_timer.is_stopped():
            slider_repeat_timer.start(SLIDER_REPEAT_SPEED)
            if slider.value < slider.max_value:
                slider.value += slider.step
            
    else:
        slider_repeating_right = false
        
    slider.value = clamp(slider.value, slider.min_value, slider.max_value)
    
    if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
        set_using_slider(false)
    
func place_cursor_on_current_node():
    var button = current_node.get_node("Clickable")
    var node_pos = button.rect_global_position
    var node_size = button.rect_size*button.rect_scale
    var new_position = node_pos + node_size/2
    
    get_viewport().warp_mouse(new_position)

func press_current_node_button():
    var button : Control = current_node.get_node("Clickable")
    if button is OptionButton:
        original_ob_selection = button.get_selected_id()
        set_using_ob(true)
    
    elif button is HSlider:
        set_using_slider(true)
        
    else:
        button._pressed()

func set_using_ob(value : bool, exiting : bool = false):
    if using_option_button and not value:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        current_node.get_node("ArrowLeft").visible = false
        current_node.get_node("ArrowRight").visible = false
        
    elif not exiting:
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

    using_option_button = value
    
func set_using_slider(value : bool, exiting : bool = false):
    if using_slider and not value:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        
    elif not exiting:
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

    using_slider = value
