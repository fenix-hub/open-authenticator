extends PanelContainer

signal add_account(account: Account)

@onready var buttons_box: HBoxContainer = $ButtonsBox
@onready var add_manually_pnl: PanelContainer = $AddManually
@onready var import_qr_pnl: PanelContainer = $ImportQR

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cancel_btn_pressed() -> void:
	reset()


func reset() -> void:
	buttons_box.show()
	add_manually_pnl.hide()
	import_qr_pnl.hide()
	$FileDialog.hide()

func _on_add_btn_pressed() -> void:
	var label: String = %Label.get_text()
	var issuer: String = %Issuer.get_text()
	var account: String = %Account.get_text()
	var secret: String = %Secret.get_text()
	
	
	%Label.clear()
	%Issuer.clear()
	%Account.clear()
	%Secret.clear()
	
	var new_account: Account = Account.new(label, issuer, account, secret)
	AccountsManager.save_account(new_account)
	add_account.emit(new_account)
	
	reset()
	hide()
	AlertManager.alert_success("Account added!")


func _on_import_qr_code_btn_pressed() -> void:
	import_qr_pnl.show()
	add_manually_pnl.hide()
	buttons_box.hide()


func _on_add_manually_btn_pressed() -> void:
	add_manually_pnl.show()
	import_qr_pnl.hide()
	buttons_box.hide()


func _on_drop_area_account_read(account: Account) -> void:
	AccountsManager.save_account(account)
	add_account.emit(account)
	
	reset()
	hide()
	AlertManager.alert_success("Account added!")


func _on_add_account_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == 1:
			reset()
			hide()


func _on_visibility_btn_toggled(button_pressed: bool) -> void:
	%Secret.set_secret(button_pressed)


func _on_button_pressed() -> void:
	$FileDialog.position = Vector2i(get_rect().size/2) - $FileDialog.get_size()/2
	$FileDialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
	%DropArea.on_files_dropped(PackedStringArray([path]))
