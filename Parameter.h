//
//  Parameter.h
//  OpenManifold
//
//  Created by Allan William Martin on 8/1/09.
//  Copyright 2009 Anomalus Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>

class Geometry;

@interface Parameter : NSObject {
  NSMutableDictionary* values;
  
  /** Linkages are four-part arrays that contain how the property is to be used.
   *  e.g. controlpoint for surface 1, global id 17.
   *  [0] = local index
   *  [1] = parameter type ("controlpoint", etc.)
   *  [2] = object type (SURFACE, CURVE, POINT, etc.)
   *  [3] = global index
   */
  NSMutableArray* linkages;
  
  /** Contains a list of all the rules that attach to this parameter.
   *  This helps conceive of the total relationships of parameters through
   *  rules as a potentially cyclic, undirected graph.
   */
  NSMutableArray* rules;
  
  id parent; /**< The id of the parent Part. */
  Geometry* geometry;
  
  BOOL dirty;
  
  BOOL selected;
}

@property (nonatomic, retain) NSMutableDictionary* values;
@property (nonatomic, retain) NSMutableArray* linkages;
@property (nonatomic, retain) NSMutableArray* rules;

/** 
 *  Standard constructor. 
 *  Constructor attaches to an part and its geometry object.
 *  
 */
- (id) initWithPart:(id)part andGeometry:(Geometry *)geo;

- (void) addRule:(id)newRule;

- (NSMutableArray*) getUnexecutedRules;

- (BOOL) isDirty;

/**
 *  Makes a node dirty for the graph evaluation.
 */
- (void) setDirty;


/**
 *  Makes cleans a dirty node.
 */
- (void) reset;

/** 
 *  Links a property to a piece of geometry.
 *  A linkage is an association between a Parameter and a geometric object. It 
 *  tells the software what the Parameter should "mean." That is, whether it is
 *  a 3d point, a control point on a surface, a control point on a curve, a vector,
 *  a dimension, a material property, etc.
 *  @param localObjectIndex is the integer identifier of the geometry relative to the Part.
 *  @param parameterType is one of the following: "controlpoint", "vector", "point", "dimension"
 *  @param objectType is an integer of a predefined symbol: SURFACE, CURVE, POINT. This plus localObjectIndex and the part is enough to identify the geometry.
 *  @param globalIndex is a the unique, global identifier for the object.
 */
- (void) addLinkTo:(int)localObjectIndex type:(NSString *)parameterType geometry:(int)objectType globalIndex:(int)globalIndex;

/** Creates a new value in the Parameter.
 *  Method adds a new value to the values dictionary in the Parameter. These
 *  values have specific meaning to how the data is used by geometry.
 *  "posX" x-axis parameter of a 2d/3d point
 *  "posY" y-axis parameter of a 2d/3d point
 *  "posZ" z-axis parameter of a 2d/3d point
 *  "uVal" u-direction parameter of a control point
 *  "vVal" v-direction parameter of a control point
 *  @param key A string that contains the name of the value.
 *  @param value A number that contains the value that should be assigned to the key.
 */
- (void) initValue:(NSString *)key withNumber:(NSNumber *)value;

/** Sets an existing value in a Parameter.
 *  This follows the same rules and format as initValue. But this requires that
 *  a value already be added with initValue. The difference is that this function
 *  executes a callback that changes the geometry. If the parameter refers to a
 *  piece of geometry that hasn't been built completely, it will produce an error.
 */
- (void) setValue:(NSString *)key withNumber:(NSNumber *)value;

/** An alias for setValue.
 *  Intended for use from the scripting console for direct access to changing one
 *  of a parameter's values.
 */
- (void) set:(NSString *)key to:(NSNumber *)value;

- (BOOL) isLinkedTo:(int)localIndex objectType:(int)objectType;

- (BOOL) isLinkedTo:(int)globalIndex;

- (NSNumber *)getValue:(NSString *)key;

- (float) getFloatValue:(NSString*) key;

- (int) getIntValue:(NSString *)key;

- (NSString *) getLinkageType:(int)index;

- (NSArray*) parentDiagramCoordinates;

- (float) parentDiagramPosX;

- (float) parentDiagramPosY;

- (void) draw:(BOOL)select zoom:(float)zoom;

- (void) focus;

- (void) select;

- (void) unSelect;

- (BOOL) isSelected;

@end
