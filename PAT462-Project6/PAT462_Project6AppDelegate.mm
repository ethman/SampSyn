//
//  PAT462_Project6AppDelegate.m
//  PAT462-Project6
//
//  Created by Ethan Manilow on 4/3/12.
//  Copyright 2012 Ethan Manilow. All rights reserved.
//
//
//  VERSION 6 of PAT462 final project
//
//  Implementation file for main menu

#import <dispatch/dispatch.h>
#import <iomanip>
#import <Quartz/Quartz.h>
#import <QTKit/QTKit.h>
#import <OpenGL/OpenGL.h>
#import <vector>

#import "PAT462_Project6AppDelegate.h"
#import "synth.h"
#import "WaveFormGraph.h"

//use grand central dispatch to handle threading
dispatch_queue_t driverQue, talkerQue, waveformQue;

@implementation PAT462_Project6AppDelegate


@synthesize infoField = _infoField;
@synthesize midiSelector = _midiSelector;
@synthesize window = _window;
@synthesize fileName = _fileName;
@synthesize selectedPort = _selectedPort;
@synthesize filePath = _filePath;
@synthesize midiActive = _midiActive;
@synthesize midiOnOff = _midiOnOff;
@synthesize fileGood = _fileGood;
//@synthesize waveformView;
@synthesize fileSampleRate = _fileSampleRate;
@synthesize fileLength = _fileLength;
@synthesize smoothBool = _smoothBool;
@synthesize pitchBool = _pitchBool;
@synthesize midiNote = _midiNote;
@synthesize noteLength = _noteLength;
@synthesize octavesDisplay = _octavesDisplay;
@synthesize octaveStepper = _octaveStepper;
@synthesize octavesWord = _octavesWord;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //This function runs upon opening the program: initializes
    //relevant varaibles and populates midi selector
    
    
    //Initialize variables
    self.midiActive = false;
    self.fileGood = false;
    
    //talker is how we communicate with the STK synthesis driver
    talkToDriver = new talker();
    
    //Find all MIDI ports and fill the selector with port names
    std::vector<std::string> ports;
    NSUInteger numPorts = probeMidiPorts(ports);
    
    [self.midiSelector removeAllItems];
    [self.midiSelector addItemWithTitle:@"Select MIDI Input Device"];
    if (numPorts != 0) {
        
        for (NSUInteger i=0; i<ports.size(); i++) {
            [self.midiSelector addItemWithTitle:
                    [NSString stringWithCString:ports[i].c_str() encoding:[NSString defaultCStringEncoding]]];
        }
        
        
    } else {
        [self.infoField setStringValue:@"No MIDI ports available!"];
    }
    
    
    //Turn off octave selecter on launch
    [self.octavesDisplay setTextColor:[NSColor secondarySelectedControlColor]];
    [self.octavesWord setTextColor:[NSColor secondarySelectedControlColor]];
    
    //[waveFormDelegate setDrawWave:YES];
    
    //[waveFormGraph viewWillDraw];
    //waveFormDelegate = [[WaveFormGraph alloc] init];
    //waveFormLayer = [CALayer layer];
    //waveFormLayer.delegate = waveFormDelegate;
    //[waveFormLayer setNeedsDisplay];
    //waveformView.layer = waveFormLayer;
    
    //waveFormLayerGL = [WaveFormGraph layer];
    //[waveFormLayerGL setNeedsDisplay];
    //waveformView.layer = waveFormLayerGL;
    
    
    
}

- (IBAction)open:(id)sender {
    //Function to open a file: user can select file from NSOpenPanel
    //and function fills file data into text fields.
    
    NSLog(@"OPEN!\n");
    NSInteger result;
    
    //terminate current session if user decides to open another file
    if (self.midiActive) {
        self.midiActive = false;
        [self.midiOnOff setTitle:@"Start MIDI"];
        [self.infoField setStringValue:@"Synthesizer stopped."];
        driveMutex->signal();
    }
    
    
    //Set settings for open panel
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    NSArray *fileTypes = [NSSound soundUnfilteredTypes];
    [oPanel setAllowsMultipleSelection:NO];
    
    result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:fileTypes];
    
    //If user hit 'Okay'
    if (result == NSOKButton) {
        NSString *selectedFile = [oPanel filename];
        NSLog(@"%@", (NSString*)[[[oPanel filename] componentsSeparatedByString:@"/"] lastObject]);
        
        //shortName is the name of the file without the whole path
        NSString *shortName = (NSString*)[[[oPanel filename] componentsSeparatedByString:@"/"] lastObject];
        //[self.track setFileName:selectedFile];
        
        
        self.filePath = [[NSString stringWithString:selectedFile] retain];
        
        NSLog(@"FILEPATH: %@", self.filePath);
        
        
        // ATUALLY DRAW THE WAVE FORM
        //[waveFormGraph drawFromFrequency:];
        
        
        //getFileData checks to make sure file is good
        //and populates file length and smaple rate text fields
        [self getFileData]; 
        if (self.fileGood) {
            [self.fileName setStringValue:shortName];
            
            
            const char *name = [self.filePath cStringUsingEncoding:NSASCIIStringEncoding];
                
                waveformQue = dispatch_queue_create("com.EthanManilow.PAT462-P6.STKsynthDriver", NULL);
                dispatch_async(waveformQue, ^{
                    NSLog(@"Starting to draw waveform thread\n");
                    [self getReadyToDraw:name];
                });
                
            
        }
        
    }
}


- (void)getReadyToDraw:(const char *)name{
    std::vector<float> arraySTL;
    
    if ( getArrayToDraw(arraySTL, name) ) {
        NSMutableArray * rawDataArray = [[NSMutableArray alloc] init];
        NSNumber * temp;
        for (unsigned int i=0; i<arraySTL.size(); i++) {
            temp = [NSNumber numberWithFloat: arraySTL[i]];
            [rawDataArray addObject:temp];
        }
        
        [waveformView setDrawWave:YES];
        [waveformView calculateWaveForm:rawDataArray];
        [waveformView setNeedsDisplay:YES];
    }

}

- (void)getFileData{
    //calls getFileInfo() in synth.cpp and determines
    //if specified file is usable, if not then it tells the user
    
    const char *name = [self.filePath cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned long fileSR=0;
    
    //actual call to cpp function
    bool canOpen = getFileInfo(fileLength, fileSR, name);
    
    if ( canOpen  && (fileSR == 44100 || fileSR == 96000)) {
        
        double len = (double) fileLength / (double) fileSR;
        
        //Set info fields for user
        lengthInSec = len;
        [self.fileSampleRate setIntValue:fileSR];
        [self.fileLength setFloatValue:lengthInSec];
        self.fileGood = true;
        NSLog(@"File Good!");
        
    } else {
        if ((fileSR != 44100 || fileSR != 96000)) {
            //I get errors with RtMidi when trying to use midi at 
            //any other smaple rate.
            [self.infoField setStringValue:@"Cannot open specified file! Must have sample rate of 44.1 or 96 kHz!"];
        } else {
            //Also, I know RtAudio supports aiff, but for some reason
            //it does not work on my machine. Just to be safe:
            [self.infoField setStringValue:@"Cannot open specified file type! Must be WAV!"];
        }
        
        self.fileGood = false;
    }
}

- (IBAction)setMidi:(id)sender {
    //self.selectedPort = [sender integerValue];
    //NSLog(@"%@", _selectedPort);
}

- (IBAction)startSynth:(id)sender {
    //Once a file and midi port are selected, user clicks 'start midi'
    //If everything is in order, this function starts driver() in synth.cpp
    //which actually handles the sound synthesis.
    
    self.selectedPort = [self.midiSelector indexOfSelectedItem];
    
    //cases for incorrect usage
    if (self.filePath == nil) {
        [self.infoField setStringValue:@"No file selected!"];
        if (self.midiActive) {
            self.midiActive = false;
            [self.midiOnOff setTitle:@"Start MIDI"];
            driveMutex->signal();
            [self.infoField setStringValue:@"Synthesizer stopped. Select an input file."];
        }
    } else if (_selectedPort == 0) {
        [self.infoField setStringValue:@"No MIDI controller selected!"];
        if (self.midiActive) {
            self.midiActive = false;
            [self.midiOnOff setTitle:@"Start MIDI"];
            driveMutex->signal();
            [self.infoField setStringValue:@"Synthesizer stopped. Select MIDI controller."];
        }
    } else if (!self.fileGood) {
        if (self.midiActive) {
            self.midiActive = false;
            [self.midiOnOff setTitle:@"Start MIDI"];
            driveMutex->signal();
            [self.infoField setStringValue:@"Synthesizer stopped. Must select WAV input file."];
        }
        
    } else if (!self.midiActive && self.filePath != nil 
            && _selectedPort != 0 && self.fileGood) {
        
        //all of the above criteria must be satisfied to run the driver 
        
        [self.infoField setStringValue:@""];
        self.midiActive = true;
        talkToDriver->driverActive = true;
        
        //create seperate thread to run driver
        driverQue = dispatch_queue_create("com.EthanManilow.PAT462-P6.STKsynthDriver", NULL);
        dispatch_async(driverQue, ^{
            NSLog(@"Starting driver thread\n");
            [self startDriver];
        });
        

        //create another thread so we can get RT info from the driver
        talkerQue = dispatch_queue_create("com.EthanManilow.PAT462-P6.STKsynthTalker", NULL);
        dispatch_async(talkerQue, ^{
            NSLog(@"Starting talker thread\n");
            [self startTalking];
        });
        [self.midiOnOff setTitle:@"Stop MIDI"];
        [self.infoField setStringValue:@"Synthesizer running..."];
        
    } else { 
        //     Midi already running
        self.midiActive = false;
        [self.midiOnOff setTitle:@"Start MIDI"];
        [self.infoField setStringValue:@"Synthesizer stopped."];
        driveMutex->signal();
    }
}

- (IBAction)toggleSmoothBool:(id)sender {
    //The selector for the intended smoothing synthesis algorithm: implimentation pending.
    //
    //This function does nothing except send the driver a message (which it doesn't use)
    //when the check box is selected.
    
    talkToDriver->m.lock();
    talkToDriver->smoothing = (NSOnState == [self.smoothBool state]);
    talkToDriver->m.unlock();
}

- (IBAction)togglePitchBool:(id)sender {
    //selector for Pitch correction algorithm
    //still on its first iteration: improvements needed.
    //
    //Also turns on octave switcher, which is intended for use with
    //pitch correction.
    
    BOOL isOn = (NSOnState == [self.pitchBool state]);
    talkToDriver->m.lock();
    talkToDriver->pitchCor = isOn;
    talkToDriver->m.unlock();
    
    //turn on/off octave switcher
    [self.octaveStepper setEnabled:isOn];
    if(isOn) {
        [self.octavesDisplay setTextColor:[NSColor controlTextColor]];
        [self.octavesWord setTextColor:[NSColor controlTextColor]];
    } else {
        [self.octavesDisplay setTextColor:[NSColor secondarySelectedControlColor]];
        [self.octavesWord setTextColor:[NSColor secondarySelectedControlColor]];
    }
    
}

-(void)startDriver {
    //Wrapper function to start driver() in synth.cpp
    //called in a seperate thread. Will exit once driveMutex->signal()
    //is called from another thread (eg 'Stop MIDI' botton)
    
    NSLog(@"--->%@, %lu", self.filePath, self.selectedPort);
    driveMutex = new Mutex();
    const char *name = [self.filePath cStringUsingEncoding:NSASCIIStringEncoding];
    
    //driver waits for signal
    driver(name, self.selectedPort, driveMutex, talkToDriver);
    delete driveMutex;
}

- (IBAction)changeOctaves:(id)sender {  
    //Ocvate switch for use with the pitch correction algorithm
    //Is disabled when the pitch correction check box is unchecked
    
    
    octaveVal = [sender intValue];
    NSMutableString *display = [[NSMutableString alloc] init];
    
    [self.octaveStepper setIntValue:octaveVal];
    if (octaveVal < 0) {
        [self.octavesDisplay setIntValue:octaveVal];
    } else {
        [display appendFormat:@"%c", '+'];
        [display appendFormat:@"%ld", octaveVal];
        [self.octavesDisplay setStringValue:display];
    }
    
    talkToDriver->m.lock();
    talkToDriver->octaveShift = octaveVal * 12;
    talkToDriver->m.unlock();
         
    [display release];
}

- (void)startTalking {
    //Function to show realtime info on what is being played.
    //It's called at the same time as startDriver() and exits
    //at the same time, too, using talkToDriver->driverActive
    
    /*talkToDriver->m.lock();
    bool keepGoing = talkToDriver->driverActive;
    talkToDriver->m.unlock();*/
    double division, mousePos, rectWidth = [waveformView getRectWidth];
    unsigned long numSamples; 
    int noteVal, octave, index;    
    NSArray *noteArray = [NSArray arrayWithObjects:@"C", @"C#",
                          @"D", @"D#", @"E", @"F", @"F#", @"G",
                          @"G#", @"A", @"A#", @"B", nil];
    NSMutableString *display = [[NSMutableString alloc] init];
    
    while (talkToDriver->driverActive) {
        
        //wait until we have data to show
        talkToDriver->s.wait();
        NSLog(@"Got signal!");
        
        mousePos = [waveformView getMouseAtX];
        
        //Go!
        talkToDriver->m.lock();
        division = talkToDriver->division;
        numSamples = talkToDriver->numSamples;
        noteVal = talkToDriver->noteVal;
        talkToDriver->timeOffset = (mousePos / rectWidth) * (double)fileLength;
        talkToDriver->m.unlock();
        
        if (noteVal != -1) {
            // -1 means noteOff or no note
            
            octave = (noteVal /12);
            index = noteVal % 12;
            NSLog(@"%d, %d", index, octave);
            
            [display setString:@""];
            [display appendString:[noteArray objectAtIndex:index]];
            [display appendFormat:@"%ld", octave];
            [self.midiNote setStringValue:display];
            
            if (NSOnState == [self.pitchBool state]) {
                //This still has issues.
                //NSLog(@"%f", (CGFloat)numSamples/(CGFloat)fileLength);
                [self.noteLength setIntValue:(int)numSamples];
                [waveformView setHighlight:numSamples];
                /*if ((CGFloat)numSamples/(CGFloat)fileLength < 0.0001) {
                    [self.noteLength setStringValue:@"< 0.0001"];
                } else {
                    [self.noteLength setFloatValue:(CGFloat)numSamples/(CGFloat)fileLength];
                }*/
            } else  {
                [self.noteLength setIntValue:(int)fileLength/division];
                [waveformView setHighlight:(int)fileLength/division];
                /*if ((CGFloat)(lengthInSec/division) < 0.0001) {
                    [self.noteLength setStringValue:@"< 0.0001"];
                } else {
                    [self.noteLength setFloatValue:(CGFloat)(lengthInSec/division)];
                }*/
                
            }
            //waveformQue = dispatch_queue_create("com.EthanManilow.PAT462-P6.STKsynthDriver", NULL);
            //dispatch_async(waveformQue, ^{
            //    NSLog(@"Starting to draw waveform thread\n");
                [waveformView setNeedsDisplay:YES];
            //});
        } else {
            [self.midiNote setStringValue:@""];
            [self.noteLength setStringValue:@""];
            [display setString:@""];
            [waveformView setHighlight:-1.0];
            //waveformQue = dispatch_queue_create("com.EthanManilow.PAT462-P6.STKsynthDriver", NULL);
            //dispatch_async(waveformQue, ^{
                NSLog(@"Starting to draw waveform thread\n");
                [waveformView setNeedsDisplay:YES];
            //});
        }
        /*talkToDriver->m.lock();
        keepGoing = talkToDriver->driverActive;
        talkToDriver->m.unlock();*/
    }
    
    [self.midiNote setStringValue:@""];
    [self.noteLength setStringValue:@""];
    
    
    [display release];
    //[noteArray release];
    NSLog(@"Leaving startTalking");
    
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    //Gets called when user exits program
    //cleans up all dirtiness.
    
    //turn off driver if it's still on 
    if (self.midiActive) {
        driveMutex->signal();
    }
    delete talkToDriver;
}

@end
