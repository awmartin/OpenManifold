//
//  GrowlController.m
//  OpenManifold
//
//  Created by Allan William Martin on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GrowlController.h"


@implementation GrowlController

- (void) awakeFromNib
{
  [GrowlApplicationBridge setGrowlDelegate:self];
}


- (NSString *) applicationNameForGrowl
{
  return @"OpenManifold";
}



@end
