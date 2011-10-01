//
//  MeshPoint.mm
//  OpenManifold
//
//  Created by William Martin on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MeshPoint.h"


@implementation MeshPoint

@synthesize x;
@synthesize y;
@synthesize z;
@synthesize loadX;
@synthesize loadY;
@synthesize loadZ;
@synthesize selected;
@synthesize locked;
@synthesize index;

- (id) initWithX:(double)posX y:(double)posY z:(double)posZ index:(int)pointIndex
{
    self = [super init];
    if (self) {
      // Initialization code here.
      self.x = posX;
      self.y = posY;
      self.z = posZ;
      
      self.loadX = 0.0;
      self.loadY = 0.0;
      self.loadZ = 0.0;
      
      self.selected = NO;
      self.locked = NO;
      
      self.index = pointIndex;
    }
    
    return self;
}

- (void) drawMeshPoint
{
  glPushMatrix();
  {
    glDisable( GL_LIGHTING );
    glTranslatef( x, y, z );
    
    if( selected )
      glColor3f(1.0,1.0,0.0);
    else
      glColor3f(1.0,0.0,0.0);
    
    float s = 0.05;
    
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
    
    
    double mag = sqrt( loadX*loadX + loadY*loadY + loadZ*loadZ );
    
    if ( mag > 0.0 ) {
      
      float r = 0.05;
      float o = 0.1;
      
      double magXZ = sqrt(loadX*loadX + loadZ*loadZ);
      double altitude = atan2(magXZ, loadY) * 180.0 / pi;
      double azimuth = atan2(-loadZ, loadX) * 180.0 / pi;
      
      glPushMatrix();
      glTranslated( -loadX, -loadY, -loadZ );
      //glScalef( 0.3,0.3,0.3 );
      
      glRotated( azimuth, 0, 1.0, 0 );
      glRotated( altitude, 0, 0, -1.0 );
      
      glColor3f( 0, 1.0, 0 );
      
      glBegin(GL_QUAD_STRIP);
      for( float a=0; a<=2*pi+pi/10; a+=pi/10 ){
        glVertex3f( r*cos(a), (float)mag - 0.5f, r*sin(a) );
        glVertex3f( r*cos(a), -0.5f, r*sin(a) );
      }
      glEnd();
      
      glBegin(GL_TRIANGLE_STRIP);
      for( float a=0; a<=2*pi+pi/10; a+=pi/10 ){
        glVertex3f( 0, (float)mag, 0 );
        glVertex3f( o*cos(a), (float)mag - 0.5f, o*sin(a) );
      }
      glEnd();
      
      glPopMatrix();
    }
    
    if( locked ){
      glColor3f(1,1,1);
      
      glPushMatrix();
      {
        float s = 0.2;
        glScalef(s, s, s);
        
        glBegin(GL_LINES);
        {
          glVertex3f(1,1,1);
          glVertex3f(-1,-1,-1);
          glVertex3f(1,-1,1);
          glVertex3f(-1,1,-1);
          
          glVertex3f(-1,1,1);
          glVertex3f(1,-1,-1);
          glVertex3f(-1,-1,1);
          glVertex3f(1,1,-1);
        }
        glEnd();
      
      }
      glPopMatrix();
      
    }
    
    glEnable( GL_LIGHTING );

  }
  glPopMatrix();
  
}

- (BOOL) hasLoad
{
  return loadX != 0.0 or loadY != 0.0 or loadZ != 0.0;
}

- (void)dealloc
{
    [super dealloc];
}

@end
