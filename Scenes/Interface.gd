extends CanvasLayer

onready var the_game = get_tree().get_root().get_node("Game")
onready var options_menu = $Centered/OptionsMenu
onready var config = get_tree().get_root().get_node("Game/SettingsManager")
onready var background : TextureRect = get_tree().get_root().get_node("Game/Background/Sprite")
onready var camera : Camera2D = get_tree().get_root().get_node("Game/Camera2D")
var time_when_paused : int = 0

func _ready():
    config.use_settings()

func _process(_delta):        
    config.use_settings()
    align_ui_elements()
    update_hud_text()
    process_selected_unit_pointer()
    
func update_hud_text():
    if the_game.is_current_state(the_game.GameState.INGAME):
        var elapsed_time = OS.get_unix_time() - the_game.start_time
        var minutes = elapsed_time / 60
        var seconds = elapsed_time % 60
        var string_time : String = "%02d:%02d" % [minutes, seconds]
        $TopRight/ElapsedTime.set_text("TIME: %s" % string_time)
    
    $BotLeft/Framerate.set_text("%s FPS" % Engine.get_frames_per_second())
    
func open_options_menu():
    options_menu.visible = true
    enable_mouse_cursor()
    config.reset_temp_settings()
    time_when_paused = OS.get_unix_time()
    
func close_options_menu():
    options_menu.visible = false
    options_menu.set_using_ob(false, true)
    options_menu.set_using_slider(false, true)
    the_game.start_time += OS.get_unix_time() - time_when_paused
    config.clear_temp_settings()

func align_ui_elements():
    var internal_x = ProjectSettings.get_setting("display/window/size/width")
    var internal_y = ProjectSettings.get_setting("display/window/size/height")
    var effective_x = get_viewport().get_visible_rect().size.x
    var effective_y = get_viewport().get_visible_rect().size.y
    
    $Centered.rect_global_position.x = 0.5*(effective_x - internal_x)
    $Centered.rect_global_position.y = 0.5*(effective_y - internal_y)
    $TopRight.rect_global_position.x = effective_x - internal_x
    $BotLeft.rect_global_position.y = effective_y - internal_y
    $TopCenter.rect_global_position.x = 0.5*(effective_x - internal_x)
    $BotRight.rect_global_position.x =  effective_x - internal_x
    $BotRight.rect_global_position.y =  effective_y - internal_y

func enable_joystick_cursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    
func enable_mouse_cursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
func process_selected_unit_pointer():
    var world_rect = the_game.get_visible_world_rect()
    var r_topleft = world_rect[0]
    var r_botright = world_rect[1]
    var target_pos = Vector2.ZERO
    var pointer_zone = (r_botright - r_topleft).y*0.03
    
    if the_game.does_rect_contain_point(r_topleft, r_botright, target_pos):
        $Pointer.visible = false
        return
        
    else:
        $Pointer.visible = true
    
    # Top and Bot
    if r_topleft.x <= target_pos.x and target_pos.x <= r_botright.x:
        $Pointer.global_position.x = clamp(target_pos.x, r_topleft.x + pointer_zone, r_botright.x - pointer_zone)
        
        # Top
        if target_pos.y <= r_topleft.y:
            $Pointer.global_position.y = r_topleft.y + pointer_zone
            
        # Bot
        else:
            $Pointer.global_position.y = r_botright.y - pointer_zone
        
    # Left and Right
    else:
        $Pointer.global_position.y = clamp(target_pos.y, r_topleft.y + pointer_zone, r_botright.y - pointer_zone)
        
        # Left
        if target_pos.x <= r_topleft.x:
            $Pointer.global_position.x = r_topleft.x + pointer_zone
            
        # Right
        else:
            $Pointer.global_position.x = r_botright.x - pointer_zone
            
    $Pointer.rotation = $Pointer.global_position.angle_to_point(target_pos)
    $Pointer.global_position = $Pointer.global_position + r_botright - 2*camera.offset        
