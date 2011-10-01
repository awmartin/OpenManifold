//
//  Parameter.m
//  OpenManifold
//
//  Created by Allan William Martin on 8/1/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import "Parameter.h"
#import "Geometry.h"
#import "OpenManifoldDocument.h"
#import "MainDocumentWindowController.h"
#import "MainDocumentView.h"
#import "Rule.h"
#import "Part.h"


@implementation Parameter

@synthesize linkages;
@synthesize values;
@synthesize rules;
@synthesize fixedX;
@synthesize fixedY;
@synthesize fixedZ;

- (id) initWithPart:(id)part andGeometry:(Geometry *)geo
{
  self = [super init];
  if( self != nil ) {
    parent = part;
    values = [[NSMutableDictionary alloc] init];
    
    linkages = [NSMutableArray array];     /**< Keeps track of what this parameter is attached to. */
    [linkages retain];
    
    rules = [NSMutableArray array];
    [rules retain];
    
    geometry = geo;
    dirty = NO;
    selected = NO;
    fixed = NO;
  }
  return self;
}

#pragma mark -
#pragma mark Graph

- (void) addRule:(id)newRule
{
  [rules addObject:newRule];
}

- (NSMutableArray*) getUnexecutedRules
{
  NSMutableArray* result = [NSMutableArray array];
  
  for( int i=0; i<[rules count]; i++ ){
    id rule = [rules objectAtIndex:i];
    
    if( ![rule hasBeenExecuted] )
      [result addObject:rule];
  }
  
  return result;
}

- (BOOL) isDirty
{
  return dirty;
}

- (void) setDirty
{
  dirty = YES;
}

- (void) setFixed:(BOOL)x
{
  fixedX = x;
  fixedY = x;
  fixedZ = x;
}

- (BOOL) isFixed
{
  return fixedX and fixedY and fixedZ;
}

- (void) reset
{
  dirty = NO;
}

#pragma mark -
#pragma mark Linkages

- (void) addLinkTo:(int)localObjectIndex type:(NSString *)parameterType geometry:(int)objectType globalIndex:(int)globalIndex
{
  NSMutableArray* newLinkage = [[NSMutableArray alloc] init];
  
  [newLinkage addObject:[NSNumber numberWithInt:localObjectIndex]];   // 0
  [newLinkage addObject:parameterType];                               // 1
  [newLinkage addObject:[NSNumber numberWithInt:objectType]];         // 2
  [newLinkage addObject:[NSNumber numberWithInt:globalIndex]];        // 3
  
  [linkages addObject:newLinkage];
  
  [newLinkage release];
  newLinkage = nil;
}


- (NSString *) getLinkageType:(int)index
{
  return [[linkages objectAtIndex:index] objectAtIndex:1];
}


- (BOOL) isLinkedTo:(int)localIndex objectType:(int)objectType
{
  int i, index, link_object_type;
  for( i=0;i<[linkages count];i++ ){
    index = [[[linkages objectAtIndex:i] objectAtIndex:0] intValue];
    link_object_type = [[[linkages objectAtIndex:i] objectAtIndex:2] intValue];
    
    if( index == localIndex and link_object_type == objectType )
      return YES;
  }
  return NO;
}


- (BOOL) isLinkedTo:(int)globalIndex
{
  int i, index;
  for( i=0;i<[linkages count];i++ ){
    index = [[[linkages objectAtIndex:i] objectAtIndex:3] intValue];
    if( index == globalIndex )
      return YES;
  }
  return NO;
}


#pragma mark -
#pragma mark Values

- (void) initValue:(NSString *)key withNumber:(NSNumber *)value 
{
  [values setObject:value forKey:key];
}


- (void) set:(NSString *)key to:(NSNumber *)value
{
  [self setValue:key withNumber:value];
}


- (void) setValue:(NSString *)key withNumber:(NSNumber *)value 
{
  if ([self isFixed]) return;
  if ([key isEqualToString:@"posX"] and fixedX) return;
  if ([key isEqualToString:@"posY"] and fixedY) return;
  if ([key isEqualToString:@"posZ"] and fixedZ) return;
  
  //printf("The value received in setValue is %f.\n", [value floatValue]);
  [values setObject:value forKey:key];
  
  int count = [linkages count];
  
  if( count > 0 ){
    //printf("Linkages found. Attempting to update objects.\n");
    
    int i;
    for( i=0;i<count;i++ ){
      
      // Handle the control points.
      NSNumber* geometryObjectIndex = [[linkages objectAtIndex:i] objectAtIndex:0];
      NSString* type = [[linkages objectAtIndex:i] objectAtIndex:1];
      NSNumber* objectType = [[linkages objectAtIndex:i] objectAtIndex:2];
      
      // Surface control point?
      if( ([type isEqualToString:@"controlpoint"] or [ type UTF8String ] == "controlpoint") and [objectType intValue] == SURFACE ){
        
        geometry->setSurfaceCV( [geometryObjectIndex intValue], 
                               [[values objectForKey:@"uVal"] intValue], 
                               [[values objectForKey:@"vVal"] intValue], 
                               [[values objectForKey:@"posX"] floatValue], 
                               [[values objectForKey:@"posY"] floatValue], 
                               [[values objectForKey:@"posZ"] floatValue] );
        // end surface controlpoint case
      } else if( ([type isEqualToString:@"controlpoint"] or [ type UTF8String ] == "controlpoint") and [objectType intValue] == CURVE ){
        // Curve control point?
        geometry->setCurveCV( [geometryObjectIndex intValue], 
                           [[values objectForKey:@"uVal"] intValue], 
                           [[values objectForKey:@"posX"] floatValue], 
                           [[values objectForKey:@"posY"] floatValue], 
                           [[values objectForKey:@"posZ"] floatValue] );
        // end curve controlpoint case
      }  else if( ([type isEqualToString:@"endpoint"] or [ type UTF8String ] == "endpoint") and [objectType intValue] == LINE ){
        // Line end point?
        geometry->setLineEndPoint( [geometryObjectIndex intValue], 
                             [[values objectForKey:@"uVal"] intValue], 
                             [[values objectForKey:@"posX"] floatValue], 
                             [[values objectForKey:@"posY"] floatValue], 
                             [[values objectForKey:@"posZ"] floatValue] );
        // end line endpoint case
      } else if( ([type isEqualToString:@"point"] or [ type UTF8String ] == "point") and [objectType intValue] == POINT ){
        geometry->setPoint( [geometryObjectIndex intValue], 
                                  [[values objectForKey:@"posX"] floatValue], 
                                  [[values objectForKey:@"posY"] floatValue], 
                                  [[values objectForKey:@"posZ"] floatValue] );
      }
      
    } // loop through count
    
  } // end count case
  
  [self setDirty];
	[parent update];
}


- (NSNumber *) getValue:(NSString *)key
{
  return [values objectForKey:key];
}


- (float) getFloatValue:(NSString *)key
{
  return [[values objectForKey:key] floatValue];
}


- (int) getIntValue:(NSString *)key
{
  return [[values objectForKey:key] intValue];
}


#pragma mark -
#pragma mark Drawing

- (NSArray*) parentDiagramCoordinates
{
  //NSArray* result = [NSArray arrayWithObjects:[parent diagramPosX],[parent diagramPosY],nil];
  NSArray* result = [NSArray array];
  return result;
}


- (float) parentDiagramPosX
{
  return [parent diagramPosX];
}

- (float) parentDiagramPosY
{
  return [parent diagramPosY];
}


- (void) draw:(BOOL)select zoom:(float)zoom
{
  glDisable( GL_LIGHTING );
  glColor3f( 1.0, 1.0, 1.0 );
  for( int i=0; i<[linkages count]; i++ ){
    
    NSArray* linkage = [linkages objectAtIndex:i];
    NSString* type = [linkage objectAtIndex:1];
    
    if( [type isEqualToString:@"controlpoint"] or [type isEqualToString:@"endpoint"] ){
      
      float x = [[values objectForKey:@"posX"] floatValue];
      float y = [[values objectForKey:@"posY"] floatValue];
      float z = [[values objectForKey:@"posZ"] floatValue];
      
      glPushMatrix();
      {
        glTranslatef( x, y, z );
        glScalef( 0.5*zoom, 0.5*zoom, 0.5*zoom );
      
        if( selected )
          glColor3f(1.0,1.0,0.0);
        else
          glColor3f(1.0,1.0,1.0);
      
        geometry->cube(0.02f);
      }
      glPopMatrix();
      
    }
  
  }
  glEnable( GL_LIGHTING );
}


- (void) focus
{
  [[[[parent document] getWindowController] getMainView] setManipulatorTarget:self];
  selected = YES;
}


#pragma mark -
#pragma mark Selection

- (void) select
{
  selected = YES;
}

- (void) unSelect
{
  selected = NO;
}


- (BOOL) isSelected
{
  return selected;
}

@end
