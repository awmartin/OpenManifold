//
//  GravityLoad.h
//  OpenManifold
//
//  Created by William Martin on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GravityLoad : NSObject {
  double x, y, z;
  double loadX, loadY, loadZ;
}


@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double z;
@property (nonatomic, assign) double loadX;
@property (nonatomic, assign) double loadY;
@property (nonatomic, assign) double loadZ;

- (id) initWithX:(double)posX y:(double)posY z:(double)posZ;

- (void) drawLoad;

- (double) magnitude;

@end
