extends PanelContainer

@onready var unlock_btn: Button = $PanelContainer/VBoxContainer/HBoxContainer/Button

signal unlock_failed(message: String)
signal accounts_read(accounts: Dictionary)

var accounts_file: ConfigFile = ConfigFile.new()
var accounts_file_path: String = "user://.accounts"

var icon_disabled: Texture2D = load("res://assets/img/icons/lock/1x/baseline_lock_white_24dp.png")
var icon_enabled: Texture2D = load("res://assets/img/icons/lock_open/1x/baseline_lock_open_white_24dp.png")

var hotp_generator: HOTPGenerator = HOTPGenerator.new(10)

@onready var btn_inital_pos: Vector2 = unlock_btn.get_rect().position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    set_unlock_disabled(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass



func unlock(text: String) -> void:
    %AccessSecret.clear()
    if text.length() <= 7:
        unlock_failed.emit("Secret must be at least of 8 characters")
        return
    
    if not AccountsManager.load_accounts(text):
        unlock_failed.emit("Invalid secret")
        return
    
    emit_signal("accounts_read", AccountsManager.accounts)
    hide()

func _on_button_pressed() -> void:
    unlock(%AccessSecret.get_text())

func _on_access_secret_text_submitted(new_text: String) -> void:
    unlock(new_text)

func _on_access_secret_text_changed(new_text: String) -> void:
    var is_unlocked: bool = new_text.length() > 7
    if is_unlocked != not unlock_btn.disabled:
        animate_button(is_unlocked)

func animate_button(unlocked: bool) -> void:
    var tween: Tween = get_tree().create_tween().bind_node(self) \
    .set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
    tween.tween_callback(set_unlock_disabled.bind(not unlocked))
    tween.tween_property(
        unlock_btn, "position", btn_inital_pos + Vector2(0, 10), 0.2
    )
    tween.tween_property(
        unlock_btn, "position", btn_inital_pos, 0.2
    )

func set_unlock_disabled(disabled: bool) -> void:
    unlock_btn.set_disabled(disabled)
    unlock_btn.set_button_icon(icon_disabled if disabled else icon_enabled)
