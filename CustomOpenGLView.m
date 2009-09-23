//
//  CustomOpenGLView.m
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "CustomOpenGLView.h"


@implementation CustomOpenGLView


- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self != nil) {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_surfaceNeedsUpdate:)
                                                 name:NSViewGlobalFrameDidChangeNotification
                                               object:self];
    
    // Create the gl context object.
    _pixelFormat = [CustomOpenGLView defaultPixelFormat];
    
    _openGLContext = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:nil];
    
    [self setOpenGLContext:_openGLContext];
    
  }
  return self;
}

- (void) _surfaceNeedsUpdate:(NSNotification*)notification
{
  [self update];
}

- (void)lockFocus
{
  NSOpenGLContext* context = [self openGLContext];
  
  [super lockFocus];
  if([context view] != self) {
    [context setView:self];
  }
  [context makeCurrentContext];
}

// Detaches the context from the drawable object when the custom view 
// is moved from the window.
/*- (void) viewDidMoveToWindow
 {
 [super viewDidMoveToWindow];
 NSOpenGLContext* context = [self openGLContext];
 if ([self window] == nil)
 [context clearDrawable];
 }*/

+ (NSOpenGLPixelFormat*) defaultPixelFormat
{
  NSOpenGLPixelFormatAttribute attrs[] =
  {
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFADepthSize, 32,
    0
  };
  NSOpenGLPixelFormat* fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
  
  return fmt;
}

+ (NSOpenGLPixelFormat*) fullScreenPixelFormat
{
  NSOpenGLPixelFormatAttribute attrs[] =
  {
    NSOpenGLPFAFullScreen,
    NSOpenGLPFAScreenMask,
    CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
    NSOpenGLPFAColorSize, 24,
    NSOpenGLPFADepthSize, 16,
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFAAccelerated,
    0
  };
  NSOpenGLPixelFormat* fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
  
  return fmt;
}

- (void) update
{
  [_openGLContext update];
}

- (NSOpenGLContext*)openGLContext
{
  return [[_openGLContext retain] autorelease];
}

- (void) setOpenGLContext:(NSOpenGLContext*)context
{
  // First check to see if the value has changed.
  if( ![_openGLContext isEqual:context] ) {
    
    [_openGLContext release];
    
    _openGLContext = [context retain];
    [_openGLContext makeCurrentContext];
  }
}

- (void) setPixelFormat:(NSOpenGLPixelFormat*)pixelFormat
{
  if( ![_pixelFormat isEqual:pixelFormat] ) {
    [_pixelFormat release];
    _pixelFormat = [pixelFormat retain];
  }
}

- (NSOpenGLPixelFormat *) pixelFormat
{
  return [[_pixelFormat retain] autorelease];
}

- (void) clearGLContext
{
  [NSOpenGLContext clearCurrentContext];
  [_openGLContext release];
}

- (void) prepareOpenGL
{

  
}

- (BOOL)isOpaque
{
  return YES;
}

- (BOOL)acceptsFirstMouse
{
  return YES;
}

- (BOOL) acceptsFirstResponder
{
  return YES;
}

- (void) awakeFromNib
{
  
  [[self window] setAcceptsMouseMovedEvents: YES];
  
} // awakeFromNib

- (void) dealloc
{
  [_pixelFormat release];
  _pixelFormat = nil;
  [_openGLContext release];
  _openGLContext = nil;
  [super dealloc];
}


@end
