//
//  MainDocumentView.h
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PerspectiveView.h"

@class MainDocumentWindowController;
@class Manipulator;
@class OpenManifoldDocument;
@class Part;
@class Parameter;


#define X_AXIS    1
#define Y_AXIS    2
#define Z_AXIS    0

@interface MainDocumentView : PerspectiveView {
  IBOutlet MainDocumentWindowController* theController;
  
  Manipulator* mani;
  
  double* clickPos;
  double* maniPos;
  double* dirPos;
  double dragDistance;
}

- (void) setManipulatorTarget:(Parameter *)param;

- (void) calculateDragPath:(int)axis;
- (double) getDeltaDrag;

- (void) updateAllSubViews;

@end
