class_name _OVAL extends Object
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	GDAnti-Cheats
#
#	https://github.com/CodeNameTwister/GDAnti-Cheats
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
const STRS : String = 'abcdefghijklmnopqrstuvwxyz0123456789_'

static var __INIT_1 : bool = false
static var GDAC_GROUP : StringName = &"GDAntiCheats":
	get:
		if !__INIT_1:
			__INIT_1 = true
			var random : RandomNumberGenerator = RandomNumberGenerator.new()
			random.randomize()
			var shift : int = random.randi()
			var data : PackedStringArray = []
			var raw : String = GDAC_GROUP.strip_edges()
			for i in raw:
				var char : String = STRS[(i.unicode_at(0) + shift) % 26]
				if random.randi() % 2 == 0:
					char = char.to_upper()
				data.append(char)
			GDAC_GROUP = ''.join(data)
		return GDAC_GROUP

signal log_message(msg0 : String, msg1 : String)

var value : _VAL = _VAL.new()

func _set(property: StringName, value: Variant) -> bool:
	log_message.emit(property, value)
	Engine.get_main_loop().quit(6)
	return true

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(value):
			value.free()
