//
//  Part.m
//  OpenManifold
//
//  Created by Allan William Martin on 7/22/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//


#import "Geometry.h"
#import "Part.h"
#import "Parameter.h"
#import "opennurbs_interface.h"
#import "Behavior.h"

@implementation Part

@synthesize parameters;
@synthesize geometries;
@synthesize document;
@synthesize name;
@synthesize diagramPosX;
@synthesize diagramPosY;
@synthesize behaviors;

- (id) initWithWrapper:(ON_Wrapper*)wrap forDocument:(id)doc;
{
  self = [super init];
  if( self != nil ){
    document = doc;
    
    geometry = new Geometry(wrap->model);
    selected = NO;

    parameters = [NSMutableArray array];
    [parameters retain];
    
    behaviors = [NSMutableArray array];
    [behaviors retain];
    
    diagramPosX = 0;
    diagramPosY = 0;
    
    draggingDiagram = NO;
    
    name = @"New Part";
    [name retain];
  }
  return self;
}


- (void) behave
{
  if( [behaviors count] > 0 )
    for( int i=0; i<[behaviors count]; i++ )
      [[behaviors objectAtIndex:i] execute];
    
  [document updateGraph];
}

- (void) addBehavior:(id)behavior
{
  [behavior setup];
  [behaviors addObject:behavior];
  
  Behavior* b = [behaviors lastObject];
  b.part = self;
}  

#pragma mark -
#pragma mark Adding Geometry.

- (id) addPointParameter:(NSString *)name x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z
{
  Parameter* point = [[Parameter alloc] initWithPart:self andGeometry:geometry];
  
  [ point initValue:@"posX" withNumber:x ];
  [ point initValue:@"posY" withNumber:y ];
  [ point initValue:@"posZ" withNumber:z ];
  
  [parameters addObject:point];
  
  return point;
}


- (void) addLine
{
  int line_index = geometry->addLine( 0.0, 0.0, 0.0, 1.0, 0.0, 0.0 );
  int global_index = geometry->getGlobalIndex(line_index, LINE);
  
  // Create the Parameter for this control vector.
  Parameter* point1 = [[Parameter alloc] initWithPart:self andGeometry:geometry];
  [ point1 initValue:@"uVal" withNumber:[NSNumber numberWithInt:0]];
  [ point1 initValue:@"posX" withNumber:[NSNumber numberWithFloat:0.0 ]];
  [ point1 initValue:@"posY" withNumber:[NSNumber numberWithFloat:0.0 ]];
  [ point1 initValue:@"posZ" withNumber:[NSNumber numberWithFloat:0.0 ]];
  [parameters addObject:point1];
  
  [point1 addLinkTo:line_index type:@"endpoint" geometry:LINE globalIndex:global_index];
  
  Parameter* point2 = [[Parameter alloc] initWithPart:self andGeometry:geometry];
  [ point2 initValue:@"uVal" withNumber:[NSNumber numberWithInt:1]];
  [ point2 initValue:@"posX" withNumber:[NSNumber numberWithFloat:1.0 ]];
  [ point2 initValue:@"posY" withNumber:[NSNumber numberWithFloat:0.0 ]];
  [ point2 initValue:@"posZ" withNumber:[NSNumber numberWithFloat:0.0 ]];
  [parameters addObject:point2];
  
  [point2 addLinkTo:line_index type:@"endpoint" geometry:LINE globalIndex:global_index];
}

- (void) addCurve
{
  [self addCurve:6];
}

- (void) addCurve: (int)uCount
{
  if( uCount < 4 ) return; // Must be at least 4 for dim = 3.
  
  bool rational = false;
  const int dim = 3;
  const int order = dim + 1;
  const int num_control_vertices = uCount; 
  const int u_knot_count = order+num_control_vertices-2;
  double u_knot[ u_knot_count ];
  
  // Create the curves and grab the local and global indices.
  int curve_index = geometry->addNewCurve( dim, rational, order, num_control_vertices );
  int global_index = geometry->getGlobalIndex(curve_index, CURVE);
  
  // Set the knots.
  int u_max = u_knot_count - 5;
  
  for( int u=0; u<3; u++ )
    u_knot[u] = 0.0;
  
  if( u_knot_count >= 7 )
    for( int u=3;u<u_knot_count-3;u++ )
      u_knot[u] = u-2;
  
  for( int u=u_knot_count-3;u<u_knot_count;u++ )
    u_knot[u] = u_max;
  
  
  for( int i=0;i<u_knot_count;i++ )
    geometry->setCurveKnot( curve_index, i, u_knot[i] );
  
  // Add the control vertices.
  float x, y, z;
  for ( int i = 0; i < num_control_vertices; i++ ) {
    x = i;
    y = 0;
    z = 0;
    
    // Create the Parameter for this control vector.
    Parameter* point = [[Parameter alloc] initWithPart:self andGeometry:geometry];
    [ point initValue:@"uVal" withNumber:[NSNumber numberWithInt:i ]];
    [ point initValue:@"posX" withNumber:[NSNumber numberWithFloat:x ]];
    [ point initValue:@"posY" withNumber:[NSNumber numberWithFloat:y ]];
    [ point initValue:@"posZ" withNumber:[NSNumber numberWithFloat:z ]];
    [parameters addObject:point];
    
    [point addLinkTo:curve_index type:@"controlpoint" geometry:CURVE globalIndex:global_index];
    
    geometry->setCurveCV( curve_index, i, x, y, z );
  }
  
  geometry->finishCurve( curve_index );
}

- (void) addSurface:(NSString*)identifier u:(int)uCount v:(int)vCount
{
  if( uCount < 4 ) return;
  if( vCount < 4 ) return;
  
  const int dim = 3;
  const int u_degree = 3;
  const int v_degree = 3;
  const int u_cv_count = uCount;
  const int v_cv_count = vCount;
  const int u_knot_count = u_cv_count + u_degree - 1;
  const int v_knot_count = v_cv_count + v_degree - 1;
  double u_knot[ u_knot_count ];
  double v_knot[ v_knot_count ];
  
  // Set u knot vector.
  int u_max = u_knot_count - 5;
  
  for( int u=0; u<3; u++ )
    u_knot[u] = 0.0;
  
  if( u_knot_count >= 7 )
    for( int u=3;u<u_knot_count-3;u++ )
      u_knot[u] = u-2;
    
  for( int u=u_knot_count-3;u<u_knot_count;u++ )
    u_knot[u] = u_max;
  
  
  // Set the v knot vector.
  int v_max = v_knot_count - 5;
  
  for( int v=0; v<3; v++ )
    v_knot[v] = 0.0;
  
  if( v_knot_count >= 7 )
    for( int v=3;v<v_knot_count-3;v++ )
      v_knot[v] = v-2;
    
  for( int v=v_knot_count-3;v<v_knot_count;v++ )
    v_knot[v] = v_max;
  
  
  int surface_index = geometry->addEmptySurface( dim, u_cv_count, v_cv_count );
  int global_index = geometry->getGlobalIndex(surface_index, SURFACE);
  int i, j;
  
  for ( i = 0; i < u_knot_count; i++ )
    geometry->setSurfaceKnot( surface_index, 0, i, u_knot[i] );
  
  for ( j = 0; j < v_knot_count; j++ )
    geometry->setSurfaceKnot( surface_index, 1, j, v_knot[j] );
  
  
  float x, y, z;
  for ( i = 0; i < u_cv_count; i++ ) {
    for ( j = 0; j < v_cv_count; j++ ) {
      x = i;
      y = j;
      z = 0;
      
      // Create the Parameter for this control vector.
      Parameter* point = [[Parameter alloc] initWithPart:self andGeometry:geometry];
      [ point initValue:@"uVal" withNumber:[NSNumber numberWithInt:i ]];
      [ point initValue:@"vVal" withNumber:[NSNumber numberWithInt:j ]];
      [ point initValue:@"posX" withNumber:[NSNumber numberWithFloat:x ]];
      [ point initValue:@"posY" withNumber:[NSNumber numberWithFloat:y ]];
      [ point initValue:@"posZ" withNumber:[NSNumber numberWithFloat:z ]];
      [parameters addObject:point];
      
      // Note: this adds with the surface_index, which could be a problem later when
      // other object types are added. 
      // Hook this new Parameter up with the surface.
      [point addLinkTo:surface_index type:@"controlpoint" geometry:SURFACE globalIndex:global_index];
      
      geometry->setSurfaceCV( surface_index, i, j, x, y, z );
    }
  }
  
  geometry->finishSurface( surface_index );
  
}

- (void) addSurface
{
  [self addSurface:@"" u:5 v:5];
}

#pragma mark -
#pragma mark Transformations.

- (void) translate:(double)dx dy:(double)dy dz:(double)dz
{
  geometry->translate(dx,dy,dz);
  [self updateParametersFromGeometry];
}


- (void) translateGeometry:(int)geometryIndex dx:(double)dx dy:(double)dy dz:(double)dz
{
  geometry->translateObject( geometryIndex, dx, dy, dz );
  [self updateParametersFromGeometry];
}


- (void) scale:(double)x y:(double)y z:(double)z
{
  geometry->scale(x, y, z);
  [self updateParametersFromGeometry];
}


- (void) scaleGeometry:(int)geometryIndex x:(double)x y:(double)y z:(double)z
{
  geometry->scaleObject( geometryIndex, x, y, z );
  [self updateParametersFromGeometry];
}


- (void) rotateGeometry:(int)geometryIndex angle:(float)angle axisX:(double)ax axisY:(double)ay axisZ:(double)az centerX:(double)cx centerY:(double)cy centerZ:(double)cz
{
  geometry->rotateObject( geometryIndex, angle, ax, ay, az, cx, cy, cz );
  
  [self updateParametersFromGeometry];
}

- (void) rotate:(float)angle axisX:(double)ax axisY:(double)ay axisZ:(double)az centerX:(double)cx centerY:(double)cy centerZ:(double)cz
{
  geometry->rotate( angle, ax, ay, az, cx, cy, cz );
  [self updateParametersFromGeometry];
}

- (void) rotateGeometryX:(int)geometryIndex angle:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz
{
  geometry->rotateObject( geometryIndex, angle, 1, 0, 0, cx, cy, cz );
  [self updateParametersFromGeometry];
}

- (void) rotateX:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz
{
  geometry->rotate( angle, 1, 0, 0, cx, cy, cz );
  [self updateParametersFromGeometry];
}

- (void) rotateGeometryY:(int)geometryIndex angle:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz
{
  geometry->rotateObject( geometryIndex, angle, 0, 1, 0, cx, cy, cz );
  [self updateParametersFromGeometry];
}

- (void) rotateY:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz
{
  geometry->rotate( angle, 0, 1, 0, cx, cy, cz );
  [self updateParametersFromGeometry];
}

- (void) rotateGeometryZ:(int)geometryIndex angle:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz
{
  geometry->rotateObject( geometryIndex, angle, 0, 0, 1, cx, cy, cz );
  [self updateParametersFromGeometry];
}

- (void) rotateZ:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz
{
  geometry->rotate( angle, 0, 0, 1, cx, cy, cz );
  [self updateParametersFromGeometry];
}


- (void) updateParametersFromGeometry
{
  int s, p, i, j;
  double pt[3];
  Parameter* param;
  
  // Loop through all the surfaces.
  for( s=0;s<geometry->getSurfaceCount();s++ ){
    
    // Loop through all the parameters.
    for( p=0;p<[parameters count];p++ ){
      
      // If this parameter is attached to this surface, get the new value.
      if( [[parameters objectAtIndex:p] isLinkedTo:s objectType:SURFACE] ){
        
        param = [parameters objectAtIndex:p];
        i = [param getIntValue:@"uVal"];
        j = [param getIntValue:@"vVal"];
        
        // Get the new point.
        geometry->getSurfaceCV(s, i, j, pt);
        
        // Set the parameter.
        [param initValue:@"posX" withNumber:[NSNumber numberWithDouble:pt[0]]];
        [param initValue:@"posY" withNumber:[NSNumber numberWithDouble:pt[1]]];
        [param initValue:@"posZ" withNumber:[NSNumber numberWithDouble:pt[2]]];
      }
    }
  
  }
  
  // Loop through all the curves.
  for( s=0;s<geometry->getGeometryCount(CURVE);s++ ){
    
    // Loop through all the parameters.
    for( p=0;p<[parameters count];p++ ){
      
      // If this parameter is attached to this curve, get the new value.
      if( [[parameters objectAtIndex:p] isLinkedTo:s objectType:CURVE] ){
        
        param = [parameters objectAtIndex:p];
        i = [param getIntValue:@"uVal"];
        
        // Get the new point.
        geometry->getCurveCV(s, i, pt);
        
        // Set the parameter.
        [param initValue:@"posX" withNumber:[NSNumber numberWithDouble:pt[0]]];
        [param initValue:@"posY" withNumber:[NSNumber numberWithDouble:pt[1]]];
        [param initValue:@"posZ" withNumber:[NSNumber numberWithDouble:pt[2]]];
      }
    }
    
  }
  
  
  // Loop through all the lines.
  for( s=0;s<geometry->getGeometryCount(LINE);s++ ){
    
    // Loop through all the parameters.
    for( p=0;p<[parameters count];p++ ){
      
      // If this parameter is attached to this line, get the new value.
      if( [[parameters objectAtIndex:p] isLinkedTo:s objectType:LINE] ){
        
        param = [parameters objectAtIndex:p];
        i = [param getIntValue:@"uVal"];
        
        // Get the new point.
        geometry->getLineEndPoint(s, i, pt);
        
        // Set the parameter.
        [param initValue:@"posX" withNumber:[NSNumber numberWithDouble:pt[0]]];
        [param initValue:@"posY" withNumber:[NSNumber numberWithDouble:pt[1]]];
        [param initValue:@"posZ" withNumber:[NSNumber numberWithDouble:pt[2]]];
      }
    }
    
  }
}


#pragma mark -
#pragma mark Selection.

- (BOOL) isSelected
{
  return selected;
}


- (void) select
{
  selected = YES;
  geometry->selectAll();
}


- (void) unselect
{
  selected = NO;
  geometry->unselectAll();
}


- (void) selectPartContaining:(int)globalObjectIndex
{
  if( geometry->contains(globalObjectIndex) )
    [self select];
}


- (void) selectGeometry:(int)globalObjectIndex
{
  geometry->selectGeometry(globalObjectIndex);
}


- (void) unhighlightPart
{
  selected = NO;
  geometry->unselectAll();
}


- (NSMutableArray *) indicesForSelectedGeometry
{
  int i;
  int* rawIndices = geometry->getObjectIndicies();
  int* selections = geometry->getSelected();
  
  NSMutableArray *indices = [NSMutableArray array];
  
  for( i=0;i<geometry->getObjectCount();i++ ){
    if( selections[i] == 1 )
      [ indices addObject:[ NSNumber numberWithInt:rawIndices[i] ] ];
  }
  
  return indices;
}


- (NSMutableArray *) parametersForSelectedGeometry
{
  NSMutableArray *indices = [self indicesForSelectedGeometry];
  NSMutableArray *params = [NSMutableArray array];
  
  int i;
  for( i=0;i<[indices count];i++ ){
    [params addObjectsFromArray:[ self parametersForGeometry:[[indices objectAtIndex:i] intValue]]];
  }
  
  return params;
}


- (int) objectCount
{
  return geometry->getObjectCount();
}


- (NSString *) getUUID:(int)globalObjectIndex
{
  return [NSString stringWithUTF8String:geometry->getUUID(globalObjectIndex)];
}

- (NSMutableArray *) objectIndices
{
  // Have to convert this to an NSMutableArray so these numbers are easily
  // accessible as an array in the scripting window.
  int i;
  int* rawIndices = geometry->getObjectIndicies();
  
  NSMutableArray *indices = [NSMutableArray array];
  
  for( i=0;i<geometry->getObjectCount();i++ )
    [indices addObject:[NSNumber numberWithInt:rawIndices[i]]];
  
  return indices;
}

- (NSMutableArray *) parametersForGeometry:(int)globalIndex
{
  NSMutableArray* params = [NSMutableArray array];
  
  int i;
  for( i=0;i<[parameters count];i++ ){
    if( [[parameters objectAtIndex:i] isLinkedTo:globalIndex] )
      [params addObject: [parameters objectAtIndex:i]];
  }
  
  return params;
}

- (NSMutableArray *) getSelectedParameters
{
  NSMutableArray* params = [NSMutableArray array];
  
  for( int i=0; i<[parameters count]; i++ ){
    id p = [parameters objectAtIndex:i];
    
    if( [p isSelected] )
      [ params addObject:p ];
  }
    
  return params;
}

#pragma mark -
#pragma mark Graph

- (NSMutableArray*) getAllDirtyParameters
{
  NSMutableArray* result = [NSMutableArray array];
  for( int j=0; j<[parameters count]; j++ ){
    
    id p = [parameters objectAtIndex:j];
    
    if( [p isDirty] )
      [result addObject:p];
    
  } // end parameters loop
  return result;
}

- (void) cleanAllParameters
{
  [parameters makeObjectsPerformSelector:@selector(reset)];
}

#pragma mark -
#pragma mark Drawing.

- (void) draw:(BOOL)select zoom:(float)zoom
{
  if( geometry->getObjectCount() == 0 ) {
    [[[document getWindowController] getMainView] cube:0.5];
  }
  
  if( [document getEditingMode] == PARAMETER ){
    for( int i=0; i<[parameters count]; i++ ){
      if( select ) glPushName(i);
      
      [[parameters objectAtIndex:i] draw:select zoom:zoom];
      
      if( select ) glPopName();
    }
    
    geometry->drawParameterLines(select);
  }
  
}


- (void) dragInDiagram:(float)dx dy:(float)dy
{
  /*[diagramPosX release];
  [diagramPosY release];
  diagramPosX = [NSNumber numberWithFloat:[diagramPosX floatValue]+dx];
  diagramPosY = [NSNumber numberWithFloat:[diagramPosY floatValue]+dy];*/
  diagramPosX += dx;
  diagramPosY += dy;
}


- (void) drawDiagram:(BOOL)select
{
  glRectf(diagramPosX, diagramPosY, diagramPosX+10, diagramPosY+10);
}

@end