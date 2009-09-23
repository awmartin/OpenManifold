//
//  DiagramPanelController.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "DiagramPanelController.h"


@implementation DiagramPanelController

- (id)initWithDocument:(id)document
{
  self = [self initWithWindowNibName:@"DiagramPanel"];
  
  if( self != nil ){
    doc = document;
  }
  
  return self;
}


- (id) getDocument
{
  return doc;
}


- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
  NSMutableString* title = [[NSMutableString alloc] initWithString:displayName];
  [title appendString:@" (Diagram Panel)"];
  return title;
}


- (IBAction)togglePanel:(id)sender
{
  NSWindow* window = [self window];
  
  if ([window isVisible])
  {
    [window orderOut:sender];
  }
  else
  {
    [window orderFront:sender];
  }
}


@end
