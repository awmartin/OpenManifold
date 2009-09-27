//
//  ObjectView.m
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "ObjectView.h"


@implementation ObjectView

- (id) initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  
  if( self != nil ){
    backgroundColor[0] = 0.07;
    backgroundColor[1] = 0.14;
    backgroundColor[2] = 0.29;
    backgroundColor[3] = 1.0;
    
    select = NO;
    
    viewFrame = [self frame];
    
    shiftKeyDown = NO;
    altKeyDown = NO;
  }
  
  return self;
}



/* ********************* Mouse click events ********************* */

#pragma mark Mouse Click Events

- (void) onMouseDown
{
  // To be overriden by subclass.
}

- (void) onOtherMouseDown
{
  // To be overriden by subclass.
}

- (void) onRightMouseDown
{
  // To be overriden by subclass.
}

- (void) onMouseUp
{
  // To be overriden by subclass.
}

- (void) mouseDown:(NSEvent *)event
{
  [self onMouseDown];
}

- (void) otherMouseDown:(NSEvent *)event
{
  [self onOtherMouseDown];
}

- (void) rightMouseDown:(NSEvent *)event
{
  [self onRightMouseDown];
}

- (void) mouseUp:(NSEvent *)event
{
  [self onMouseUp];
}

/* ********************* Dragging events ********************* */

#pragma mark Dragging Events

- (void) onMouseDrag
{
  // To be overridden by a subclass;
}

- (void) onOtherMouseDrag
{
  // To be overridden by a subclass;
}

- (void) onRightMouseDrag
{
  // To be overridden by a subclass;
}

- (void) mouseDragged:(NSEvent*)event
{
  [self updateMousePosition:event];
  
  [self onMouseDrag];
  
  [self setNeedsDisplay:YES];
}

- (void) otherMouseDragged:(NSEvent*)event
{
  if( ![[self window] isKeyWindow] ) return;
  
  [self updateMousePosition:event];
  
  [self onOtherMouseDrag];
  
  [self setNeedsDisplay:YES];
}

- (void) rightMouseDragged:(NSEvent *)event
{
  // The key window is the "active" window.
  if( ![[self window] isKeyWindow] ) return;
  
  [self updateMousePosition:event];
  
  [self onRightMouseDrag];
  
  [self setNeedsDisplay:YES];
}


/* ********************* Scroll wheel events ********************* */

#pragma mark Scroll Wheel Events

- (void) onScroll
{
  // To be overridden by a subclass.
}

- (void) scrollWheel:(NSEvent *)event
{
  scrollDeltaX = event.deltaX;
  scrollDeltaY = event.deltaY;
  [self onScroll];
	[self setNeedsDisplay:YES];
}


/* ********************* Mouse move events ********************* */

#pragma mark Mouse Move Events

- (void) mouseMoved:(NSEvent *)event
{
  [self updateMousePosition:event];
}

- (void) updateMousePosition:(NSEvent*)event
{
  NSPoint curPoint = [event locationInWindow];
  
  pMouseX = mouseX;
  pMouseY = mouseY;
  
  mouseX = curPoint.x - viewFrame.origin.x;
  mouseY = curPoint.y - viewFrame.origin.y;
}


/* ********************* Keyboard events ********************* */

#pragma mark Keyboard Events

- (void) onKeyDown:(char)key
{
  // To be overridden by a subclass.
}

- (void) keyDown:(NSEvent*)event
{
  unsigned int flags = [event modifierFlags];
  
  if ( flags & NSShiftKeyMask ) {
    shiftKeyDown = YES;
  } else {
    shiftKeyDown = NO;
  }
  
  if ( flags & NSAlternateKeyMask ) {
    altKeyDown = YES;
  } else {
    altKeyDown = NO;
  }
  
  char key = [event.characters characterAtIndex:0];
  [self onKeyDown:key];
  [self setNeedsDisplay:YES];
}

- (void) onKeyUp
{
  // To be overridden by a subclass.
}

- (void) keyUp:(NSEvent*)event
{
  unsigned int flags = [event modifierFlags];
  
  if ( flags & NSShiftKeyMask ) {
    shiftKeyDown = YES;
  } else {
    shiftKeyDown = NO;
  }
  
  if ( flags & NSAlternateKeyMask ) {
    altKeyDown = YES;
  } else {
    altKeyDown = NO;
  }
  
  [self onKeyUp];
}

- (void) flagsChanged:(NSEvent*)event
{
  unsigned int flags = [event modifierFlags];
  
  if ( flags & NSShiftKeyMask ) {
    shiftKeyDown = YES;
  } else {
    shiftKeyDown = NO;
  }
  
  if ( flags & NSAlternateKeyMask ) {
    altKeyDown = YES;
  } else {
    altKeyDown = NO;
  }
}

/* ********************* Drawing methods ********************* */
#pragma mark Drawing Methods

- (void) viewSetup:(NSRect*)rect
{
  // To be overridden by the subclass. This sets up the view parameters,
  // like, glFrustum for perspective, etc...
}

- (void) build
{
  // To be overridden. For rebuilding a objects if selection is implemented.
}

- (void) draw
{
  // To be overridden by the subclass to draw stuff...
}

- (void) viewCleanup
{
  // To be overridden by the subclass. This cleans up anything done in the
  // viewSetup method, like glPushMatrix().
}


- (void) handleSelection
{
  // To be overridden by the subclass
}

- (void)drawRect:(NSRect)rect 
{
  NSOpenGLContext* context = [self openGLContext];
  [context makeCurrentContext];
  // Drawing code here.
  
  float w = NSWidth(rect);
  float h = NSHeight(rect);
  
  glViewport( 0, 0, w, h );
  
  glClearColor(backgroundColor[0],backgroundColor[1],backgroundColor[2],backgroundColor[3]);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  
  if( select ) {
    // This is the selection rendering.
    [self viewSetup:&rect];
    
    glPushMatrix();
    {
      [self draw];
    }
    glPopMatrix();
    
    [self viewCleanup];
    
    select = NO;
    
    [self build];
  }
  
  // This is the physical rendering.
  [self viewSetup:&rect];
  
  glPushMatrix();
  {
    [self draw];
  }
  glPopMatrix();
  
  [self viewCleanup];
  
  glFlush();
  [context flushBuffer];
}



@end
