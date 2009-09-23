//
//  ScriptsBrowserPanelController.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/4/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ScriptsNodeInfo;

@interface ScriptsBrowserPanelController : NSWindowController {
  IBOutlet NSBrowser* scriptsBrowser;
  IBOutlet NSImageView  *nodeIconWell;  // Image well showing the selected items icon.
  IBOutlet NSTextView  *nodeInspector; // Text field showing the selected items attributes.
  ScriptsNodeInfo *rootNodeInfo;
  NSInteger draggedColumnIndex;
  NSFont *monaco;
  id document;
}

- (id) initWithDocument:(id)doc;

// Force a reload of column zero and thus, all the data.
- (IBAction)reloadData:(id)sender;

// Methods sent by the browser to us from theBrowser.
- (IBAction)browserSingleClick:(id)sender;
- (IBAction)browserDoubleClick:(id)sender;

- (IBAction)togglePanel:(id)sender;
- (IBAction)evaluate:(id)sender;
@end
