extends Node

var accounts_file: ConfigFile = ConfigFile.new()
var accounts_file_path: String = "user://.accounts"
var secret: String = ""
var accounts: Dictionary = {}
var known_issuers: PackedStringArray = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    load_known_issuers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func load_known_issuers() -> void:
    var dir: Directory = Directory.new()
    if not dir.open("res://assets/img/logos"):
        known_issuers = dir.get_files()

func load_accounts(secret: String) -> bool:
    if not File.new().file_exists(accounts_file_path):
        accounts_file.save_encrypted_pass(accounts_file_path, secret)
    
    if accounts_file.load_encrypted_pass(accounts_file_path, secret):
        return false
    
    self.secret = secret
    var issuer_list: Array[Account] = []
    for label in accounts_file.get_sections():
        accounts[label] = get_account(label)
    return true

func get_account(label: String) -> Account:
    return Account.new(
        label,
        accounts_file.get_value(label, "issuer"),
        accounts_file.get_value(label, "account"),
        accounts_file.get_value(label, "secret")
    )

func save_account(account: Account) -> void:
    accounts[account.label] = account
    accounts_file.set_value(account.label, "issuer", account.issuer)
    accounts_file.set_value(account.label, "account", account.account)
    accounts_file.set_value(account.label, "secret", account.secret)
    accounts_file.save_encrypted_pass(accounts_file_path, secret)
