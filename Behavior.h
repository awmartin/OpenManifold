/**
 *
 *  Behavior.h
 *  OpenManifold
 *
 *  Created by Allan William Martin on 8/10/09.
 *  Copyright 2009 Anomalus Design. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

@class Part;

@interface Behavior : NSObject {
  BOOL running;
  
  Part* part;
}


@property (nonatomic, retain) Part* part;

/** Method to override with code run once on initialization.
 *  This method is overriden by the user to set up instance variables, etc., when
 *  defining a new behavior.
 */
- (void) setup;

/** Method to be overridden with code run once every clock tick.
 *  This method is overridden by the user to execute the Behavior's rules. It is
 *  defined when the user is creating a new behavior.
 */
- (void) loop;

/** Private method used by the timer tp execute the Behavior.
 *  This is called once every timer click to check if the behavior is actually
 *  running before sending the loop message explicitly. Do not override this
 *  method.
 */
- (void) execute;

/** Public method to start the behavior's activity.
 *  This makes the Behavior active, so the execute method knows to send the loop
 *  message and thus execute the Behavior. Do not override this method.
 */
- (void) start;

/** Public method to stop the behavior's activity.
 *  This is the opposite of the start method. Just stops the behavior from doing anything.
 *  Do not override this method.
 */
- (void) stop;

@end
