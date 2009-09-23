//
//  RuleMaintainOffset.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "RuleMaintainOffset.h"


@implementation RuleMaintainOffset

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
}

- (void) rule
{
  // Conditions.
  if( [dirtyParameters count] == 0 or [cleanParameters count] == 0 ) return;
  if( [dirtyParameters count] > 1 ) return;
  
  if( [p0 isDirty] and ![p1 isDirty] ){
    
    float x = [p0 getFloatValue:@"posX"];
    float y = [p0 getFloatValue:@"posY"];
    float z = [p0 getFloatValue:@"posZ"];
    
    [p1 set:@"posX" to:[ NSNumber numberWithFloat: x+dx ] ];
    [p1 set:@"posY" to:[ NSNumber numberWithFloat: y+dy ] ];
    [p1 set:@"posZ" to:[ NSNumber numberWithFloat: z+dz ] ];
    
    [p1 setDirty];
  }
  
  if( ![p0 isDirty] and [p1 isDirty] ){
    
    float x = [p1 getFloatValue:@"posX"];
    float y = [p1 getFloatValue:@"posY"];
    float z = [p1 getFloatValue:@"posZ"];
    
    [p0 set:@"posX" to:[ NSNumber numberWithFloat: x-dx ] ];
    [p0 set:@"posY" to:[ NSNumber numberWithFloat: y-dy ] ];
    [p0 set:@"posZ" to:[ NSNumber numberWithFloat: z-dz ] ];
    
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
