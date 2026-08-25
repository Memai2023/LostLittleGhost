extends Node
# Autoload "SoundGen" — generates tiny SFX (woosh/chime/buzz) at runtime so the
# project needs no external audio files. Swap these for real SFX later if you want.

const MIX_RATE := 22050

func tone(freq: float, duration: float, wave: String = "sine", volume: float = 0.5, sweep_to: float = -1.0) -> AudioStreamWAV:
	var count := int(MIX_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		var t := float(i) / MIX_RATE
		var progress := float(i) / float(max(count - 1, 1))
		var f := freq if sweep_to < 0.0 else lerpf(freq, sweep_to, progress)
		var phase := t * f * TAU
		var raw := 0.0
		match wave:
			"square":
				raw = 1.0 if sin(phase) >= 0.0 else -1.0
			"noise":
				raw = randf_range(-1.0, 1.0)
			_:
				raw = sin(phase)
		var envelope := 1.0 - progress
		samples[i] = raw * volume * envelope
	return _make_stream(samples)

func woosh() -> AudioStreamWAV:
	return tone(220.0, 0.22, "sine", 0.35, 520.0)

func chime() -> AudioStreamWAV:
	return tone(880.0, 0.35, "sine", 0.4, 1320.0)

func buzz() -> AudioStreamWAV:
	return tone(90.0, 0.25, "square", 0.3)

func _make_stream(samples: PackedFloat32Array) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		var v := int(clamp(samples[i], -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, v)
	stream.data = bytes
	return stream
