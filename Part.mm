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
#import "OpenManifoldDocument.h"
#import "MainDocumentWindowController.h"
#import "MainDocumentView.h"
#import "ThickenedSurface.h"
#import "MeshPoint.h"
#import "GravityLoad.h"
#import "SupportZone.h"

@implementation Part

@synthesize parameters;
@synthesize meshPoints;
@synthesize geometries;
@synthesize document;
@synthesize name;
@synthesize diagramPosX;
@synthesize diagramPosY;
@synthesize behaviors;
@synthesize derivedProperties;
@synthesize loads;
@synthesize supports;

- (id) initWithWrapper:(ON_Wrapper*)wrap forDocument:(id)doc;
{
  self = [super init];
  if( self != nil ){
    document = doc;
    
    geometry = new Geometry(wrap->model);
    selected = NO;

    parameters = [NSMutableArray array];
    [parameters retain];
    
    meshPoints = [NSMutableArray array];
    [meshPoints retain];
    
    behaviors = [NSMutableArray array];
    [behaviors retain];
		
		derivedProperties = [NSMutableArray array];
		[derivedProperties retain];
    
    loads = [NSMutableArray array];
    [loads retain];
    
    supports = [NSMutableArray array];
    [supports retain];
    
    diagramPosX = 0;
    diagramPosY = 0;
    
    draggingDiagram = NO;
    
    name = @"New Part";
    [name retain];
  }
  return self;
}

- (void) thickenSurfaceTest
{
	if( geometry->surfaces_table.size() > 0 ){
		geometry->thickenSurface(0, 0.1);
	}
}

- (void) thicken
{
	ThickenedSurface* tr = [[ThickenedSurface alloc] initWithSurface:0 andGeometry:geometry andPart:self];
	[derivedProperties addObject:tr];
}

- (void) thicken:(double)thickness
{
  ThickenedSurface* tr = [[ThickenedSurface alloc] initWithSurface:0 andGeometry:geometry andPart:self andThickness:thickness];
	[derivedProperties addObject:tr];
}

- (void) update
{
	for( int i=0; i<[derivedProperties count]; i++ ){
		[[derivedProperties objectAtIndex:i] update];
	}
}

- (void) mesh
{
	if( [derivedProperties count] > 0 ){
		[[derivedProperties objectAtIndex:0] mesh];
	}
}

- (void) showMesh
{
	if( [derivedProperties count] > 0 ){
		[[derivedProperties objectAtIndex:0] showMesh];
	}
}

- (void) addMeshPoint:(double)posX y:(double)posY z:(double)posZ index:(int)pointIndex
{
  MeshPoint* p = [[MeshPoint alloc] initWithX:posX y:posY z:posZ index:pointIndex];
  [meshPoints addObject:p];
}

- (void) removeAllMeshPoints
{
  [meshPoints removeAllObjects];
}

- (void) analyze
{
	if( [derivedProperties count] > 0 ){
    // Pass in the restraints and the loads.
		[[derivedProperties objectAtIndex:0] analyze:[self meshPoints] withLoads:[self getLoads]];
	}
}

- (void) refreshAnalysis
{
  [self removeAllMeshPoints];
  if( [derivedProperties count] > 0 ){
		[[derivedProperties objectAtIndex:0] refreshAnalysis];
	}
}

- (void) addSupport:(double)sx sy:(double)sy sz:(double)sz ex:(double)ex ey:(double)ey ez:(double)ez
{
  SupportZone* z = [[SupportZone alloc] init];
  z.startX = sx;
  z.startY = sy;
  z.startZ = sz;
  z.endX = ex;
  z.endY = ey;
  z.endZ = ez;
  [supports addObject:z];
}

- (bool) supportsToPoints
{
  bool foundPoints = NO;
  for( int i=0; i<[supports count]; i++ ){
    SupportZone* support = [supports objectAtIndex:i];
    NSMutableArray* fixedPoints = [NSMutableArray array];
    for( int p=0; p<[meshPoints count]; p++ ){
      MeshPoint* pt = [meshPoints objectAtIndex:p];
      if ((pt.x <= support.endX && pt.x >= support.startX) && 
          (pt.y <= support.endY && pt.y >= support.startY) &&
          (pt.z <= support.endZ && pt.z >= support.startZ)){
        [fixedPoints addObject:pt];
        foundPoints = YES;
      }
    }
    
    if( foundPoints ){
      for( int p; p<[fixedPoints count]; p++ ){
        MeshPoint* pt = [fixedPoints objectAtIndex:p];
        pt.locked = YES;
      }
    }
  }
  return foundPoints;
}

- (void) addLoad:(double)x y:(double)y z:(double)z loadY:(double)loadY
{
  GravityLoad* ld = [[GravityLoad alloc] initWithX:x y:y z:z];
  ld.loadY = loadY;
  [loads addObject:ld];
}

// Loops through all the loads and points to assign actual loads to generated mesh points.
- (bool) loadsToPoints
{
  bool foundPoints = NO;
  double loadRadius = 0.5;
  for( int i=0; i<[loads count]; i++ ){
    NSMutableArray* cachedPoints = [NSMutableArray array];
    
    GravityLoad* l = [loads objectAtIndex:i];
    
    for( int p=0; p<[meshPoints count]; p++ ){
      MeshPoint* pt = [meshPoints objectAtIndex:p];
      
      // Just the distance in the xz plane.
      double dist = sqrt( pow(l.x-pt.x,2) + pow(l.z-pt.z,2) );
      if ( dist < loadRadius ){
        foundPoints = YES;
        [cachedPoints addObject:pt];
      }
    }
    
    // Distribute the load and add to the y component of the point load.
    if( foundPoints ) {
      double loadValue = [l magnitude] / double([cachedPoints count]);
      for( int p=0; p<[cachedPoints count]; p++){
        MeshPoint* pt = [cachedPoints objectAtIndex:p];
        pt.loadY += -loadValue; // They're negative...
      }
    }
  }
  
  return foundPoints;
}

- (NSArray *) getLoads
{
  NSMutableArray* tr = [NSMutableArray array];
  for( int i=0; i<[meshPoints count]; i++ ){
    MeshPoint* pt = [meshPoints objectAtIndex:i];
    if( [ pt hasLoad ] )
      [tr addObject:pt];
  }
  return tr;
}

- (NSArray *) getRestraints
{
  NSMutableArray* tr = [NSMutableArray array];
  for( int i=0; i<[meshPoints count]; i++ ){
    MeshPoint* pt = [meshPoints objectAtIndex:i];
    if( [ pt locked ] )
      [tr addObject:pt];
  }
  return tr;
}

- (void) processResults
{
	if( [derivedProperties count] > 0 ){
		[[derivedProperties objectAtIndex:0] processResults];
	}
}

- (double) meshVolume
{
  if( [derivedProperties count] > 0 ){
		return [[derivedProperties objectAtIndex:0] meshVolume];
	}
  return 0;
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

- (void) addPoint:(NSString *)name x:(float)x y:(float)y z:(float)z
{
	geometry->addPoint( x, y, z );
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

- (void) addSimpleSurface
{
	int uCount = 2;
	int vCount = 2;
  
  const int dim = 3;
  const int u_degree = 1;
  const int v_degree = 1;
  const int u_cv_count = uCount;
  const int v_cv_count = vCount;
  const int u_knot_count = u_cv_count + u_degree - 1;
  const int v_knot_count = v_cv_count + v_degree - 1;
  double u_knot[ u_knot_count ];
  double v_knot[ v_knot_count ];
	
	u_knot[0] = 0;
	u_knot[1] = 1;
	v_knot[0] = 0;
	v_knot[1] = 1;
  
  int surface_index = geometry->addEmptySurface( dim, u_cv_count, v_cv_count, u_degree, v_degree );
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
  
  
  int surface_index = geometry->addEmptySurface( dim, u_cv_count, v_cv_count, u_degree, v_degree );
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
  for( int i=0; i<[meshPoints count]; i++ )
    [[meshPoints objectAtIndex:i] setSelected:NO];
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


- (void) selectMeshPoint:(int)localObjectIndex
{
  [[meshPoints objectAtIndex:localObjectIndex] setSelected:YES];
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


- (NSMutableArray *) getSelectedMeshPoints
{
  NSMutableArray* params = [NSMutableArray array];
  
  for( int i=0; i<[meshPoints count]; i++ ){
    MeshPoint* p = [meshPoints objectAtIndex:i];
    
    if( [p selected] )
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
    glPushName(PARAMETER);
    
    for( int i=0; i<[parameters count]; i++ ){
      if( select ) glPushName(i);
      
      [[parameters objectAtIndex:i] draw:select zoom:zoom];
      
      if( select ) glPopName();
    }
    glPopName();
    
    geometry->drawParameterLines(select);
  }
  
  if( [document getEditingMode] == MESHPOINT ){
    // Draw points here, selectable for choosing loads and restraints for analysis.
    // The 'geometry' object should keep track of the selectable points.
    glPushName(MESHPOINT);
    for( int i=0; i<[meshPoints count]; i++ )
    {
      if( select ) glPushName(i);
      
      // local object index
      [[meshPoints objectAtIndex:i] drawMeshPoint];
      
      if( select ) glPopName();
    }
    glPopName();
  }
  
  for( int i=0; i<[loads count]; i++ ){
    [[loads objectAtIndex:i] drawLoad];
  }
  
  for( int i=0; i<[supports count]; i++ ){
    [[supports objectAtIndex:i] drawSupport];
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
