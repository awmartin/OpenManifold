/**
 *  Part.h
 *  OpenManifold
 *
 *  Created by Allan William Martin on 7/22/09.
 *  Copyright 2009 Anomalus Design. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

class Geometry;
class ON_Wrapper;
@class MeshPoint;
@class OpenManifoldDocument;
@class MainDocumentWindowController;
@class MainDocumentView;

@interface Part : NSObject {
  Geometry* geometry;
  
  NSMutableArray* parameters;
  NSMutableDictionary* geometries;
  NSMutableArray* meshPoints;
  NSMutableArray* loads;
  NSMutableArray* supports;
  
  BOOL selected;
  OpenManifoldDocument* document;
  
  float diagramPosX;
  float diagramPosY;
  
  BOOL draggingDiagram;
  
  NSString* name;
  
  NSMutableArray* behaviors;
	NSMutableArray* derivedProperties;
}

/** An array of all the parameters that make up this Part. 
 */
@property (nonatomic, retain) NSMutableArray* parameters;

@property (nonatomic, retain) NSMutableArray* meshPoints;

@property (nonatomic, retain) NSMutableDictionary* geometries;

@property (nonatomic, retain) NSMutableArray* loads;
@property (nonatomic, retain) NSMutableArray* supports;

@property (nonatomic, retain) OpenManifoldDocument* document;

@property (nonatomic, retain) NSString* name;

@property (nonatomic, assign) float diagramPosX;

@property (nonatomic, assign) float diagramPosY;

@property (nonatomic, retain) NSMutableArray* behaviors;

@property (nonatomic, retain) NSMutableArray* derivedProperties;

/** Contructor for a Part.
 *  This contructor requires the OpenNURBS wrapper object and the current document, so
 *  the Part can send messages to both.
 *  @param wrap is a pointer to the ON_Wrapper object;
 *  @param doc is a pointer to the current document. When called from the Document, use self.
 *  @return An id to the new Part.
 */
- (id) initWithWrapper:(ON_Wrapper*)wrap forDocument:(id)doc;

- (void) thickenSurfaceTest;
- (void) thicken;
- (void) thicken:(double)thickness;
- (void) update;
- (void) mesh;
- (void) analyze;
- (void) showMesh;

- (void) addMeshPoint:(double)posX y:(double)posY z:(double)posZ index:(int)pointIndex;
- (void) removeAllMeshPoints;
- (void) selectMeshPoint:(int)localObjectIndex;

- (void) addSupport:(double)sx sy:(double)sy sz:(double)sz ex:(double)ex ey:(double)ey ez:(double)ez;
- (bool) supportsToPoints;
- (void) addLoad:(double)x y:(double)y z:(double)z loadY:(double)loadY;
- (bool) loadsToPoints;
- (NSArray *) getLoads;
- (NSArray *) getRestraints;

- (void) processResults;
- (double) meshVolume;

- (void) addBehavior:(id)behavior;

- (void) behave;

- (void) addLine;

- (void) addCurve;

- (void) addCurve: (int)uCount;

- (void) addSimpleSurface;

- (void) addSurface:(NSString*)identifier u:(int)uCount v:(int)vCount;

/** Method that adds a generic surface to a Part.
 *  This method adds a generic NURBS surface to a part. By default, it has 25 control points, 
 *  numbered 0 to 4 in both the u and v directions. More control points and linkages for the
 *  existing points can be added later.
 */
- (void) addSurface;


/** Adds a point as a parameter to the Part.
 *  This is a convenience method to add another 3-dimensional point parameter to an part.
 *  If it is to be used as a control point, uVal and vVal values must be added. The returned
 *  parameter must be linked to the geometries it controls using addLinkTo.
 *  @param name Doesn't do anything yet. A placeholder for user-chosen names.
 *  @param x An NSNumber x world coordinate.
 *  @param y An NSNumber y world coordinate.
 *  @param z An NSNumber z world coordinate.
 *  @return A reference to the Parameter object.
 */
- (id) addPointParameter:(NSString *)name x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z;

- (void) addPoint:(NSString *)name x:(float)x y:(float)y z:(float)z;


/** Translates the Part and all geometries.
 *  @param dx The change in x.
 *  @param dy The change in y.
 *  @param dz The change in z.
 */
- (void) translate:(double)dx dy:(double)dy dz:(double)dz;

- (void) translateGeometry:(int)geometryIndex dx:(double)dx dy:(double)dy dz:(double)dz;


/** Scales the Part and all its geometries.
 *  @param x The scaling factor along the x axis. e.g. 0.5 = 50%.
 *  @param y The scaling factor along the y axis. e.g. 0.5 = 50%.
 *  @param z The scaling factor along the z axis. e.g. 0.5 = 50%.
 */
- (void) scale:(double)x y:(double)y z:(double)z;
- (void) scaleGeometry:(int)geometryIndex x:(double)x y:(double)y z:(double)z;


- (void) rotateGeometry:(int)geometryIndex angle:(float)angle axisX:(double)ax axisY:(double)ay axisZ:(double)az centerX:(double)cx centerY:(double)cy centerZ:(double)cz;
- (void) rotate:(float)angle axisX:(double)ax axisY:(double)ay axisZ:(double)az centerX:(double)cx centerY:(double)cy centerZ:(double)cz;


- (void) rotateGeometryX:(int)geometryIndex angle:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz;
- (void) rotateX:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz;


- (void) rotateGeometryY:(int)geometryIndex angle:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz;
- (void) rotateY:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz;


- (void) rotateGeometryZ:(int)geometryIndex angle:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz;
- (void) rotateZ:(float)angle centerX:(double)cx centerY:(double)cy centerZ:(double)cz;

/** Updates all the appropriate parameters in an Part from geometry.
 *  This method is used when the geometries of an object change from an opennurbs
 *  transformation, like scaling, rotating, translating, etc.
 */
- (void) updateParametersFromGeometry;


/** Returns a boolean, whether the part is selected or not.
 */
- (BOOL) isSelected;


/** Selects the part.
 */
- (void) select;


/** Unselects the part.
 */
- (void) unselect;


/** Selects the part that contains the geometry with the globalObjectIndex provided.
 *  This is used primarily for the selection. OpenGL makes it easy to handle selections
 *  if a unique identifier is given to each piece of drawn selectable geometry. This
 *  method searches through all the geometry objects and checks to see if they have a
 *  global index equal to the provided parameter.
 *  @param globalObjectIndex An integer containing the global index of a geometry.
 */
- (void) selectPartContaining:(int)globalObjectIndex;


/** Selects a single geometry if it is contained by this part.
 */
- (void) selectGeometry:(int)globalObjectIndex;


/** Unhighlights all geometries in this part.
 */
- (void) unhighlightPart;


/** Returns an array of all the global indices for the geometries that are selected.
 */
- (NSMutableArray *) indicesForSelectedGeometry;


- (NSMutableArray *) parametersForSelectedGeometry;


- (NSMutableArray*) getAllDirtyParameters;

- (void) cleanAllParameters;

/** Function for drawing stuff outside the model, pure openGL geometry.
 *  This is mainly used for additional notational geometry like dashed lines, control 
 *  points, etc.
 *  @param select A boolean that indicates whether the user is attempting to pick an object on mouseDown.
 */
- (void) draw:(BOOL)select zoom:(float)zoom;


- (void) dragInDiagram:(float)dx dy:(float)dy;

- (void) drawDiagram:(BOOL)select;

/** Returns the number of geometry objects in the part.
 */
- (int) objectCount;


/** Returns the UUID of geometry with the given globalObjectIndex
 */
- (NSString *) getUUID:(int)globalObjectIndex;


/** Returns all the global indices of the Part's geometry objects.
 */
- (NSMutableArray *) objectIndices;


/** Returns all the parameters that affect a geometry given its global index.
 */
- (NSMutableArray *) parametersForGeometry:(int)globalIndex;

- (NSMutableArray *) getSelectedParameters;

- (NSMutableArray *) getSelectedMeshPoints;

@end
