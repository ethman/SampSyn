//
//  WaveFormGraph.m
//  PAT462-Project6
//
//  Created by Ethan Manilow on 4/5/12.
//  Copyright 2012 Ethan Manilow. All rights reserved.
//
//#import <OpenGL/OpenGL.h>

#import "WaveFormGraph.h"


@implementation WaveFormGraph


//@synthesize nsImageObj;
@synthesize DrawWave;
@synthesize WaveFormArray;
@synthesize mouseAtX, rectWidth;
//@synthesize rectHeight, rectWidth, max;
//@synthesize resolution;

- (id)initWithFrame:(NSRect)frame {
    if (! (self = [super initWithFrame:frame] ) ) {
		NSLog(@"Error: MyNSView initWithFrame");
        return self;
    } // end if
	    
    resolution = 7.0;
    rectHeight = frame.size.height;
    rectWidth = frame.size.width;
    self.mouseAtX = 0.0;
    highlight = -1.0;
    return self;
}  // end initWithFrame


- (void)drawRect:(NSRect)dirtyRect {
	if (!self.DrawWave) {		
		[[NSColor blackColor] set];
		NSRectFill( dirtyRect );
        NSLog(@"NO");
        //self.rectWidth = dirtyRect.size.width;
        //self.rectHeight = dirtyRect.size.height;
        
        return;
	} // end if
	//NSRect zOurBounds = [self bounds];
    
    [super drawRect:dirtyRect];
    //NSLog(@"width: %f", dirtyRect.size.width);
    
    NSGraphicsContext	*	tvarNSGraphicsContext	= [NSGraphicsContext currentContext];
	CGContextRef			tvarCGContextRef		= (CGContextRef) [tvarNSGraphicsContext graphicsPort];
    
    
    CGRect background = CGRectMake(dirtyRect.origin.x, dirtyRect.origin.y,
                                   dirtyRect.size.width, dirtyRect.size.height);
    
    CGContextSetRGBFillColor(tvarCGContextRef, 0.0, 0.0, 0.0, 1.0);
    CGContextFillRect(tvarCGContextRef, background);
    
    //NSLog(@"width: %f, height: %f", rectWidth, rectHeight);
    
    //NSNumber * temp;
    CGFloat height;
    
    NSUInteger i;
    for ( i=0; i < [WaveFormArray count]; i++ ) {
        height = [[WaveFormArray objectAtIndex:i] floatValue];
        
        if (mouseAtX == 0.0) {
            //Draw waveform initially
            
            if (highlight != -1.0 && i > mouseAtX*resolution && i <= highlight + mouseAtX*resolution ) 
                CGContextSetRGBStrokeColor(tvarCGContextRef, 1.0, 1.0,  1.0, 1.0);
            else
                CGContextSetRGBStrokeColor(tvarCGContextRef, 
                                           i/rectWidth/resolution, 0.3, 
                                           1.0 - i/rectWidth/resolution, 1.0);
            
            CGContextSetLineWidth(tvarCGContextRef, 1.0/resolution);
            
            CGContextBeginPath(tvarCGContextRef);
            CGContextMoveToPoint(tvarCGContextRef,i/resolution,rectHeight/2);
            CGContextAddLineToPoint(tvarCGContextRef, i/resolution, rectHeight/2 + height*rectHeight/max/2);
            CGContextStrokePath(tvarCGContextRef);
            
            CGContextBeginPath(tvarCGContextRef);
            CGContextMoveToPoint(tvarCGContextRef,i/resolution,rectHeight/2);
            CGContextAddLineToPoint(tvarCGContextRef, i/resolution, rectHeight/2 - height*rectHeight/max/2);
            CGContextStrokePath(tvarCGContextRef);
            
            if (highlight != -1.0 && i > mouseAtX*resolution && i <= highlight + mouseAtX*resolution ) 
                CGContextSetRGBStrokeColor(tvarCGContextRef, 1.0, 1.0,  1.0, 1.0);
            
            
            
        } else if ( i == mouseAtX*resolution ) {
            //Set Cursor posistion
            CGContextSetRGBStrokeColor(tvarCGContextRef, 1.0, 1.0, 1.0, 1.0);
            CGContextSetLineWidth(tvarCGContextRef, 1.0);
            
            
            CGContextBeginPath(tvarCGContextRef);
            CGContextMoveToPoint(tvarCGContextRef,i/resolution,0.0);
            CGContextAddLineToPoint(tvarCGContextRef, i/resolution, rectHeight);
            CGContextStrokePath(tvarCGContextRef);
            
        } else if (highlight != -1.0 && i > mouseAtX*resolution && i <= highlight + mouseAtX*resolution ) {
            //Highlight the region being played
            
            CGContextSetRGBStrokeColor(tvarCGContextRef, 1.0, 1.0, 1.0, 1.0);
            CGContextSetLineWidth(tvarCGContextRef, 1.0/resolution);
            
            CGContextBeginPath(tvarCGContextRef);
            CGContextMoveToPoint(tvarCGContextRef,i/resolution,rectHeight/2);
            CGContextAddLineToPoint(tvarCGContextRef, i/resolution, rectHeight/2 + height*rectHeight/max/2);
            CGContextStrokePath(tvarCGContextRef);
            
            CGContextBeginPath(tvarCGContextRef);
            CGContextMoveToPoint(tvarCGContextRef,i/resolution,rectHeight/2);
            CGContextAddLineToPoint(tvarCGContextRef, i/resolution, rectHeight/2 - height*rectHeight/max/2);
            CGContextStrokePath(tvarCGContextRef);
        
        } else {
            //Draw the rest of the wave form (other than cursor or highlighting)
            CGContextSetRGBStrokeColor(tvarCGContextRef, 
                                       i/rectWidth/resolution, 0.3, 
                                       1.0 - i/rectWidth/resolution, 1.0);
            CGContextSetLineWidth(tvarCGContextRef, 1.0/resolution);
            
            CGContextBeginPath(tvarCGContextRef);
            //CGContextMoveToPoint(tvarCGContextRef,i/resolution,(rectHeight/1)*height/max);
            CGContextMoveToPoint(tvarCGContextRef,i/resolution,rectHeight/2);
            CGContextAddLineToPoint(tvarCGContextRef, i/resolution, rectHeight/2 + height*rectHeight/max/2);
            CGContextStrokePath(tvarCGContextRef);
            
            CGContextBeginPath(tvarCGContextRef);
            CGContextMoveToPoint(tvarCGContextRef,i/resolution,rectHeight/2);
            CGContextAddLineToPoint(tvarCGContextRef, i/resolution, rectHeight/2 - height*rectHeight/max/2);
            CGContextStrokePath(tvarCGContextRef);
            
        }
        
        CGContextDrawPath(tvarCGContextRef,kCGPathStroke);
    }
    //NSLog(@"drawRect=%f",highlight + mouseAtX*resolution );
    //NSLog(@"HERE!");
    
} // end drawRect

-(void)calculateWaveForm:(NSMutableArray *) rawData{
    WaveFormArray = [[NSMutableArray alloc] init];
    CGFloat avg = 0.0;
    max = 0.0;
    fLength = [rawData count];
    NSUInteger binSize = ceil(fLength  / (rectWidth * resolution)); //try floor too
    NSNumber * temp;

    
    for (NSUInteger i=0; i < [rawData count]; i++) {
        avg += fabsf([[rawData objectAtIndex:i] floatValue]);
        
        if (i % binSize == 0) {
            avg /= binSize;
            temp = [NSNumber numberWithFloat:avg];
            [WaveFormArray addObject:temp];
            if (avg >= max) max = avg;
            avg = 0.0;
        }
        
        
    }
    
    //max *= 0.9;
    
    //NSLog(@"WaveFormArray=%lu",[WaveFormArray count]);
}

-(void)mouseDown:(NSEvent *)theEvent {
    NSPoint tvarMousePointInWindow	= [theEvent locationInWindow];
	NSPoint tvarMousePointInView	= [self convertPoint:tvarMousePointInWindow fromView:nil];
    
    //NSLog(@"click:View=%f",tvarMousePointInView.x );
        
    self.mouseAtX = tvarMousePointInView.x;
    [self setNeedsDisplay:YES];
    
}


-(void)mouseDragged:(NSEvent *)theEvent {
    
	NSPoint tvarMousePointInWindow	= [theEvent locationInWindow];
	NSPoint tvarMousePointInView	= [self convertPoint:tvarMousePointInWindow fromView:nil];
	

    if (tvarMousePointInView.x >= 0 && tvarMousePointInView.x <= rectWidth) {
        //NSLog(@"drag :View=%f",tvarMousePointInView.x );
        self.mouseAtX = tvarMousePointInView.x;
        [self setNeedsDisplay:YES];
    }
	
} // end mouseDragged

-(double)getMouseAtX {
    return (double) mouseAtX;
}

-(double)getRectWidth {
    return (double)rectWidth;
}

-(void)setHighlight:(int)numSamples {
    highlight = (double)numSamples/(double)fLength * rectWidth * resolution;
    //NSLog(@"numSamples=%i, fLength=%ul, highlight=%ul", numSamples, fLength, highlight);
}

@end
