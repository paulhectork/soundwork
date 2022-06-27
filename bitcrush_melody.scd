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

SynthDef(\impulse_melody, {
	// sine percussion w/ melodic mids and lows
	arg bps, dirout=0, fxout;
	var impulse, mldhigh, mldbass, mix;

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

	mix = (mldbass*0.5) + (mldhigh*0.5);
	Out.ar(fxout, mix);
}).add;



SynthDef(\impulse_crush, {
	// bitcrushed crackle
	arg bps, fxout;
	var impulse, bitcrush;

	bps = Dust2.ar(bps);
	impulse = BrownNoise.ar(bps);  // crackle
	bitcrush = Ringz.ar(impulse, SinOsc.kr(10000), 1);

	Out.ar(fxout, bitcrush);
}).add;



SynthDef(\crush, {
	// distort + crush the output of \impulse_crush
	arg input, fxout, ndist, ncmp, bs, lo, hi, fq, mkup, inL, inR;
	var dist, comp, trf, eq, in;

	// distorsion and compression functions
	dist = {
		arg inp; // input
		AnalogVintageDistortion.ar(
			inp, 1, bs, lo.dbamp, hi.dbamp, LFNoise1.ar(fq * 2), 0, 2
	)};
	comp = {
		arg inp, makeup;
		// sweet spot: inp, Dust.ar(10), 1, 40, -80, 10, 10, 40, 1 ; big impact of makeup level
		DCompressor.ar(inp * 0.1, inp, 1, 40, -80, 10, 10, makeup, 1)
	};

	// setting the bus inputs and mixing them to stereo
	inL = Pan2.ar(In.ar(inL, 1), 1);
	inR = Pan2.ar(In.ar(inR, 1), -1);
	in = Mix([inL, inR]);

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

	Out.ar(fxout, trf);
}).add;
)



(
/*
  SYNTH CONNEXION + MIXING
*/
var bL, bR, inL, inR, cr, out;
bL = Bus.audio(s, 1);
bR = Bus.audio(s, 1);
b = Bus.audio(s, 2);

cr = Synth.new(\crush,
	[inL:bL, inR:bR, fxout:0, lo:25, hi:10, fq:1000, bs:1, ndist:10, ncmp:100, mkup:40]);
inL = Synth.before(cr, \impulse_crush, [bps:5, fxout:bL]);
inR = Synth.before(cr, \impulse_crush, [bps:5, fxout:bR]);
)



(
/*
  RECORDING TO A FILE
  https://github.com/supercollider/supercollider/wiki/Recording-in-SuperCollider-(WIP)
*/
Server.default.record(
	"musique/supercollider/out/test.aiff", duration:25*60
);
)


/* cool online example to build a reverb
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
*/

