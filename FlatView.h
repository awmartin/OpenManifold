//
//  FlatView.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/4/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjectView.h"


@interface FlatView : ObjectView {
  float originX;
  float originY;
  float zoom;
  float scaleFactor;
}

- (id) initWithFrame:(NSRect)frameRect;
- (void) setupEnvironment;
- (void) grid;

@end
