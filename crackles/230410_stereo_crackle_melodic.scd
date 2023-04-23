s.boot;
s.quit;


(
SynthDef(\crackle, {
  /**
   * crackle generation
   *
   * @arg bps       : impulses / second
   * @arg ringratio : ring to crackle ratio. in range 0..1
   * @arg rfreqsrc  : ring frequency
   * @arg out       : output buffer
   */
  arg bps, out=0;
  var tempo;

  tempo = Dust2.ar(bps);
  Out.ar(
    out,
    // actual output
    PinkNoise.ar(tempo),
    // additionnal volume
    TExpRand.ar(
      0.0001                    // lo number
      , 0.2                     // hi number
      , PulseDivider.ar(tempo)  // trigger
    )
  )
}).add;


SynthDef(\polyring, {
  /**
   * create an array of ringing sinoscs of random
   * frequencies and mix them down to a single channel
   *
   * it creates quite varing results:
   * - `freqsrc` and `freqeq` affect the sound the most.
   * - with those two at low intensities (~100), the sound is crushing
   * - with higher values, a high aggressive buzz / drone comes out.
   *
   * @arg freqsrc : source ring frequence (used in the first exprand)
   * @arg freqeq  : bpeakeq frequence
   * @arg rq      : bpeakeq bandwidth or cutoff frequency
   * @arg db      : bpeakeq: number of decibels to boost/cut the center frequency by
   * @arg out     : output buffer
   */
  arg freqsrc=1000, freqeq=100, rq, db, out=0;
  var ring, polyring;

  polyring = [];
  x = Array.fill(25, { arg i; ExpRand( freqsrc-50, freqsrc+50 ); });
  x.do({
    arg freq;
    ring = SinOsc.ar(
      freq: freq
      , mul: 0.5// EnvGen.ar(Env.perc(0.01, 1, 2))
      , add: Dust2.ar(freq) * 0.5
    );
    ring = AnalogVintageDistortion.ar(ring, 1, 2.5, 0.3);
    ring = BPeakEQ.ar(ring, freqeq, rq, db);  // high `freqsrc` (~1000) + low `freqeq` (~100) give a super dense result
    /*
    ring = FreeVerb.ar(
      ring
      ,  mix:1
      , room:1
      , damp:1
    );
    */
    polyring = polyring.add(ring);
  });
  polyring = PinkNoise.ar(
    Mix(polyring),
    TExpRand.ar(
      0.0001                        // lo number
      , 0.2                         // hi number
      , PulseDivider.ar(ring * 10)  // trigger
    )
  );
  Out.ar(out, polyring);
}).add;


SynthDef(\mixmono, {
  /**
   * mix the different layers together
   * into a single mono channel
   *
   * @arg crackle   : the crackle buffer
   * @arg polyring  : the polyring buffer
   * @arg ringratio : polyring to crackle ratio
   * @arg out       : output buffer
   */
  arg crackle, polyring, ringratio=0.05, out=0;
  var mix;
  mix = Mix.ar([
    In.ar(polyring, 1) * ringratio
    , In.ar(crackle, 1) * ( 1 - ringratio )
  ]);
  Out.ar(out, mix);
}).add;


SynthDef(\mixstereo, {
  /**
   * mix the different channels together
   * into a stereo channel
   *
   * @arg inL : left ear input
   * @arg inR : right ear input
   * @arg out : the output buffer
   */
  arg inL, inR, out=0;
  var mix;

  mix = Mix([
    Pan2.ar(In.ar(inL, 1), -1)
    , Pan2.ar(In.ar(inR, 1), 1)
  ]);
  Out.ar(out, mix);
}).add;
)




(
/* CRACKLE ONLY MIX */
var bL = Bus.audio(s, 1);
var bR = Bus.audio(s, 1);

var mix = Synth.new(\mixstereo, [ inL:bL, inR:bR, out:0 ]);
Synth.before(mix, \crackle, [ bps:100, out:bL]);
Synth.before(mix, \crackle, [ bps:100, out:bR ]);
)




(
/* FULL MIX */
var bCrackleL, bCrackleR, bPolyringL, bPolyringR, bL, bR
    , mixstereo, mixmonoL, mixmonoR, polyringL, polyringR
    , paramsCrackle, paramsPolyring, paramsMixmono, eqparams;

bL = Bus.audio(s, 1);
bR = Bus.audio(s, 1);
bCrackleL = Bus.audio(s, 1);
bCrackleR = Bus.audio(s, 1);
bPolyringL = Bus.audio(s, 1);
bPolyringR = Bus.audio(s, 1);

eqparams = [
  [ 2, 5 ]     // base
  , [ 1, 20 ]  // harsh
];

// PROBLEM: CRACKLE SEEMS TO BE IN THE RIGHT EAR ONLY

paramsCrackle = [ bps:100 ];
paramsPolyring = [ freqsrc:100, freqeq:70, rq:eqparams[0][0], db:eqparams[0][1] ];  // freqsrc:100 / freqeq:100 and eqparams[1] is a sweet spot
paramsMixmono = [ ringratio:0.1 ];

mixstereo = Synth.new(\mixstereo, [ inL:bL, inR:bR ]);
mixmonoL = Synth.before(mixstereo, \mixmono, paramsMixmono ++ [ crackle:bCrackleL, polyring:bPolyringL, out:bL ]);
mixmonoR = Synth.before(mixstereo, \mixmono, paramsMixmono ++ [ crackle:bCrackleR, polyring:bPolyringR, out:bR ]);
polyringL = Synth.before(mixmonoL, \polyring, paramsPolyring ++ [ out:bPolyringL ]);
polyringR = Synth.before(mixmonoL, \polyring, paramsPolyring ++ [ out:bPolyringR ]);
Synth.before(mixmonoL, \crackle, paramsCrackle ++ [ out:bCrackleL ]);
Synth.before(mixmonoR, \crackle, paramsCrackle ++ [ out:bCrackleR ]);
)


/**************************************************/
/*               RANDOM BITS AND BOPS             */
/**************************************************/

/*
 * HELP 4 DRONES https://github.com/schollz/workshops/tree/main/2021-08-music-hackspace-supercollider/droning
 */

/* bee's nest
  ring = Ringz.ar(
    PulseDivider.ar(Dust2.kr(bps * 5))              // trigger
    , TRand.ar( rfreqsrc-100,rfreqsrc+100, tempo )  // frequency. TRand genebpss random numbers w/in intervals (here, +-10)
    , 100                                           // decay time
    , 1                                             // mul
  );
  ring = CoinGate.ar(
    Rand(0,1)
    , FreeVerb.ar(
      ring
      ,  mix:1
      , room:1
      , damp:1
    )
  ).clip;
*/


