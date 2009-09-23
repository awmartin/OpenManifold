//
//  KeyboardReferencePanel.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/6/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "KeyboardReferencePanel.h"
#import "KeyboardReferencePanelController.h"

@implementation KeyboardReferencePanel


- (void) keyDown:(NSEvent*)event
{
  char key = [event.characters characterAtIndex:0];
  
  [panelController handleKeyReference:[NSString stringWithFormat:@"%c",key]];
}


@end
