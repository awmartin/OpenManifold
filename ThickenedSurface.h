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

@interface ThickenedSurface : DerivedProperty {
	Geometry* geometry;
	vector<int> indices;
}

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo;

@end
