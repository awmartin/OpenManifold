//
//  Animator.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/9/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Animator : NSObject {
  BOOL running;
}

- (void) setup;

- (void) execute:(id)openmanifold;

- (void) loop:(id)openmanifold;

- (void) start;

- (void) stop;

@end
