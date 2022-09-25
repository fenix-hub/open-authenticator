extends NinePatchRect

signal account_read(account: Account)


var image: Image = Image.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    get_viewport().files_dropped.connect(on_files_dropped)

func on_files_dropped(files: PackedStringArray) -> void:
    var file_path: String = files[0]
    if not (file_path.get_extension() in ["png", "jpg", "svg"]):
        AlertManager.alert_error("Importing %s files is not supported" % file_path.get_extension())
        return
    
    if image.load(file_path) != OK:
        AlertManager.alert_error("Could not load image file, error: %s" % file_path.get_extension())
    
    var decode_result : QRDecodeResult = QRNative.decode_image(image) as QRDecodeResult
    if not decode_result.is_valid():
        AlertManager.alert_error("Could not read QR code")
        return
    
    account_read.emit(extract_account(decode_result.get_content()))

func extract_account(qr_code: String) -> Account:
    if not qr_code.begins_with("otpauth://totp/"):
        AlertManager.alert_error("QR doesn't contain a valid oautpath")
        return
    
    qr_code = qr_code.lstrip("otpauth://totp/").uri_decode()
    var parts: PackedStringArray = qr_code.split("?")
    var label: String = parts[0]
    var account_info: PackedStringArray = parts[1].split("&")
    
    var account_dict: Dictionary = {}
    for info in account_info:
        var keyval: PackedStringArray = info.split("=")
        account_dict[keyval[0]] = keyval[1]
    
    return Account.new(
        label,
        account_dict.issuer,
        label.split(":")[1],
        account_dict.secret
    )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
