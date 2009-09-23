/*
 Copyright (c) 2008 Matthew Ball - http://www.mattballdesign.com
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

#import "PreferencesModuleGeneralController.h"


@implementation PreferencesModuleGeneralController


- (NSString *)title
{
	return NSLocalizedString(@"General", @"Title of 'General' preference pane");
}

- (NSString *)identifier
{
	return @"PreferencesGeneralPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}


- (IBAction)getRootLibraryPath:(id)sender
{
  NSOpenPanel* panel = [NSOpenPanel openPanel];
  [panel setAllowsMultipleSelection:NO];
  [panel setCanChooseDirectories:YES];
  [panel setCanChooseFiles:YES];
  [panel setResolvesAliases:YES];
  [panel setTitle:@"Choose a folder."];
  [panel setPrompt:@"Choose"];
  
  [panel beginSheetForDirectory:nil file:nil types:nil modalForWindow:[[PreferencesController sharedController] window]
                  modalDelegate:self
                 didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
                    contextInfo:self];
}

- (void)openPanelDidEnd:(NSOpenPanel*)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// hide the open panel
	[panel orderOut:self];
	
	// if the return code wasn't ok, don't do anything.
	if (returnCode != NSOKButton)
		return;
	
	// get the first URL returned from the Open Panel and set it at the first path component of the control
	NSArray* paths = [panel URLs];
	NSURL* url = [paths objectAtIndex: 0];
	
  // NSPathControl objects don't work because they return NSUrl. Do this with a text field.
  [rootLibraryFolderField setStringValue:[ url path ] ];
  
  // Since we didn't physically type the new address into the text field, we have to set this
  // value manually here.
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[url path] forKey:@"RootLibraryPath"];
}


@end
