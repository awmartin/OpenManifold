//
//  Manipulator.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/3/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Parameter.h"

#define TRANSLATE 0
#define ROTATE    1
#define SCALE     2

@interface Manipulator : NSObject {
  BOOL dragging;
  int draggingAxis;
  NSMutableArray *targets;
  
  float x;
  float y;
  float z;
  
  int mode;
}

@property (nonatomic, retain) NSMutableArray* targets;

- (void) setMode:(int)newMode;

- (int) getMode;

- (float) getX;

- (float) getY;

- (float) getZ;

- (void) setPositionX:(float)newX y:(float)newY z:(float)newZ;

/** Resets the manipulator by clearing all targets and moving it to the origin.
 */
- (void) reset;

- (void) clearSelection;

- (void) addTarget:(id)newTarget;

- (void) setTarget:(id)newTarget;

- (int) getDraggingAxis;

/** Updates the position of the manipulator from the target(s) position.
 *  This moves the manipulator to center on the last target if there are multiple
 *  targets.
 */
- (void) update;

- (void) updateX:(float)deltaX;

- (void) updateY:(float)deltaY;

- (void) updateZ:(float)deltaZ;

- (BOOL) isDragging;

- (void) startDrag:(int)axis;

- (void) stopDrag;

- (void) draw:(BOOL)select zoom:(float)zoom;

- (void) drawTranslateManipulator:(BOOL)select zoom:(float)zoom;

- (void) drawRotateManipulator:(BOOL)select zoom:(float)zoom;

- (void) drawScaleManipulator:(BOOL)select zoom:(float)zoom;

/** Helper method to draw a cube for the scale manipulator.
 */
- (void) cube:(float)s;

@end
