//
//  RuleEqualPosition.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "RuleEqualPosition.h"

@implementation RuleEqualPosition

- (void) rule
{
  // Conditions.
  if( [dirtyParameters count] == 0 or [cleanParameters count] == 0 ) return;
  if( [dirtyParameters count] > 1 ) return;
  
  // Do the changing.
  Parameter* source = [dirtyParameters objectAtIndex:0];
  Parameter* nodeToChange;
  
  for( int i=0; i<[cleanParameters count]; i++ ){
    nodeToChange = [cleanParameters objectAtIndex:i];
    
    float x = [source getFloatValue:@"posX"];
    float y = [source getFloatValue:@"posY"];
    float z = [source getFloatValue:@"posZ"];
    
    [nodeToChange set:@"posX" to:[NSNumber numberWithFloat:x]];
    [nodeToChange set:@"posY" to:[NSNumber numberWithFloat:y]];
    [nodeToChange set:@"posZ" to:[NSNumber numberWithFloat:z]];
    
    [nodeToChange setDirty];
  }
  
}

- (void) drawDiagram
{
  if( [parameters count] != 2 ) return;
  
  float x0 = [[parameters objectAtIndex:0] parentDiagramPosX];
  float y0 = [[parameters objectAtIndex:0] parentDiagramPosY];
  float x1 = [[parameters objectAtIndex:1] parentDiagramPosX];
  float y1 = [[parameters objectAtIndex:1] parentDiagramPosY];
  
  glBegin(GL_LINES);
  glVertex3f( x0, y0, 0.0f );
  glVertex3f( x1, y1, 0.0f );
  glEnd();
}


@end
