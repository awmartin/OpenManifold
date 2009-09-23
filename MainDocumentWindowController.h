//
//  MainDocumentWindowController.h
//  OpenManifold
//
//  Created by Allan William Martin on 7/29/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#define PARAMETER_SELECT_TAG  100
#define GEOMETRY_SELECT_TAG   101
#define PART_SELECT_TAG       102

#define OUTLINE_SELECT_TAG    2000
#define FILLED_SELECT_TAG     2001

@interface MainDocumentWindowController : NSWindowController {
  id doc;
  IBOutlet NSView* mainView;
  IBOutlet id editModeSelect;
  IBOutlet id renderModeSelect;
}

- (void) setEditingModeSelect:(int)mode;
- (void) setRenderingModeSelect:(int)mode;

- (id) getDocument;

- (void) refreshView;

- (id) getMainView;

- (IBAction) save:(id)sender;

- (IBAction) toggleInspectorPanel:(id)sender;
@end
