s.boot;

(
/* DEFINE SYNTHS */
SynthDef(\crackle, {
  arg rate, out=0;
  var tempo=Dust2.ar(rate);
  var source={
    WhiteNoise.ar(Decay2.ar(PulseDivider.ar(tempo), 2, 0.1)) * 10
      + SinOsc.ar(tempo * 10000, 1, 1) * 0.1
  };
  Out.ar(
    out,
    (
      Gate.ar(source, tempo * 0.0001);
    ) ! 2
  )
}).add;
)

(
/* PLAY SYTNH */
Synth.new(\crackle, [rate:10]);
)


s.quit;