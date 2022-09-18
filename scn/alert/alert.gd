extends PanelContainer
class_name AlertBox

signal started()
signal finished()

@onready var background: ColorRect = $ColorRect
@onready var progress: ProgressBar = $Progress
@onready var icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var message_lbl: Label = $MarginContainer/HBoxContainer/Message

enum Type {
    SUCCESS,
    INFO,
    WARNING,
    ERROR
}

const colors: PackedColorArray = [
    Color("00c745"),
    Color("3cadff"),
    Color("edd100"),
    Color("f32500")
]

var icons: Array[Texture2D] = [
    load("res://assets/img/icons/done/1x/baseline_done_white_24dp.png") as Texture2D,
    load("res://assets/img/icons/alert/1x/baseline_info_outline_white_24dp.png") as Texture2D,
    load("res://assets/img/icons/error/1x/baseline_error_outline_white_24dp.png") as Texture2D,
    load("res://assets/img/icons/clear/1x/baseline_clear_white_24dp.png") as Texture2D
]

var type: Type = Type.WARNING
var message: String = ""

func setup(type: Type, message: String) -> void:
    self.type = type
    self.message = message

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    hide()
    self.position = calculate_relative_pos()
    set_type(self.type)
    message_lbl.set_text(self.message)

func calculate_relative_pos() -> Vector2:
    var window_size: Vector2 = DisplayServer.window_get_size()
    return Vector2(
        (window_size.x / 2) - (self.get_rect().size.x / 2), 
        window_size.y + 10
    )

func display(duration: float = 3.0) -> void:
    emit_signal("started")
    
    show()
    
    var tween: Tween = create_tween().bind_node(self)
    tween.tween_property(
        self, 
        "position", 
        (self.position - Vector2(0, self.get_rect().size.y + 30)), 
        0.7
    ).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(
        progress,
        "value",
        100,
        duration
    ).set_trans(Tween.TRANS_LINEAR)
    tween.tween_interval(0.5)
    tween.tween_property(
        self, 
        "position", 
        self.position + Vector2(0, 30),
        0.7
    ).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN).finished
    tween.tween_callback(queue_free)
    
    emit_signal("finished")

func set_type(type: Type) -> void:
    background.set_color(colors[type])
    icon.set_texture(icons[type])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
