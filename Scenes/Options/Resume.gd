extends Button

onready var interface = get_tree().get_root().get_node("Game/Interface")
onready var the_game = get_tree().get_root().get_node("Game")

func _pressed():
    interface.close_options_menu()
    the_game.revert_game_state()
