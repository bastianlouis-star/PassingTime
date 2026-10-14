extends SceneTree
# Prints the peak level and length of every synthesised sound effect.
func _initialize() -> void:
	var s := Synth.new()
	s._make_sfx()
	for k in s.sfx:
		var w: AudioStreamWAV = s.sfx[k]
		var peak := 0
		for i in range(0, w.data.size(), 2):
			peak = maxi(peak, absi(w.data.decode_s16(i)))
		print("%-9s %.2fs  peak %.2f" % [k, w.get_length(), peak / 32768.0])
	# run the music generator for a while through every era
	for e in 9:
		s.set_era(e)
		for i in 60:
			s._process(0.016)
	print("music voices alive: ", s.v_f.size())
	quit(0)
