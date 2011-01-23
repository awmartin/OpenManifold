//
//  ThickenedSurface.mm
//  OpenManifold
//
//  Created by awm on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Geometry.h"
#import "ThickenedSurface.h"


@implementation ThickenedSurface

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo
{
	self = [super init];
  if( self != nil ) {
		object_type = SURFACE;
		object_index = surfaceIndex;
		geometry = geo;
		
		indices = geometry->thickenSurface( object_index, 0.1 );
	}
	return self;
}

- (void) update
{
	geometry->updateThickenedSurface( object_index, 0.1, indices );
}

@end
