s.boot;

/*
  randomize the playback of input files

  see:
  - randomness : https://depts.washington.edu/dxscdoc/Help/Guides/Randomness.html
  - patterns (to create a random sequence of buffer playback) : https://doc.sccode.org/Tutorials/Getting-Started/16-Sequencing-with-Patterns.html
  - buffers : https://depts.washington.edu/dxscdoc/Help/Classes/Buffer.html
  - filepath manipulation (see `.filesDo`) : https://doc.sccode.org/Classes/PathName.html
*/

/*************** READ FROM A FILE TUTORIAL ***************/
(
f = "/home/paulhector/musique/supercollider/test/byz_drone_octave.flac";  // absolute path to file
b = Buffer.read(s, f);  // define a buffer to read that file
SynthDef(\player, {
	// define a synth to read the file.
	arg out=0, bufnum;
  Out.ar(
		out,  // channel on which to play the file
    PlayBuf.ar(
			2, // number of channels
			bufnum, // the `b` buffer's, passed as the `bufnum`; each buffer is represented by a number on the server-side, and `bufnum` points to this buffer
			BufRateScale.kr(bufnum)  // get the samplerate of the soundfile to play the playback at a normal speed
	  )
  )
}).add;

c = Synth.new(\player, [\bufnum, b]);  // play the synth
)

(
// read all files in folder, recursively
var fpath = PathName.new("/home/paulhector/musique/supercollider/test");
fpath.filesDo( { arg file; file.postln; });
)


/*************** PLAY RANDOM SOUNDS RANDOMLY TUTORIAL ***************/
(
SynthDef(\randsin, {
	// generate a random pitch sinusoidal sound
	arg out=0, freq, gate=1, wait;
	var audio, env;
	audio = SinOsc.ar(freq);

	env = Linen.kr(gate, doneAction: Done.freeSelf);  // `env` determines the level of `Pan2.ar`
	Out.ar(out, Pan2.ar(audio,0,env));
}).add;
)

(
p = Pbind(
	// ìn `Pbind`, arguments are passed into key-value pairs. the key is a symbol pointing
	// to the synth to be played (`\instrument`), or to parameters of that synth based on
	// their name (`\freq`)
	\instrument, \randsin,  // the instrument to play
	\freq, Prand([200, 400, 600, 800, 1000], inf),  // `inf ` is crucial as it allows for a constant loop
	\gate, Prand(Array.rand(20, 0, 0.01), inf),  // the gate
	\wait, Prand(Array.rand(20, 0, 2), inf)
	\dur, Prand(Array.rand(7, 0.3, 0.5), inf)  // the duration
);
p.play;
)

s.quit;