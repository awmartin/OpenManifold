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
      
      self.selected = NO;
      self.locked = NO;
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
    
    glEnable( GL_LIGHTING );
    // TODO: draw load arrow
  }
  glPopMatrix();
  
}

- (void)dealloc
{
    [super dealloc];
}

@end
