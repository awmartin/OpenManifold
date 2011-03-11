//
//  ThickenedSurface.mm
//  OpenManifold
//
//  Created by awm on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define TETLIBRARY

#import "tetgen.h"

#import "Geometry.h"
#import "ThickenedSurface.h"

#import <math.h>

@implementation ThickenedSurface

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo
{
	self = [super init];
  if( self != nil ) {
		object_type = SURFACE;
		object_index = surfaceIndex;
		geometry = geo;
		
		indices = geometry->thickenSurface( object_index, 0.1 );
		
		uCount = 11;
		vCount = 11;
		
		in = new tetgenio;
		out = new tetgenio;
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
	
	tetgenio::facet *f;
	tetgenio::polygon *p;
	
	in->firstnumber = 0;
	in->numberofpoints = nodes.size();
	in->pointlist = new REAL[in->numberofpoints * 3];
	for( int i=0; i<in->numberofpoints; i++ ){
		in->pointlist[ i*3 + 0 ] = nodes[i].x;
		in->pointlist[ i*3 + 1 ] = nodes[i].y;
		in->pointlist[ i*3 + 2 ] = nodes[i].z;
	}
	
	in->numberoffacets = faces.size();
	in->facetlist = new tetgenio::facet[in->numberoffacets]; 
	in->facetmarkerlist = new int[in->numberoffacets];
	
	for( int i=0; i<faces.size(); i++ ){
		f = &in->facetlist[i];
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
		
		in->facetmarkerlist[i] = i;
	}
	
	//tetrahedralize("pq1.414a0.1", &in, &out);
	tetrahedralize("p", in, out);
	
	
	out->save_nodes("mesh");
	out->save_elements("mesh");
	out->save_faces("mesh");
	
}

/**
 * Shows the generated tetrahedral mesh.
 */
- (void) showMesh
{
	vector<Node> tmpNodes;
  
  double disp_scale = 1.0;
  
	for( int i=0; i<out->numberofpoints; i++ ){
		Node n;
		n.x = out->pointlist[i*3+0] + disp_scale*node_displacements[i*3+0];
		n.y = out->pointlist[i*3+1] + disp_scale*node_displacements[i*3+1];
		n.z = out->pointlist[i*3+2] + disp_scale*node_displacements[i*3+2];
		tmpNodes.push_back( n );
	}
	
	//f0 (v0, v1, v2), f1 (v0, v3, v1), f2 (v1, v3, v2), f3 (v2, v3, v0).
	vector<Face> tmpFaces;
	for( int i=0; i<out->numberoftetrahedra; i++ ){
		Face f0;
		f0.pt0 = out->tetrahedronlist[i*4+0];
		f0.pt1 = out->tetrahedronlist[i*4+1];
		f0.pt2 = out->tetrahedronlist[i*4+2];
		tmpFaces.push_back(f0);
		
		Face f1;
		f1.pt0 = out->tetrahedronlist[i*4+0];
		f1.pt1 = out->tetrahedronlist[i*4+3];
		f1.pt2 = out->tetrahedronlist[i*4+1];
		tmpFaces.push_back(f1);
		
		Face f2;
		f2.pt0 = out->tetrahedronlist[i*4+1];
		f2.pt1 = out->tetrahedronlist[i*4+3];
		f2.pt2 = out->tetrahedronlist[i*4+2];
		tmpFaces.push_back(f2);
		
		Face f3;
		f3.pt0 = out->tetrahedronlist[i*4+2];
		f3.pt1 = out->tetrahedronlist[i*4+3];
		f3.pt2 = out->tetrahedronlist[i*4+0];
		tmpFaces.push_back(f3);
	}
	
	geometry->generateMesh( tmpNodes, tmpFaces, vertexColors );
}

- (void) analyze
{
	// Build the oofem file.
	NSMutableString* oofem = [NSMutableString string];
	[oofem appendString:@"oofemtest.out\n"];
	[oofem appendString:@"Testing tetgen to oofem analysis step.\n"];
	[oofem appendString:@"NonLinearStatic nsteps 1 controllmode 1 rtolv 0.0001 MaxIter 100 stiffmode 0 deltaT 1.0 nmodules 1 lstype 0\n"];
	[oofem appendString:@"vtk tstep_all domain_all primvars 1 1 vars 2 1 4 stype 1\n"];
	[oofem appendString:@"domain 3d\n"];
	[oofem appendString:@"OutputManager tstep_all dofman_all element_all\n"];
	[oofem appendFormat:@"ndofman %d nelem %d ncrosssect 1 nmat 1 nbc 2 nic 0 nltf 1\n", out->numberofpoints, out->numberoftetrahedra];
	
	for( int i=0; i<out->numberofpoints; i++ ){
		// Temporary selection of constraints for the spiral save surface, if the y-value is 0.
		if( out->pointlist[i*3 + 1] == 0 ){
			[oofem appendFormat:@"Node %d coords 3 %f %f %f bc 3 1 1 1\n", i+1, out->pointlist[i*3+0], out->pointlist[i*3+1], out->pointlist[i*3+2] ];
		} else {
			[oofem appendFormat:@"Node %d coords 3 %f %f %f\n", i+1, out->pointlist[i*3+0], out->pointlist[i*3+1], out->pointlist[i*3+2] ];			
		}
	}
	
	for( int i=0; i<out->numberoftetrahedra; i++ ){
		if( out->pointlist[i*3+2] > 13.0 ){ // Arbitrary number to start.
			[oofem appendFormat:@"LTRSpace %d nodes 4 %d %d %d %d crossSect 1 mat 1 boundaryLoads 2 2 1\n", i+1,
				out->tetrahedronlist[i*4+0]+1, out->tetrahedronlist[i*4+1]+1, out->tetrahedronlist[i*4+2]+1, out->tetrahedronlist[i*4+3]+1 ];
		} else {
			[oofem appendFormat:@"LTRSpace %d nodes 4 %d %d %d %d crossSect 1 mat 1\n", i+1,
				out->tetrahedronlist[i*4+0]+1, out->tetrahedronlist[i*4+1]+1, out->tetrahedronlist[i*4+2]+1, out->tetrahedronlist[i*4+3]+1 ];
		}		
	}
	
	// Cross section record.
	[oofem appendString:@"SimpleCS 1\n"];
	
	// Material.
	[oofem appendString:@"IsoLE 1 tAlpha 1.2e-05 d 1 E 30000.0 n 0.3\n"];
	
	// Boundary and load conditions.
	[oofem appendString:@"BoundaryCondition 1 loadTimeFunction 1 prescribedvalue 0.0\n"];
	[oofem appendString:@"ConstantSurfaceLoad 2 ndofs 3 loadType 2 Components 3 0.0 0.0 10.0 loadTimeFunction 1\n"];
	
	// Time function.
	[oofem appendString:@"ConstantFunction 1 f(t) 1.0\n"];
	
	// DONE.
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString* rootLibraryPath = [ defaults stringForKey:@"RootLibraryPath" ];
	
	NSString* oofemInputPath = [rootLibraryPath stringByAppendingPathComponent:@"oofemtest.in"];
	
	// Write the file.
	[oofem writeToFile:oofemInputPath atomically:YES encoding:NSASCIIStringEncoding error:NULL];
	
	printf("About to set up the oofem task.\n");
	
	// Find the path to the executable.
	NSBundle* myBundle = [NSBundle mainBundle];
	NSString* oofemPath = [myBundle pathForResource:@"oofem" ofType:@""];
	printf("oofem resource located at: %s\n", [oofemPath UTF8String]);
	
	NSTask* oofemTask = [[NSTask alloc] init];
	[oofemTask setLaunchPath:oofemPath];
	[oofemTask setCurrentDirectoryPath:rootLibraryPath];
	
	NSMutableArray* oofemArgs = [NSMutableArray array];
	[oofemArgs addObject:@"-f"];
	[oofemArgs addObject:oofemInputPath];
	[oofemTask setArguments:oofemArgs];
	
	NSString* outputFilePath = [rootLibraryPath stringByAppendingPathComponent:@"oofemOutput.log"];
	NSFileHandle* oofemOutput = [NSFileHandle fileHandleForWritingAtPath:outputFilePath];
	[oofemTask setStandardOutput:oofemOutput];
	
	NSString* errorFilePath = [rootLibraryPath stringByAppendingPathComponent:@"oofemErrors.log"];
	NSFileHandle* oofemErrors = [NSFileHandle fileHandleForWritingAtPath:errorFilePath];
	[oofemTask setStandardError:oofemErrors];
	
	printf("About to launch...\n");
	[oofemTask launch];
	
	int pid = [oofemTask processIdentifier];
	printf("Launching oofem with PID = %d\n", pid);
	
	[oofemTask waitUntilExit];
	
	printf("Done with oofem analysis.\n");
}

- (void) visualize
{
	// Reads the oofem output and correlates the data to the existing tetgenio.out object data.
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString* rootLibraryPath = [ defaults stringForKey:@"RootLibraryPath" ];
	
	NSString* oofemOutputPath = [rootLibraryPath stringByAppendingPathComponent:@"oofemtest.out"];
	
	NSString* oofemOutput = [NSString stringWithContentsOfFile:oofemOutputPath encoding:NSASCIIStringEncoding error:NULL];
	if (oofemOutput != nil) {
		// Parse the oofem output. Remember all the indices are indexed at 1.
		
		int numberofnodes = out->numberofpoints;
		//int numberofelements = out->numberoftetrahedra;
		
		//double node_displacements[numberofnodes][3];
		//double element_stresses[numberofelements][6];
		//double element_strains[numberofelements][6];
		
		NSArray *lines = [oofemOutput componentsSeparatedByString:@"\n"];
		printf("Number of lines = %d\n", [lines count]);
		
		double minDisplacement = 1000000;
		double maxDisplacement = 0;
		
		// 100 lines for testing.
		for( int i=0; i<[lines count]; i++ ){
			NSString* str = [lines objectAtIndex:i];
			
			if( [str hasPrefix:@"Node"] ){
				
				// This is a node. The next 3 lines are displacements.
				NSRange rng = NSMakeRange(18, 8);
				int index = [[str substringWithRange:rng] integerValue]-1;
				
				NSRange r = NSMakeRange(12, 15);
				NSString* displacement0 = [lines objectAtIndex:i+1];
				NSString* displacement1 = [lines objectAtIndex:i+2];
				NSString* displacement2 = [lines objectAtIndex:i+3];
				
				//node_displacements[index][0] = [[displacement0 substringWithRange:r] doubleValue];
				//node_displacements[index][1] = [[displacement1 substringWithRange:r] doubleValue];
				//node_displacements[index][2] = [[displacement2 substringWithRange:r] doubleValue];
        
        node_displacements.push_back( [[displacement0 substringWithRange:r] doubleValue] );
        node_displacements.push_back( [[displacement1 substringWithRange:r] doubleValue] );
        node_displacements.push_back( [[displacement2 substringWithRange:r] doubleValue] );
        
				// Calculate magnitude. Calculate min and max.
				double mag = sqrt( pow(node_displacements[index*3+1],2) + pow(node_displacements[index*3+1],2) + pow(node_displacements[index*3+2],2) );
				
				if( mag > maxDisplacement ) maxDisplacement = mag;
				if( mag < minDisplacement ) minDisplacement = mag;
				
				i += 3;
			} else if ( [str hasPrefix:@"element"] ){
				// This is an element. The next 2 lines are stress and strain tensors.
				
			}
		}
		
		double deltaDisplacement = maxDisplacement - minDisplacement;
		
		for( int i=0; i<numberofnodes; i++ ){
			
			double mag = sqrt( pow(node_displacements[i*3+0],2) + pow(node_displacements[i*3+1],2) + pow(node_displacements[i*3+2],2) );
			double p = (mag-minDisplacement)/deltaDisplacement;
			// Calculate color given magnitude range.
			Color c;
			// yellow-blue;
			/*c.r = 255.0*(mag/deltaDisplacement);
			c.g = 255.0*(mag/deltaDisplacement);
			c.b = 255.0-255.0*(mag/deltaDisplacement);*/
			
			if( p <= 0.5 ){
				c.r = 255.0 * (p * 2.0);
				c.g = 255.0 * (p * 2.0);
				c.b = 255.0;
			} else {
				c.r = 255.0;
				c.g = 255.0 * (2.0 - 2.0 * p);
				c.b = 255.0 * (2.0 - 2.0 * p);
			}
			
			vertexColors.push_back( c );
		}
		
	} else {
		printf("Error reading oofem output.\n");
	}
}

@end
