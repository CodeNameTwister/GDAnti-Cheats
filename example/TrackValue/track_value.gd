extends Node
#region _GUI_EXAMPLE_
@export var _gui_value : Control
@export var _gui_time : Control
@export var _gui_time_seconds_update : SpinBox

var _index : int = 0
var _time_update : float = 0.0
var _current_delta_time : float = 0.0
#endregion

# Own Tracked Object
var tracked : TrackValue = TrackValue.new()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_up"):
		#Get last value
		print("Last tracked value {0}".format([tracked.get_last_tracked_value()]))
	elif event.is_action_pressed(&"ui_down"):
		#Get track list
		print("Tracked list\n{0}".format([str(tracked.get_track())]))

func _ready() -> void:
	#region _TRACK_SIGNASL_
	tracked.updated.connect(_on_update)
	tracked.last_value_error.connect(_on_value_modified)
	#endregion
	
	# Just Used for the example scene.
	var values : int = tracked.MAX_TRACK_VALUES
	
	for x : int in range(0, values, 1):
		var value_label : Label = Label.new()
		var time_label : Label = Label.new()
		_gui_value.add_child(value_label)
		_gui_time.add_child(time_label)
	
	_time_update = maxf(_gui_time_seconds_update.value, 1.0)
	_current_delta_time = _time_update
	
	_gui_time_seconds_update.value_changed.connect(_on_change_time)
	
#region _EXAMPLE_SCENE_FUNCTIONS_
func _on_change_time(time : float) -> void:
	_time_update = maxf(time, 1.0)
	
func _on_value_modified(last_value : Variant, current_value : Variant) -> void:
	print("[WARNING] Values unspected change! last track value: {0} ; current buffer value: {1}".format([last_value, current_value]))
	
func _on_update(_last_value : Variant, new_value : Variant) -> void:
	if _index == _gui_value.get_child_count():
		_index = 0
		
	var value_label : Label = _gui_value.get_child(_index)
	var time_label : Label = _gui_time.get_child(_index)
	
	value_label.text = str(new_value)
	time_label.text = _get_time()
	
	for x : Node in _gui_value.get_children():
		x.set(&"modulate", Color.GRAY)
	for x : Node in _gui_time.get_children():
		x.set(&"modulate", Color.GRAY)
	value_label.modulate = Color.WHITE
	time_label.modulate = Color.WHITE
	
	_index += 1
	
func _get_time() -> String:
	var time : Dictionary = Time.get_datetime_dict_from_system()
	for x : String in ["hour", "minute", "second"]:
		var val : int = 0
		var variant : Variant = time[x]
		if typeof(variant) == TYPE_INT:
			val = variant
		else:
			val = str(variant).to_int()
		if val < 10:
			time[x] = str("0", variant)
		else:
			time[x] = str(variant)
	
	return "{0}:{1}:{2}".format([time["hour"], time["minute"], time["second"]])

func _process(delta: float) -> void:
	_current_delta_time += delta
	if _time_update < _current_delta_time:
		_current_delta_time = 0.0
		tracked.value = randi_range(0, 1000)

func _update_gui() -> void:
	for x : int in range(0, _gui_value.get_child_count(), 1):
		var text : Label = _gui_value.get_child(x)
		text.text = str(tracked.value)
	for x : int in range(0, _gui_time.get_child_count(), 1):
		var text : Label = _gui_time.get_child(x)
		text.text = str(tracked.value)
#endregion
