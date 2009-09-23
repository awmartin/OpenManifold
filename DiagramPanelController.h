//
//  DiagramPanelController.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DiagramPanelController : NSWindowController {
  id doc;
}

- (id) initWithDocument:(id) document;

- (id) getDocument;

- (IBAction) togglePanel:(id) sender;

@end
