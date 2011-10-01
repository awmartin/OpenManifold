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
  vector<Color> elementColors;
  vector<Color> faceColors;
  vector<double> node_displacements;
  vector<double> element_stresses;
  
  double thickness;
  
  Part* part;
  
  int mesh_index;
  int global_mesh_index;
  
  bool hasAnalysis;
  
  double minStress, maxStress, minDisplacement, maxDisplacement;
}

@property (nonatomic, retain) Part* part;
@property (nonatomic, assign) double thickness;
@property (nonatomic, assign) double minStress;
@property (nonatomic, assign) double maxStress;
@property (nonatomic, assign) double minDisplacement;
@property (nonatomic, assign) double maxDisplacement;
@property (nonatomic, assign) bool hasAnalysis;

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo andThickness:(double)t;

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo andPart:(Part *)p;

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo andPart:(Part *)p andThickness:(double)t;

- (void) refreshAnalysis;

- (void) mesh;

- (void) showMesh;

- (void) analyze: (NSArray *)meshPoints withLoads: (NSArray *)loadPoints;

- (void) processResults;

- (double) meshVolume;
- (double) tetrahedronVolume: (int)ptIndex;
- (double) determinant2x2:(double[2][2])matrix;
- (double) determinant3x3: (double[3][3])matrix;
- (double) determinant4x4: (double[4][4])matrix;

@end
