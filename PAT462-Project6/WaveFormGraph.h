//
//  WaveFormGraph.h
//  PAT462-Project6
//
//  Created by Ethan Manilow on 4/5/12.
//  Copyright 2012 Ethan Manilow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
//#import <OpenGL/OpenGL.h>


@interface WaveFormGraph : NSView {
    //NSImage	* nsImageObj;
    BOOL DrawWave;
    NSMutableArray * WaveFormArray;
    CGFloat rectWidth, rectHeight, max, resolution;
    CGFloat mouseAtX;
    UInt highlight, fLength;
}
//@property (assign) NSImage	* nsImageObj;
@property (assign) BOOL DrawWave;
@property (assign) NSMutableArray * WaveFormArray;
@property (assign) CGFloat mouseAtX, rectWidth;
//@property (assign) CGFloat rectWidth, rectHeight, max;

-(void)calculateWaveForm:(NSMutableArray *)rawData;
-(double)getMouseAtX;
-(double)getRectWidth;
-(void)setHighlight:(int)key;

//-(void)drawWaveFormFromFrequency:(Byte);

//-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
@end
