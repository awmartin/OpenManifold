//
//  DerivedProperty.h
//  OpenManifold
//
//  Created by awm on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DerivedProperty : NSObject {
	int object_type;
	int object_index;
}

- (void) update;

@end
