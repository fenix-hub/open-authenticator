extends RefCounted
class_name TOTPTest

var format_str: String = "%-9s %-12s %-18s %s"

var test_secret: String = "12345678901234567890"

var times: PackedInt32Array = [
    59,
    1111111109,
    1111111111,
    1234567890,
    2000000000,
    20000000000
]

var T0: int = 0
var steps: int = 30

var test_totps: PackedStringArray = [
    "94287082",
    "07081804",
    "14050471",
    "89005924",
    "69279037",
    "65353130",
]

func _ready() -> void:
    pass

func run() -> bool:
    var totp_generator: TOTPGenerator = TOTPGenerator.new(steps, T0)
    totp_generator.digit = 8
    print("Testing with secret: %s" % test_secret)
    print(format_str % ["Count", "Unix Time", "T value (Hex)", "TOTP"])
    for i in times.size():
        var current_time: int = times[i]
        if current_time < 0:
            continue
        var T: int = totp_generator.calc_time(current_time, T0, steps)
        var hex_T: String = totp_generator.int_to_hex(T).hex_encode()
        var totp: String = totp_generator.generate_totp(test_secret.to_ascii_buffer(), current_time)
        print(format_str % [str(i), current_time, hex_T, totp])
        assert(totp == test_totps[i], "TOTP value doesn't match expected value.")
    return true
