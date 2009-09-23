//
//  Rule.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/5/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Parameter.h"

@interface Rule : NSObject {
  NSMutableArray* parameters;
  NSMutableArray* dirtyParameters;
  NSMutableArray* cleanParameters;
  BOOL done;
}

@property (nonatomic, retain) NSMutableArray* parameters;

- (id) initWithParameters:(NSArray*)params;

- (BOOL) hasBeenExecuted;

- (void) setup;

- (void) applyRule;

- (void) rule;

- (void) drawRule;

- (void) drawDiagram;

- (NSMutableArray*) getOtherParameters:(Parameter*)param;

- (int) numberOfRequiredParameters;

- (void) reset;

@end
