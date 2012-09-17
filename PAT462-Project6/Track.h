//
//  Track.h
//  PAT462-Project6
//
//  Created by Ethan Manilow on 4/3/12.
//  Copyright 2012 Ethan Manilow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"


@interface Track : NSObject {
@private
    
}

@property (assign) NSUInteger ports, currentPort;
@property (assign) NSMutableArray *portNames;
@property (assign) NSString *fileName;
- (void) printName;
- (void) setPortNames;
- (NSString *) getFileName;

@end
