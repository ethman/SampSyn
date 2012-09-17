//
//  synth.h
//  PAT462-Project6
//
//  Created by Ethan Manilow on 4/3/12.
//  Copyright 2012 Ethan Manilow. All rights reserved.
//

#ifndef __SYNTH_H__
#define __SYNTH_H__


#include <iostream>
#include <signal.h>
#include <cstdlib>
#include <string>
#include <cmath>
//#include <algorithm>

#include "Stk.h"
#include "FileLoop.h"
#include "RtAudio.h"
#include "Skini.h"
#include "SKINI.msg"
#include "Messager.h"
#include "Mutex.h"

using namespace stk;

struct talker {
    bool smoothing, pitchCor, driverActive;
    int noteVal, octaveShift;
    double division;
    unsigned long numSamples, timeOffset;
    Mutex m, s;
    
    talker() : noteVal(-1), driverActive(false), octaveShift(0), timeOffset(0) {}
};


struct dataHolder {
    FileLoop *file;
    Messager messager;
    Skini::Message message;
    //RtMidiIn *midi;
    unsigned long int pos, size, sampleRate, numSamples;
    double division, rate;
    long counter;
    bool haveMessage;
    unsigned int keyCount, vol;
    talker *t;
    
    dataHolder() : file(0), pos(0), counter(0),
    haveMessage(false), rate(1.0), keyCount(0), division(1.0) {}
};


int driver(const char filePath[], unsigned int midiPort, Mutex* m, talker *t);

int tick(   void *outputBuffer, void *inputBuffer, 
            unsigned int nBufferFrames, double streamTime, 
            RtAudioStreamStatus status, void *userData);
void processMessage(dataHolder *data);

int probeMidiPorts(std::vector<std::string> &ports);
bool getFileInfo(unsigned long &length, unsigned long &samepleRate, const char filePath[]);
bool getArrayToDraw(std::vector<float> &array, const char filePath[]);


//Need to use 'pitches' lower than MIDI spec so we can play the whole file.
static const double myMidi2Pitch[165] = {
    1.02197, 1.08274, 1.14713, 1.21534, 1.28761, 1.36417, 1.44529, 
    1.53123, 1.62228, 1.71875, 1.82095, 1.92923, 2.04395, 2.16549, 
    2.29426, 2.43068, 2.57522, 2.72835, 2.89058, 3.06246, 3.24457, 
    3.4375, 3.6419, 3.85846, 4.0879, 4.33098, 4.58851, 4.86136, 
    5.15043, 5.45669, 5.78116, 6.12493, 6.48914, 6.875, 7.28381, 7.71693, 
    8.176, 8.662, 9.177, 9.723, 10.301, 10.913, 11.562, 12.25,
    12.978, 13.75, 14.568, 15.434, 16.352, 17.324, 18.354, 19.445,
    20.602, 21.827, 23.125, 24.50, 25.957, 27.50, 29.135, 30.868,
    32.703, 34.648, 36.708, 38.891, 41.203, 43.654, 46.249, 49.0,
    51.913, 55.0, 58.271, 61.735, 65.406, 69.296, 73.416, 77.782,
    82.407, 87.307, 92.499, 97.999, 103.826, 110.0, 116.541, 123.471,
    130.813, 138.591, 146.832, 155.563, 164.814, 174.614, 184.997, 195.998,
    207.652, 220.0, 233.082, 246.942, 261.626, 277.183, 293.665, 311.127,
    329.628, 349.228, 369.994, 391.995, 415.305, 440.0, 466.164, 493.883,
    523.251, 554.365, 587.33, 622.254, 659.255, 698.456, 739.989, 783.991,
    830.609, 880.0, 932.328, 987.767, 1046.502, 1108.731, 1174.659, 1244.508,
    1318.51, 1396.913, 1479.978, 1567.982, 1661.219, 1760.0, 1864.655, 1975.533,
    2093.005, 2217.461, 2349.318, 2489.016, 2637.02, 2793.826, 2959.955, 3135.963,
    3322.438, 3520.0, 3729.31, 3951.066, 4186.009, 4434.922, 4698.636, 4978.032,
    5274.041, 5587.652, 5919.911, 6271.927, 6644.875, 7040.0, 7458.62, 7902.133,
    8372.018, 8869.844, 9397.273, 9956.063, 10548.082, 11175.303, 11839.822, 12543.854,
    13289.75};


#endif



