class_name SaveManager
extends RefCounted
## Saves a Dictionary as JSON in the folder the game runs from:
##  - exported build: next to the executable
##  - running from the editor: the project folder (next to project.godot)

const FILE_NAME := "savegame.json"


static func get_save_path() -> String:
	var dir: String
	if OS.has_feature("editor"):
		dir = ProjectSettings.globalize_path("res://")
	else:
		dir = OS.get_executable_path().get_base_dir()
	return dir.path_join(FILE_NAME)


static func save(data: Dictionary) -> void:
	var file := FileAccess.open(get_save_path(), FileAccess.WRITE)
	if file == null:
		push_error("Could not write save file (error %d)" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(data, "\t"))


## Returns {} if there is no (valid) save yet.
static func load_data() -> Dictionary:
	var path := get_save_path()
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}
