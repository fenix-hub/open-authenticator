extends RefCounted
class_name HOTPTest


var format_str: String = "%-9s %-44s %-14s %-14s %s"


var test_secret: String = "12345678901234567890"


var hex_hmac_sha_1: PackedStringArray = [
    "cc93cf18508d94934c64b65d8ba7667fb7cde4b0",
    "75a48a19d4cbe100644e8ac1397eea747a2d33ab",
    "0bacb7fa082fef30782211938bc1c5e70416ff44",
    "66c28227d03a2d5529262ff016a1e6ef76557ece",
    "a904c900a64b35909874b33e61c5938a8e15ed1c",
    "a37e783d7b7233c083d4f62926c7a25f238d0316",
    "bc9cd28561042c83f219324d3c607256c03272ae",
    "a4fb960c0bc06e1eabb804e5b397cdc4b45596fa",
    "1b3c89f65e6c9e883012052823443f048b4332db",
    "1637409809a679dc698207310c8c7fc07290d9e5"
]


var trunc_hex: PackedStringArray = [
    "4c93cf18",
    "41397eea",
    "82fef30",
    "66ef7655",
    "61c5938a",
    "33c083d4",
    "7256c032",
    "4e5b397",
    "2823443f",
    "2679dc69"
]


var trunc_dec: PackedInt32Array = [
    1284755224,
    1094287082,
    137359152,
    1726969429,
    1640338314,
    868254676,
    1918287922,
    82162583,
    673399871,
    645520489
]


var test_hotps: PackedStringArray = [
    "755224",
    "287082",
    "359152",
    "969429",
    "338314",
    "254676",
    "287922",
    "162583",
    "399871",
    "520489"
]


func _ready() -> void:
    pass


func run() -> bool:
    var hotp_generator: HOTPGenerator = HOTPGenerator.new()
    print("Testing with secret: %s" % test_secret)
    print(format_str % ["Count", "HMAC-SHA-1", "Hexadecimal", "Decimal", "HOTP"])
    for i in 10:
        var hmac: PackedByteArray = hotp_generator.hmac_sha(test_secret.to_ascii_buffer(), hotp_generator.int_to_hex(i))
        var truncated: String = hotp_generator.truncate(hmac)
        var decimal: int = hotp_generator.hex_to_int(truncated)
        var t_hotp: String = str(decimal % int(pow(10, 6)))
        print(format_str % [str(i), hmac.hex_encode(), truncated, decimal, t_hotp])
        assert(hmac.hex_encode() == hex_hmac_sha_1[i], "HMAC-SHA value doesn't match expected value.")
        assert(truncated == trunc_hex[i], "Hexadecimal value doesn't match expected value.")
        assert(decimal == trunc_dec[i], "Decimal value doesn't match expected value.")
        assert(t_hotp == test_hotps[i], "HOTP value doesn't match expected value.")
    return true
