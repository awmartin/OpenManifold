//
//  RuleMaintainDistance.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "RuleMaintainDistance.h"

@implementation RuleMaintainDistance

- (void) setup
{
  p0 = [parameters objectAtIndex:0];
  p1 = [parameters objectAtIndex:1];
  
  float x0 = [p0 getFloatValue:@"posX"];
  float y0 = [p0 getFloatValue:@"posY"];
  float z0 = [p0 getFloatValue:@"posZ"];
  
  float x1 = [p1 getFloatValue:@"posX"];
  float y1 = [p1 getFloatValue:@"posY"];
  float z1 = [p1 getFloatValue:@"posZ"];
  
  dx = x1 - x0;
  dy = y1 - y0;
  dz = z1 - z0;
  
  d = sqrt(dx*dx + dy*dy + dz*dz);
}

- (void) rule
{
  // Conditions.
  if( [dirtyParameters count] == 0 or [cleanParameters count] == 0 ) return;
  if( [dirtyParameters count] > 1 ) return;
  
  if( [p0 isDirty] and ![p1 isDirty] ){
    
    // The one already changed.
    float x0 = [p0 getFloatValue:@"posX"];
    float y0 = [p0 getFloatValue:@"posY"];
    float z0 = [p0 getFloatValue:@"posZ"];
    
    // The one we're changing.
    float x1 = [p1 getFloatValue:@"posX"];
    float y1 = [p1 getFloatValue:@"posY"];
    float z1 = [p1 getFloatValue:@"posZ"];
    
    // The new difference. This determines the new slope.
    float nx = x1 - x0;
    float ny = y1 - y0;
    float nz = z1 - z0;
    
    // The new (wrong) distance.
    float nd = sqrt( nx*nx + ny*ny + nz*nz );
    
    float ratio = d/nd;
    
    // Calculate the new position.
    [p1 set:@"posX" to:[ NSNumber numberWithFloat: x0+nx*ratio ] ];
    [p1 set:@"posY" to:[ NSNumber numberWithFloat: y0+ny*ratio ] ];
    [p1 set:@"posZ" to:[ NSNumber numberWithFloat: z0+nz*ratio ] ];
    
    [p1 setDirty];
  }
  
  if( ![p0 isDirty] and [p1 isDirty] ){
    
    // The one we're changing.
    float x0 = [p0 getFloatValue:@"posX"];
    float y0 = [p0 getFloatValue:@"posY"];
    float z0 = [p0 getFloatValue:@"posZ"];
    
    // The one already changed.
    float x1 = [p1 getFloatValue:@"posX"];
    float y1 = [p1 getFloatValue:@"posY"];
    float z1 = [p1 getFloatValue:@"posZ"];
    
    // The new difference. This determines the new slope.
    float nx = x1 - x0;
    float ny = y1 - y0;
    float nz = z1 - z0;
    
    // The new (wrong) distance.
    float nd = sqrt( nx*nx + ny*ny + nz*nz );
    
    float ratio = d/nd;
    
    // Calculate the new position.
    [p0 set:@"posX" to:[ NSNumber numberWithFloat: x1-nx*ratio ] ];
    [p0 set:@"posY" to:[ NSNumber numberWithFloat: y1-ny*ratio ] ];
    [p0 set:@"posZ" to:[ NSNumber numberWithFloat: z1-nz*ratio ] ];
  
    [p0 setDirty];
  }
  
}

- (void) drawDiagram
{
  if( [parameters count] != 2 ) return;
  
  float x0 = [p0 parentDiagramPosX];
  float y0 = [p0 parentDiagramPosY];
  float x1 = [p1 parentDiagramPosX];
  float y1 = [p1 parentDiagramPosY];

  glBegin(GL_LINES);
  glVertex3f( x0, y0, 0.0f );
  glVertex3f( x1, y1, 0.0f );
  glEnd();
}


@end
