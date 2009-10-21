//
//  DiagramView.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FlatView.h"

@class DiagramPanelController;
@class OpenManifoldDocument;


@interface DiagramView : FlatView {
  IBOutlet DiagramPanelController* theController;
  
  BOOL dragging;
  int dragTarget;
}

- (void) startDrag:(int) targetPartIndex;;

@end
