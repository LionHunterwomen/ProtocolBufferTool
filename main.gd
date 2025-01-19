extends Node2D

const CONFIG_PATH: String = "user://config.cfg"

@onready var protoc_path_line_edit: LineEdit = %ProtocPath
@onready var protoc_select_button: TextureButton = %ProtocSelectButton
@onready var protoc_select_dialog: FileDialog = %ProtocSelectDialog

@onready var type_bar: TabContainer = %TypeBar

@onready var proto_file_path_line_edit: LineEdit = %ProtoFilePath
@onready var proto_file_select_button: TextureButton = %ProtoFileSelectButton
@onready var proto_file_select_dialog: FileDialog = %ProtoFileSelectDialog

@onready var proto_dir_path_line_edit: LineEdit = %ProtoDirPath
@onready var proto_dir_select_button: TextureButton = %ProtoDirSelectButton
@onready var proto_dir_select_dialog: FileDialog = %ProtoDirSelectDialog

@onready var output_dir_path_line_edit: LineEdit = %OutputDirPath
@onready var output_dir_select_button: TextureButton = %OutputDirSelectButton
@onready var output_dir_select_dialog: FileDialog = %OutputDirSelectDialog

@onready var export_button: Button = %ExportButton
@onready var save_config_button: Button = %SaveConfigButton
@onready var log_button: Button = %LogButton

@onready var log_panel: LogPanel = %LogPanel

@export var button_group: ButtonGroup

func _ready() -> void:
	load_config()
	
	export_button.pressed.connect(_on_export_button_pressed)
	save_config_button.pressed.connect(_on_save_config_button_pressed)
	log_button.pressed.connect(_on_log_button_pressed)
	
	protoc_select_button.pressed.connect(_on_protoc_select_button_pressed)
	protoc_select_dialog.file_selected.connect(_on_protoc_select_dialog_file_selected)
	
	proto_dir_select_button.pressed.connect(_on_proto_dir_select_button_pressed)
	proto_dir_select_dialog.dir_selected.connect(_on_proto_dir_select_dialog_dir_selected)
	
	output_dir_select_button.pressed.connect(_on_output_dir_select_button_pressed)
	output_dir_select_dialog.dir_selected.connect(_on_output_dir_select_dialog_dir_selected)
	
	proto_file_select_button.pressed.connect(_on_proto_file_select_button_pressed)
	proto_file_select_dialog.file_selected.connect(_on_file_selected_file_selected)

func save_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("protoc", "path", protoc_path_line_edit.text)
	config.set_value("type_bar", "current_tab", type_bar.current_tab)
	config.set_value("proto_file", "path", proto_file_path_line_edit.text)
	config.set_value("proto_dir", "path", proto_dir_path_line_edit.text)
	config.set_value("output_dir", "path", output_dir_path_line_edit.text)
	
	config.save(CONFIG_PATH)

func load_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var err := config.load(CONFIG_PATH)
	if err != OK:
		printerr("读取配置文件失败!!")
		log_panel.add_log("读取配置文件失败!!")
		return
	
	protoc_path_line_edit.text = config.get_value("protoc", "path", "")
	type_bar.current_tab = config.get_value("type_var", "current_tab", 0)
	proto_file_path_line_edit.text = config.get_value("proto_file", "path", "")
	proto_dir_path_line_edit.text = config.get_value("proto_dir", "path", "")
	output_dir_path_line_edit.text = config.get_value("output_dir", "path", "")

func _on_proto_dir_select_dialog_dir_selected(dir: String) -> void:
	proto_dir_path_line_edit.text = dir

func _on_proto_dir_select_button_pressed() -> void:
	proto_dir_select_dialog.show()

func _on_file_selected_file_selected(path: String) -> void:
	proto_file_path_line_edit.text = path

func _on_proto_file_select_button_pressed() -> void:
	proto_file_select_dialog.show()

func _on_output_dir_select_dialog_dir_selected(dir: String) -> void:
	output_dir_path_line_edit.text = dir

func _on_output_dir_select_button_pressed() -> void:
	output_dir_select_dialog.show()

func _on_protoc_select_dialog_file_selected(path: String) -> void:
	protoc_path_line_edit.text = path

func _on_protoc_select_button_pressed() -> void:
	protoc_select_dialog.show()

func _on_log_button_pressed() -> void:
	log_panel.show()

func _on_save_config_button_pressed() -> void:
	save_config()

func _on_export_button_pressed() -> void:
	export()

func export() -> void:
	if type_bar.current_tab == 0:
		var protoc_path: String = get_protoc_path()
		var proto_file_path: String = get_proto_file_path()
		var output_dir: String = get_output_dir_path()
		var language_cmd: String = get_language_cmd()
		
		var output: Array = []
		OS.execute(protoc_path, ["-I="+proto_file_path.get_base_dir(), language_cmd+output_dir, proto_file_path], output, true)
		
		log_panel.add_log(output[0])
		print(output)
	else:
		var protoc_path: String = get_protoc_path()
		var output_dir: String = get_output_dir_path()
		var language_cmd: String = get_language_cmd()
		var proto_dir_path: String = get_proto_dir_path()
		
		if not DirAccess.dir_exists_absolute(proto_dir_path):
			printerr("Proto目录不存在!!!")
			log_panel.add_log("Proto目录不存在!!!")
			return
		
		var output: Array = []
		for proto_file: String in DirAccess.get_files_at(proto_dir_path):
			if proto_file.get_extension() == "proto":
				var proto_file_path: String = proto_dir_path.path_join(proto_file)
				OS.execute(protoc_path, ["-I="+proto_file_path.get_base_dir(), language_cmd+output_dir, proto_file_path], output, true)
		
		for msg: String in output:
			if msg.is_empty():
				continue
			log_panel.add_log(msg)

func get_language_cmd() -> String:
	return button_group.get_pressed_button().get_meta("Language")

func get_proto_dir_path() -> String:
	return proto_dir_path_line_edit.text

func get_proto_file_path() -> String:
	return proto_file_path_line_edit.text

func get_protoc_path() -> String:
	return protoc_path_line_edit.text

func get_output_dir_path() -> String:
	return output_dir_path_line_edit.text
