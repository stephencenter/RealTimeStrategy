extends Button

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.OPTIONS]

onready var config = get_tree().get_root().get_node("Game/SettingsManager")
onready var checkbox_sprite_on : Texture = load("res://Sprites/checkbox_filled.png")
onready var checkbox_sprite_off : Texture = load("res://Sprites/checkbox_empty.png")

func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
        
    update_button_icon()

func _pressed():
    config.set_temp_setting("pan_enabled", !config.get_temp_setting("pan_enabled"))
        
func update_button_icon():
    if config.get_temp_setting("pan_enabled"):
        icon = checkbox_sprite_on
    else:
        icon = checkbox_sprite_off
