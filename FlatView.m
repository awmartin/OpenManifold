//
//  FlatView.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/4/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "FlatView.h"

@implementation FlatView

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  
  if (self != nil) {
    float w = NSWidth(frameRect);
    float h = NSHeight(frameRect);
    originX = w/2.0f;
    originY = h/2.0f;
    zoom = 1.0f;
    scaleFactor = 10.0f;
  }
  return self;
}


/* ********************* Mouse events ********************* */

- (void) pan
{
  originX += (mouseX - pMouseX);
  originY += (mouseY - pMouseY);
}

- (void) zoom
{
  zoom += scrollDeltaY / 50.0f;
  // When implementing as a zoom...
  if( zoom < 0.05f ) zoom = 0.05f;
}

- (void) onOtherMouseDrag
{
  [self pan];
}

- (void) onRightMouseDrag
{
  [self pan];
}

- (void) onScroll
{
  [self zoom];
}


/* ********************* OpenGL methods ********************* */

- (void) prepareOpenGL
{
  glEnable(GL_AUTO_NORMAL);
  glEnable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  
  glEnable(GL_LIGHTING);
  
  //[self setHeadlight];
  //[self setFixedLights];
  
  //glEnable(GL_LIGHT0);
  //glEnable(GL_LIGHT1);
  
  glShadeModel( GL_SMOOTH );
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE);
  
  glEnable(GL_POINT_SMOOTH);
  glPointSize(3);
}

- (void) setupEnvironment
{
  //glDisable(GL_LIGHTING);
  //[self grid];
  //[self axes];
  //glEnable(GL_LIGHTING);
}

- (void) grid
{
  glColor4f(0.5, 0.5, 0.5, 0.5);
  glBegin(GL_LINES);
  {
    for( float i=-100.0;i<=100.0;i+=10 ){
      glVertex3f( -100.0, i, 0 );
      glVertex3f(  100.0, i, 0 );
      glVertex3f( i, -100.0, 0 );
      glVertex3f( i, 100.0,  0 );
    }
  }
  glEnd();
}


- (void) viewSetup:(NSRect*)rect
{
  if( select ){
    // Handle the selection case.
    glGetIntegerv (GL_VIEWPORT, viewport); 
    glSelectBuffer (BUFSIZE, selectBuf); 
    (void) glRenderMode (GL_SELECT);
    
    glInitNames();
    //glPushName(-1); // -1 reserved for all the non-selectable background stuff.
  }
  
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity();
  
  if( select ){
    /* create 5x5 pixel picking region near cursor location */ 
    gluPickMatrix((GLdouble) mouseX, (GLdouble) mouseY, 5.0, 5.0, viewport);
  }
  
  gluOrtho2D(0.0, width/scaleFactor, 0.0, height/scaleFactor);
  //gluPerspective( 60, aspect, 1.0, 200.0 );
  /*glFrustum( -(GLfloat)w/(GLfloat)1000.0f, (GLfloat)w/(GLfloat)1000.0f, 
   -(GLfloat)h/(GLfloat)1000.0f, (GLfloat)h/(GLfloat)1000.0f, 1.0, 200.0 );*/
  
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();
  
  //if( !select )
    //[self setHeadlight];
  
  // Scroll as dolly.
  //glTranslatef(originX/100.0f, originY/100.0f, -3.0f * zoom);
  
  // Scroll as zoom.
  glTranslatef(originX/scaleFactor, originY/scaleFactor, 0.0);
  glScalef(zoom,zoom,zoom);
  glDisable(GL_LIGHTING);
  
  //if (!select)
    //[self setupEnvironment];
  //[self setFixedLights];
  
  //if( select )
  //glPopName();
}

- (void) viewCleanup
{
  glPopMatrix();
  
  if( select ){
    
    hits = glRenderMode(GL_RENDER);
    
    if( currentOperation == MOUSE_DOWN ){
      [self handleMouseDownSelection];
    } else if( currentOperation == MOUSE_UP ){
      [self handleMouseUpSelection];
    }
  }
}




@end
