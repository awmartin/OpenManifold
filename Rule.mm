//
//  Rule.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "Rule.h"


@implementation Rule

@synthesize parameters;

- (id) initWithParameters:(NSArray*)params
{
  self = [super init];
  if( self != nil ){
    parameters = [params mutableCopy];
    
    for( int i=0; i<[parameters count]; i++ ){
      [[parameters objectAtIndex:i] addRule:self];
    }
    
    done = NO;
    dirtyParameters = [NSMutableArray array];
    [dirtyParameters retain];
    
    cleanParameters = [NSMutableArray array];
    [cleanParameters retain];
    
    [self setup];
  }
  return self;
}

- (BOOL) hasBeenExecuted
{
  return done;
}

- (void) setup
{
  
}

- (void) findDirtyNodes
{
  [dirtyParameters removeAllObjects];
  [cleanParameters removeAllObjects];
  
  for( int i=0; i<[parameters count]; i++ ){
    
    if( [[parameters objectAtIndex:i] isDirty] ) {
      [dirtyParameters addObject:[parameters objectAtIndex:i]];
    } else {
      [cleanParameters addObject:[parameters objectAtIndex:i]];
    }
    
  }
}


- (void) applyRule
{
  if( done ) return;
  
  [self findDirtyNodes];
  
  [self rule];
  
  for( int i=0; i<[parameters count]; i++ )
    [[parameters objectAtIndex:i] setDirty];
  
  done = YES;
}


- (void) rule
{
  
}


- (void) drawDiagram
{
  
}

- (void) drawRule
{
  glEnable(GL_LINE_STIPPLE);
  glLineStipple(1, 0xF0F0);
  
  glDisable(GL_LIGHTING);
  glColor3f(1.0f,0.0f,0.0f);
  glLineWidth(2.0f);
  
  for( int i=0; i<[parameters count]-1; i++ ){

    Parameter* p0 = [parameters objectAtIndex:i];
    Parameter* p1 = [parameters objectAtIndex:i+1];
    
    float x0 = [p0 getFloatValue:@"posX"];
    float y0 = [p0 getFloatValue:@"posY"];
    float z0 = [p0 getFloatValue:@"posZ"];
    
    float x1 = [p1 getFloatValue:@"posX"];
    float y1 = [p1 getFloatValue:@"posY"];
    float z1 = [p1 getFloatValue:@"posZ"];
  
    glBegin(GL_LINES);
    glVertex3f( x0, y0, z0 );
    glVertex3f( x1, y1, z1 );
    glEnd();
  }
  
  glEnable(GL_LIGHTING);
  glDisable(GL_LINE_STIPPLE);
  glLineWidth(1.0f);
}


- (NSMutableArray*) getOtherParameters:(Parameter*)param
{
  NSMutableArray* params = [parameters mutableCopy];
  [params removeObjectIdenticalTo:param];
  return params;
}

- (int) numberOfRequiredParameters
{
  return 0;
}


- (void) reset
{
  done = NO;
  
  [parameters makeObjectsPerformSelector:@selector(reset)];
}


- (void) dealloc
{
  [super dealloc];
}

@end
