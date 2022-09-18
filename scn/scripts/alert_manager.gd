extends Node

@onready var alert_scn: PackedScene = preload("res://scn/alert/alert.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func alert(type: AlertBox.Type, message: String, duration: float = 3.0) -> void:
    var alert: AlertBox = alert_scn.instantiate()
    alert.setup(type, message)
    get_tree().root.add_child(alert)
    alert.display(duration)

func alert_success(message: String, duration: float = 3.0) -> void:
    alert(AlertBox.Type.SUCCESS, message, duration)

func alert_info(message: String, duration: float = 3.0) -> void:
    alert(AlertBox.Type.INFO, message, duration)

func alert_warning(message: String, duration: float = 3.0) -> void:
    alert(AlertBox.Type.WARNING, message, duration)

func alert_error(message: String, duration: float = 3.0) -> void:
    alert(AlertBox.Type.ERROR, message, duration)
