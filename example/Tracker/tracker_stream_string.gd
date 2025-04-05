extends Node

var my_grant_value_string : TrackerStream = TrackerStream.new()

var track : Array = []

## On update callback for save track!
func _on_update_int(last_value : Variant, new_value : Variant) -> void:
	# Get last tracked value
	if track.size() > 0:
		if track[track.size() - 1] != last_value:
			#External altered value!
			print("[WARNING] Altered last value!")

	# Add new value to track
	track.append(new_value)

	# Remove overflow stack
	if track.size() > 10:
		track.remove_at(0)

	print("OK > Update with new value: Last value {0}, New Value {1}".format([last_value, new_value]))

## On validations fail! see: TrackStream._is_valid
func _on_error(last_value : Variant, new_value : Variant) -> void:
	print("X > On error trying update, values: Last value {0}, New Value {1}".format([last_value, new_value]))

func _ready() -> void:
	print(" ==== STRING EXAMPLE ===== ")

	#CONNECT
	my_grant_value_string.updated.connect(_on_update_int)
	my_grant_value_string.error.connect(_on_error)

	#INTIIALZIE
	print("Before initialize: is string ", my_grant_value_string.get_type() == TYPE_STRING)
	my_grant_value_string.value = "Any thing" #First time defined this tracker as integer
	print("After initialize: is string ", my_grant_value_string.get_type() == TYPE_STRING)

	my_grant_value_string.value = 1.4 # Trigger error by another type by default
	my_grant_value_string.value = 12 # Trigger error by another type by default
	my_grant_value_string.value = "Trying update" # OK

	my_grant_value_string.value = "Hello" # Append to track
	my_grant_value_string.value = "Godot" # Append to track
	my_grant_value_string.value = "World" # Append to track
	my_grant_value_string.value = "4.3" # Append to track
	my_grant_value_string.value = "Tracker Script" # Append to track

	print("\nTrack:\n",track,"\n")
