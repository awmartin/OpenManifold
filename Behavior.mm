//
//  Behavior.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/10/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "Behavior.h"
#import "Part.h"

@implementation Behavior

@synthesize part;

- (void) setup
{
  
}

- (void) execute
{
  if( running )
    [self loop];
}

- (void) loop
{
  
}

- (void) start
{
  running = YES;
}

- (void) stop
{
  running = NO;
}

@end
