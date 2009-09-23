//
//  OpenManifoldApplicationController.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/4/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "OpenManifoldDocumentController.h"
#import "PreferencesModuleGeneralController.h"
#import "PreferencesModuleMobileMeController.h"
#import "KeyboardReferencePanelController.h"


@implementation OpenManifoldDocumentController

+ (void) initialize
{
  
  NSString *userDefaultsValuesPath;
  NSDictionary *userDefaultsValuesDict;
  //NSDictionary *initialValuesDict;
  //NSArray *resettableUserDefaultsKeys;
  
  // load the default values for the user defaults
  userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"DefaultPreferences" ofType:@"plist"];
  userDefaultsValuesDict=[NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
  
  // set them in the standard user defaults
  [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
  
  // if your application supports resetting a subset of the defaults to
  // factory values, you should set those values
  // in the shared user defaults controller
  //resettableUserDefaultsKeys=[NSArray arrayWithObjects:@"Value1",@"Value2",@"Value3",nil];
  //initialValuesDict=[userDefaultsValuesDict dictionaryWithValuesForKeys:resettableUserDefaultsKeys];
  
  // Set the initial values in the shared user defaults controller
  //[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValuesDict];
  
  /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"~/Documents/OpenManifold" forKey:@"ScriptsLibraryPath"];
  
  [defaults registerDefaults:appDefaults];*/
}

- (void)awakeFromNib
{
	PreferencesModuleGeneralController *general = [[PreferencesModuleGeneralController alloc] initWithNibName:@"PreferencesGeneral" bundle:nil];
	PreferencesModuleMobileMeController *mobileMe = [[PreferencesModuleMobileMeController alloc] initWithNibName:@"PreferencesMobileMe" bundle:nil];
	[[PreferencesController sharedController] setModules:[NSArray arrayWithObjects:general, mobileMe, nil]];
  [[[PreferencesController sharedController] window] setDelegate:self];
	[general release];
	[mobileMe release];
}

- (void)windowWillClose:(NSNotification *)notification
{
  // Writes the preferences to disk when the window is closed to make sure they are saved.
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults synchronize];
}

- (void)showPreferences:(id)sender
{
	[[PreferencesController sharedController] showWindow:sender];
}

- (IBAction)toggleInspectorPanel:(id)sender
{
  if ([inspectorPanel isVisible])
  {
    [inspectorPanel orderOut:sender];
  }
  else
  {
    [inspectorPanel orderFront:sender];
  }
}

- (void) setInspectorText:(NSString*)text
{
  [inspectorPanelTextView setString:text];
  [inspectorPanelTextView setTextColor:[NSColor whiteColor]];
}


- (void) toggleKeyboardReferencePanel
{
  [keyboardReferenceController toggleKeyboardReference:nil];
}

@end
