extends HOTPGenerator
class_name TOTPGenerator

var t0: int = 0
var timestep: int = 30

var secs_remaning: int = 0

func _init(timestep: int = 30, t0: int = 0):
    self.timestep = timestep
    self.t0 = t0

func generate_totp(secret: PackedByteArray, epoch: int = int(Time.get_unix_time_from_system())) -> String:
    return generate_hotp(secret, calc_time(epoch, t0, timestep))

func calc_time(time: int, t0: int, timestep: int) -> int:
    self.secs_remaning = timestep - (time % timestep)
    return int((time - t0) / timestep)
