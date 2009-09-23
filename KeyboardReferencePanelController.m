//
//  keyboardReferencePanelController.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/6/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "KeyboardReferencePanelController.h"


@implementation KeyboardReferencePanelController

@synthesize keyDescriptions;

- (id) init
{
  self = [super init];
  if( self != nil ){
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"KeyboardReference" ofType:@"plist"];
    NSData* plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
      propertyListFromData:plistXML
      mutabilityOption:NSPropertyListMutableContainersAndLeaves
      format:&format
      errorDescription:&errorDesc];
    if( !temp ){
      NSLog(errorDesc);
      [errorDesc release];
    }
    self.keyDescriptions = (NSMutableDictionary*)temp;
  }
  return self;
}

/* To write the property list back when the application terminates. */
/*
- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
  NSString *errorDesc;
  NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"KeyboardReference" ofType:@"plist"];
  NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:
                             [NSArray arrayWithObjects: numericKeys, alphabeticKeys, nil]
                                                        forKeys:[NSArray arrayWithObjects: @"Numeric", @"Alphabetic", nil]];
  NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                        format:NSPropertyListXMLFormat_v1_0
                        errorDescription:&errorDesc];
  if( plistData ) {
    [plistData writeToFile:bundlePath atomically:YES];
  } else {
    NSLog(errorDesc);
    [errorDesc release];
  }
  return NSTerminateNow;
}*/

- (void) handleKeyReference:(NSString*)key
{
  if( [key isEqualTo:@" "] )
    [self toggleKeyboardReference:nil];
  
  NSString* result = [keyDescriptions objectForKey:[key capitalizedString]];
  
  if( result == nil ){
    [keyboardReferenceText setString:@""];
  } else {
    [keyboardReferenceText setString:result];
  }
  
  [keyboardReferenceText setTextColor:[NSColor whiteColor]];
}

- (IBAction) viewKeyboardReference:(id)sender
{
  NSArray* letters = [NSArray arrayWithObjects: @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",
                                                @"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",
                                                @"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil ];
  NSArray* numbers = [NSArray arrayWithObjects: @"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",nil ];
  
  NSInteger tag = [sender selectedTag];
  
  if( tag >= 301 && tag <= 326 ){
    int index = tag - 301;
    
    if( index > 26 || index < 0 ) return;
    
    [self handleKeyReference:[letters objectAtIndex:index]];
  }
  
  // 401 is number 1. 410 is number 0.
  if( tag >= 401 && tag <= 410 ){
    int index = tag - 401;
    
    if( index > 10 || index < 0 ) return;
    
    [self handleKeyReference:[numbers objectAtIndex:index]];
  }
  
}


- (IBAction) toggleKeyboardReference:(id)sender
{
  if ([keyboardReferencePanel isVisible])
  {
    [keyboardReferencePanel orderOut:sender];
  }
  else
  {
    [keyboardReferencePanel makeKeyAndOrderFront:sender];
  }
}


@end
