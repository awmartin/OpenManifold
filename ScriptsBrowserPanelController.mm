//
//  ScriptsBrowserPanelController.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/4/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "ScriptsBrowserPanelController.h"
#import "ScriptsNodeInfo.h"
#import "ScriptsBrowserCell.h"
#import "OpenManifoldDocument.h"

#define MAX_VISIBLE_COLUMNS 3

@interface ScriptsBrowserPanelController (PrivateUtilities)
- (NSDictionary*)normalFontAttributes;
- (NSDictionary*)boldFontAttributes;
- (NSAttributedString*)attributedInspectorStringForScriptsNode:(ScriptsNodeInfo*)scriptsnode;
@end

@implementation ScriptsBrowserPanelController

- (id) initWithDocument:(id)doc
{
  self = [self initWithWindowNibName:@"ScriptsBrowserPanel"];
  
  if( self != nil ){
    monaco = [NSFont fontWithName:@"Monaco" size:10.0];
    [monaco retain];
    document = doc;
  }
  
  return self;
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
  NSMutableString* title = [[NSMutableString alloc] initWithString:displayName];
  [title appendString:@" (Scripts Library)"];
  return title;
}


- (void)awakeFromNib {
  // Make the browser user our custom browser cell.
  [scriptsBrowser setCellClass: [ScriptsBrowserCell class]];
  
  // Tell the browser to send us messages when it is clicked.
  [scriptsBrowser setTarget:self];
  [scriptsBrowser setAction:@selector(browserSingleClick:)];
  [scriptsBrowser setDoubleAction:@selector(browserDoubleClick:)];
  
  // Configure the number of visible columns (default max visible columns is 1).
  [scriptsBrowser setMaxVisibleColumns:MAX_VISIBLE_COLUMNS];
  [scriptsBrowser setMinColumnWidth:NSWidth([scriptsBrowser bounds])/(CGFloat)MAX_VISIBLE_COLUMNS];
  
  // Drag and drop support
  [scriptsBrowser registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
  [scriptsBrowser setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
  [scriptsBrowser setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
  
  // Prime the browser with an initial load of data.
  [self reloadData:nil];
}


- (IBAction)reloadData:(id)sender {
  [scriptsBrowser loadColumnZero];
}

#pragma mark ** Browser Delegate Methods **

- (ScriptsNodeInfo *)parentNodeInfoForColumn:(NSInteger)column {
  ScriptsNodeInfo *result;
  if (column == 0) {
    if (rootNodeInfo == nil) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSString* rootLibraryPath = [ defaults stringForKey:@"RootLibraryPath" ];
      
      rootNodeInfo = [[ScriptsNodeInfo alloc] initWithParent:nil atRelativePath:rootLibraryPath];
    }
    result = rootNodeInfo;
  } else {
    // Find the selected item leading up to this column and grab its ScriptsNodeInfo stored in that cell
    ScriptsBrowserCell *selectedCell = [scriptsBrowser selectedCellInColumn:column-1];
    result = [selectedCell nodeInfo];
  }
  return result;
}

// Use lazy initialization, since we don't want to touch the file system too much.
- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column {
  ScriptsNodeInfo *parentNodeInfo = [self parentNodeInfoForColumn:column];
  return [[parentNodeInfo subNodes] count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(ScriptsBrowserCell *)cell atRow:(NSInteger)row column:(NSInteger)column {
  // Find our parent ScriptsNodeInfo and access the child at this particular row
  ScriptsNodeInfo *parentNodeInfo = [self parentNodeInfoForColumn:column];
  ScriptsNodeInfo *currentNodeInfo = [[parentNodeInfo subNodes] objectAtIndex:row];
  [cell setNodeInfo:currentNodeInfo];
  [cell loadCellContents];
}

#pragma mark ** Browser Target / Action Methods **

- (IBAction)browserSingleClick:(id)browser {
  // In order to improve performance, we only want to update the preview image if the user pauses for at least a moment on a select node. This allows one to scroll through the nodes at a more acceptable pace. First, we cancel the previous request so we don't get a whole bunch of them queued up.
  [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateCurrentPreviewImage:) object:browser];
  [self performSelector:@selector(updateCurrentPreviewImage:) withObject:browser afterDelay:0.3];    
}

- (void)updateCurrentPreviewImage:(id)browser {
  // Determine the selection and display it's icon and inspector information on the right side of the UI.
  NSImage *inspectorImage = nil;
  NSAttributedString *attributedString = nil;
  NSArray *selectedCells = [browser selectedCells];
  if ([selectedCells count] == 1) {
    // Find the last selected cell and show its information
    ScriptsBrowserCell *lastSelectedCell = [selectedCells objectAtIndex:[selectedCells count] - 1];
    ScriptsNodeInfo *scriptsNode = [lastSelectedCell nodeInfo];
    attributedString = [self attributedInspectorStringForScriptsNode:scriptsNode];
    inspectorImage = [scriptsNode iconImageOfSize:NSMakeSize(128,128)];
  } else if ([selectedCells count] > 1) {
    attributedString = [[NSAttributedString alloc] initWithString: @"Multiple Selection"];
  } else {
    attributedString = [[NSAttributedString alloc] initWithString: @"No Selection"];
  }
  
  [[nodeInspector textStorage] setAttributedString: attributedString];
  //[nodeInspector setAttributedStringValue:attributedString];
  [nodeIconWell setImage:inspectorImage];
}

- (IBAction)browserDoubleClick:(id)browser {
  // Open the file and display it information by calling the single click routine.
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString* rootLibraryPath = [ defaults stringForKey:@"RootLibraryPath" ];
  
  NSString *nodePath = [rootLibraryPath stringByAppendingString: [browser path] ];
  [document openInScriptingPanel:nodePath];
  
  //[self browserSingleClick: browser];
  //[[NSWorkspace sharedWorkspace] openFile: nodePath];
}

#pragma mark ** Dragging Source Methods **

- (BOOL)browser:(NSBrowser *)browser writeRowsWithIndexes:(NSIndexSet *)rowIndexes inColumn:(NSInteger)column toPasteboard:(NSPasteboard *)pasteboard {
  NSInteger i;
  NSMutableArray *filenames = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
  for (i = [rowIndexes firstIndex]; i <= [rowIndexes lastIndex]; i = [rowIndexes indexGreaterThanIndex:i]) {
    ScriptsBrowserCell *cell = [browser loadedCellAtRow:i column:column];
    [filenames addObject:[[cell nodeInfo] absolutePath]];
  }
  [pasteboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:self];
  [pasteboard setPropertyList:filenames forType:NSFilenamesPboardType];
  draggedColumnIndex = column;
  return YES;
}

- (BOOL)browser:(NSBrowser *)browser canDragRowsWithIndexes:(NSIndexSet *)rowIndexes inColumn:(NSInteger)column withEvent:(NSEvent *)event {
  // We will allow dragging any cell -- even disabled ones. By default, NSBrowser will not let you drag a disabled cell
  return YES;
}

- (NSImage *)browser:(NSBrowser *)browser draggingImageForRowsWithIndexes:(NSIndexSet *)rowIndexes inColumn:(NSInteger)column withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset {
  NSImage *result = [browser draggingImageForRowsWithIndexes:rowIndexes inColumn:column withEvent:event offset:dragImageOffset];
  // Create a custom drag image "badge" that displays the number of items being dragged
  if ([rowIndexes count] > 1) {
    NSString *str = [NSString stringWithFormat:@"%ld items being dragged", (long)[rowIndexes count]];
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:NSMakeSize(0.5, 0.5)];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowColor:[NSColor blackColor]];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           shadow, NSShadowAttributeName, 
                           [NSColor whiteColor], NSForegroundColorAttributeName,            
                           nil];
    
    [shadow release];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:str attributes:attrs];
    NSSize stringSize = [countString size];
    NSSize imageSize = [result size];
    imageSize.height += stringSize.height;
    imageSize.width = MAX(stringSize.width + 3, imageSize.width);
    [result setSize:imageSize];
    
    [result lockFocus];
    [countString drawAtPoint:NSMakePoint(0, imageSize.height - stringSize.height)];        
    [result unlockFocus];        
  }
  return result;
}

#pragma mark ** Dragging Destination Methods **

- (NSDragOperation)browser:(NSBrowser *)browser validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger *)row column:(NSInteger *)column  dropOperation:(NSBrowserDropOperation *)dropOperation {
  NSDragOperation result = NSDragOperationNone;
  // We only accept file types, and only accept dropping on it (not between)
  if ((*dropOperation == NSBrowserDropOn) && ([[[info draggingPasteboard] types] indexOfObject:NSFilenamesPboardType] != -1)) {
    // Only allow dropping in folders, but don't allow dragging from the same folder into itself, if we are the source
    if (*column != -1) {
      BOOL droppingFromSameFolder = ([info draggingSource] == browser) && (*column == draggedColumnIndex);
      if (*row != -1) {
        // If we are dropping on a folder, then we will accept the drop at that row
        ScriptsBrowserCell *cell = [browser loadedCellAtRow:*row column:*column];
        if ([[cell nodeInfo] isDirectory]) {
          // Yup, a good drop
          result = NSDragOperationEvery;
        } else {
          // Nope, we can't drop onto a file! We will retarget to the column, if it isn't the same folder.
          if (!droppingFromSameFolder) {
            result = NSDragOperationEvery;
            *row = -1;
            *dropOperation = NSBrowserDropOn;
          }
        }
      } else if (!droppingFromSameFolder) {
        result = NSDragOperationEvery;
        *row = -1;
        *dropOperation = NSBrowserDropOn;
      }
    }
  }
  return result;
  
}

- (BOOL)browser:(NSBrowser *)browser acceptDrop:(id <NSDraggingInfo>)info atRow:(NSInteger)row column:(NSInteger)column dropOperation:(NSBrowserDropOperation)dropOperation {
  NSArray *filenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
  // Find the target folder
  ScriptsNodeInfo *targetNodeInfo = nil;
  if ((column != -1) && (filenames != nil)) {
    if (row != -1) {
      ScriptsBrowserCell *cell = [browser loadedCellAtRow:row column:column];
      if ([[cell nodeInfo] isDirectory]) {
        targetNodeInfo  = [cell nodeInfo];
      }
    } else {
      if (column > 0) {
        // Grab the column before us, since we will be dropping in that folder
        ScriptsBrowserCell *cell = [browser selectedCellInColumn:column - 1];
        if ([[cell nodeInfo] isDirectory]) {
          targetNodeInfo = [cell nodeInfo];
        }
      } else {
        // We are dropping in the first folder, which is the root folder on the system.
        targetNodeInfo = rootNodeInfo;
        column = 0;
      }
    }
  }
  
  // We now have the target folder, so move things around    
  if (targetNodeInfo != nil) {
    NSString *targetFolder = [targetNodeInfo absolutePath];
    NSMutableString *prettyNames = nil;
    NSInteger i;
    // Create a display name of all the selected filenames that are moving
    for (i = 0; i < [filenames count]; i++) {
      NSString *filename = [[NSFileManager defaultManager] displayNameAtPath:[filenames objectAtIndex:i]];
      if (prettyNames == nil) {
        prettyNames = [filename mutableCopy];                
      } else {
        [prettyNames appendString:@", "];
        [prettyNames appendString:filename];
      }
    }
    // Ask the user if they really want to move thos files.
    if ([[NSAlert alertWithMessageText:@"Verify file move" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"Would you like to move '%@' to '%@'?", prettyNames, targetFolder] runModal] == NSAlertDefaultReturn) {
      // Do the actual moving of the files.
      for (i = 0; i < [filenames count]; i++) {
        NSString *filename = [filenames objectAtIndex:i];
        NSString *targetPath = [targetFolder stringByAppendingPathComponent:[filename lastPathComponent]];
        // Normally, you should check the result of movePath to see if it worked or not.
        [[NSFileManager defaultManager] movePath:filename toPath:targetPath handler:nil];
      }
      
      // We now need to reload our cached objects that have the source or destination directory. For simplicity, we will just walk each cell in the matrix, and drop everything. 
      for (i = 0; i <= [browser lastColumn]; i++) {
        NSInteger j;
        NSMatrix *matrix = [browser matrixInColumn:i];
        NSArray *cells = [matrix cells];
        for (j = 0; j < [cells count]; j++) {
          id cell = [cells objectAtIndex:j];
          // We may have lazily loaded cells -- by checking the class, we can prevent loading too much data.
          if ([cell isKindOfClass:[ScriptsBrowserCell class]]) {
            [[cell nodeInfo] invalidateChildren];
          }
        }
      }
      
      // Now that the cache has been invalidated, we need to reload the current columns
      if ([info draggingSource] == browser) {
        [browser reloadColumn:draggedColumnIndex];
      }
      [browser reloadColumn:column];
      // If we dropped on the selected row in the target column, then we have to reload the next column too
      if ((row != -1) && (column < [browser lastColumn])) {
        if ([browser loadedCellAtRow:row column:column] == [browser selectedCellInColumn:column]) {
          [browser reloadColumn:column + 1];
        }
      }
    }
    return YES;
  }
  return NO;
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


- (IBAction)evaluate:(id)sender
{
  // do nothing. this must be deleted. there must be a more direct way to link
  // the evaluate message to the scripting window then by using 'first responder'.
}

- (void)dealloc {
  [rootNodeInfo release];
  [monaco release];
  [super dealloc];
}



@end


@implementation ScriptsBrowserPanelController(PrivateUtilities)

- (NSDictionary *)normalFontAttributes {
  //return [NSDictionary dictionaryWithObject:[NSFont systemFontOfSize:[NSFont systemFontSize]] forKey:NSFontAttributeName];
  return [NSDictionary dictionaryWithObject:monaco forKey:NSFontAttributeName];
}

- (NSDictionary *)boldFontAttributes {
  //return [NSDictionary dictionaryWithObject:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]] forKey:NSFontAttributeName];
  return [NSDictionary dictionaryWithObject:[NSFont boldSystemFontOfSize:10] forKey:NSFontAttributeName];
}

- (NSAttributedString *)attributedInspectorStringForScriptsNode:(ScriptsNodeInfo*)scriptnode {
  
  NSMutableAttributedString *attrString = [[[NSMutableAttributedString alloc] initWithString:@"" attributes:[self normalFontAttributes]] autorelease];
  
  if( [[scriptnode fsType] isEqualToString:@"Non-Directory" ] ){
    NSString *path = [scriptnode absolutePath];
    NSError *error;
    NSString *stringFromFileAtPath = [[NSString alloc]
                                      initWithContentsOfFile:path
                                      encoding:NSUTF8StringEncoding
                                      error:&error];
    
    if ( stringFromFileAtPath == nil) {
      // an error occurred
      NSLog(@"Error reading file at %@\n%@",
            path, [error localizedFailureReason]);
      [attrString appendAttributedString:  [[[NSMutableAttributedString alloc] initWithString:@"Oops." attributes:[self normalFontAttributes]] autorelease]];
    } else {
      [attrString appendAttributedString:  [[[NSMutableAttributedString alloc] initWithString:stringFromFileAtPath attributes:[self normalFontAttributes]] autorelease]];
    }
    
  } else {

    /*[attrString appendAttributedString: [[[NSMutableAttributedString alloc] initWithString:@"Name: " attributes:[self boldFontAttributes]] autorelease]];
    [attrString appendAttributedString: [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@\n", [scriptnode lastPathComponent]] attributes:[self normalFontAttributes]] autorelease]];
    [attrString appendAttributedString: [[[NSAttributedString alloc] initWithString:@"Type: " attributes:[self boldFontAttributes]] autorelease]];
    [attrString appendAttributedString: [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@\n", [scriptnode fsType]] attributes:[self normalFontAttributes]] autorelease]];*/
  }
  
  return attrString;
}

@end