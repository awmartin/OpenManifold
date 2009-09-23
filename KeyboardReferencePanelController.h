//
//  keyboardReferencePanelController.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/6/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KeyboardReferencePanelController : NSWindowController {
  
  IBOutlet id keyboardReferencePanel;
  IBOutlet id keyboardReferenceText;
  
  NSMutableDictionary *keyDescriptions;
  
}

@property (nonatomic, retain) NSMutableDictionary *keyDescriptions;

- (void) handleKeyReference:(NSString*)key;

- (IBAction) viewKeyboardReference:(id)sender;
- (IBAction) toggleKeyboardReference:(id)sender;

@end
