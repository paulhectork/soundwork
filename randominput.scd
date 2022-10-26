s.boot;

/*
  randomize the playback of input files
*/

(
f = "/home/paulhector/musique/supercollider/byz_drone_octave.flac";  // absolute path to file
b = Buffer.read(s, f);  // define a buffer to read that file
x = SynthDef(\player, {
	// define a synth to read the file.
	arg out=0, bufnum;
  Out.ar(
		out,  // channel on which to play the file
    PlayBuf.ar(
			2, // number of channels
			bufnum, // the `b` buffer, passed as the `bufnum` argument
			BufRateScale.kr(bufnum)  // ratio of the soundfile to scale the playback
	  )
  )
});
x.play(s,[\bufnum, b])
)

s.quit;