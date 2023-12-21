class_name UI
extends CanvasLayer


signal restart()
signal start_game()

@onready var _timer_label : Label = %Timer
@onready var _progress_bar : TextureProgressBar = %Clock
@onready var _height_label : Label = %HeightCounter

@onready var _timer_control : Control = $TimerControl
@onready var _height_control : Control = $HeightCounterControl
@onready var _high_scores_button_control : Control = $HighScoresButtonControl
@onready var _high_scores_control : HighScoresControl = $HighScoresControl
@onready var _main_menu_control: Control = $MainMenuControl
@onready var _info_control : Control = $InfoControl

@onready var _audio_stream_player : AudioStreamPlayer = $HighScoresControl/AudioStreamPlayer
var _button_sound = preload("res://assets/audio/sfx/click.wav")

var _stack_height_px : int


func _ready() -> void:
	_audio_stream_player.stream = _button_sound


func on_tick(time_left : float) -> void:
	_progress_bar.value = 100 - ceili(100 * (time_left - floor(time_left)))
	_timer_label.text = str(ceili(time_left))
	#print("Time left: " + str(time_left))


func on_gameover() -> void:
	_timer_control.hide()


func on_start_measuring() -> void:
	_height_control.show()


func on_height_counter(current_height : String) -> void:
	_height_label.text = current_height
	#print("Current height: " + str(current_height))


func on_done_measuring(height : int) -> void:
	_stack_height_px = height
	_high_scores_button_control.show()


func _on_end_game_button_pressed() -> void:
	#print("end game button pressed")
	_audio_stream_player.play()
	#_main_menu_control.hide()
	_height_control.hide()
	_high_scores_button_control.hide()
	_high_scores_control.show()
	_high_scores_control.play_again_button.hide()
	_high_scores_control.check_score(_stack_height_px)


func _on_play_again_button_pressed() -> void:
	#print("play again button pressed")
	# Send signal to top_level.gd through game.gd to restart.
	restart.emit()
	_audio_stream_player.play()
	_main_menu_control.show()
	_high_scores_control.hide()
	start_game.emit()


func _on_play_button_pressed() -> void:
	#print("play button pressed")
	_audio_stream_player.play()
	_main_menu_control.hide()
	start_game.emit()


func _on_high_scores_button_pressed() -> void:
	#print("high scores button pressed")
	_audio_stream_player.play()
	_main_menu_control.hide()
	_high_scores_control.show()
	_high_scores_control.login()


func _on_info_button_pressed() -> void:
	_audio_stream_player.play()
	_main_menu_control.hide()
	_info_control.show()


func _on_main_menu_button_pressed() -> void:
	_audio_stream_player.play()
	_main_menu_control.show()
	_info_control.hide()
