//
//  SupportZone.h
//  OpenManifold
//
//  Created by William Martin on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SupportZone : NSObject {
  double startX;
  double startY;
  double startZ;
  double endX;
  double endY;
  double endZ;
}

@property (nonatomic, assign) double startX;
@property (nonatomic, assign) double startY;
@property (nonatomic, assign) double startZ;
@property (nonatomic, assign) double endX;
@property (nonatomic, assign) double endY;
@property (nonatomic, assign) double endZ;

- (void) drawSupport;

@end
