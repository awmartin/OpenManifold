//
//  MeshPoint.h
//  OpenManifold
//
//  Created by William Martin on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MeshPoint : NSObject {
  double x, y, z;
  double loadX, loadY, loadZ;
  BOOL selected;
  BOOL locked; // for restraints
  int index;
}

@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double z;
@property (nonatomic, assign) double loadX;
@property (nonatomic, assign) double loadY;
@property (nonatomic, assign) double loadZ;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) int index;

- (id) initWithX:(double)posX y:(double)posY z:(double)posZ index:(int)pointIndex;

- (void) drawMeshPoint;

- (BOOL) hasLoad;

@end
