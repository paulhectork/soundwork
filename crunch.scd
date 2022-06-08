s.boot;
s.quit;

(
SynthDef(\white, {
	// crackly white noise + tonal crackle
	arg bps=8, out=0, dirratio=1,
	sustain=0, accent=0.5, freq=50, tone=0.5, decay=0.5, attack=0.5, fm=0.25;
	var crunch, bass, crackle, dist;

	bps = Dust2.kr(bps * Rand(0.2, 1.2));
	crackle = PitchShift.ar(
		in:Crackle.ar(2, 0.5), windowSize:0.1,
		pitchRatio: SinOsc.kr(bps, 2), pitchDispersion:10,
		timeDispersion:0.05
	);
	bass = AnalogBassDrum.ar(
		bps, SinOsc.kr(sustain * Rand(0.1, 1)), accent,
		Rand(freq - 30, freq + 30), tone, decay, attack, fm
	);

	Out.ar(out, ((crackle * 0.5) + (bass * 0.5)) ! 2);
	// Out.ar(outfx, (hi + mid + low) * (1 - dirratio) !2);
}).add;

/////////////////////////////////////////////////////////

SynthDef(\crunch, {
	// total crunch worship if played loud, reverbed crackle
	// at a low volume
	arg bps=8, out=0, phase=0, outvol=0.2, inverb=1;
	var crunchL, crunchR, snapL, snapR, left, right, mix;

	bps = Dust2.kr(bps);

	// left channel
	crunchL = SinOsc.ar(
		bps * Rand(1000, 1500),  // freq
		phase + (2 * phase),
		Decay2.ar(
			PulseDivider.ar(bps * 3, 4, 2), 0.005, 1;
		) // mul: dynamics
	);
	snapL = AnalogTape.ar(
		FreqShift.ar(
			BrownNoise.ar(
				Dust.ar(bps.cosh), 0,
				Decay.ar(PulseDivider.ar(bps * 3, 4, 2))
			), freq:Crackle.kr(2);
		), saturation:10, drive:10, oversample:0, mode:2
	);

	// right channel
	crunchR = SinOsc.ar(
		bps * Rand(1000, 1500),  // freq
		phase - (2 * phase),
		Decay2.ar(
			PulseDivider.ar(bps * 3, 4, 2), 0.005, 1;
		) // mul: dynamics
	);
	snapR = AnalogTape.ar(
		FreqShift.ar(
			BrownNoise.ar(
				Dust.ar(bps.cosh), 0,
				Decay.ar(PulseDivider.ar(bps * 3, 4, 2))
			), freq:Crackle.kr(2);
		), saturation:10, drive:10, oversample:0, mode:2
	);

	// mixing
	left = (FreeVerb.ar(crunchL * inverb, 0.45, 1, 0.8) * outvol)
	+ snapL;
	right = (FreeVerb.ar(crunchR * inverb, 0.45, 1, 0.8) * outvol)
	+ snapR;

	Out.ar(out, [left, right]);
}).add;
)

(
var buf;
buf = Buffer.alloc(s, s.sampleRate * 4, 2);  // 25 min stereo buffer
b = Bus.audio(s, 2);

i = Synth.new(\crunch, [bps:20, out:0, phase:2, inverb:0.2,
	 outvol: 0.05]);
j = Synth.new(\white, [bps:3, out:0, dirratio:1,
	sustain:1, accent:0.5, freq:120, tone:0.5, decay:0.1,
	attack:0.5, fm:0.25]);

/* FUTILE ATTEMPS AT RECORDING

r = {
	RecordBuf.ar(inputArray:b, bufnum:buf, loop:0);
}.play(s);
{PlayBuf.ar(2, buf)}.play(s);
// {Out.ar(0, b)}.play;*/
)
j.free; i.free;
