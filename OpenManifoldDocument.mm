//
//  OpenManifoldDocument.m
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright Anomalus Design 2009 . All rights reserved.
//

#import "OpenManifoldDocument.h"
#import "Part.h"
#import "ScriptingPanelController.h"
#import "MainDocumentWindowController.h"
#import "ScriptsBrowserPanelController.h"
#import "OpenManifoldDocumentController.h"
#import "DiagramPanelController.h"
#import "Rule.h"
#import "Animator.h"


#import "Growl/Growl.h"

#ifdef RUBY
#import <MacRuby/MacRuby.h>
#endif

@implementation OpenManifoldDocument

@synthesize parts;
@synthesize rules;
@synthesize animators;
@synthesize dirtyNodeList;

- (id)init
{
  self = [super init];
  if (self != nil) {
    // If an error occurs here, send a [self release] message and return nil.
    wrap = new ON_Wrapper();
    
    parts = [NSMutableArray array];
    [parts retain];
    
    rules = [NSMutableArray array];
    [rules retain];
    
    animators = [NSMutableArray array];
    [animators retain];
    
    dirtyNodeList = [NSMutableArray array];
    [dirtyNodeList retain];
    
    editingMode = PARAMETER;
    renderingMode = OUTLINE;
    
    /* Set up the timer. */
    timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f/100.0f) target:self selector:@selector(animate) 
                                           userInfo:nil repeats:YES];
    [timer retain];
    
    [[NSRunLoop currentRunLoop] addTimer: timer forMode: NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer: timer forMode: NSEventTrackingRunLoopMode];
  }
  return self;
}


- (void) makeWindowControllers
{
  // The first window added is considered the primary document window. e.g. where the save dialog appears.
  wc = [[MainDocumentWindowController alloc] initWithDocument:self];
  [wc setShouldCloseDocument:YES];
  [self addWindowController:wc];
  
  scriptsBrowserPanel = [[ScriptsBrowserPanelController alloc] initWithDocument:self];
  [self addWindowController:scriptsBrowserPanel];
  [(NSPanel*)[scriptsBrowserPanel window] setFloatingPanel:NO];
  
  scriptingPanel = [[ScriptingPanelController alloc] initWithDocument:self];
  [self addWindowController:scriptingPanel];
  [(NSPanel*)[scriptingPanel window] setFloatingPanel:NO];
  
  diagramPanel = [[DiagramPanelController alloc] initWithDocument:self];
  [self addWindowController:diagramPanel];
  [(NSPanel*)[diagramPanel window] setFloatingPanel:NO];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
  [super windowControllerDidLoadNib:aController];
  // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

/*- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

  if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}*/

- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)type {
  
  // Create the root node.
  NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"openmanifold"];
  
  // Set up the document, etc.
  NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
  [xmlDoc setVersion:@"1.0"];
  [xmlDoc setCharacterEncoding:@"UTF-8"];
  
  // Start adding data.
  [root addChild:[NSXMLNode commentWithStringValue:@"Hello world!"]];
  
  // Add all the parts.
  NSXMLElement* partsTree = [NSXMLElement elementWithName:@"parts"];
  [root addChild:partsTree];
  
  for( int i=0;i<[parts count];i++ ){
    // Get this part.
    Part* part = [parts objectAtIndex:i];
    
    // Start the tree for the part.
    NSXMLElement* partXML = [NSXMLElement elementWithName:@"part"];
    [partsTree addChild:partXML];
    
    // Set the table index.
    [partXML addAttribute:[NSXMLNode attributeWithName:@"index" stringValue:[NSString stringWithFormat:@"%d",i]]];
    
    // Start the parameters tree.
    NSXMLElement* parametersXML = [NSXMLElement elementWithName:@"parameters"];
    [partXML addChild:parametersXML];
    
    // Add all the parameters.
    for( int j=0;j<[part.parameters count];j++ ){
      // Get the parameter from the array.
      Parameter* param = [part.parameters objectAtIndex:j];
      
      // Start the parameter's tree.
      NSXMLElement* parameterXML = [NSXMLElement elementWithName:@"parameter"];
      [parametersXML addChild:parameterXML];
      
      // Set the parameter's index.
      [parameterXML addAttribute:[NSXMLNode attributeWithName:@"index" stringValue:[NSString stringWithFormat:@"%d",j]]];
      
      // Start the values tree.
      NSXMLElement* valuesXML = [NSXMLElement elementWithName:@"values"];
      [parameterXML addChild:valuesXML];
      
      // Get all the value keys.
      NSArray* keys = [param.values allKeys];
      // Build the values list.
      for( int k=0;k<[param.values count];k++ ){
        
        NSString* key = [keys objectAtIndex:k];
        // Get the value for this key.
        id value = [param.values objectForKey:key];
        
        // Add the value to the values list.
        NSXMLElement* valueXML = [NSXMLElement elementWithName:@"value"];
        [valuesXML addChild:valueXML];
        
        // Set the name of the value.
        [valueXML addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:key]];
        
        // Set the value itself. There are different types. Most of them are numbers.
        if( [value isKindOfClass:[NSNumber class]] ){
          [valueXML addAttribute:[NSXMLNode attributeWithName:@"val" stringValue:[value stringValue]]];
          [valueXML addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"number"]];
        }
      }
      
      // Start the linkages tree.
      NSXMLElement* linkagesXML = [NSXMLElement elementWithName:@"linkages"];
      [parameterXML addChild:linkagesXML];
      
      // Loop through all the linkages.
      for( int m=0;m<[param.linkages count];m++ ){
        
      }
    }
    
    // Start the geometry tree.
    NSXMLElement* geometryXML = [NSXMLElement elementWithName:@"geometry"];
    [partXML addChild:geometryXML];
    
    // Surfaces
    
    
    // Curves
    
    
  }
  
  // Create an NSData object and write it out.
  NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
  if (![xmlData writeToFile:fileName atomically:YES]) {
    NSBeep();
    NSLog(@"Could not write document out...");
    return NO;
  }
  return YES;
}

/*
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
  
 // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
 
 // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
  
 // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
 
  if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
  return YES;
}*/

- (BOOL)readFromURL:(NSURL*)absoluteURL ofType:(NSString *)typeName error:(NSError**)outError
{
  // Create a new part and load the model.
  printf("You just tried to load %s.", [[absoluteURL absoluteString] UTF8String]);
  
  if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
  return YES;
  
}


#pragma mark -
#pragma mark Import/Export Functions

- (IBAction) export:(id)sender
{
  int result;
  NSArray *fileTypes = [NSArray arrayWithObject:@"3dm"];
  NSSavePanel *sPanel = [NSSavePanel savePanel];
  [sPanel setAllowedFileTypes:fileTypes];

  result = [sPanel runModalForDirectory:NSHomeDirectory() file:nil];

  if (result == NSOKButton) {
    NSString *aFile = [sPanel filename];

    wrap->save( [aFile UTF8String] );
  }
}


- (void) openInScriptingPanel:(NSString *)path
{
  NSError *error;
  NSString *stringFromFileAtPath = [[NSString alloc]
                                    initWithContentsOfFile:path
                                    encoding:NSUTF8StringEncoding
                                    error:&error];
  
  if ( stringFromFileAtPath == nil) {
    // an error occurred
    NSLog(@"Error reading file at %@\n%@", path, [error localizedFailureReason]);
  } else {
    [scriptingPanel loadScript:stringFromFileAtPath];
  }
  
  [[scriptingPanel window] makeKeyAndOrderFront:nil];
  
}

/* This method will eventually import a 3dm file and create the appropriate
 Part object to contain it. This will be for components modeled externally, etc. */
 - (void)import:(id)sender
 {
 /*int result;
 NSArray *fileTypes = [NSArray arrayWithObject:@"3dm"];
 NSOpenPanel *oPanel = [NSOpenPanel openPanel];
 
 [oPanel setAllowsMultipleSelection:YES];
 result = [oPanel runModalForDirectory:NSHomeDirectory()
 file:nil types:fileTypes];
   
 if (result == NSOKButton) {
   NSArray *filesToOpen = [oPanel filenames];
   int i, count = [filesToOpen count];
   
   for (i=0; i<count; i++) {
     NSString *aFile = [filesToOpen objectAtIndex:i];
     
     //wrap->load( [aFile UTF8String] );
     
     [self setNeedsDisplay:YES];
     }
   }*/
 }

#pragma mark -
#pragma mark Parametric Graph/Rule Handling

- (void) updateGraph
{
  // Start the queue with all the dirty nodes.
  NSMutableArray* queue = [self getAllDirtyNodes];
  if( [queue count] == 0 ) return;
  
  while( [queue count] > 0 ){
    
    id node = [queue objectAtIndex:0];
    
    if( [[node rules] count] > 0 ){
      
      // Get only the unexecuted rules.
      NSMutableArray* nodeRules = [node getUnexecutedRules];
      
      for( int i=0; i<[nodeRules count]; i++ ){
        id thisRule = [nodeRules objectAtIndex:i];
        
        // Apply the rule. This makes the rule 'executed' or 'done'.
        [thisRule applyRule];
        
        // Gather the other node(s), put it(them) on the queue.
        [queue addObjectsFromArray:[ thisRule getOtherParameters:node ] ];
      }
    }
    
    // Remove node at 0 from the queue, since we're done.
    [queue removeObjectAtIndex:0];
  }

  // Reset all the rules.
  [rules makeObjectsPerformSelector:@selector(reset)];
}

- (NSMutableArray*) getAllDirtyNodes
{
  NSMutableArray* params = [NSMutableArray array];
  
  for( int i=0; i<[parts count]; i++ )
    [ params addObjectsFromArray:[[parts objectAtIndex:i] getAllDirtyParameters] ];
  
  return params;
}

#pragma mark -
#pragma mark Drawing Methods

- (void) draw:(BOOL)select zoom:(float)zoom
{
  if( select ) glPushName(PARAMETER);
  
  for( int i=0;i<[parts count];i++ ){
    if( select ) glPushName(i);
    
    [[parts objectAtIndex:i] draw:select zoom:zoom];
    
    if( select ) glPopName();
  }
  
  if( select ) glPopName();
  
  if( editingMode != PART ){
    for( int i=0;i<[rules count];i++ ){
      [[rules objectAtIndex:i] drawRule];
    }
  }
  
  wrap->drawModel();
}


- (void) drawDiagram:(BOOL)select
{
  if( select ) glPushName(DIAGRAM_PART);
  
  for( int i=0;i<[parts count];i++ ){
    if( select ) glPushName(i);
    
    [[parts objectAtIndex:i] drawDiagram:select];
    
    if( select ) glPopName();
  }
  
  if( select ) glPopName();
  
  
  if( select ) glPushName(DIAGRAM_RULE);
  
  for( int i=0;i<[rules count];i++ ){
    if( select ) glPushName(i);
    
    [[rules objectAtIndex:i] drawDiagram];
    
    if( select ) glPopName();
  }
  
  if( select ) glPopName();
}

- (void) dragPartInDiagram: (int)partIndex dx:(float)dx dy:(float)dy
{
  [[parts objectAtIndex:partIndex] dragInDiagram:dx dy:dy];
}


- (void) refreshView
{
  wrap->refreshModel();
}


 - (void) build
{
  wrap->build();
}

- (void) refreshMainWindow
{
  [[wc window] makeKeyAndOrderFront:nil];
  [wc refreshView];
}

#pragma mark -
#pragma mark Selection Methods

- (void) addToSelection:(int)globalObjectIndex
{
  int i;
  if( editingMode == GEOMETRY )
    for( i=0;i<[parts count];i++ )
      [[parts objectAtIndex:i] selectGeometry:globalObjectIndex];
  
  if( editingMode == PART ){
    for( i=0;i<[parts count];i++ )
      [[parts objectAtIndex:i] selectPartContaining:globalObjectIndex];
    
    NSArray* selectedParts = [self getSelectedParts];
    
    if( [selectedParts count] > 0 ){
      NSString* inspectorText = [NSString stringWithFormat:@"Number of selected parts: %d", [selectedParts count]];
      [[NSDocumentController sharedDocumentController] setInspectorText:inspectorText];
    }
  }
}


- (void) unselectAll
{
  int i;
  for( i=0;i<[parts count];i++ )
    [[parts objectAtIndex:i] unselect];
}


- (id) addPart
{
  Part* el = [[Part alloc] initWithWrapper:wrap forDocument:self];
  [self.parts addObject:el];
  wrap->refreshModel();
  
  [GrowlApplicationBridge
    notifyWithTitle:@"Part added."
    description:@"A new part was added to the document."
    notificationName:@"Part Added"
   iconData:nil
   priority:nil
   isSticky:nil
   clickContext:nil];
  
  return el;
}

- (NSMutableArray*) getSelectedParts
{
  int i, count;
  count = [parts count];
  
  NSMutableArray* result = [NSMutableArray array];
  
  for( i=0;i<count;i++ ){
    if( [[parts objectAtIndex:i] isSelected] ){
      [result addObject:[parts objectAtIndex:i]];
    }
  }
  
  return result;
}

- (NSMutableArray *) getSelectedParameters
{
  NSMutableArray* params = [NSMutableArray array];
  
  for( int i=0; i<[parts count]; i++ )
    [params addObjectsFromArray:[[parts objectAtIndex:i] getSelectedParameters]];
  
  return params;
}


#pragma mark -
#pragma mark Editing and Display Modes


- (void) setEditingMode:(int)newMode
{
  editingMode = newMode;
}

- (int) getEditingMode
{
  return editingMode;
}


- (IBAction) displayModeFill:(id)sender
{
  if( [sender isKindOfClass:[NSMenuItem class]] )
     [wc setRenderingModeSelect:FILLED];

  wrap->displayModeFill();
  [wc refreshView];
}

- (IBAction) displayModeOutline:(id)sender
{
  if( [sender isKindOfClass:[NSMenuItem class]] )
    [wc setRenderingModeSelect:OUTLINE];
  
  wrap->displayModeOutline();
  [wc refreshView];
}


- (IBAction) pickEditingMode:(id)sender
{
  NSInteger segment = [sender selectedSegment];
  if( segment == 0 ){
    [self setEditingMode:PARAMETER];
    [wc refreshView];
  }
  if( segment == 1 ){
    [self setEditingMode:GEOMETRY];
    [wc refreshView];
  }
  if( segment == 2 ){
    [self setEditingMode:PART];
    [wc refreshView];
  }
}

- (IBAction) pickRenderingMode:(id)sender
{
  NSInteger segment = [sender selectedSegment];
  if( segment == 0 ){
    renderingMode = OUTLINE;
    [self displayModeOutline:sender];
  }
  if( segment == 1 ){
    renderingMode = FILLED;
    [self displayModeFill:sender];
  }
}


#pragma mark -
#pragma mark Window Handling

- (IBAction) toggleScriptingPanel:(id)sender
{
  [scriptingPanel togglePanel:sender];
}

- (IBAction) toggleScriptsBrowserPanel:(id)sender
{
  [scriptsBrowserPanel togglePanel:sender];
}

- (IBAction) toggleDiagramPanel:(id)sender
{
  [diagramPanel togglePanel:sender];
}

- (IBAction) toggleFloating:(id)sender
{
  [(NSPanel*)[scriptingPanel window] setFloatingPanel: ![[scriptingPanel window] isFloatingPanel]];
  [(NSPanel*)[scriptsBrowserPanel window] setFloatingPanel: ![[scriptsBrowserPanel window] isFloatingPanel]];
  [(NSPanel*)[diagramPanel window] setFloatingPanel: ![[diagramPanel window] isFloatingPanel]];
  
  // If the panels aren't floating, make the main window come up front.
  if( ![[diagramPanel window] isFloatingPanel] )
    [[wc window] makeKeyAndOrderFront:sender];
}

- (IBAction) showPreferences:(id)sender
{
  [[OpenManifoldDocumentController sharedDocumentController] showPreferences:sender];
}

- (IBAction) toggleInspectorPanel:(id)sender
{
  [[OpenManifoldDocumentController sharedDocumentController] toggleInspectorPanel:sender];
}


#pragma mark -
#pragma mark Ruby Script Evaluation


- (void) animate
{
  int count = [animators count];
  for( int i=0; i<[parts count]; i++ )
    count += [[[parts objectAtIndex:i] behaviors] count];
  
  if( count>0 ){
    for( int i=0; i<[animators count]; i++ )
      [[animators objectAtIndex:i] execute:self];

    [parts makeObjectsPerformSelector:@selector(behave)];
    
    [self refreshView];
    [wc refreshView];
  }
}

- (void) addAnimator:(id)anim
{
  [anim setup];
  [animators addObject:anim];
}


- (IBAction) evaluate:(id)sender
{
  [scriptingPanel evaluate:sender];
}

- (NSString*)evaluateRuby:(NSString*)stringToEvaluate
{
#ifdef RUBY
  @try {
    NSString* completeString = [NSString stringWithFormat:@"proc do |x|\n @openmanifold = x\n %@\n end", stringToEvaluate];
    
    id object = [[MacRuby sharedRuntime] evaluateString:completeString];

    id output = [object performRubySelector:@selector(call:) withArguments:self,nil];
    
    wrap->refreshModel();
    [self refreshMainWindow];
    
    return [output description];
  }
  @catch (NSException *exception) {
    NSString *string = [NSString stringWithFormat:@"%@: %@\n%@", [exception name], [exception reason], 
                        [[[exception userInfo] objectForKey:@"backtrace"] description]];
    return string;
  }
#endif
  return @"";
}

- (id) getWindowController
{
  return wc;
}


- (void) dealloc
{
  wrap->cleanUp();
  
  [timer invalidate];
  [timer release];
  timer = nil;
  
  // Release all the view controllers.
  [wc release];
  wc = nil;
  [scriptingPanel release];
  scriptingPanel = nil;
  [scriptsBrowserPanel release];
  scriptsBrowserPanel = nil;
  [diagramPanel release];
  diagramPanel = nil;
  
  [parts release];
  parts = nil;
  [rules release];
  rules = nil;
  [animators release];
  animators = nil;
  
  
  
  [super dealloc];
}

@end
