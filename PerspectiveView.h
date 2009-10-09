//
//  PerspectiveView.h
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjectView.h"

#define PI 3.14159265358979


@interface PerspectiveView : ObjectView {  
  float rotationAngleX;
  float rotationAngleY;
  float originX;
  float originY;
  float originZ;
  float zoomFactor;
  float distanceToTarget;
  float eyeX, eyeY, eyeZ;
  double startBoxSelectX;
  double startBoxSelectY;
}

- (id) initWithFrame:(NSRect)frameRect;

- (void) setFixedLights;
- (void) setHeadlight;
- (void) setupEnvironment;

- (void) zoom;
- (void) pan;
- (void) orbit;

- (void) point:(float)x yPos:(float)y zPos:(float)z;
- (void) cube:(float)s;
- (void) axes;
- (void) grid;

- (void) updateEyePosition;

@end
