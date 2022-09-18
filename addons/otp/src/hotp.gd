extends RefCounted
class_name HOTPGenerator


#   https://www.rfc-editor.org/rfc/rfc4226
#
#   C       8-byte counter value, the moving factor.  This counter
#           MUST be synchronized between the HOTP generator (client)
#           and the HOTP validator (server).
#   K       shared secret between client and server; each HOTP
#           generator has a different and unique secret K.
#   T       throttling parameter: the server will refuse connections
#           from a user after T unsuccessful authentication attempts.
#   s       resynchronization parameter: the server will attempt to
#           verify a received authenticator across s consecutive
#           counter values.
#   Digit   number of digits in an HOTP value; system parameter.


var C: int
var K: PackedByteArray
var T: int
var s: int
var digit: int = 6
var add_checksum: bool = false
var truncation_offset: int = -1
var precision: int = -1

var algorithm: int = HashingContext.HASH_SHA1

# These are used to calculate the check-sum digits.
# 0  1  2  3  4  5  6  7  8  9
var double_digits: PackedInt32Array = [ 0, 2, 4, 6, 8, 1, 3, 5, 7, 9 ]

func _init(digit: int = 6, add_checksum: bool = false, truncation_offset: int = -1, precision: int = -1) -> void:
    self.digit = digit
    self.add_checksum = add_checksum
    self.truncation_offset = truncation_offset
    self.precision = precision

func generate_hotp(secret: PackedByteArray, moving_factor: int) -> String:
    var result: String = ""
    var digits: int = (digit + 1) if add_checksum else digit
    var text: PackedByteArray = int_to_hex(moving_factor, precision)
    var hmac: PackedByteArray = hmac_sha(secret, text)
    var decimal: int = hex_to_int(truncate(hmac))
    var otp: int = decimal % int(pow(10, digits))
    if add_checksum:
        otp = otp * 10 + calc_checksum(otp, digits)
    result = str(otp)
    while (result.length() < digits):
        result = "0" + result
    return result

func hmac_sha(secret: PackedByteArray, text: PackedByteArray, algorithm: int = self.algorithm) -> PackedByteArray:
    var hmac_sha1_ctx: HMACContext = HMACContext.new()
    var err: int = hmac_sha1_ctx.start(algorithm, secret)
    assert(err == OK, "Could not create hashing context!")
    
    err = hmac_sha1_ctx.update(text)
    assert(err == OK, "Could not hash!")
    return hmac_sha1_ctx.finish()

#   As the output of the HMAC-SHA-1 calculation is 160 bits, we must
#   truncate this value to something that can be easily entered by a
#   user. Dynamic truncation is used if truncation_offset is not set
func truncate(hmac_result: PackedByteArray, truncation_offset: int = self.truncation_offset) -> String:
    # Get the last byte of the `hmac_result` and extract the last 4 bits.
    # These will be used as an offset for the DT.
    var offset: int = (hmac_result[hmac_result.size() - 1] & 0xf)
    if ( 0 <= truncation_offset and truncation_offset < (hmac_result.size() - 4) ):
        offset = truncation_offset
    
    # We treat the dynamic binary code as a 31-bit, unsigned, big-endian
    # integer; the first byte is masked with a 0x7f.
    var truncated: PackedByteArray = PackedByteArray([
        (hmac_result[offset] & 0x7f),
        (hmac_result[offset+1] & 0xff),
        (hmac_result[offset+2] & 0xff),
        (hmac_result[offset+3] & 0xff)
    ])

#   # It is equivalent to the following RFC
#    var bin_code: int = (hmac_result[offset] & 0x7f) << 24 | \
#        (hmac_result[offset+1] & 0xff) << 16 | \
#        (hmac_result[offset+2] & 0xff) << 8 | \
#        (hmac_result[offset+3] & 0xff) << 0
#    return bin_code

    return truncated.hex_encode().lstrip("0")

#func hex_to_array(hex: String) -> PoolStringArray:
#    var text: PoolStringArray = []
#    for nibble in range(0, hex.length(), 2):
#        text.append(nibble & 0xff)
#    return text

#   Convert a non-formatted hexadecimal String to an Integer
func hex_to_int(hex: String) -> int:
    return ("0x" + hex).hex_to_int()

func int_to_hex(moving_factor: int, precision: int = self.precision) -> PackedByteArray:
    var text: PackedByteArray = []
    for i in range(56, -8, -8):
        text.append((moving_factor >> i) & 0xff)
    if precision > 0:
        while(text.size() < precision):
            text.insert(0, 0)
    return text

#    Calculates the checksum using the credit card algorithm.
#    This algorithm has the advantage that it detects any single
#    mistyped digit and any single transposition of
#    adjacent digits.
#
#    @param num the number to calculate the checksum for
#    @param digits number of significant places in the number
#
#    @return the checksum of num
func calc_checksum(num: int, digits: int) -> int:
    var double_digit: bool = true
    var total: int = 0
    while (0 < digits):
        var digit: int = int(num % 10)
        num /= 10
        if (double_digit):
            digit = double_digits[digit]
        total += digit
        double_digit = !double_digit
        digits -= 1
    var result: int = total % 10
    if (result > 0):
        result = 10 - result
    return result
