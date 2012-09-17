//
//  synth.cpp
//  PAT462-Project6
//
//  Created by Ethan Manilow on 4/3/12.
//  Copyright 2012 Ethan Manilow. All rights reserved.
//

#include "synth.h"
#include <iostream>
#include <signal.h>
#include <cstdlib>
#include <string>
#include <cmath>
#include <vector>

#include "FileLoop.h"
#include "FileWvIn.h"
#include "RtAudio.h"
#include "Skini.h"
#include "SKINI.msg"
#include "Messager.h"
#include "RtMidi.h"



using namespace stk;

bool done;
StkFrames frames;
static void finish(int ignore) { done = true; }

//Debug variable
#define DBG 1


#define DELTA_CONTROL_TICKS 64
//#define TWELFTH_ROOT_TWO 1.05946309435
//#define LOW_C_FREQ 1.02197486453 //this is the frequency of C -2 in Hz

void processMessage(dataHolder *data) {
    //This function gets called whenever a midi event is pushed
    //into data->haveMessage by tick()
    //determines if note is on/off, computes data for synthesis
    //depending on which algorithm is selected, and provides data
    //to be displayed in startTalker in AppDelegate.mm
    
    register StkFloat value1 = data->message.floatValues[0];
    register StkFloat value2 = data->message.floatValues[1];
    
    data->t->m.lock();
    register int index = (int)value1 + data->t->octaveShift + 36;
    register bool doPitch = data->t->pitchCor;
    data->t->m.unlock();

    //std::cout << "index: " << index << "\n";
    if (DBG) std::cout << data->message.type << "\t" << value1 << "\t" << value2 << "\t";
    
    switch (data->message.type) {
        case __SK_Exit_:
            return;
            //break;
        case __SK_NoteOn_:
            if (index < 0) {
                index = 0;
            }
            if (index > 164) {
                //do nothing, out of array bounds/invalid note
            } else if (value2 == 0.0) {
                
                //really a noteOff signal
                data->keyCount--;
                if (DBG) std::cout << "OFF1!\tkeyCount=" << data->keyCount << "\t";
                data->t->m.lock();
                data->t->noteVal = -1;
                data->t->m.unlock();
                data->t->s.signal();
                if (DBG) std::cout << "signalOff1\n";
            } else {
                if (DBG) std::cout << "ON!\t\t";
                data->keyCount++;
                
                //The two synthesis algorithms
                if (doPitch) { 
                    //Pitch Correction algorithm
                    //uses predetermined "pitches" from myMidi2Pitch[]
                    
                    data->numSamples =  data->sampleRate / myMidi2Pitch[index];
                    data->t->m.lock();
                    data->t->noteVal = value1;
                    data->t->numSamples = data->numSamples;
                    data->t->m.unlock();
                } else {
                    //Standard algorithm
                    //every octave will halve the length the file is played
                    
                    data->division = pow(2, (double)value1 / 12.0);
                    data->t->m.lock();
                    data->t->noteVal = value1;
                    data->t->division = data->division;
                    data->t->m.unlock();
                }
                
                //set volume
                data->vol = value2;
                
                //std::cout << "pitch: " << data->t->pitchCor << "\toctave: " << data->t->octaveShift << "\n";
                
                //send signal to update user display
                data->t->s.signal();
                if (DBG) std::cout << "division=" << data->division << "\tkeyCount=" << data->keyCount << "\tsingalOn!\n";
            }
            break;
            
        case __SK_NoteOff_:
            data->keyCount--;
            data->t->m.lock();
            data->t->noteVal = -1;
            data->t->m.unlock();
            data->t->s.signal();
            if (DBG) std::cout << "OFF2!\tkeyCount=" << data->keyCount << "\tsignalOff2!\n";
            break;
            
        default:
            break;
    }
    
    data->haveMessage = false;
    
}



int tick( void *outputBuffer, void *inputBuffer, unsigned int nBufferFrames,
                double streamTime, RtAudioStreamStatus status, void *userData) 
{
    //Called by RtAudio framework automatically when dac stream is started.
    //A lot of mess in here because I'm still tweaking things and don't want
    //to delete everything just yet.
    //
    //Actually puts synthesized samples on output buffer when determined by
    //midi.
    //Issues: Mono. Still need to figure out how to put data onto buffer correctly.
    
    dataHolder *data = (dataHolder*) userData;
    register double sample, *samples = (double *) outputBuffer;
    unsigned int counter, nTicks = (int) nBufferFrames * data->file->channelsOut();
    
    //data->file->tick(frames);
    while (nTicks > 0 && !done) {
        if ( !data->haveMessage ) {
            data->messager.popMessage( data->message );
            if ( data->message.type > 0 ) {
                
                data->counter = (long) (data->message.time * Stk::sampleRate() );
                data->haveMessage = true;
            } else
                data->counter = RT_BUFFER_SIZE;
        }
        
        
        counter =  ((!(nTicks < data->counter)) ? (data->counter) : (nTicks)); // == min(nTicks, data->counter)
        data->counter -= counter;
        
        //frames.resize(counter);// data->file->channelsOut());
        //if (data->keyCount > 0) data->file->reset();
        //data->file->tick(frames);
        //std::cout << frames.size() << "\n";
        
        for (unsigned int i=0; i<counter; i++) {
            
            if (data->keyCount > 0 ) {
                sample = ( (double)data->vol / 128.0 ) * data->file->tick();
                data->pos++;
                
            } else {
                sample = 0.0;
                data->file->reset();
                data->file->addTime( data->t->timeOffset );
                
            } // end of (keyCount > 0)
            
            if (data->t->pitchCor) {
                if (data->pos >= data->numSamples) {
                    data->file->reset();
                    data->file->addTime( data->t->timeOffset );
                    data->pos = 0;
                }
                
            } else {
                if (data->pos >= data->size/data->division) {
                    //if (DBG)    std::cout   << "Restarting!\t" << data->pos << "\t" 
                    //            << data->size << "\t/\t" << data->division << "\t=\t" << data->size/data->division << "\n";
                    data->file->reset();
                    data->file->addTime( data->t->timeOffset );
                    data->pos = 0;
                } //end of if(pos >= size/division) (i <= 1 || i >= counter-2) &&
            }
            
            //sample = data->file->tick();
            
            
            *samples++ = sample;
            
            //if ( data->pos < data->file->getSize() ) 
            //    std::cout << "pos= " << data->pos << "\t\tval= " << sample << "\n";
            //sample = frames[i];
            //data->pos++;
            nTicks--;
            
        }
        
        if (nTicks == 0) break;
        
        if (data->haveMessage) processMessage(data); 
        
    } //end of while (nTicks > 0 && !done)
    
    //data->rate *= -1;
    //data->file->setRate(data->rate);
    
    return 0;
}

int driver (const char filePath[], unsigned int midiPort, Mutex *m, talker *t)
{
    //The main shebang!
    //Opens the file and starts dac stream and synthesis processes.
    
    //Get the file first so we can set the global sample
    //rate before instantiating all of the objects
    if (!filePath) {
        if (DBG) std::cout << filePath << "\t\tnope!\n";
        return 1;
    }
    std::string fileName = filePath;
    FileLoop input;
    
    if (DBG) std::cout      << "\n~~~~~~~~~~~~~~In driver()~~~~~~~~~~~~~~\n";
    if (DBG) std::cout      << "Name of input file: " << filePath 
                            << "\tMidi port: " << midiPort << "\n";
    
    try {
        input.openFile(fileName);
    } catch ( StkError &) {
        if (DBG) std::cout << "Could not open " << fileName << "\nExiting...\n";
        exit(1);
    }
    
    if (DBG) std::cout   << "Sample Rate: " << input.getFileRate() 
    << "\tSize: " << input.getSize()
    << "\tLength: " << (double) input.getSize() / (double) input.getFileRate() << " sec\n";
    
    //Sets global sample rate
    Stk::setSampleRate( input.getFileRate() ); //only 44.1 & 96 kHz supported for MIDI input
    
    
    RtAudio dac;
    dataHolder holder;
    holder.file = &input;
    input.setRate(1.0 / input.channelsOut() ); //<-Changed this from 0.5 to current
    holder.size = input.getSize(); //input.getSize() does not work for .aif files
    holder.t = t;
    holder.sampleRate = input.getFileRate();
    
    getFileInfo(holder.size, holder.sampleRate, filePath); 
    
    //if (DBG) std::cout << "holder.size = " << holder.size << "  input.getSize() = " << input.getSize() << "\n";
    
    //midiPort is 1-based, but messager takes 0-based input
    midiPort--;
    holder.messager.startMidiInput(midiPort);
    
    //input.addPhaseOffset(holder.size *2);
    //input.addTime(holder.size / 2);
    
    int channels = input.channelsOut();
    
    RtAudio::StreamParameters parameters;
    parameters.deviceId = dac.getDefaultOutputDevice();
    parameters.nChannels = channels;
    RtAudioFormat format = (sizeof(StkFloat) == 8) ? RTAUDIO_FLOAT64 : RTAUDIO_FLOAT32;
    unsigned int bufferFrames = RT_BUFFER_SIZE;
    try {
        dac.openStream( &parameters, NULL, format, (unsigned int)Stk::sampleRate(), &bufferFrames, &tick, (void *)&holder);
    } catch (RtError &error) {
        error.printMessage();
        goto cleanup;
    }
    
    (void) signal(SIGINT, finish);
    
    frames.resize( bufferFrames, channels, 0.0);
    
    try {
        dac.startStream();
    } catch (RtError &error) {
        error.printMessage();
        goto cleanup;
    }
    
    
    //wait until we get signal from AppDelegate (ie user)
    if (!done) 
        m->wait();
    
        
    try {
        dac.stopStream();
    } catch (RtError &error) {
        error.printMessage();
    }
    
    //Tell talker to quit
    t->s.signal();
    t->driverActive = false;

    
    if (DBG) std::cout << "~~~~~~~~~Leaving driver()~~~~~~~~~\n";
    
cleanup:
    
    return 0;
}

int probeMidiPorts(std::vector<std::string> &ports) {
    //Called upon starting program
    //determines how many midi ports are available
    //fills &ports to send to AppDelegate
    
    
    RtMidiIn *midiin = 0;
    
    //This was used to calculate pitches lower than C0
    /*std::cout << "\n\n\n";
    double freq=LOW_C_FREQ;
    for (int i=0; i<36; i++) {
        std::cout << freq << ", ";
        freq *= TWELFTH_ROOT_TWO;
    }
    std::cout << "\n\n\n"; */
    
    try {
        midiin = new RtMidiIn();
    }
    catch ( RtError &error ) {
        error.printMessage();
        exit( EXIT_FAILURE );
    }
    
    unsigned int nPorts = midiin->getPortCount();
    if (DBG) std::cout << "\nThere are " << nPorts << " MIDI input sources available.\n";
    std::string portName;
    unsigned int i;
    for ( i=0; i<nPorts; i++ ) {
        try {
            portName = midiin->getPortName(i);
        }
        catch ( RtError &error ) {
            error.printMessage();
            goto cleanup;
        }
        if (DBG) std::cout << "  Input Port #" << i+1 << ": " << portName << '\n';
        ports.push_back(portName);
    }
    

    
    delete midiin;
    return nPorts;
    
cleanup:
    delete midiin;
    
    return 0;
}

bool getFileInfo(unsigned long &length, unsigned long &sampleRate, const char filePath[]) {
    //Called afer user selects a file.
    //Determines if file is okay to use
    
    
    std::string fileName = filePath;
    
    try {
        FileRead file(fileName);
        if (file.isOpen() ) {
            length = file.fileSize();
            sampleRate = file.fileRate();
            std::cout << "length: " << length << "\n\n";
            file.close();
            return true;
        } else
            return false;
        
    } catch (StkError &) {
        return false;
        
    }
    
}

bool getArrayToDraw(std::vector<float> &array, const char filePath[]) {
    
    std::string fileName = filePath;
    double curPoint;
    
    //if (DBG) std::cout << "getArrayToDraw!\n";
    
    try {
        FileWvIn file(fileName);
        if (file.isOpen() ) {
            while (!file.isFinished()) {
                curPoint = file.tick();
                array.push_back(curPoint);
            }
            return true;
        } else
            return false;
    } catch (StkError &) {
        return false;
    }
    
    
}
