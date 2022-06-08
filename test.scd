s.boot;
s.kill;

// add vintage analog drum to snare

b = Bus.audio(s,2);
b.free;

(
SynthDef(\drum, {
	arg bps=4, distlvl=0.5, lgain=0.0, bias=0, hgain=0, shelving=600, oversample=0, fxout;
	var snare, bdrum, hihat;

	bps = Dust.ar(bps);
  snare = AnalogVintageDistortion.ar(
		WhiteNoise.ar(
			Decay.ar(PulseDivider.ar(bps.tanh, 1, 2), 0.5, 2)
		),
		distlvl, bias, lgain, hgain, shelving, oversample
	);
  hihat = HPF.ar(WhiteNoise.ar(1), 10000)
	* Decay2.ar(bps, 0.005, 0.5);

	Out.ar(fxout, (snare + hihat) * 0.15 ! 2)  // write out to bus
}).add;

SynthDef(\pitch, {
	arg window=0.2, ratio=1.0, disp=0.0, time=0.0, out, inbus;
	var pitched, input;

	input = In.ar(inbus, 2);
	pitched = PitchShift.ar(input, window, ratio, disp);
	Out.ar(out, pitched ! 2)  // write output to bus
}).add;
)

(
t = Synth.new(\pitch);
u = Synth.before(t, \drum, [bps: 10, distlvl: 2, shelving: 50, bias: 2.5, oversampling: 10]);
)
t.free; u.free;