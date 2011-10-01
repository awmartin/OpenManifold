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
#import "MeshPoint.h"

#import "Part.h"

#import <math.h>

@implementation ThickenedSurface

@synthesize part;
@synthesize thickness;
@synthesize minStress;
@synthesize maxStress;
@synthesize minDisplacement;
@synthesize maxDisplacement;
@synthesize hasAnalysis;

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo andThickness:(double)t
{
	self = [super init];
  if( self != nil ) {
		object_type = SURFACE;
		object_index = surfaceIndex;
		geometry = geo;
		
    thickness = t;
		indices = geometry->thickenSurface( object_index, t );
		
		uCount = 11;
		vCount = 11;
		
		in = new tetgenio;
		out = new tetgenio;
    
    hasAnalysis = NO;
	}
	return self;
}

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo andPart:(Part *)p
{
	self = [super init];
  if( self != nil ) {
    thickness = 0.1;
    [self initWithSurface:surfaceIndex andGeometry:geo andThickness:0.1];
    part = p;
	}
	return self;
}

- (id) initWithSurface:(int)surfaceIndex andGeometry:(Geometry *)geo andPart:(Part *)p andThickness:(double)t
{
	self = [super init];
  if( self != nil ) {
    [self initWithSurface:surfaceIndex andGeometry:geo andThickness:t];
    part = p;
	}
	return self;
}

- (void) refreshAnalysis
{
  in = new tetgenio;
  out = new tetgenio;
  node_displacements.clear();
  element_stresses.clear();
  elementColors.clear();
  faceColors.clear();
  [self update];
}

- (void) update
{
	geometry->updateThickenedSurface( object_index, thickness, indices );
}

/**
 * Turns this thickened surface into a tetrahedral mesh with the tetgen library.
 */
- (void) mesh
{
	// Get the nodes and faces of the thickened surface.
	vector<Node> nodes;
	vector<Face> faces;
	geometry->getMesh( object_index, thickness, nodes, faces );
	
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
  char opts[] = "pq"; // Just "p" works as a test. 
	tetrahedralize(opts, in, out);
	
	char tr[] = "mesh";
	out->save_nodes(tr);
	out->save_elements(tr);
	out->save_faces(tr);
	
  // Produce the selectable points here from the 'out' object. They have to be indexed by the new tetrahedral mesh.

  for( int i=0; i<out->numberofpoints; i++ ){
		Node n;
		n.x = out->pointlist[i*3+0];
		n.y = out->pointlist[i*3+1];
		n.z = out->pointlist[i*3+2];
    // add a mesh point to the part
    
    if( part != nil ){
      //geometry->addPoint( n.x, n.y, n.z );
      [part addMeshPoint:n.x y:n.y z:n.z index:i];
    }
	}
}

/**
 * Shows the colored, analyzed tetrahedral mesh.
 */
- (void) showMesh
{
	vector<Node> tmpNodes;
  
  double disp_scale = 1.0;
  
	for( int i=0; i<out->numberofpoints; i++ ){
		Node n;
    if( hasAnalysis ){
      n.x = out->pointlist[i*3+0] + disp_scale*node_displacements[i*3+0];
      n.y = out->pointlist[i*3+1] + disp_scale*node_displacements[i*3+1];
      n.z = out->pointlist[i*3+2] + disp_scale*node_displacements[i*3+2];
    } else {
      n.x = out->pointlist[i*3+0];
      n.y = out->pointlist[i*3+1];
      n.z = out->pointlist[i*3+2];
    }
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
    
    if (hasAnalysis){
      for( int k=0; k<4; k++ )
        faceColors.push_back( elementColors[i] );
    } else {
      Color c;
      c.r = 128.0;
      c.g = 128.0;
      c.b = 128.0;
      for( int k=0; k<4; k++ )
        faceColors.push_back( c );
    }
	}
	
	geometry->generateMesh( tmpNodes, tmpFaces, vertexColors, faceColors );
  mesh_index = geometry->local_object_indices.back(); // Last one should now be a mesh. 
  global_mesh_index = geometry->global_object_indices.back(); // Now we can grab the proper one for deletion from the OpenNurbs object.
}

- (double) meshVolume
{
  double totalVolume = 0.0;
  for( int i=0; i<out->numberoftetrahedra; i++ ){
    totalVolume += [self tetrahedronVolume:i];
  }
  return totalVolume;
}

- (double) tetrahedronVolume: (int)ptIndex
{
  int pts[4];
  Node nodes[4];
  
  for( int i=0; i<4; i++){
    pts[i] = out->tetrahedronlist[ptIndex*4+i];
    
    nodes[i].x = out->pointlist[pts[i]*3+0];
    nodes[i].y = out->pointlist[pts[i]*3+1];
    nodes[i].z = out->pointlist[pts[i]*3+2];
  }
  
  double mat[4][4] = {{ nodes[0].x, nodes[0].y, nodes[0].z, 1.0 },
                      { nodes[1].x, nodes[1].y, nodes[1].z, 1.0 },
                      { nodes[2].x, nodes[2].y, nodes[2].z, 1.0 },
                      { nodes[3].x, nodes[3].y, nodes[3].z, 1.0 }};
  double det = [self determinant4x4:mat];
  double vol = det/6.0;
  if (vol<0.0) vol = -vol; // Gets around ambigious abs() call.
  return vol;
}

- (double) determinant2x2:(double[2][2])matrix
{
  return matrix[0][0]*matrix[1][1] - matrix[0][1]*matrix[1][0];
}

// double[row][col]
- (double) determinant3x3: (double[3][3])matrix
{
  double ma[2][2] = { {matrix[1][1],matrix[1][2]}, 
                      {matrix[2][1],matrix[2][2]} };
  double mb[2][2] = { {matrix[1][0],matrix[1][2]}, 
                      {matrix[2][0],matrix[2][2]} };
  double mc[2][2] = { {matrix[1][0],matrix[1][1]}, 
                      {matrix[2][0],matrix[2][1]} };
  return matrix[0][0]*[self determinant2x2:ma] - matrix[0][1]*[self determinant2x2:mb] + matrix[0][2]*[self determinant2x2:mc];
}

- (double) determinant4x4: (double[4][4])matrix
{
  double ma[3][3] = { {matrix[1][1],matrix[1][2],matrix[1][3]}, 
                      {matrix[2][1],matrix[2][2],matrix[2][3]}, 
                      {matrix[3][1],matrix[3][2],matrix[3][3]} };
  double mb[3][3] = { {matrix[1][0],matrix[1][2],matrix[1][3]}, 
                      {matrix[2][0],matrix[2][2],matrix[2][3]}, 
                      {matrix[3][0],matrix[3][2],matrix[3][3]}};
  double mc[3][3] = { {matrix[1][0],matrix[1][1],matrix[1][3]}, 
                      {matrix[2][0],matrix[2][1],matrix[2][3]}, 
                      {matrix[3][0],matrix[3][1],matrix[3][3]} };
  double md[3][3] = { {matrix[1][0],matrix[1][1],matrix[1][2]}, 
                      {matrix[2][0],matrix[2][1],matrix[2][2]}, 
                      {matrix[3][0],matrix[3][1],matrix[3][2]} };
  return matrix[0][0]*[self determinant3x3:ma] - matrix[0][1]*[self determinant3x3:mb] + matrix[0][2]*[self determinant3x3:mc] - matrix[0][3]*[self determinant3x3:md];
}

- (void) analyze: (NSArray *)meshPoints withLoads: (NSArray *)loadPoints
{
	// Build the oofem file.
	NSMutableString* oofem = [NSMutableString string];
	[oofem appendString:@"oofemtest.out\n"];
	[oofem appendString:@"Testing tetgen to oofem analysis step.\n"];
	[oofem appendString:@"NonLinearStatic nsteps 1 controllmode 1 rtolv 0.0001 MaxIter 100 stiffmode 0 deltaT 1.0 nmodules 1 lstype 0\n"];
	[oofem appendString:@"vtk tstep_all domain_all primvars 1 1 vars 2 1 4 stype 1\n"];
	[oofem appendString:@"domain 3d\n"];
	[oofem appendString:@"OutputManager tstep_all dofman_all element_all\n"];
  int nbc = [loadPoints count] + 1; // Loads plus the single boundary condition.
	[oofem appendFormat:@"ndofman %d nelem %d ncrosssect 1 nmat 1 nbc %d nic 0 nltf 1\n", out->numberofpoints, out->numberoftetrahedra, nbc];
	
  // Restraints.
	for( int i=0; i<out->numberofpoints; i++ ){
		// Temporary selection of constraints for the spiral save surface, if the y-value is 0.
    
    MeshPoint* pt = [meshPoints objectAtIndex:i];
    
		if( [pt locked] ){
			[oofem appendFormat:@"Node %d coords 3 %f %f %f bc 3 1 1 1\n", i+1, out->pointlist[i*3+0], out->pointlist[i*3+1], out->pointlist[i*3+2] ];
		} else if ( [pt hasLoad] ) {
      int loadIndex;
      for( int j=0; j<[loadPoints count]; j++ ){
        MeshPoint* load = [loadPoints objectAtIndex:j];
        if( [pt index] == [load index] ){
          loadIndex = j+2;
          break;
        }
      }
      
      [oofem appendFormat:@"Node %d coords 3 %f %f %f load 1 %d\n", i+1, out->pointlist[i*3+0], out->pointlist[i*3+1], out->pointlist[i*3+2], loadIndex ];
    } else {
			[oofem appendFormat:@"Node %d coords 3 %f %f %f\n", i+1, out->pointlist[i*3+0], out->pointlist[i*3+1], out->pointlist[i*3+2] ];		
		}
  
	}
	
  // Elements.
	for( int i=0; i<out->numberoftetrahedra; i++ ){
    [oofem appendFormat:@"LTRSpace %d nodes 4 %d %d %d %d crossSect 1 mat 1\n", i+1,
      out->tetrahedronlist[i*4+0]+1, out->tetrahedronlist[i*4+1]+1, out->tetrahedronlist[i*4+2]+1, out->tetrahedronlist[i*4+3]+1 ];
	}
	
	// Cross section record.
	[oofem appendString:@"SimpleCS 1\n"];
	
	// Material.
	[oofem appendString:@"IsoLE 1 tAlpha 1.2e-05 d 1 E 30000.0 n 0.3\n"];
	
	// Boundary and load conditions.
	[oofem appendString:@"BoundaryCondition 1 loadTimeFunction 1 prescribedvalue 0.0\n"];
  
  
  // Add loads.
  for( int i=0; i<[loadPoints count]; i++ ){
    MeshPoint* tr = [loadPoints objectAtIndex:i];
    [oofem appendFormat:@"NodalLoad %d loadTimeFunction 1 Components 3 %f %f %f\n", i+2, [tr loadX], [tr loadY], [tr loadZ]];
    //[oofem appendFormat:@"ConstantSurfaceLoad %d ndofs 3 loadType 2 Components 3 %f %f %f loadTimeFunction 1\n", i+2, [tr loadX], [tr loadY], [tr loadZ]];
  }
	
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
  hasAnalysis = YES;
}


/**
 * Reads the oofem output and correlates the data to the existing tetgenio.out object data.
 * This essentially adds all the data necessary to visualize the results. It calculates
 * displacement and stress.
 */
- (void) processResults
{
  
  
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString* rootLibraryPath = [ defaults stringForKey:@"RootLibraryPath" ];
	
	NSString* oofemOutputPath = [rootLibraryPath stringByAppendingPathComponent:@"oofemtest.out"];
	
	NSString* oofemOutput = [NSString stringWithContentsOfFile:oofemOutputPath encoding:NSASCIIStringEncoding error:NULL];
	if (oofemOutput != nil) {
		// Parse the oofem output. Remember all the indices are indexed at 1.
		
		int numberofnodes = out->numberofpoints;
    int numberofelements = out->numberoftetrahedra;
		
		NSArray *lines = [oofemOutput componentsSeparatedByString:@"\n"];
		printf("Number of lines = %lu\n", [lines count]);
		
    node_displacements.clear();
    element_stresses.clear();
    elementColors.clear();
    faceColors.clear();
    minDisplacement = 1000000;
    maxDisplacement = 0;
    minStress = 1000000;
    maxStress = -1000000;
		
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
        
        node_displacements.push_back( [[displacement0 substringWithRange:r] doubleValue] );
        node_displacements.push_back( [[displacement1 substringWithRange:r] doubleValue] );
        node_displacements.push_back( [[displacement2 substringWithRange:r] doubleValue] );
        
				// Calculate magnitude. Calculate min and max.
				double mag = sqrt( pow(node_displacements[index*3+1],2) + pow(node_displacements[index*3+1],2) + pow(node_displacements[index*3+2],2) );
				
				if( mag > maxDisplacement ) maxDisplacement = mag;
				if( mag < minDisplacement ) minDisplacement = mag;
				
				i += 3;
			} else if ( [str hasPrefix:@"element"] ){
				// This is an element. The next 2 lines are stress and strain tensors. Assume Voigt form.
				//NSRange rng = NSMakeRange(13, 8);
				//int index = [[str substringWithRange:rng] integerValue]-1;
        
        NSRange r1 = NSMakeRange(23, 11);
        NSRange r2 = NSMakeRange(35, 11);
        NSRange r3 = NSMakeRange(47, 11);
        NSRange r4 = NSMakeRange(59, 11);
        NSRange r5 = NSMakeRange(71, 11);
        NSRange r6 = NSMakeRange(83, 11);
        
				//NSString* strains = [lines objectAtIndex:i+1];
				NSString* stresses = [lines objectAtIndex:i+2];
        
        double o11 = [[stresses substringWithRange:r1] doubleValue];
        double o22 = [[stresses substringWithRange:r2] doubleValue];
        double o33 = [[stresses substringWithRange:r3] doubleValue];
        double o23 = [[stresses substringWithRange:r4] doubleValue];
        //double o32 = o23;
        double o13 = [[stresses substringWithRange:r5] doubleValue];
        double o31 = o13;
        double o12 = [[stresses substringWithRange:r6] doubleValue];
        //double o21 = o12;
        
        
        // Stress invariants.
        double I1 = o11 + o22 + o33;
        double I2 = o11*o22 + o22*o33 + o33*o11 - o12*o12 - o23*o23 - o31*o31;
        double I3 = o11*o22*o33 - o11*o23*o23 - o22*o31*o31 - o33*o12*o12 + 2.0*o12*o23*o31;
        
        double phi = acos( (2.0*pow(I1,3) - 9.0*I1*I2 + 27.0*I3)/(2.0*pow(I1*I1 - 3.0*I2, 1.5) ) )/3.0;
        
        double o1 = I1/3.0 + 2.0*(sqrt(I1*I1 - 3.0*I2))*cos(phi)/3.0;
        double o2 = I1/3.0 + 2.0*(sqrt(I1*I1 - 3.0*I2))*cos(phi + 2.0*pi/3.0)/3.0;
        double o3 = I1/3.0 + 2.0*(sqrt(I1*I1 - 3.0*I2))*cos(phi + 4.0*pi/3.0)/3.0;
        
        // Calculate the von Mises stress...
        double o = sqrt(0.5*( pow(o1-o2,2) + pow(o2-o3,2) + pow(o3-o1,2) ) );
        
        element_stresses.push_back(o);
        
        if( o > maxStress ) maxStress = o;
				if( o < minStress ) minStress = o;
        
        i+=2;
			}
		}
		
		double deltaDisplacement = maxDisplacement - minDisplacement;
    double deltaStress = maxStress - minStress;
    
    printf( "Minimum stress found: %f, maximum: %f\n", minStress, maxStress );
		
    int STRESS = 0;
    int DISPLACEMENT = 1;
    
    int renderProperty = STRESS;
    
    if( renderProperty == DISPLACEMENT ){
      
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
      for( int i=0; i<numberofelements; i++ ){
        
        double p = (element_stresses[i]-minStress)/deltaStress;
        
        Color c;
        if( p <= 0.5 ){
          c.r = 255.0 * (p * 2.0);
          c.g = 255.0 * (p * 2.0);
          c.b = 255.0;
        } else {
          c.r = 255.0;
          c.g = 255.0 * (2.0 - 2.0 * p);
          c.b = 255.0 * (2.0 - 2.0 * p);
        }
        /*c.r = 128.0 + 128.0 * p;
        c.g = 128.0;
        c.b = 128.0;*/
        
        elementColors.push_back( c );
      }
      
    }
		
	} else {
		printf("Error reading oofem output.\n");
	}
}

@end
