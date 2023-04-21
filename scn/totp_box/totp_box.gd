extends PanelContainer
class_name TOTPBoxContainer

@onready var totp_digits: HBoxContainer = %TOTPDigits
@onready var secs_remaining_progress: TextureProgressBar = %SecsRemaining
@onready var secs_remaining_lbl: Label = secs_remaining_progress.get_child(0)

var totp_generator: TOTPGenerator = TOTPGenerator.new()
var account: Account
var secret_buffer: PackedByteArray
var totp: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Timer.timeout.connect(_on_timeout)
	$TOTPBox/BodyBox/VisibilityBtn.set_pressed(true)
	_on_timeout()

func set_otp_hidden(otp_hidden: bool) -> void:
	%TOTPDigits.visible = not otp_hidden
	%TOTPDigitsHidden.visible = otp_hidden
	$TOTPBox/BodyBox/VisibilityBtn.set_tooltip_text(
		"%s this code" % ["Show" if otp_hidden else "Hide"]
	)

func set_account(account: Account) -> void:
	self.name = account.label.sha1_text()
	self.account = account
	secret_buffer = Base32.decode(account.secret)
	%IssuerLbl.set_text(account.issuer)
	%UserLbl.set_text(account.account)
	%IssuerLogo.set_texture(load("res://assets/img/logos/%s.svg" % 
		[
			account.issuer.to_lower() 
			if (account.issuer.to_lower()) in AccountsManager.known_issuers 
			else "anon"
		]
	))

func _on_timeout() -> void:
	totp = totp_generator.generate_totp(secret_buffer)
	update_totp_labels(totp)

func set_otp(totp: String) -> void:
	for digit in totp.length():
		totp_digits.get_node("%s" % (digit+1)).set_text(totp[digit])

func update_totp_labels(totp: String) -> void:
	set_otp(totp)
	secs_remaining_progress.set_value(30 - totp_generator.secs_remaning)
	secs_remaining_lbl.set_text(str(totp_generator.secs_remaning))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_copy_btn_pressed() -> void:
	DisplayServer.clipboard_set(totp)
	AlertManager.alert(AlertBox.Type.INFO, "Code copied to clipboard!")


func _on_visibility_btn_toggled(otp_hidden: bool) -> void:
	set_otp_hidden(otp_hidden)
