class_name TrackValue extends RefCounted
const MAX_TRACK_VALUES : int = 10

## Emitted when value _buffer_track is updated.
signal updated(last_value : Variant, new_value : Variant)

## Emitted when value can not updated.
signal error(last_value : Variant, new_value : Variant)

## Emitted when the last value is not the same as the last tracked value.
signal last_value_error(last_value : Variant, current_value : Variant)

## Property used for update and get current value.
var value : Variant:
	set(new_value):
		_track_stream.value = new_value
	get:
		if _buffer_track.size() > 0 and _buffer_track[_buffer_track.size() - 1] != _track_stream.value:
			last_value_error.emit(_buffer_track[_buffer_track.size() - 1], _track_stream.value)
		return _track_stream.value

var _buffer_track : Array[Variant] = []:
	set(__):
		return
		

var _track_stream : TrackerStream = TrackerStream.new():
	set(__):
		return

## Get Tracked List.
func get_track() -> Array[Variant]:
	return _buffer_track.duplicate(true)
	
## Get Last Tracked Value.
func get_last_tracked_value() -> Variant:
	if _buffer_track.size() > 0:
		return _buffer_track[_buffer_track.size() - 1]
	if OS.is_debug_build():
		push_warning("Not has a tracked value!")
	return null

func _on_updated(last_value : Variant, new_value : Variant) -> void:
	# Get last tracked value
	if _buffer_track.size() > 0:
		if _buffer_track[_buffer_track.size() - 1] != last_value:
			#External altered value!
			last_value_error.emit(last_value, _buffer_track[_buffer_track.size() - 1])

	# Add new value to _buffer_track
	_buffer_track.append(new_value)

	# Remove overflow stack
	if _buffer_track.size() > MAX_TRACK_VALUES:
		_buffer_track.remove_at(0)
		
	# Emit Propagation
	updated.emit(last_value, new_value)
		
func _on_error(last_value : Variant, new_value : Variant) -> void:
	if OS.is_debug_build():
		push_warning("On error trying update, values: Last value {0}, New Value {1}".format([last_value, new_value]))
		
	# Emit Propagation
	error.emit(last_value, new_value)

func _init() -> void:
	_track_stream = TrackerStream.new()
	_track_stream.updated.connect(_on_updated)
	_track_stream.error.connect(_on_error)
