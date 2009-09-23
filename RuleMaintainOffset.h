//
//  RuleMaintainOffset.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Rule.h"


@interface RuleMaintainOffset : Rule {
  Parameter* p0;
  Parameter* p1;
  
  float dx;
  float dy;
  float dz;
}

@end
