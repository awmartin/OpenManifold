//
//  OpenManifoldApplicationController.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/4/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OpenManifoldDocumentController : NSDocumentController {
  IBOutlet id inspectorPanel;
  IBOutlet id inspectorPanelTextView;
  IBOutlet id keyboardReferenceController;
}

- (void) showPreferences:(id)sender;

- (IBAction) toggleInspectorPanel:(id)sender;

- (void) setInspectorText:(NSString*)text;

- (void) toggleKeyboardReferencePanel;

@end
