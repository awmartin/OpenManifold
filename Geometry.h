/*
 *  Geometry.h
 *  OpenManifold
 *
 *  Created by Allan William Martin on 7/23/09.
 *  Copyright 2009 Anomalus Design. All rights reserved.
 *
 */

#include <vector>
using namespace std;

class ON_NurbsSurface;
class ON_NurbsCurve;
class ONX_Model;
class ONX_Model_Object;
class ON_LineCurve;
class ON_Point;

#define POINT     0
#define LINE      1
#define CURVE     2
#define SURFACE   3
#define BREP      4

class Geometry {

public:
  
  vector<int> local_object_indices;   /**< The local index of each object relative to their respective tables. */
  vector<int> global_object_indices;  /**< Global OpenGL indices of all the objects. Used for selection. */
  vector<int> object_types;           /**< Keeps track of what an object is, e.g. SURFACE. */
  vector<int> selected_objects;    /**< Keeps track of whether objects are selected. */
  
  vector<ON_NurbsSurface *> surfaces_table;
  vector<ON_NurbsCurve *> curves_table;
  vector<ON_LineCurve *> lines_table;
  
  ONX_Model* model;               /**< Reference to the opennurbs model object. */
  
  Geometry( ONX_Model* mo );
  
  int addLine( float x1, float y1, float z1, float x2, float y2, float z2 );
  void setLineEndPoint( int line_index, int num, float x, float y, float z );
  
  int addNewCurve( int dim, int rational, int order, int num_control_vertices );
  void setCurveKnot( int curve_index, int knot_index, double knot );
  void setCurveCV( int curve_index, int u, float x, float y, float z );
  int finishCurve( int curve_index );
  
  int addEmptySurface( int, int, int );
  void setSurfaceKnot( int, int, int, double );
  void setSurfaceCV( int, int, int, float, float, float );
  
  /** Completes the process of creating a nurbs surface.
   *  This is the last step, after adding knots and control vectors.
   *  @param surface_index An integer containing the local index of the new surface.
   *  @return An integer containing the global index of the surface if successful. -1 if not.
   */
  bool finishSurface( int surface_index );

  /** Returns a control vector from a surface geometry.
   *  This is used to update the parameters of a part or part when the opennurbs
   *  engine is responsible for a transformation. Most of the time, the parameters
   *  govern the geometry of a part and the parameterized relationships exist on 
   *  the Part level. Sometimes, opennurbs may be more convenient or robust in its
   *  mathematical implementation.
   *  @param[in]  surface_index The array index of the surface.
   *  @param[in]  i             The integer in the u-direction of the control point.
   *  @param[in]  j             The integer in the v-direction of the control point.
   *  @param[out] pt            A three-part array of doubles 
   */
  void getSurfaceCV( int surface_index, int i, int j, double pt[] );
  
  void getCurveCV( int curve_index, int i, double pt[] );
  
  void getLineEndPoint( int line_index, int i, double pt[] );
  
  int getLocalIndex( int globalIndex );
  int getGlobalIndex( int localIndex, int objectType );
  int getObjectType( int globalIndex );
  
  void translateObject( int globalObjectIndex, double dx, double dy, double dz );
  void translate( double dx, double dy, double dz );
  
  void scaleObject( int globalObjectIndex, double x, double y, double z );
  void scale( double x, double y, double z );
  
  void rotateObject( int globalObjectIndex, double angle, double ax, double ay, double az, double cx, double cy, double cz );
  void rotate( double angle, double ax, double ay, double az, double cx, double cy, double cz );
  
  
  /** Returns whether a Part contains the given globalObjectIndex.
   */
  bool contains( int globalObjectIndex );
  
  bool selectGeometry( int globalObjectIndex );
  void unselectGeometry( int );
  void selectAll();
  void unselectAll();

  void cube(float s);
  void drawParameterLines( bool select );
  
  int getSurfaceCount();
  int getGeometryCount( int type );
  int getObjectCount();
  
  char* getUUID( int globalObjectIndex );
  int* getObjectIndicies();
  int* getSelected();
};


