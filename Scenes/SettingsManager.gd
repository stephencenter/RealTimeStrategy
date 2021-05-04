extends Node

var SETTINGS : Dictionary = {
    "aspect_ratio": 0,
    "resolution_id": 2,
    "resolution_x": 1600,
    "resolution_y": 900,
    "display_mode": 0,
    "pan_enabled": true,
    "pan_speed": 1.0
}       

var temp_settings : Dictionary
var previous_ratio_id = -1
var previous_reso_id = -1
var previous_dm = -1

func _ready():
    reset_temp_settings()
        
func use_settings():
    # Set display mode
    if get_setting("display_mode") == 0:
        OS.window_fullscreen = false
        OS.window_borderless = false
        
    if get_setting("display_mode") == 1:
        OS.window_fullscreen = true
        OS.window_borderless = false
        
    if get_setting("display_mode") == 2:
        OS.window_borderless = true
        OS.window_fullscreen = false
        
    # Update window resolution
    var screen_size = OS.get_screen_size()
    var desired_size = Vector2(get_setting("resolution_x"), get_setting("resolution_y"))
    
    if previous_ratio_id != get_setting("aspect_ratio") or previous_reso_id != get_setting("resolution_id"):
        OS.set_window_size(desired_size)
        if desired_size.x < screen_size.x and desired_size.y < screen_size.y:
            OS.window_maximized = false
            
        previous_ratio_id = get_setting("aspect_ratio")
        previous_reso_id = get_setting("resolution_id")
            
        center_window()
    
    # Center window if the display mode changed
    if get_setting("display_mode") != previous_dm:
        previous_dm = get_setting("display_mode")
        center_window()

func get_setting(key: String):
    if SETTINGS.has(key):
        return SETTINGS[key]
    return null

func apply_temp_settings():
    SETTINGS = temp_settings.duplicate()

func get_temp_setting(key : String):
    if temp_settings.has(key):
        return temp_settings[key]
    return null
    
func set_temp_setting(key : String, value):
    temp_settings[key] = value

func reset_temp_settings():
    temp_settings = SETTINGS.duplicate()
    
func clear_temp_settings():
    temp_settings = {}

func center_window():    
    var screen_size = OS.get_screen_size()
    var window_size = OS.get_window_size()
    OS.set_window_position(screen_size/2 - window_size/2)
