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

  DOCUMENTATION
  - pattern cookbook: http://doc.sccode.org/Tutorials/A-Practical-Guide/PG_01_Introduction.html
  - patterns (to create a random sequence of buffer playback) : https://doc.sccode.org/Tutorials/Getting-Started/16-Sequencing-with-Patterns.html
  - randomness : https://depts.washington.edu/dxscdoc/Help/Guides/Randomness.html
  - buffers : https://depts.washington.edu/dxscdoc/Help/Classes/Buffer.html
  - filepath manipulation (see `.filesDo`) : https://doc.sccode.org/Classes/PathName.html
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
    PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)) ! 2
  )
}).add;
)

/*********************************************************************/

(
/* DEFINE THE BUFFERARRAY ENVIRONMENT VARIABLE -- WITH TIME */
// `~bufferArray` = array of [buffer, buffer_duration_in_seconds]
var path;
Buffer.freeAll;
path = PathName.new("/home/paulhector/musique/supercollider/tapeswap2022/sources");
~bufferArray = Array.new(100);
path.filesDo({
  arg file;
  b = Buffer.read(s, file.fullPath, action: {
    // buffer loading is asynchronous =>
    // when the buffer is loaded, add it and its duration to `~bufferArray`
    arg buffer;
    var duration = buffer.numFrames / buffer.sampleRate;  // duration in s.
    ~bufferArray.add( [ buffer, duration ]);
  });
});
)

(
/* PLAYING THE SYNTH -- WITH DURATION TIME IN `~bufferArray` */
p = Pbind(
  \buffer, Prand(~bufferArray, inf),
  \instrument, \player,
  \bufnum, Pkey(\buffer[0]),
  \dur, Pkey(\buffer[1])
);
p.play;
)

(
/* PLAYING THE SYNTH -- WITH DURATION TIME IN `~bufferArray` */
// attempt using pfset
p = Pfset(
  {
    ~bufferArray.postln;  // WHY IS IT NIL ???
    ~bufArray = Prand(~bufferArray, inf);
    ~buf = ~bufArray[0];
    ~bufDur = ~bufArray[1];
  }, Pbind(
    \instrument, \player,
    \bufnum, Pkey(\buf),
    \dur, Pkey(\bufDur)
  );
);
p.play;
)

/*********************************************************************/

(
/* DEFINE THE BUFFERARRAY ENVIRONMENT VARIABLE -- WITHOUT TIME */
// `~bufferArray` = array of buffers.
var path;
Buffer.freeAll;
path = PathName.new("/home/paulhector/musique/supercollider/tapeswap2022/sources");
~bufferArray = Array.new(100);
path.filesDo({
  // add the buffer to `~bufferArray` asynchronously
  arg file;
  b = Buffer.read(s, file.fullPath, action: {
    arg buffer;
    ~bufferArray.add( buffer );
  })
});
)

(
/* PLAYING THE SYNTH -- WITHOUT DURATION TIME IN `~bufferArray` */
p = Pbind(
  \buffer, Prand(~bufferArray, inf),
  \instrument, \player,
  \bufnum, Pkey(\buffer),
  \dur, (Pkey(\buffer.numFrames) / Pkey(\buffer.sampleRate))
);
p.play;
)


