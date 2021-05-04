extends Button

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.OPTIONS]

onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var config = get_tree().get_root().get_node("Game/SettingsManager")
onready var success_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var success_label = get_parent().get_parent().get_node("SuccessLabel")

func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        success_label.set_text("")
        return
        
    if success_timer.is_stopped():
        success_label.set_text("")
    
func _pressed():
    config.apply_temp_settings()
    config.previous_ratio_id = -1
    config.previous_reso_id = -1
    success_label.set_text("Settings applied successfully!")
    success_timer.start(3)
