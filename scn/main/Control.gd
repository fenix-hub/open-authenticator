extends Control

@onready var totp_list: VBoxContainer = %TOTPList

var totp_box_scn: PackedScene = preload("res://scn/totp_box/totp_box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $Container.hide()
    $AddAccountContainer.hide()
    $AccessContainer.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_button_pressed() -> void:
    $AddAccountContainer.show()


func _on_access_container_accounts_read(accounts: Dictionary) -> void:
    for issuer_id in accounts.keys():
        _on_add_account(accounts[issuer_id])
    $Container.show()

func _on_add_account(account: Account) -> void:
    for totp_box in totp_list.get_children():
        if totp_box.account.is_equal(account):
            totp_box.set_account(account)
            return
        continue
    var new_totp: TOTPBoxContainer = totp_box_scn.instantiate()
    new_totp.set_account(account)
    totp_list.add_child(new_totp)

func _on_access_container_unlock_failed(message: String) -> void:
    AlertManager.alert_error(message)

