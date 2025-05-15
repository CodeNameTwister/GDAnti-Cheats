class_name TrackValue extends RefCounted

## Max Buffer Track Capacity.
var max_track_value : int = 10:
	set(max_value):
		max_track_value = maxi(max_value, 0)
		
		if _buffer_track.size() > 0 and max_track_value != _buffer_track.size():
			if max_track_value < 1:
				_index_track = 0
				_buffer_track.resize(max_track_value)
				_time_track.resize(max_track_value)
				return
				
			var index : int = 0
			var new_buffer : Array[Array] = get_log_track()
			
			_buffer_track.resize(max_track_value)
			_time_track.resize(max_track_value)
		
			_buffer_track.fill(null)
			_time_track.fill(0.0)
			
			if max_track_value >= new_buffer.size():
				_index_track = new_buffer.size()
				for x : int in range(_index_track):
					var data : Array = new_buffer[x]
					_buffer_track[x] = data[0]
					_time_track[x] = data[1]
				_index_track = wrapi(_index_track + 1, 0, _buffer_track.size())
			else:
				_index_track = _buffer_track.size()
				var current : int = new_buffer.size() - 1
				for x : int in range(_index_track - 1, -1, -1):
					var data : Array = new_buffer[current]
					_buffer_track[x] = data[0]
					_time_track[x] = data[1]
					current -= 1
				_index_track = wrapi(_index_track + 1, 0, _buffer_track.size())
		

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

var _index_track : int = 0

var _buffer_track : Array[Variant] = []:
	set(__):
		return

var _time_track : PackedFloat64Array = []:
	set(__):
		return

var _track_stream : TrackerStream = TrackerStream.new():
	set(__):
		return

## Get Full Track Buffer List.
func get_track() -> Array[Variant]:
	var track : Array[Variant] = Array(_buffer_track)
	for x : int in range(_buffer_track.size()):
		track[x] =  _buffer_track[x]
	return _buffer_track.duplicate(true)
	
## Get Sorter Current Tracked List By Time Updated.
func get_sorter_track() -> Array[Variant]:
	var track : Array[Array]
	var out : Array[Variant]
	
	var total : int = 0
	var size : int = _buffer_track.size()
	
	track.resize(size)
	out.resize(size)
	
	for x : int in range(size):
		var time : float = _time_track[x]
		if time == 0.0:
			break
		total += 1
		track[x] = [_buffer_track[x], time]
		
	if total < track.size():
		track.resize(total)
		out.resize(total)
		
	track.sort_custom(_sort_ascending)
	
	for x : int in range(track.size()):
		out[x] = track[x][0]
		
	return out
	
## Get Current Track With Time Unix Parsed.
func get_log_track_time_parsed() -> Array[Array]:
	var track : Array[Array]
	var total : int = 0
	track.resize(_buffer_track.size())
	
	for x : int in range(_buffer_track.size()):
		var time : float = _time_track[x]
		if time == 0.0:
			break
		total += 1
		track[x] = [_buffer_track[x], time]
	
	if total < track.size():
		track.resize(total)
		
	track.sort_custom(_sort_ascending)
	
	for x : int in range(track.size()):
		track[x][1] = _convert_time(track[x][1])
		
	return track
	
## Get Current Track With Unix Time.
func get_log_track() -> Array[Array]:
	var track : Array[Array]
	var total : int = 0
	
	track.resize(_buffer_track.size())
	
	for x : int in range(_buffer_track.size()):
		var time : float = _time_track[x]
		if time == 0.0:
			break
		total += 1
		track[x] = [_buffer_track[x], _time_track[x]]
	
	if total < track.size():
		track.resize(total)
		
	track.sort_custom(_sort_ascending)
		
	return track
	
func _convert_time(unix_time : float) -> String:
	return Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_unix_time(unix_time), true)
	
func _sort_ascending(val0 : Array, val1 : Array) -> bool:
	return val0[1] < val1[1]
	
## Get Last Tracked Value.
func get_last_tracked_value() -> Variant:
	if _buffer_track.size() > 0:
		return _buffer_track[wrapi(_index_track - 1, 0, _buffer_track.size())]
	if OS.is_debug_build():
		push_warning("Not has a tracked value!")
	return null

func _on_updated(last_value : Variant, new_value : Variant) -> void:
	# Get last tracked value
	if _buffer_track.size() > 0:
		if _buffer_track[wrapi(_index_track - 1, 0, _buffer_track.size())] != last_value:
			#External altered value!
			last_value_error.emit(last_value, _buffer_track[_buffer_track.size() - 1])
	elif max_track_value > 0:
		_time_track.resize(max_track_value)
		_buffer_track.resize(max_track_value)
	else:
		updated.emit(last_value, new_value)
		return

	# Add new value to _buffer_track
	_buffer_track[_index_track] = new_value
	_time_track[_index_track] = Time.get_unix_time_from_system()
	_index_track = wrapi(_index_track + 1, 0, _buffer_track.size())
		
	# Emit Propagation
	updated.emit(last_value, new_value)
		
func _on_error(last_value : Variant, new_value : Variant) -> void:
	if OS.is_debug_build():
		push_warning("On error trying update, values: Last value {0}, New Value {1}".format([last_value, new_value]))
		
	# Emit Propagation
	error.emit(last_value, new_value)

func _init() -> void:
	_track_stream.updated.connect(_on_updated)
	_track_stream.error.connect(_on_error)
