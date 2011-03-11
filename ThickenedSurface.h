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

@interface ThickenedSurface : DerivedProperty {
	Geometry* geometry;
	vector<int> indices;
	
	int uCount;
	int vCount;
	
	tetgenio *in, *out;
	vector<Color> vertexColors;
  vector<double> node_displacements;
}

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo;

- (void) mesh;

- (void) showMesh;

- (void) analyze;

- (void) visualize;

@end
