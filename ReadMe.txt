
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SampSyn - Beta
by Ethan Manilow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	This is a real time, MIDI controlled, file dependent granular synthesizer that takes  a user specified file as input and plays a length of the file specified by input from a MIDI keyboard. There are currently two algorithms used to create sound. 
	The first is the standard algorithm which will play and repeat the whole file if the lowest MIDI note is played (C0), half of the file if a note an octave higher is played, a quarter of the file if one more octave higher, and so on. At higher note values the user hears a pitch based on the rapidly playing grains instead of the actual file content. The actual algorithm is based of fileDivision =  2^(midiNoteNumber / 12), where fileDivision is how much of the input file is played. This is selected by default when you first open the program.
	The second is a pitch corrected algorithm. This algorithm is not yet finished, but a semi-working version is provided. This defines the fileDivision based on the frequencies associated with each key on the keyboard. For instance, A440 would play 1/440th of the file, and likewise for every other key. Since hearing the file content is also very interesting, the provided "frequencies" (ie file divisions) are extended to below the hearing range of a typical frequency so the file can be played almost in full.




To run:

-Make sure you have a MIDI device connected to your computer (if I don't have an external one, I just open Logic Pro, or GarageBand to use the software MIDI controller).
-Open provided Xcode file, click run.
-Once built, click "Open" in the top right corner of the application window to select a file from your computer. Notice that the "File Sample Rate" and "File Length" have been filled in.  I have provided two files that work well named HW2.wav and HW5.wav. Read below to learn about good input files.
-Select MIDI port from drop down menu.
-Pertinent info will be displayed in the window below the "Start MIDI" button
-Click "Start MIDI" By default the standard algorithm is selected
-Play!!! Have fun!! The program knows if you are not having fun and will execute your computer's self destruct function if you do not have fun.
-Notice that when you play the note info is updated in real time on the display.
-The "Smoothing" checkbox does nothing.
-The "Pitch Correction" checkbox switches to the pitch correction algorithm. The octave selector is enabled to lower octaves. Turn off pitch selection before you click "Stop MIDI"
-When you are finished, click "Stop MIDI" and exit!





Known issues (issues I've had):

-The final build product created by Xcode doesn't make sound. Although if you open the Xcode project and hit run, it works fine. I have no idea why. BIG ISSUE, potentially solved by migrating to CoreAudio (See below).


-Pitch correction algorithm produces wrong notes at high note values. This is because the algorithm computes number of samples to be played based on keyboard input. When the number of samples is very small (ie high frequency/notes), the difference between two keys can be so small that it is effectively 0 according to the algorithm. Thus we hear a few keys in the higher register that are incorrect. This should be better for files with higher sample rates.

-Pith correction algorithm has a hard time playing the whole file. There is an octave shifter in place, but that can sometimes be finicky. This means that the pitch correction algorithm mainly produces an expensive sawtooth wave unless we can hear the transition from file content to rapid grains. Not very cool sounding. Potentially not such a huge issue - easily fixed by adding lower powers of 2 to the bottom.




Still to do:

-Implement the Smoothing Algorithm. This will be useful because even at moderate frequencies the synth sounds like a sawtooth wave because we hear the restarting of the sampled bit more than the actual samples. In the end though, it might not make much of a difference at high frequencies. This algorithm will be similar to the time stretching algorithms mentioned in class. For instance, if the user depressed the key corresponding to putting 1000 samples on the output buffer, I would grab 1100 samples: 50 samples before starting point, the 1000 desired samples, and 50 samples after the end point (50 is an arbitrary number I picked for this example). Then I would cross fade the 50 extra samples at the beginning with the 50 extra samples at the end. Still a few details to work out: how to retain correct timing with extra samples, how this will affect pitch correction algorithm, what if user selects beginning/end of file?

-Try to reimplement this as an AudioUnit so it is compatible with other audio hosts. Requires a lot of learning about CoreAudio & AudioUnits. Big idea!!!

