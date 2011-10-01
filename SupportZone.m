//
//  SupportZone.m
//  OpenManifold
//
//  Created by William Martin on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SupportZone.h"


@implementation SupportZone

@synthesize startX;
@synthesize startY;
@synthesize startZ;
@synthesize endX;
@synthesize endY;
@synthesize endZ;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
      startX = 0;
      startY = 0;
      startZ = 0;
      endX = 0;
      endY = 0;
      endZ = 0;
    }
    
    return self;
}

- (void) drawSupport
{
  glDisable(GL_LIGHTING);
  glColor4d(1.0,1.0,1.0,1.0);
  glPushMatrix();
  {
    glBegin(GL_LINES);
    
    // Bottom rect.
    glVertex3d(startX,startY,startZ);
    glVertex3d(startX,endY,startZ);
    
    glVertex3d(startX,endY,startZ);
    glVertex3d(endX,endY,startZ);
    
    glVertex3d(endX,endY,startZ);
    glVertex3d(endX,startY,startZ);
    
    glVertex3d(endX,startY,startZ);
    glVertex3d(startX,startY,startZ);
    
    // Top rect.
    glVertex3d(startX,startY,endZ);
    glVertex3d(startX,endY,endZ);
    
    glVertex3d(startX,endY,endZ);
    glVertex3d(endX,endY,endZ);
    
    glVertex3d(endX,endY,endZ);
    glVertex3d(endX,startY,endZ);
    
    glVertex3d(endX,startY,endZ);
    glVertex3d(startX,startY,endZ);
    
    // Middle 4 connecting lines.
    glVertex3d(startX,startY,startZ);
    glVertex3d(startX,startY,endZ);
    
    glVertex3d(startX,endY,startZ);
    glVertex3d(startX,endY,endZ);
    
    glVertex3d(endX,endY,startZ);
    glVertex3d(endX,endY,endZ);
    
    glVertex3d(endX,startY,startZ);
    glVertex3d(endX,startY,endZ);
    
    glEnd();
  }
  glPopMatrix();
  glEnable(GL_LIGHTING);
}

- (void)dealloc
{
    [super dealloc];
}

@end
