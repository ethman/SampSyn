//
//  PAT462_Project6AppDelegate.h
//  PAT462-Project6
//
//  Created by Ethan Manilow on 4/3/12.
//  Copyright 2012 Ethan Manilow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGL/OpenGL.h>
#import "Mutex.h"
#import "WaveFormGraph.h"
#import "synth.h"

@class WaveFormGraph;

@interface PAT462_Project6AppDelegate : NSObject <NSApplicationDelegate> {
    //IBOutlet NSView *drawWave;
    CALayer *waveFormLayer;
    WaveFormGraph *waveFormDelegate;
    IBOutlet NSView *waveformView;
    //CAOpenGLLayer *waveFormLayerGL;
@private
    NSWindow *_window;
    NSTextField *_fileName;
    NSString *_filePath;
    NSTextField *_infoField;
    NSPopUpButton *_midiSelector;
    NSButton *_midiOnOff;
    stk::Mutex *driveMutex;
    //IBOutlet WaveFormGraph *waveFormGraph;
    NSTextField *_fileSampleRate;
    NSTextField *_fileLength;
    NSButton *_smoothBool;
    NSButton *_pitchBool;
    NSTextField *_midiNote;
    NSTextField *_noteLength;
    NSTextField *_octavesDisplay;
    NSStepper *_octaveStepper;
    NSTextField *_octavesWord;
    talker *talkToDriver;
    int octaveVal;
    CGFloat lengthInSec;
    unsigned long fileLength;
    NSUInteger _selectedPort;
    BOOL _fileGood;
    BOOL _midiActive;
    
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *fileName;
@property (assign) IBOutlet NSTextField *infoField;
@property (assign) IBOutlet NSPopUpButton *midiSelector;
@property (assign) NSUInteger selectedPort;
@property (assign) NSString *filePath;
@property (assign) BOOL midiActive;
@property (assign) BOOL fileGood;
@property (assign) IBOutlet NSButton *midiOnOff;
//@property (nonatomic, retain) IBOutlet WaveFormGraph *waveFormGraph;
@property (assign) IBOutlet NSTextField *fileSampleRate;
@property (assign) IBOutlet NSTextField *fileLength;
@property (assign) IBOutlet NSButton *smoothBool;
@property (assign) IBOutlet NSButton *pitchBool;
@property (assign) IBOutlet NSTextField *midiNote;
@property (assign) IBOutlet NSTextField *noteLength;
@property (assign) IBOutlet NSTextField *octavesDisplay;
@property (assign) IBOutlet NSStepper *octaveStepper;
@property (assign) IBOutlet NSTextField *octavesWord;


- (IBAction)changeOctaves:(id)sender;
- (void)startTalking;
- (void)startDriver;
- (void)getFileData;
- (void)getReadyToDraw:(const char*)name;
- (IBAction)open:(id)sender;
- (IBAction)setMidi:(id)sender;
- (IBAction)startSynth:(id)sender;
- (IBAction)toggleSmoothBool:(id)sender;
- (IBAction)togglePitchBool:(id)sender;

@end
