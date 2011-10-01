//
//  ScriptingPanelController.m
//  OpenManifold
//
//  Created by Allan William Martin on 7/29/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "ScriptingPanelController.h"
#import "OpenManifoldDocument.h"
#import "PythonController.h"

@implementation ScriptingPanelController

- (id)initWithDocument:(id)document
{
  self = [self initWithWindowNibName:@"ScriptingPanel"];
  
  if( self != nil ){
    doc = document;
  }
  
  return self;
}

- (void) windowDidLoad
{

}

- (void) awakeFromNib
{
  //[expressionTextView setString:@""];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
  NSMutableString* title = [[NSMutableString alloc] initWithString:displayName];
  [title appendString:@" (Scripting Panel)"];
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

- (void) loadScript:(NSString *)code
{
  [expressionTextView setString:code];
}

- (IBAction)evaluate:(id)sender
{
  NSString* selectedLanguage = [scriptingLanguageSelect titleOfSelectedItem];
  if( [selectedLanguage isEqualToString:@"Ruby"] ){

    @try {
      NSString* result = [doc evaluateRuby:[expressionTextView string]];
      [self addStringToResult:result];
    }
    @catch (NSException *exception) {
      NSString *error = [NSString stringWithFormat:@"%@: %@\n%@", [exception name], [exception reason], 
                          [[[exception userInfo] objectForKey:@"backtrace"] description]];
      [self addStringToResult:error];
    }
  } else if ( [selectedLanguage isEqualToString:@"Python"] ){

    @try {
      [ pythonController evaluatePython:[expressionTextView string] ];
      // Stdout callback in the PythonController handles passing the result to the resultTextView.
      
      [doc refreshView];
      [doc refreshMainWindow];
    }
    @catch (NSException *exception) {
      
    }
  }
}


- (void) addStringToResult:(NSString*)stringToAdd
{
  NSString* currentResult = [resultTextView string];
  //NSString* withNewLine = [currentResult stringByAppendingString:@"\n"];
  [resultTextView setString:[ currentResult stringByAppendingString:stringToAdd ] ];
}


- (IBAction) save:(id)sender
{
  int result;
  NSArray *fileTypes = [NSArray arrayWithObjects:@"rb",@"py",nil];
  NSSavePanel *sPanel = [NSSavePanel savePanel];
  [sPanel setAllowedFileTypes:fileTypes];
  
  result = [sPanel runModalForDirectory:NSHomeDirectory() file:nil];
  
  if (result == NSOKButton) {
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSString *aFile = [sPanel filename];
    NSError *error;
    
    [[expressionTextView string] writeToFile:aFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [pool drain];
    
  }
}



@end
