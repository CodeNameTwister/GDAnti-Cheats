extends Node

var my_grant_value_int : TrackerStream = TrackerStream.new()

# Buffer Track
var track : Array = []

## Success Update callback
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
	print(" ==== INTEGER EXAMPLE ===== ")

	#CONNECT
	my_grant_value_int.updated.connect(_on_update_int)
	my_grant_value_int.error.connect(_on_error)

	#INTIIALZIE
	print("Before initialize: is integer ", my_grant_value_int.get_type() == TYPE_INT)
	my_grant_value_int.value = 0 #First time defined this tracker as integer
	print("After initialize: is integer ", my_grant_value_int.get_type() == TYPE_INT)

	my_grant_value_int.value = "Trying update" # Trigger error by another type by default
	my_grant_value_int.value = 1.4 # Trigger error by another type by default

	my_grant_value_int.value = 12 # Append to track
	my_grant_value_int.value = 15 # Append to track
	my_grant_value_int.value = 24 # Append to track
	my_grant_value_int.value = 32 # Append to track
	my_grant_value_int.value = 10 # Append to track

	print("\nTrack:\n",track,"\n")
