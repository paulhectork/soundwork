s.boot;
s.quit;



(
SynthDef(\crackle, {
	// a line of crackly white noise + tonal metalic bubbles
	arg bps=8, out=0, outfx, dirratio=1,
	sustain=0, accent=0.5, freq=50, tone=0.5, decay=0.5,
	attack=0.5, fm=0.25;
	var crunch, bass, crackle, dist;

	bps = Dust2.kr(bps * Rand(0.2, 1.2));

	crackle = Compander.ar(
		PitchShift.ar(
			in:Crackle.ar(2, 0.5), windowSize:0.1,
			pitchRatio: SinOsc.kr(bps, 2), pitchDispersion:10,
			timeDispersion:0.5
	), BrownNoise.ar(2), 1, slopeBelow:2, slopeAbove:0.1, clampTime:5, relaxTime:0.001);

	bass = AnalogBassDrum.ar(
		bps, SinOsc.kr(sustain * Rand(0.1, 1)), accent,
		freq, tone, decay, attack, fm
	);

	Out.ar(out, ((crackle * 2) + (bass * 0.02)) ! 2);
	// Out.ar(outfx, (hi + mid + low) * (1 - dirratio) !2);
}).add;

/////////////////////////////////////////////////////////

SynthDef(\crunch, {
	// total crunch worship if outvol is turned up,
	// reverbed crackle if it's turned at a lower volume
	arg bps=8, out=0, outvol=0.2;
	var crunchL, crunchR, stereo;

	bps = Dust2.kr(bps);

	// left channel
	crunchL = SinOsc.ar(
		bps * Rand(1000, 1500),  // freq
		Rand(1, 100).mod(2pi),
		Decay2.ar(
			PulseDivider.ar(bps * 3, 4, 2), 0.005, 1;
		) // mul: dynamics
	);

	// right channel
	crunchR = SinOsc.ar(
		bps * Rand(1000, 1500),  // freq
		Rand(1, 100).mod(2pi),
		Decay2.ar(
			PulseDivider.ar(bps * 3, 4, 2), 0.005, 1;
		) // mul: dynamics
	);

	// stereo
	stereo = FreeVerb2.ar(
		(crunchL * 3), (crunchR * 3), 0.45, 1, 0.8
	);

	Out.ar(out, stereo * outvol);
}).add;
)

(
i = Synth.new(\crunch, [bps:10, out:0, phase:4, outvol: 0.00006]);
j = Synth.new(\crackle, [bps:8, out:0, outfx:0, dirratio:1,
	sustain:1, accent:0.5, freq:120, tone:0.5, decay:0.1,
	attack:0.5, fm:0.25]);
)

// m = Mix([i, j]);
j.free; i.free;


(
SynthDef("help-PulseDivider",{ arg out=0;
    var p, a, b;
    p = Dust.ar(8);
    a = SinOsc.ar(1200, 0, Decay2.ar(p, 0.005, 0.1));
    b = SinOsc.ar(600,  0, Decay2.ar(PulseDivider.ar(p, 4), 0.005, 0.5));

    Out.ar(out,(a + b) * 0.4)
}).play;
)


