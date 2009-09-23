//
//  CustomOpenGLView.h
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@interface CustomOpenGLView : NSView {
@private
  NSOpenGLContext*      _openGLContext;
  NSOpenGLPixelFormat*  _pixelFormat;
}

+ (NSOpenGLPixelFormat*) defaultPixelFormat;
+ (NSOpenGLPixelFormat*) fullScreenPixelFormat;

- (void) setOpenGLContext:(NSOpenGLContext*) context;
- (NSOpenGLContext*) openGLContext;
- (void) clearGLContext;
- (void) prepareOpenGL;
- (void) update;
- (void) setPixelFormat:(NSOpenGLPixelFormat*) pixelFormat;
- (NSOpenGLPixelFormat*) pixelFormat;
@end
