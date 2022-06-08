s.boot;
s.quit;

(
/*
  SYNTH DEFINITION
- bitcrush+transf output when bps is set low (<10): bitcrushed
  crackle (snaps n pops)
- bitcrush+transf output when bps is set high (>100): lofi
  crackly crunch, lovely. density changes when upping bps.
*/

SynthDef(\impulse, {
	arg bps, dirout=0, fxout;
	var impulse, mldhigh, mldbass, bitcrush, dirsend, fxsend;

	bps = Dust2.ar(bps);
	impulse = BrownNoise.ar(bps);  // crackle

	mldhigh = Ringz.ar(impulse, 440,
		XLine.kr(
			start:SinOsc.kr(impulse) * 100,
			end:2
	));
	mldbass = Ringz.ar(impulse, SinOscFB.kr(100, 0.15) * 100,
		XLine.ar(
			start:SinOsc.kr(impulse) * 100,
			end:4
	));
	bitcrush = Ringz.ar(impulse, SinOsc.kr(10000), 1);

	dirsend = (mldbass*0.5) + (mldhigh*0.5); // polyphonic melody

	Out.ar(fxout, bitcrush);  // fx out
	// Out.ar(dirout, bitcrush ! 2);  // direct out
}).add;


SynthDef(\crush, {
	arg input, fxout, ndist, ncmp, bs, lo, hi, fq, mkup, ear;
	var dist, comp, trf, eq, in, mix;

	// distorsion and compression functions
	dist = {
		arg inp; // input
		AnalogVintageDistortion.ar(
			inp, 1, bs, lo.dbamp, hi.dbamp, LFNoise1.ar(fq * 2), 0, 2
	)};
	comp = {
		arg inp, makeup;
		DCompressor.ar(inp * 0.1, inp, 1, 40, -40, 10, 10, makeup, 1)
		// sweet spot: inp, Dust.ar(10), 1, 40, -80, 10, 10, 40, 1 ; big impact of makeup level
	};

	// setting the bus input
	in = In.ar(input, 1);

	// distorsion
	trf = dist.value(in);
	ndist.do({trf = dist.value(trf)});  // distort ndist times.

	// eq + compression
	trf = BPeakEQ.ar(trf, 2000, 1, 30).clip;
	ncmp.do({trf = comp.value(inp:trf, makeup:mkup)});
	trf = Limiter.ar(trf, 1);
	trf = dist.value(trf).clip;
	trf = comp.value(inp:trf, makeup:35);
	trf = Limiter.ar(trf, 1);

	// mixing + output
	if (ear == "R", {var mix;
		mix = Pan2.ar(trf, 1);
	}, {
		mix = Pan2.ar(trf, -1);
	} );

	Out.ar(fxout, mix);
}).add;
)

(
/*
  SYNTH CONNEXION + MIXING
*/
var bL, bR, bR2, bL2, inL, inR, crL, crR, output, clock;
bL = Bus.audio(s, 1);
bR = Bus.audio(s, 1);
bL2 = Bus.audio(s, 2);
bR2 = Bus.audio(s, 2);

// clock = TempoClock.new(9/12, 4, 10);

crL = Synth.new(\transf,
	[input:bL, fxout:bR2, lo:25, hi:10, fq:1000, bs:1, ndist:10, ncmp:100, mkup:90, ear:"L"]);
crR = Synth.new(\transf,
	[input:bR, fxout:bL2, lo:25, hi:10, fq:1000, bs:1, ndist:10, ncmp:100, mkup:90, ear:"R";]
);
inL = Synth.before(crL, \impulse, [bps:5, fxout:bL]);
inR = Synth.before(crR, \impulse, [bps:5, fxout:bR]);

output = Mix([crL, crR]); // doesn't work..
)

i.free; j.free; b.free;



(
{
var s, z, y;
    // 10 voices of a random sine percussion sound :
s = Mix.ar(Array.fill(10, { Resonz.ar(Dust.ar(0.2, 50), 200 + 3000.0.rand, 0.003)}) );
    // reverb predelay time :
z = DelayN.ar(s, 0.048);
    // 7 length modulated comb delays in parallel :
y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
    // two parallel chains of 4 allpass delays (8 total) :
4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
    // add original sound to reverb and play it :
s+(0.2*y)
}.scope
)

