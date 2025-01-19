class_name LogPanel
extends Window

@onready var rich_text_label: RichTextLabel = %RichTextLabel

@export var log_button: Button

func _ready() -> void:
	close_requested.connect(_on_close_requested)

func add_log(log: String) -> void:
	rich_text_label.add_text(log)
	rich_text_label.newline()
	
	if visible == false:
		log_button.flat = false

func _on_close_requested() -> void:
	hide()
	log_button.flat = true

func _notification(what: int) -> void:
	
	pass
