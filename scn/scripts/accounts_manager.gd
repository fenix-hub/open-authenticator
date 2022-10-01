extends Node

var accounts_file: ConfigFile = ConfigFile.new()
var accounts_file_path: String = "user://.accounts"
var salt_path: String = "user://.salt"
var password: PackedByteArray = []
var accounts: Dictionary = {}
var known_issuers: PackedStringArray = [
    "github", "google", "paypal", "facebook", "microsoft"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Generate Salt
    if not FileAccess.file_exists(salt_path):
        var file: FileAccess = FileAccess.open(salt_path, FileAccess.WRITE)
        file.store_buffer(Crypto.new().generate_random_bytes(256))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func load_accounts(plain_secret: String) -> bool:
    # Read Salt
    var file: FileAccess = FileAccess.open(salt_path, FileAccess.READ)
    var salt: PackedByteArray = file.get_buffer(256)
    
    self.password = (plain_secret + salt.hex_encode()).sha256_buffer()
    
    if not file.file_exists(accounts_file_path):
        accounts_file.save_encrypted(
            accounts_file_path, 
            self.password
        )
    
    if accounts_file.load_encrypted(
        accounts_file_path, 
        self.password
    ):
        return false
    
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
    accounts_file.save_encrypted(accounts_file_path, password)
