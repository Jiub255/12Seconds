class_name HighScoresControl
extends Control


var _entries : Array[HBoxContainer]
var _entry_resource : PackedScene = preload("res://scenes/game/ui/high-score-entry.tscn")
var _entry_submit_resource : PackedScene = preload("res://scenes/game/ui/high-score-entry-submit.tscn")
## Array of Dicts with keys: "rank", "name", and "score".
var _high_scores : Array[Dictionary]
var _entry_submit_instance : HighScoreEntrySubmit
var _stack_height_px : int

@onready var _high_scores_vbox : VBoxContainer = $Background/VBoxContainer
@onready var play_again_button : Button = $Background/PlayAgainButton
@onready var loading_label: Label = $Background/LoadingLabel

var game_API_key = "dev_98a7bbf4a27646589bf17d30735891b5"
var development_mode = true
var leaderboard_key = "12SecondsLeaderboard"
var session_token = ""
var score = 0

# HTTP Request node can only handle one call per node
var auth_http = HTTPRequest.new()
var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()

var _player_identifier : String


func _ready() -> void:
	login()


func login() -> void:
		## Convert data to json string:
	var data = { "game_key": game_API_key, "game_version": "0.0.0.1", "development_mode": true }

	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]

	# Create a HTTPRequest node for authentication
	auth_http = HTTPRequest.new()
	add_child(auth_http)
	# TODO: Is self. needed in the connect method?
	auth_http.request_completed.connect(_on_authentication_request_completed)
	# Send request
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, str(data))
	# Print what we're sending, for debugging purposes:
	print("Sent data: " + str(data))

	# Clear high score ui.
	for child in _high_scores_vbox.get_children():
		child.queue_free()
	# Show loading label.
	loading_label.show()


func _on_authentication_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	## Save player_identifier to file
	#var file = File.new()
	#file.open("user://LootLocker.data", File.WRITE)
	#file.store_string(json.result.player_identifier)
	#file.close()
	_player_identifier = json.data["player_identifier"]

	# Save session_token to memory
	session_token = json.data["session_token"]
	print("Session token: " + str(session_token))

	# Print server response
	print("Response: " + str(json.data))

	# Clear node
	auth_http.queue_free()
	# Get leaderboards
	get_scores()


func get_scores() -> void:
	print("Getting leaderboards")
	var url = "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:" + session_token]

	# Create a request node for getting the highscore
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	# TODO: Is self. needed in the connect method?
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	# Send request
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")


func _on_leaderboard_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())

	# Print data
	print("Leaderboard request completed data: " + str(json.data))

	_high_scores.clear()

	# Formatting as a leaderboard
	var rank : String
	var player_name : String
	var score : String
	print("size: " + str(json.data["items"].size()))
	for n in json.data["items"].size():
		rank = str(json.data["items"][n]["rank"])
		player_name = json.data["items"][n]["metadata"]
		score = str(json.data["items"][n]["score"])

		# Print the formatted leaderboard to the console
		print("Rank: " + rank + ", Name: " + player_name + ", Score: " + score)

		_high_scores.append({ "rank" = rank, "name" = player_name, "score" = score})

	print("High scores: " + str(_high_scores))

	# Clear node
	leaderboard_http.queue_free()

	_setup_entries()
	play_again_button.show()


# TODO: Need to split into if _high_scores.size() < 10 and else.
# Because if < 10, then it needs to add an extra entry to account for the new one,
# but not if there's already ten.
func _setup_entries(rank : int = 42069, score : int = 0) -> void:
	for child in _high_scores_vbox.get_children():
		child.queue_free()

	loading_label.hide()

	if rank > 10:
		play_again_button.show()

	var range : Array = range(1, min(_high_scores.size() + 1, 11))
	if _high_scores.size() < 10 and rank < 42069:
		range = range(1, _high_scores.size() + 2)

	# Rank offset to make tied scores have the same rank.
	var rank_offset : int = 0
	for i in range:
		if i < rank:
			var entry_instance : HighScoreEntry = _entry_resource.instantiate()
			var high_score : Dictionary = _high_scores[i - 1]
			if i > 1:
				var previous_score : Dictionary = _high_scores[i - 2]
				if high_score["score"] == previous_score["score"]:
					rank_offset -= 1
			entry_instance.setup_entry(str(int(high_score["rank"]) + rank_offset), high_score["name"], format_height(int(high_score["score"])))
			_high_scores_vbox.add_child(entry_instance)
			_entries.append(entry_instance)
		elif rank == i:
			_entry_submit_instance = _entry_submit_resource.instantiate()
			# TODO: Is there a better way to do this without get_node?
			#var button : Button = _entry_submit_instance.get_node("SubmitButton")
			#var high_score : Dictionary = { "rank": str(rank), "score": str(score)}
			if i > 1:
				var previous_score : Dictionary = _high_scores[i - 2]
				if str(score) == previous_score["score"]:
					rank_offset -= 1
			_entry_submit_instance.setup_entry(str(rank + rank_offset), format_height(score))
			_entry_submit_instance.submit_button.pressed.connect(_on_submit_pressed)
			_high_scores_vbox.add_child(_entry_submit_instance)
			_entries.append(_entry_submit_instance)
		elif rank < i:
			var entry_instance : HighScoreEntry = _entry_resource.instantiate()
			var high_score : Dictionary = _high_scores[i - 2]
			if i == rank + 1:
				if high_score["score"] == str(score):
					rank_offset -= 1
			elif i > rank + 1:
				var previous_score : Dictionary = _high_scores[i - 3]
				if high_score["score"] == previous_score["score"]:
					rank_offset -= 1
			entry_instance.setup_entry(str(int(high_score["rank"]) + rank_offset + 1), high_score["name"], format_height(int(high_score["score"])))
			_high_scores_vbox.add_child(entry_instance)
			_entries.append(entry_instance)


func _upload_score(player_name : String, score : int) -> void:
	# TODO: What form should this data be in? Needs _player_identifier?
	var data = { "member_id": _player_identifier, "score": score, "metadata": player_name }
	var headers = ["Content-Type: application/json", "x-session-token:" + session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/" + leaderboard_key + "/submit", headers, HTTPClient.METHOD_POST, str(data))
	# Print what we're sending, for debugging purposes:
	print("Submit score data: " + str(data))


func _on_upload_score_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	# Print data
	print("Score request completed data: " + str(json.data))
	# Clear node
	submit_score_http.queue_free()
	# Reload the menu with the new scores.
	get_scores()


# Score (height) is stored in leaderboard in pixels. Need to use format_height after getting it.
# Called after height is calculated.
func check_score(stack_height_px : int) -> void:
	var rank : int = get_rank(stack_height_px)
	_setup_entries(rank, stack_height_px)
	_stack_height_px = stack_height_px


# Call from pressing submit (or maybe enter) from high score entry submit scene.
func _on_submit_pressed() -> void:
	_upload_score(_entry_submit_instance.line_edit.text, _stack_height_px)


func get_rank(stack_height_px : int) -> int:
	for i in range(_high_scores.size() - 1, -1, -1):
		if stack_height_px < int(_high_scores[i]["score"]):
			# You are in (i + 2)th place.
			return i + 2
	# You are in 1st place.
	return 1


func format_height(height : int) -> String:
	var height_inches : int = roundi(height * 0.13504)
	var feet : int = floori(height_inches / 12)
	var inches : int = height_inches % 12
	var ft_in_str : String
	if feet == 0:
		ft_in_str = str(inches) + " in"
	else:
		if inches == 0:
			ft_in_str = str(feet) + " ft"
		else:
			ft_in_str = str(feet) + " ft " + str(inches) + " in"
	var cm : int = roundi(height * 0.34302)
	var cm_str = str(cm) + " cm"
	return ft_in_str + " / " + cm_str
