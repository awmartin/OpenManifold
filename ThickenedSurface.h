//
//  ThickenedSurface.h
//  OpenManifold
//
//  Created by awm on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DerivedProperty.h"

class Geometry;
class tetgenio;
struct Color;
@class Part;

@interface ThickenedSurface : DerivedProperty {
	Geometry* geometry;
	vector<int> indices;
	
	int uCount;
	int vCount;
	
	tetgenio *in, *out;
	vector<Color> vertexColors;
  vector<double> node_displacements;
  
  Part* part;
}

@property (nonatomic, retain) Part* part;

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo;

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo andPart:(Part *)p;

- (void) mesh;

- (void) showMesh;

- (void) analyze;

- (void) visualize;

@end
