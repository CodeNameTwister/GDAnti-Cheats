class_name StreamValue extends RefCounted
var flush_rate : int = 30
var buffer_size : int = 10

var _slot : Array[_VAL] = []

var _idx : int = 0
var _flush_idx : int = 0

var flush_value : Callable = Callable()

func globaL_update_settings(buffer : int, flush : int) -> void:
	flush_rate = flush
	buffer_size = buffer
	_stream_init()

func fill(value : Variant) -> void:
	for s in _slot:
		s.set_value(value)

func get_stream(current_variant : Variant = null) -> Variant:
	return _slot[_idx].get_value()

func set_stream(value: Variant) -> void:
	if _flush_idx > flush_rate:
		for x in _slot.size():
			if x == _idx:continue
			_slot[x].free()
			_slot[x] = _VAL.new()
		_flush_idx = 0
	if flush_value.is_valid():
		flush_value.call(_slot[_idx])
	else:
		_slot[_idx].set_value(null)
	_idx = wrapi(_idx + 1, 0, _slot.size())
	_slot[_idx].set_value(value)
	_flush_idx += 1

func _init() -> void:
	_stream_init()
	_init_value()
	var singleton : Node = Engine.get_main_loop().root.get_node_or_null("GDAntiCheats")
	if singleton:
		singleton.stream_buffer_change.connect(globaL_update_settings)
		flush_value = singleton.flush_value
		flush_rate = singleton.FLUSH_RATE
		buffer_size = singleton.BUFFER_SIZE

func _init_value() -> void:pass

func _stream_init() -> void:
	while _slot.size() < buffer_size:
		_slot.append(_VAL.new())
	var __idx : int = _idx
	while _slot.size() >= buffer_size:
		__idx = wrapi(__idx - 1, 0, _slot.size())
		if __idx == _idx:break
		var v : _VAL = _slot[_idx]
		_slot.remove_at(_idx)
		v.free()
	assert(_slot.size() > 0, "No memory aviable!")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for s in _slot:
			if is_instance_valid(s):
				s.free()
		_slot.clear()
		var singleton : Node = Engine.get_main_loop().root.get_node_or_null("GDAntiCheats")
		if singleton:
			singleton.unregister(self)
