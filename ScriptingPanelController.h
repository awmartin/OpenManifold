//
//  ScriptingPanelController.h
//  OpenManifold
//
//  Created by Allan William Martin on 7/29/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScriptingPanelController : NSWindowController {
  id doc;
  
  IBOutlet NSTextView *expressionTextView;
  IBOutlet NSTextView *resultTextView;
  
  IBOutlet NSPopUpButton *scriptingLanguageSelect;
  
  IBOutlet id pythonController;
}

- (id) initWithDocument:(id)document;

- (IBAction) togglePanel:(id)sender;
- (void) loadScript:(NSString *)code;
- (IBAction) evaluate:(id)sender;
- (void) addStringToResult:(NSString*)stringToAdd;
- (IBAction) save:(id)sender;

@end
