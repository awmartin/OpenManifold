//
//  Manipulator.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/3/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "Manipulator.h"


@implementation Manipulator

@synthesize targets;

- (id) init
{
  self = [super init];
  if( self != nil ){
    dragging = false;
    draggingAxis = -1;
    x = 0;
    y = 0;
    z = 0;
    
    targets = [NSMutableArray array];
    [targets retain];
    
    mode = TRANSLATE;
  }
  return self;
}

- (void) setMode:(int)newMode
{
  mode = newMode;
  
  [targets makeObjectsPerformSelector:@selector(unSelect)];
  
  [targets removeAllObjects];
}

- (int) getMode
{
  return mode;
}

- (float) getX
{
  return x;
}

- (float) getY
{
  return y;
}

- (float) getZ
{
  return z;
}

- (void) setPositionX:(float)newX y:(float)newY z:(float)newZ
{
  x = newX;
  y = newY;
  z = newZ;
}

- (void) reset
{
  [self setPositionX:0 y:0 z:0];
  
  [self clearSelection];
}

- (void) clearSelection
{
  [targets makeObjectsPerformSelector:@selector(unSelect)];
  
  [targets removeAllObjects];
}

- (void) addTarget:(id)newTarget
{
  [targets addObject:newTarget];
  [newTarget select];
  
  x = [newTarget getFloatValue:@"posX"];
  y = [newTarget getFloatValue:@"posY"];
  z = [newTarget getFloatValue:@"posZ"];
}

- (void) setTarget:(id)newTarget
{
  if( newTarget != nil ){
    [targets makeObjectsPerformSelector:@selector(unSelect)];
    [targets removeAllObjects];
    [targets addObject:newTarget];
  
  // Move into position. Don't send update because we don't want to make the node dirty.
    x = [newTarget getFloatValue:@"posX"];
    y = [newTarget getFloatValue:@"posY"];
    z = [newTarget getFloatValue:@"posZ"];
  
    [newTarget select];
  }
}

- (int) getDraggingAxis
{
  return draggingAxis;
}

- (BOOL) isDragging
{
  return dragging;
}

- (void) startDrag:(int)axis
{
  dragging = true;
  draggingAxis = axis%3;
}

- (void) stopDrag
{
  dragging = false;
  draggingAxis = -1;
}

- (void) update
{
  if( [targets count] > 0 ){
    x = [[targets lastObject] getFloatValue:@"posX"];
    y = [[targets lastObject] getFloatValue:@"posY"];
    z = [[targets lastObject] getFloatValue:@"posZ"];
    
    [[targets lastObject] setDirty];
  }
}

- (void) updateX:(float)deltaX
{
  if( dragging ){
    x += deltaX;
    if( [targets count] > 0 ){
      for( int i=0;i<[targets count];i++ ){
        id param = [targets objectAtIndex:i];
        float currentX = [param getFloatValue:@"posX"];
        
        [param setValue:@"posX" withNumber:[NSNumber numberWithFloat:currentX+deltaX]];
        
        [param setDirty];
      }
    }
  }
}

- (void) updateY:(float)deltaY
{
  if( dragging ){
    y += deltaY;
    if( [targets count] > 0 ) {
      for( int i=0;i<[targets count];i++ ){
        id param = [targets objectAtIndex:i];
        float currentY = [param getFloatValue:@"posY"];
        
        [param setValue:@"posY" withNumber:[NSNumber numberWithFloat:currentY+deltaY]];
        
        [param setDirty];
      }
    }
  }
}


- (void) updateZ:(float)deltaZ
{
  if( dragging ){
    z += deltaZ;
    if( [targets count] > 0 ){
      for( int i=0;i<[targets count];i++ ){
        id param = [targets objectAtIndex:i];
        float currentZ = [param getFloatValue:@"posZ"];
        
        [param setValue:@"posZ" withNumber:[NSNumber numberWithFloat:currentZ+deltaZ]];
        
        [param setDirty];
      }
    }
  }
}


- (void) draw:(BOOL)select zoom:(float)zoom
{
  if( mode == TRANSLATE )
    [self drawTranslateManipulator:select zoom:zoom];
  if( mode == ROTATE )
    [self drawRotateManipulator:select zoom:zoom];
  if( mode == SCALE )
    [self drawScaleManipulator:select zoom:zoom];
}

- (void) drawTranslateManipulator:(BOOL)select zoom:(float)zoom
{
  float a = 0;
  float r = 0.05;
  float o = 0.1;
  
  if( select ) glPushName(GROUP_INTERFACE);  // This is the group name for interface objects.
  
  glDisable( GL_LIGHTING );
  
  glPushMatrix();
  glTranslatef( x, y, z );
  glScalef(0.3*zoom,0.3*zoom,0.3*zoom);
  
  if( select ) glPushName(Z_AXIS);
    glColor3f(1.0,0,0);
    glBegin(GL_QUAD_STRIP);
    for( a=0;a<=2*pi+pi/10;a+=pi/10 ){
      glVertex3f( r*cos(a), r*sin(a), 1 );
      glVertex3f( r*cos(a), r*sin(a), 0 );
    }
    glEnd();
    
    glBegin(GL_TRIANGLE_STRIP);
    for( a=0;a<=2*pi+pi/10;a+=pi/10 ){
      glVertex3f( 0, 0, 1.5f );
      glVertex3f( o*cos(a), o*sin(a), 1 );
    }
    glEnd();
  if( select ) glPopName();
  
  glRotatef(90, 0, 1, 0);
  
  if( select ) glPushName(X_AXIS);
    glColor3f(0,1.0,0);
    
    glBegin(GL_QUAD_STRIP);
    for( a=0;a<=2*pi+pi/10;a+=pi/10 ){
      glVertex3f( r*cos(a), r*sin(a), 1 );
      glVertex3f( r*cos(a), r*sin(a), 0 );
    }
    glEnd();
    
    glBegin(GL_TRIANGLE_STRIP);
    for( a=0;a<=2*pi+pi/10;a+=pi/10 ){
      glVertex3f( 0, 0, 1.5f );
      glVertex3f( o*cos(a), o*sin(a), 1 );
    }
    glEnd();
  if( select ) glPopName();
  
  glRotatef(-90, 1, 0, 0);
  
  if( select ) glPushName(Y_AXIS);
    glColor3f(0,0,1.0);
    
    glBegin(GL_QUAD_STRIP);
    for( a=0;a<=2*pi+pi/10;a+=pi/10 ){
      glVertex3f( r*cos(a), r*sin(a), 1 );
      glVertex3f( r*cos(a), r*sin(a), 0 );
    }
    glEnd();
    
    glBegin(GL_TRIANGLE_STRIP);
    for( a=0;a<=2*pi+pi/10;a+=pi/10 ){
      glVertex3f( 0, 0, 1.5f );
      glVertex3f( o*cos(a), o*sin(a), 1 );
    }
    glEnd();
  if( select ) glPopName();

  if( select ) glPopName();
  
  glPopMatrix();
  glEnable( GL_LIGHTING );
}

- (void) drawRotateManipulator:(BOOL)select zoom:(float)zoom
{
  float a = 0;
  float r = 1.5;
  
  glDisable( GL_LIGHTING );
  glLineWidth(3);
  
  glPushMatrix();
  glTranslatef( x, y, z );
  glScalef(0.3*zoom,0.3*zoom,0.3*zoom);
  
  if( select ) glPushName(2);  // This is the group name for interface objects.
  
  if( select ) glPushName(3);
    glColor3f(1.0,0,0);
    glBegin(GL_LINE_LOOP);
    for( a=0;a<=2*pi+pi/10;a+=pi/10 ){
      glVertex3f( r*cos(a), r*sin(a), 0 );
    }
    glEnd();
  if( select ) glPopName();
  
  if( select ) glPushName(4);
    glColor3f(0,1.0,0);
    glRotatef(90, 0, 1, 0);
    glBegin(GL_LINE_LOOP);
    for( a=0;a<=2*pi+pi/10;a+=pi/10 ){
      glVertex3f( r*cos(a), r*sin(a), 0 );
    }
    glEnd();
  if( select ) glPopName();

  
  if( select ) glPushName(5);
    glColor3f(0,0,1.0);
    glRotatef(-90, 1, 0, 0);
    glBegin(GL_LINE_LOOP);
    for( a=0;a<=2*pi+pi/10;a+=pi/10 ){
      glVertex3f( r*cos(a), r*sin(a), 0 );
    }
    glEnd();
  if( select ) glPopName();
  
  if( select ) glPopName();
  
  glPopMatrix();
  glEnable( GL_LIGHTING );
  glLineWidth(1);
}

- (void) drawScaleManipulator:(BOOL)select zoom:(float)zoom
{
  float r = 1;
  float s = 0.1f;
  
  glLineWidth(3);
  glDisable( GL_LIGHTING );
  
  glPushMatrix();
  glTranslatef( x, y, z );
  glScalef(0.3*zoom,0.3*zoom,0.3*zoom);
  
  if( select ) glPushName(2);  // This is the group name for interface objects.
  
  glColor3f(1.0,0,0);
  if( select ) glPushName(6);
    glBegin(GL_LINES);
      glVertex3f( 0, 0, 0 );
      glVertex3f( 0, 0, r );
    glEnd();
    glPushMatrix();
      glTranslatef( 0, 0, r );
      [self cube:s];
    glPopMatrix();
  if( select ) glPopName();
  
  glRotatef(90, 0, 1, 0);
  
  glColor3f(0,1.0,0);
  if( select ) glPushName(7);
    glBegin(GL_LINES);
      glVertex3f( 0, 0, 0 );
      glVertex3f( 0, 0, r );
    glEnd();
    glPushMatrix();
      glTranslatef( 0, 0, r );
      [self cube:s];
    glPopMatrix();
  if( select ) glPopName();
  
  glRotatef(-90, 1, 0, 0);
  
  glColor3f(0,0,1.0);
  if( select ) glPushName(8);
    glBegin(GL_LINES);
      glVertex3f( 0, 0, 0 );
      glVertex3f( 0, 0, r );
    glEnd();
    glPushMatrix();
      glTranslatef( 0, 0, r );
      [self cube:s];
    glPopMatrix();  
  glEnd();
  if( select ) glPopName();
  
  if( select ) glPopName();
  
  glPopMatrix();
  
  glLineWidth(1);
  glEnable( GL_LIGHTING );
}

- (void) cube:(float)s
{
  
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

@end
