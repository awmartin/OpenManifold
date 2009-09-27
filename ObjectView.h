//
//  ObjectView.h
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CustomOpenGLView.h"

#define BUFSIZE 512

@interface ObjectView : CustomOpenGLView {
  float mouseX;
  float mouseY;
  float pMouseX;
  float pMouseY;
  
  float scrollDeltaX;
  float scrollDeltaY;
  
  BOOL select;
  
  GLuint selectBuf[BUFSIZE];
  GLint hits;
  
  GLint viewport[4];
  
  GLclampf backgroundColor[4];
  
  NSRect viewFrame;           /**< Keeps track of the view's position so we can calculate the mouse offset. */
  
  BOOL shiftKeyDown;
  BOOL altKeyDown;
  
  float aspect;
}

- (void) onMouseDown;
- (void) onOtherMouseDown;
- (void) onRightMouseDown;

- (void) onMouseUp;

- (void) onMouseDrag;
- (void) onOtherMouseDrag;
- (void) onRightMouseDrag;

- (void) onScroll;
- (void) scrollWheel:(NSEvent *)event;

- (void) updateMousePosition:(NSEvent *)event;

- (void) onKeyDown:(char)key;
- (void) keyDown:(NSEvent*)event;
- (void) onKeyUp;
- (void) keyUp:(NSEvent*)event;

- (void) build;

- (void) viewSetup:(NSRect*)rect;
- (void) draw;
- (void) viewCleanup;

- (void) handleSelection;

@end
