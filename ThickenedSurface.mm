//
//  ThickenedSurface.mm
//  OpenManifold
//
//  Created by awm on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import "/Users/awmartin/Dropbox/OpenManifold/src/tetgen/tetgen.h"
#define TETLIBRARY

#import "tetgen.h"
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

- (void) mesh
{
	// Get the nodes and faces of the thickened surface.
	vector<Node> nodes;
	vector<Face> faces;
	geometry->getMesh( object_index, 0.1, nodes, faces );
	
	tetgenio in, out; 
	tetgenio::facet *f; 
	tetgenio::polygon *p; 
	
	in.firstnumber = 0;
	in.numberofpoints = nodes.size();
	in.pointlist = new REAL[in.numberofpoints * 3];
	for( int i=0; i<in.numberofpoints; i++ ){
		in.pointlist[ i*3 + 0 ] = nodes[i].x;
		in.pointlist[ i*3 + 1 ] = nodes[i].y;
		in.pointlist[ i*3 + 2 ] = nodes[i].z;
	}
	
	in.numberoffacets = faces.size();
	in.facetlist = new tetgenio::facet[in.numberoffacets]; 
	in.facetmarkerlist = new int[in.numberoffacets];
	
	for( int i=0; i<faces.size(); i++ ){
		f = &in.facetlist[i]; 
		f->numberofpolygons = 1;
		f->polygonlist = new tetgenio::polygon[f->numberofpolygons]; 
		f->numberofholes = 0;
		f->holelist = NULL;
		p = &f->polygonlist[0];
		p->numberofvertices = 3;
		p->vertexlist = new int[p->numberofvertices]; 
		p->vertexlist[0] = faces[i].pt0;
		p->vertexlist[1] = faces[i].pt1;
		p->vertexlist[2] = faces[i].pt2;
		
		in.facetmarkerlist[i] = i;
	}
	
	//tetrahedralize("pq1.414a0.1", &in, &out);
	tetrahedralize("p", &in, &out);
	
	out.save_nodes("mesh"); 
	out.save_elements("mesh"); 
	out.save_faces("mesh");
}

@end
