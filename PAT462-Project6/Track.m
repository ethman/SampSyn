//
//  Track.m
//  PAT462-Project6
//
//  Created by Ethan Manilow on 4/3/12.
//  Copyright 2012 Ethan Manilow. All rights reserved.
//

#import "Track.h"


@implementation Track
@synthesize fileName = _fileName;
//@synthesize filePath = _filePath;
@synthesize ports = _ports;
@synthesize portNames = _portNames;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//- (void) setPortNames: () portNames {
//    _portNames = [[NSMutableArray alloc] initWithCapacity:_ports];
    
//}

- (void) printName{
    NSLog(@"%@", _fileName);
}

- (NSString *) getFileName {
    return _fileName;
}

- (void)dealloc
{
    [super dealloc];

}

@end
