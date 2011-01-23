//
//  ThickenedSurface.mm
//  OpenManifold
//
//  Created by awm on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import "/Users/awmartin/Dropbox/OpenManifold/src/tetgen/tetgen.h"
//#import "tetgen.h"
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

- (void) writeMesh
{
	vector<Node> nodes;
	vector<Face> faces;
	
	geometry->getMesh( object_index, 0.1, nodes, faces );
	
	NSMutableString* str = [NSMutableString string];
	
	[str appendString:@"# Part 1 - node list\n"];
	[str appendFormat:@"%d 3 0 0\n", nodes.size()];
	
	for(int i=0; i<nodes.size(); i++ ){
		[str appendFormat:@"%d %f %f %F\n", i+1, nodes[i].x, nodes[i].y, nodes[i].z];
	}
	
	[str appendString:@"\n"];
	[str appendString:@"# Part 2 - facet list\n"];
	[str appendFormat:@"%d 1\n", faces.size()];
	
	for( int i=0; i<faces.size(); i++ ){
		[str appendString:@"1 0 1\n"];
		[str appendFormat:@"3 %d %d %d\n", faces[i].pt0+1, faces[i].pt1+1, faces[i].pt2+1];
	}
	
	[str appendString:@"\n"];
	[str appendString:@"# Part 3 - hole list\n"];
	[str appendString:@"0\n"];
	
	[str appendString:@"\n"];
	[str appendString:@"# Part 4 - region list\n"];
	[str appendString:@"0\n"];
	
	[str appendString:@"\n"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString* rootLibraryPath = [ defaults stringForKey:@"RootLibraryPath" ];
	
	NSString* meshFilePath = [rootLibraryPath stringByAppendingPathComponent:@"mesh.poly"];
	
	// Write the file.
	[str writeToFile:meshFilePath atomically:YES encoding:NSASCIIStringEncoding error:NULL];
	
	printf("About to set up the tetgen task.\n");
	
	// Find the path to the executable.
	NSBundle* myBundle = [NSBundle mainBundle];
	NSString* tetgenPath = [myBundle pathForResource:@"tetgen" ofType:@""];
	printf("tetgen resource located at: %s\n", [tetgenPath UTF8String]);
	
	NSTask* tetgenTask = [[NSTask alloc] init];
	[tetgenTask setLaunchPath:tetgenPath];
	[tetgenTask setCurrentDirectoryPath:rootLibraryPath];
	
	NSMutableArray* tetgenArgs = [NSMutableArray array];
	[tetgenArgs addObject:@"-p"];
	[tetgenArgs addObject:meshFilePath];
	[tetgenTask setArguments:tetgenArgs];
	
	NSString* outputFilePath = [rootLibraryPath stringByAppendingPathComponent:@"tetgenOutput.log"];
	NSFileHandle* tetgenOutput = [NSFileHandle fileHandleForWritingAtPath:outputFilePath];
	[tetgenTask setStandardOutput:tetgenOutput];
	
	NSString* errorFilePath = [rootLibraryPath stringByAppendingPathComponent:@"tetgenErrors.log"];
	NSFileHandle* tetgenErrors = [NSFileHandle fileHandleForWritingAtPath:errorFilePath];
	[tetgenTask setStandardError:tetgenErrors];
	
	printf("About to launch...\n");
	[tetgenTask launch];
	
	int pid = [tetgenTask processIdentifier];
	printf("Launching tetgen with PID = %d", pid);
	
	[tetgenTask waitUntilExit];
	/*int status = [tetgenTask terminationStatus];
	
	if (status == 1)
    NSLog(@"Tetgen succeeded.");
	else
    NSLog(@"Tetgen failed.");*/
	
}

@end
