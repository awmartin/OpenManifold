//
//  PerspectiveView.m
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "PerspectiveView.h"


@implementation PerspectiveView

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  
  if (self != nil) {
    rotationAngleX = 0.0f;
    rotationAngleY = 0.5f;
    originX = 0.0f;
    originY = 0.0f;
    originZ = 0.0f;
    zoomFactor = 1.0f;
    distanceToTarget = 3.0f;
    
    float distanceXZ = distanceToTarget*cos(rotationAngleY);
    eyeY = distanceToTarget*sin(rotationAngleY) + originY;
    eyeX = distanceXZ*sin(rotationAngleX) + originX;
    eyeZ = distanceXZ*cos(rotationAngleX) + originZ;
  }
  return self;
}


#pragma mark -
#pragma mark Lights

- (void) setFixedLights
{
  GLfloat light_ambient[] = { 0.2, 0.2, 0.2, 1.0 };
  GLfloat light_diffuse[] = { 1.0, 1.0, 1.0, 1.0 };
  GLfloat light_specular[] = { 1.0, 1.0, 1.0, 1.0 };
  
  glLightfv( GL_LIGHT0, GL_AMBIENT, light_ambient );
  glLightfv( GL_LIGHT0, GL_DIFFUSE, light_diffuse );
  glLightfv( GL_LIGHT0, GL_SPECULAR, light_specular );
  
  //glLightf( GL_LIGHT0, GL_CONSTANT_ATTENUATION, 1.5 );
  //glLightf( GL_LIGHT0, GL_LINEAR_ATTENUATION, 0.5 );
  //glLightf( GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0.2 );
  //glLightf( GL_LIGHT0, GL_SPOT_EXPONENT, 2.0 );
  
  GLfloat light_position[] = { 2.0, 2.0, 2.0, 1.0 };
  GLfloat spot_direction[] = { -1.0, -1.0, -1.0 };
  glLightf( GL_LIGHT0, GL_SPOT_CUTOFF, 180.0 );
  glLightfv( GL_LIGHT0, GL_SPOT_DIRECTION, spot_direction );
  glLightfv( GL_LIGHT0, GL_POSITION, light_position );
}

- (void) setHeadlight
{
  GLfloat light_ambient[] = { 0.0, 0.0, 0.0, 1.0 };
   GLfloat light_diffuse[] = { 1.0, 1.0, 1.0, 1.0 };
   GLfloat light_specular[] = { 1.0, 1.0, 1.0, 1.0 };
   
   glLightfv( GL_LIGHT1, GL_AMBIENT, light_ambient );
   glLightfv( GL_LIGHT1, GL_DIFFUSE, light_diffuse );
   glLightfv( GL_LIGHT1, GL_SPECULAR, light_specular );
  
  GLfloat light_position[] = { 0.0, 0.0, 1.0, 0.0 };
  /*GLfloat spot_direction[] = { 0.0, 0.0, -1.0 };
   glLightf( GL_LIGHT1, GL_SPOT_CUTOFF, 30.0 );
   glLightfv( GL_LIGHT1, GL_SPOT_DIRECTION, spot_direction );*/
  glLightfv( GL_LIGHT1, GL_POSITION, light_position );
}


#pragma mark -
#pragma mark Utility drawing methods

/* Utility methods for a cube, cross-hair point, and grid. */
- (void) point:(float)x yPos:(float)y zPos:(float)z 
{
  glDisable(GL_LIGHTING);
  
  glPushMatrix();
  
    glTranslatef(x, y, z);
    glColor3f( 1.0, 0, 0 );
  
    glBegin(GL_LINES);
    {
      glVertex3f( -0.1, 0.0, 0.0 );
      glVertex3f(  0.1, 0.0, 0.0 );
      glVertex3f(  0.0, -0.1, 0.0 );
      glVertex3f(  0.0, 0.1, 0.0 );
      glVertex3f(  0.0, 0.0, -0.1 );
      glVertex3f(  0.0, 0.0, 0.1 );
    }
    glEnd();
  
  glPopMatrix();
  
  glEnable(GL_LIGHTING);
}

- (void) cube:(float)s
{
  GLfloat mat_specular[] = { 1.0, 1.0, 1.0, 1.0 };
  GLfloat mat_shininess[] = { 100.0 };
  glMaterialfv( GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular );
  glMaterialfv( GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess );

  glBegin(GL_QUADS);
  {
    glVertex3f(  s, -s, -s );
    glVertex3f( -s, -s, -s );
    glVertex3f( -s,  s, -s );
    glVertex3f(  s,  s, -s );
    
    glVertex3f(  s,  s,  s );
    glVertex3f( -s,  s,  s );
    glVertex3f( -s, -s,  s );
    glVertex3f(  s, -s,  s );
    
    glVertex3f(  s,  s, -s );
    glVertex3f( -s,  s, -s );
    glVertex3f( -s,  s,  s );
    glVertex3f(  s,  s,  s );
    
    glVertex3f( -s,  s, -s );
    glVertex3f( -s, -s, -s );
    glVertex3f( -s, -s,  s );
    glVertex3f( -s,  s,  s );
    
    glVertex3f( -s, -s, -s );
    glVertex3f(  s, -s, -s );
    glVertex3f(  s, -s,  s );
    glVertex3f( -s, -s,  s );
    
    glVertex3f(  s, -s, -s );
    glVertex3f(  s,  s, -s );
    glVertex3f(  s,  s,  s );
    glVertex3f(  s, -s,  s );
  }
  glEnd();
  
}

- (void) axes
{
  glLineWidth(2.0f);
  glBegin(GL_LINES);
  {
    glColor3f( 0.0f, 1.0f, 0.0f );
    glVertex3f( 0.0f, 0.0f, 0.0f );
    glVertex3f( 1.0f, 0.0f, 0.0f );
    
    glColor3f( 0.0f, 0.0f, 1.0f );
    glVertex3f( 0.0f, 0.0f, 0.0f );
    glVertex3f( 0.0f, 1.0f, 0.0f );
    
    glColor3f( 1.0f, 0.0f, 0.0f );
    glVertex3f( 0.0f, 0.0f, 0.0f );
    glVertex3f( 0.0f, 0.0f, 1.0f );
  }
  glEnd();
  glLineWidth(1.0f);
}

- (void) grid
{
  glColor4f(0.5, 0.5, 0.5, 0.5);
  glBegin(GL_LINES);
  {
    for( float i=-10.0;i<=10.0;i+=0.5 ){
      glVertex3f( -10.0, 0, i );
      glVertex3f(  10.0, 0, i );
      glVertex3f( i, 0, -10.0 );
      glVertex3f( i, 0,  10.0 );
    }
  }
  glEnd();
}

#pragma mark -
#pragma mark Navigation methods.

- (void) orbit
{
  rotationAngleX -= (mouseX - pMouseX)/100.0f;
  rotationAngleY -= (mouseY - pMouseY)/100.0f;
  if( rotationAngleY >= PI/2 ) rotationAngleY = PI/2-0.01f;
  if( rotationAngleY <= -PI/2 ) rotationAngleY = -PI/2+0.01f;
  [self updateEyePosition];
}

- (void) pan
{
  float dMouseX = (mouseX - pMouseX)/50.0f;
  float dMouseY = (mouseY - pMouseY)/50.0f;
  float dx = 0.0f;
  float dy = 0.0f;
  float dz = 0.0f;
  
  dx -= dMouseX*cos(rotationAngleX);
  dz += dMouseX*sin(rotationAngleX);
  
  float dProjected = dMouseY*cos(PI/2.0-rotationAngleY);
  
  dx += dProjected*sin(rotationAngleX);
  dy -= dMouseY*sin(PI/2.0-rotationAngleY);
  dz += dProjected*cos(rotationAngleX);
  
  originX += dx;
  originY += dy;
  originZ += dz;
  eyeX += dx;
  eyeY += dy;
  eyeZ += dz;
}

- (void) zoom
{
  if( scrollDeltaY != 0 ){ // We're scrolling.
    zoomFactor += scrollDeltaY / 100.0f;
    distanceToTarget += scrollDeltaY / 25.0f;
  } else { // We're dragging the mouse.
    zoomFactor += (pMouseY - mouseY) / 100.0f;
    distanceToTarget += (pMouseY - mouseY) / 25.0f;
  }
  
  // When implementing as a zoomFactor...
  if( zoomFactor < 0.05f ) zoomFactor = 0.05f;
  if( distanceToTarget < 0.05f ) distanceToTarget = 0.05f;
  
  [self updateEyePosition];
}

- (void) updateEyePosition
{
  float distanceXZ = distanceToTarget*cos(rotationAngleY);
  eyeY = distanceToTarget*sin(rotationAngleY) + originY;
  eyeX = distanceXZ*sin(rotationAngleX) + originX;
  eyeZ = distanceXZ*cos(rotationAngleX) + originZ;
}


#pragma mark -
#pragma mark Mouse events.

- (void) onOtherMouseDrag
{
  if( altKeyDown ){
    [self pan]; // redundant, but explicit
    return;
  }
  [self pan];
}

- (void) onRightMouseDrag
{
  if( shiftKeyDown ){
    [self pan];
    return;
  }
  
  if( altKeyDown ){
    [self zoom];
    return;
  }
  
  [self orbit];
}

- (void) onScroll
{
  if( scrollDeltaY != 0 )
    [self zoom];
}


#pragma mark -
#pragma mark OpenGL methods

- (void) prepareOpenGL
{
  glEnable(GL_AUTO_NORMAL);
  glEnable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  
  glEnable(GL_LIGHTING);
  
  [self setHeadlight];
  [self setFixedLights];
  
  //glEnable(GL_LIGHT0);
  glEnable(GL_LIGHT1);
  
  glShadeModel( GL_SMOOTH );
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE);
  
  glEnable(GL_POINT_SMOOTH);
  glPointSize(3);
}

- (void) setupEnvironment
{
  glDisable(GL_LIGHTING);
  [self grid];
  [self axes];
  glEnable(GL_LIGHTING);
}

- (void) viewSetup:(NSRect*)rect
{
  if( select ){
    // Handle the selection case.
    glGetIntegerv( GL_VIEWPORT, viewport );
    glSelectBuffer( BUFSIZE, selectBuf );
    (void) glRenderMode( GL_SELECT );

    glInitNames();
  }
  
  /* For rendering perspective views. */
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  
  if( select ){
    
    /* change pick matrix to check for startBoxSelectX, startBoxSelectY */
    float dX = abs(startBoxSelectX - mouseX);
    float dY = abs(startBoxSelectY - mouseY);
    float centerX = dX/2 + MIN(startBoxSelectX, mouseX);
    float centerY = dY/2 + MIN(startBoxSelectY, mouseY);
    
    /* create 5x5 pixel picking region near cursor location */
    dX = MAX(5.0,dX);
    dY = MAX(5.0,dY);
    gluPickMatrix((GLdouble) centerX, (GLdouble) centerY, dX, dY, viewport);
    
  }
  
  //float theta = 2 * atan( (width/2.0f) / 346.4102f) * 180/PI;
  //printf("width: %f theta: %f\n", width, theta);
  
  aspect = width/height;
  //gluPerspective( theta, aspect, 1.0, 400.0 );
  gluPerspective( 60, aspect, 1.0, 400.0 );
  
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();
  
  if( !select )
    [self setHeadlight];

  gluLookAt(eyeX, eyeY, eyeZ, originX, originY, originZ, 0.0f, 1.0f, 0.0f);
  
  if (!select)
    [self setupEnvironment];
}

- (void) viewCleanup
{
  glPopMatrix();
  
  [self drawHUD];
  
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
