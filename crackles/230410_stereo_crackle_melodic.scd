s.boot;

(
SynthDef(\crackle, {
  /**
   * crackle generation
   *
   * @arg bps: impulses / second
   * @arg ringratio: ring to crackle ratio. in range 0..1
   * @arg ringfreq: ring frequency
   * @arg out: output buffer
   */
  arg bps, ringratio=0.1, ringfreq=1000, out=0;
  var tempo, ring, line, poly=[];

  tempo = Dust2.ar(bps);

  /* bee's nest
  ring = Ringz.ar(
    PulseDivider.ar(Dust2.kr(bps * 5))              // trigger
    , TRand.ar( ringfreq-100,ringfreq+100, tempo )  // frequency. TRand genebpss random numbers w/in intervals (here, +-10)
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

  // sinosc
  ring = SinOsc.ar(
    TRand.ar( ringfreq-100,ringfreq+100, tempo )  // freq
    , mul: Limiter.ar(Ringz.ar(Dust2.ar(bps)) * 10, 1)
  );
  ring = FreeVerb.ar(
    ring
    ,  mix:1
    , room:1
    , damp:1
  );

  /*  ATTEMPT TO REAPLACE THE ABOVE `ring`:
      CREATE AN ARRAY OF VALUES IN RANGE +-500 OF RINGFREQ
      IN ORDER TO CREATE AN ARRAY OF `ring` TO GENERATE POLYPHONY:
      10 TIMES THE SAME `ring` ELEMENT, BUT WITH SLIGHTLY DIFFERENT
      FREQUENCY EACH TIME.
      didn't work cause i can't manage to build an array + loop on it right

  x = Pexprand(ringfreq-500, ringfreq+500, inf).iter;
  x.do({
    arg freq;
    ring = SinOsc.ar(
      freq
      , mul: Limiter.ar(Ringz.ar(Dust2.ar(bps)) * 10, 1)
    );
    ring = FreeVerb.ar(
      ring
      ,  mix:1
      , room:1
      , damp:1
    );
    poly.add(ring);
  });
  */

  // actual output
  line = PinkNoise.ar(
    // level tigger: a blend of ringing filter + straight up crackle
    ( poly * ringratio + tempo * (1 - ringratio) ),
    // additional vol
    TExpRand.ar(
      0.0001                    // lo number
      , 0.2                     // hi number
      , PulseDivider.ar(tempo)  // trigger
    )
  );
  Out.ar(out, line);
}).add;


SynthDef(\mix, {
  /**
   * mix the different channels
   *
   * @arg inL: left ear input
   * @arg inR: right ear input
   * @arg out: the output buffer
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
var bL, bR, mix, params, paramsL, paramsR;
bL = Bus.audio(s, 1);
bR = Bus.audio(s, 1);

params = [bps:5, ringratio:0.02, ringfreq:1000];
paramsL = params ++ [\out, bL];
paramsR = params ++ [\out, bR];

mix = Synth.new(\mix, [inL:bL, inR:bR]);
Synth.before(mix, \crackle, paramsL);
Synth.before(mix, \crackle, paramsR);
)

s.quit;