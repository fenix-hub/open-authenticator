extends RefCounted
class_name Base32

static func bin_to_int(bin_str: String) -> int:
    var out: int = 0
    for c in bin_str:
        out = (out << 1) + int(c == "1")
    return out
 
static func int_to_bin(value: int, digits: int = -1) -> String:
    var out: String = ""
    while (value > 0):
        out = str(value & 1) + out  # & operator will return TRUE = 1 or FALSE = 0
        value = (value >> 1)        # a right shift is equivalent to 'value/2'
    if digits > 0:
        while (out.length() < digits):   # Make sure the binary string is an octet
            out = "0" + out
    return out

static func encode(value: PackedByteArray) -> String:
    var base32_table: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    var base32_str: String = ""
    var bit_str: String = ""
    # Convert each character to a binary ASCII value
    var t: Array
    for character in value:
        bit_str += int_to_bin(character, 8)
    # Calculate how many paddings should be added to the quintets
    var remainder: int = 5 - ((bit_str.length()/8) % 5)
    for i in remainder:
        bit_str += ("xxxxxxxx")
    # Subdivided octets in groups of quintets
    for i in range(0, bit_str.length(), 5):
        var quintet: String = bit_str.substr(i, 5)
        # If a quintet has both x values and valid bins, replace x with 0
        if quintet.count("x") < 5:
            quintet = quintet.replacen("x", "0")
        # If a quintet is XXXXX, it will be a padding character
        if quintet == "xxxxx":
            base32_str += "="
        # Else it will be a binary number. It will be used as an index in the base32_table
        else:
            base32_str += base32_table[bin_to_int(quintet)]
    return base32_str

static func decode(value: String) -> PackedByteArray:
    var base32_table: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    if value.length() % 8 > 0:
        printerr("Input value is not a valid Base32 String, perhaps it is missing padding characters?")
        return PackedByteArray([])
    var bit_str: String = ""
    var utf8: String = ""
    for character in value:
        if character == "=":
            bit_str += "xxxxx"
        else:
            bit_str += int_to_bin(base32_table.find(character), 5)
    var reminder: int = 8 - (bit_str.count("x") % 8)
    var bytes: PackedByteArray = []
    for i in range(0, bit_str.length(), 8):
        var octet: String = bit_str.substr(i, 8)
        if octet.count("x") > 0:
            continue
        else:
            bytes.append(bin_to_int(octet))
    return bytes
