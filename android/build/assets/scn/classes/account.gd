extends RefCounted
class_name Account

var label: String
var issuer: String
var account: String
var secret: String

func _init(label: String, issuer: String, account: String, secret: String) -> void:
    self.label = label
    self.issuer = issuer
    self.account = account
    self.secret = secret

func is_equal(account: Account) -> bool:
    return self.hash() == account.hash()

func hash() -> String:
    return ("%s:%s:%s:%s" % [label, issuer, account, secret]).sha1_text()
