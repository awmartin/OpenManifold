//
//  GravityLoad.m
//  OpenManifold
//
//  Created by William Martin on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GravityLoad.h"


@implementation GravityLoad

@synthesize x;
@synthesize y;
@synthesize z;
@synthesize loadX;
@synthesize loadY;
@synthesize loadZ;

- (id) initWithX:(double)posX y:(double)posY z:(double)posZ
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
    }
    
    return self;
}

- (double) magnitude
{
  return sqrt( loadX*loadX + loadY*loadY + loadZ*loadZ );
}

- (void) drawLoad
{
  glPushMatrix();
  {
    glDisable( GL_LIGHTING );
    glTranslatef( x, y, z );
    
    double mag = [self magnitude];
    
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
    
    glEnable( GL_LIGHTING );
    
  }
  glPopMatrix();
  
}

- (void)dealloc
{
    [super dealloc];
}

@end
