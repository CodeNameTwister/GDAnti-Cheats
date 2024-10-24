@tool
extends EditorPlugin

func _enter_tree() -> void:
	var cfg : ConfigFile = ConfigFile.new()
	var dir : String = (get_script() as Script).resource_path.get_base_dir()
	var path : String = str(dir,"/plugin.cfg")
	if FileAccess.file_exists(path):
		cfg.load(path)
		var buff : String = str(cfg.get_value("plugin", "name", "GDAnti-Cheats"), " enabled!")
		if cfg.has_section_key("plugin", "issues"):
			buff = str(buff, " Report bugs or request features to (", cfg.get_value("plugin", "issues"),")")
	add_autoload_singleton("GDAntiCheats", str(dir, "/singleton.gd"))

func _exit_tree() -> void:
	remove_autoload_singleton("GDAntiCheats")
