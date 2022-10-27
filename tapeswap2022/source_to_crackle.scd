s.boot;
s.quit;

/*
  play different sound sources at random intervals and process them to build crackle

  PIPELINE IDEA:
  - with `path.filesDo`, read all source sound files and build an array of buffers
  - from then on, create a `Pbind` to play those files and process them
  - find a way to add some silence between sample playbacks (maybe do 2 Pbinds inside
    another pattern, one which plays the sound inputs, the other which plays silence,
    and trigger sound and silence alternatively ?)
  - record to file
*/

(
/* SYNTHS */
SynthDef(\player, {
	/*
	  play a file from a buffer
	  out: the output channel
	  bufnum: the buffer to play
	*/
	arg out=0, bufnum;
  Out.ar(
		out,
    PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)) ! 2
  )
}).add;

)


(
/* PLAYING THE SYNTH */

// read all sound files in the `sources/` folder and create buffers for each
var path, bufferArray;
path = PathName.new("/home/paulhector/musique/supercollider/tapeswap2022/sources");
bufferArray = Array.new(100);
path.filesDo( { arg file; bufferArray.add( Buffer.read(s, file.fullPath) ); });  // load all buffers in `bufferArray`

Synth.new(\player, [bufnum:bufferArray.choose]);
)
