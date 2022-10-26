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
