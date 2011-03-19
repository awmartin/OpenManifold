//
//  MainDocumentWindowController.m
//  OpenManifold
//
//  Created by Allan William Martin on 7/29/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "MainDocumentWindowController.h"
#import "OpenManifoldDocument.h"
#import "OpenManifoldDocumentController.h"

@implementation MainDocumentWindowController

- (id)initWithDocument:(id)document
{
  self = [self initWithWindowNibName:@"OpenManifoldDocument"];
  
  if (self != nil ){
    doc = document;
  }
  
  return self;
}

- (void) setEditingModeSelect:(int)mode
{
  if( mode == PARAMETER )
    [editModeSelect selectSegmentWithTag:PARAMETER_SELECT_TAG];
  if( mode == GEOMETRY )
    [editModeSelect selectSegmentWithTag:GEOMETRY_SELECT_TAG];
  if( mode == PART )
    [editModeSelect selectSegmentWithTag:PART_SELECT_TAG];
  if( mode == MESHPOINT )
    [editModeSelect selectSegmentWithTag:MESHPOINT_SELECT_TAG];
}

- (void) setRenderingModeSelect:(int)mode
{
  if( mode == OUTLINE )
    [renderModeSelect selectSegmentWithTag:OUTLINE_SELECT_TAG];
  
  if( mode == FILLED )
    [renderModeSelect selectSegmentWithTag:FILLED_SELECT_TAG];
}

- (id) getDocument
{
  return doc;
}

- (void) refreshView
{
  [mainView setNeedsDisplay:YES];
}

- (id) getMainView
{
  return mainView;
}

- (IBAction) save:(id)sender
{
  
}

- (IBAction) toggleInspectorPanel:(id)sender
{
  [[OpenManifoldDocumentController sharedDocumentController] toggleInspectorPanel:sender];
}

@end
