//
//  Animator.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/9/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "Animator.h"


@implementation Animator

- (void) setup
{

}

- (void) execute:(id)openmanifold
{
  if( running )
    [self loop:openmanifold];
}

- (void) loop:(id)openmanifold
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
