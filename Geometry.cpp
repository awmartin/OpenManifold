/*
 *  Geometry.cpp
 *  OpenManifold
 *  A Geometry object contains references to points, surfaces, lines, etc. that describe
 *  the geometric properties of an Part.
 *
 *  Created by Allan William Martin on 7/23/09.
 *  Copyright 2009 Anomalus Design. All rights reserved.
 *
 */

#import "/Users/awmartin/Documents/DevProjects/opennurbs/opennurbs.h"
#import "/Users/awmartin/Documents/DevProjects/opennurbs/opennurbs_gl.h"
#import "opennurbs_interface.h"
#import "Geometry.h"


Geometry::Geometry( ONX_Model* mo )
{
  model = mo;
}

int Geometry::addPoint( float x, float y, float z )
{
  ON_Point* pt = new ON_Point(x, y, z);
  
  int local_object_index = points_table.size();
  local_object_indices.push_back( local_object_index );
  
  points_table.push_back( pt );
  object_types.push_back( POINT );
  
  int global_object_index = model->m_object_table.Count(); // So se can keep track of this object globally.
  global_object_indices.push_back( global_object_index );
  
  selected_objects.push_back( 0 );
  
  if ( points_table[local_object_index]->IsValid() ) {
    ONX_Model_Object& object = model->m_object_table.AppendNew();
    
    object.m_object = points_table.back();
    object.m_bDeleteObject = false;
    object.m_attributes.m_layer_index = 0;
    object.m_attributes.m_name = "point";
    
    object.m_attributes.m_material_index = 0;
    object.m_attributes.SetMaterialSource(ON::material_from_object);
    
    ON_CreateUuid( object.m_attributes.m_uuid );
    model->m_object_id_index.AddUuidIndex(object.m_attributes.m_uuid, global_object_index, false);
    
    return local_object_index;
  } else {
    points_table.pop_back();
    object_types.pop_back();
    selected_objects.pop_back();
    global_object_indices.pop_back();
    return -1;
  }
}

void Geometry::setPoint( int point_index, float x, float y, float z )
{
  points_table[point_index]->point.x = x;
  points_table[point_index]->point.y = y;
  points_table[point_index]->point.z = z;
}


int Geometry::addLine( float x1, float y1, float z1, float x2, float y2, float z2 )
{
  ON_3dPoint pt1;
  pt1.x = x1;
  pt1.y = y1;
  pt1.z = z1;
  
  ON_3dPoint pt2;
  pt2.x = x2;
  pt2.y = y2;
  pt2.z = z2;
  
  ON_LineCurve* line = new ON_LineCurve( pt1, pt2 );
  
  int local_object_index = lines_table.size();
  local_object_indices.push_back( local_object_index );
  
  lines_table.push_back( line );
  object_types.push_back( LINE );
  
  int global_object_index = model->m_object_table.Count(); // So se can keep track of this object globally.
  global_object_indices.push_back( global_object_index );
  
  selected_objects.push_back( 0 );
  
  if ( lines_table[local_object_index]->IsValid() ) {
    ONX_Model_Object& object = model->m_object_table.AppendNew();
    
    object.m_object = lines_table.back();
    object.m_bDeleteObject = false;
    object.m_attributes.m_layer_index = 0;
    object.m_attributes.m_name = "line";
    
    object.m_attributes.m_material_index = 0;
    object.m_attributes.SetMaterialSource(ON::material_from_object);
    
    ON_CreateUuid( object.m_attributes.m_uuid );
    model->m_object_id_index.AddUuidIndex(object.m_attributes.m_uuid, global_object_index, false);
    
    return local_object_index;
  } else {
    lines_table.pop_back();
    object_types.pop_back();
    selected_objects.pop_back();
    global_object_indices.pop_back();
    return -1;
  }
  
}

void Geometry::setLineEndPoint( int line_index, int num, float x, float y, float z )
{
  ON_3dPoint pt;
  pt.x = x;
  pt.y = y;
  pt.z = z;
  
  if( num == 0 ){
    lines_table[line_index]->SetStartPoint( pt );
  }
  
  if( num == 1 ){
    lines_table[line_index]->SetEndPoint( pt );
  }
}

int Geometry::addNewCurve( int dim, int rational, int order, int num_control_vertices )
{
  ON_NurbsCurve* curve = new ON_NurbsCurve( dim, rational, order, num_control_vertices );

  int local_object_index = curves_table.size();
  local_object_indices.push_back( local_object_index );
  
  curves_table.push_back( curve );
  object_types.push_back( CURVE );
  
  int global_object_index = model->m_object_table.Count(); // So se can keep track of this object globally.
  global_object_indices.push_back( global_object_index );
  
  selected_objects.push_back( 0 ); // So we can track the selection state easily.
  
  ONX_Model_Object& object = model->m_object_table.AppendNew();
  
  object.m_object = curves_table.back();
  object.m_bDeleteObject = false;
  object.m_attributes.m_layer_index = 0;
  object.m_attributes.m_name = "custom curve";
  
  object.m_attributes.m_material_index = 0;
  object.m_attributes.SetMaterialSource(ON::material_from_object);
  
  ON_CreateUuid( object.m_attributes.m_uuid );
  model->m_object_id_index.AddUuidIndex(object.m_attributes.m_uuid, global_object_index, false);
  
  return local_object_index;
}

void Geometry::setCurveKnot( int curve_index, int knot_index, double knot )
{
   curves_table[curve_index]->SetKnot( knot_index, knot );
}

void Geometry::setCurveCV( int curve_index, int u, float x, float y, float z )
{
  ON_3dPoint pt;
  pt.x = x;
  pt.y = y;
  pt.z = z;
  
  curves_table[curve_index]->SetCV( u, pt );
}

int Geometry::finishCurve( int curve_index )
{
  bool success = false;
  
  if ( curves_table[curve_index]->IsValid() ) {
    
    success = true;

  } else {
    
    curves_table.pop_back();
    local_object_indices.pop_back();
    global_object_indices.pop_back();
    object_types.pop_back();
    
    success = false;
    
  }
  
  return success;
}


int Geometry::addEmptySurface( int dim, int u_cv_count, int v_cv_count )
{
  // Always assume these for now.
  const int bIsRational = false;
  const int u_degree = 3;
  const int v_degree = 3;
  
  ON_NurbsSurface* surface = new ON_NurbsSurface( dim, bIsRational, u_degree+1, v_degree+1, u_cv_count, v_cv_count );
  
  int local_object_index = surfaces_table.size();
  local_object_indices.push_back( local_object_index );
  
  surfaces_table.push_back( surface );
  object_types.push_back( SURFACE );

  int global_object_index = model->m_object_table.Count(); // So se can keep track of this object globally.
  global_object_indices.push_back( global_object_index );
  
  selected_objects.push_back( 0 ); // So we can track the selection state easily.
  
  ONX_Model_Object& object = model->m_object_table.AppendNew();
  
  object.m_object = surfaces_table.back();
  object.m_bDeleteObject = false;
  object.m_attributes.m_layer_index = 0;
  object.m_attributes.m_name = "custom surface";
  
  object.m_attributes.m_material_index = 0;
  object.m_attributes.SetMaterialSource(ON::material_from_object);
  
  ON_CreateUuid( object.m_attributes.m_uuid );
  model->m_object_id_index.AddUuidIndex(object.m_attributes.m_uuid, global_object_index, false);
  
  return local_object_index;
}


void Geometry::setSurfaceKnot( int surface_index, int dir, int knot_index, double knot )
{
  surfaces_table[surface_index]->SetKnot( dir, knot_index, knot );
}


void Geometry::setSurfaceCV( int surface_index, int u, int v, float x, float y, float z )
{
  ON_3dPoint pt;
  pt.x = x;
  pt.y = y;
  pt.z = z;
  
  // Is there a way to get to this surface through the objects array instead?
  surfaces_table[surface_index]->SetCV( u, v, pt );
}


bool Geometry::finishSurface( int surface_index )
{
  bool success = false;
  
  if ( surfaces_table[surface_index]->IsValid() ) {

    success = true;
    
  } else {
    // This probably isn't the right way to get rid of this surface.
    surfaces_table.pop_back();
    local_object_indices.pop_back();
    global_object_indices.pop_back();
    object_types.pop_back();
    
    success = false;
  }
  
  return success;
}


void Geometry::getLineEndPoint( int line_index, int i, double pt[] )
{
  ON_3dPoint point;
  if( i == 0 )
    point = lines_table[line_index]->m_line.from;
  if( i == 1 )
    point = lines_table[line_index]->m_line.to;
  
  pt[0] = point.x;
  pt[1] = point.y;
  pt[2] = point.z;
}


void Geometry::getCurveCV( int curve_index, int i, double pt[] )
{
  ON_3dPoint point;
  point = curves_table[curve_index]->CV(i);
  
  pt[0] = point.x;
  pt[1] = point.y;
  pt[2] = point.z;
}


void Geometry::getSurfaceCV( int surface_index, int i, int j, double pt[] )
{
  ON_3dPoint point;
  point = surfaces_table[surface_index]->CV(i,j);
  
  pt[0] = point.x;
  pt[1] = point.y;
  pt[2] = point.z;
}


int Geometry::getLocalIndex( int globalIndex )
{
  int i;
  
  for( i=0;i<global_object_indices.size();i++ ){
    if( global_object_indices[i] == globalIndex )
      return local_object_indices[i];
  }
  
  return -1;
}


int Geometry::getGlobalIndex( int localIndex, int objectType )
{
  int i;
  
  for( i=0;i<local_object_indices.size();i++ ){
    if( local_object_indices[i] == localIndex && object_types[i] == objectType )
      return global_object_indices[i];
  }
  
  return -1;
}


int Geometry::getObjectType( int globalIndex )
{
  int i;
  
  for( i=0;i<global_object_indices.size();i++ ){
    if( global_object_indices[i] == globalIndex )
      return object_types[i];
  }
  
  return -1;
}



void Geometry::translateObject( int globalObjectIndex, double dx, double dy, double dz )
{
  ON_3dVector vec = ON_3dVector(dx, dy, dz);
  
  ON_Geometry* object = 0;
  object = ON_Geometry::Cast((ON_Object*)model->m_object_table[globalObjectIndex].m_object);
  
  if( object )
    object->Translate(vec);
}


void Geometry::translate( double dx, double dy, double dz )
{
  int i;
  for( i=0;i<global_object_indices.size();i++ )
    translateObject( global_object_indices[i], dx, dy, dz );
}


void Geometry::scaleObject( int globalObjectIndex, double x, double y, double z )
{
  ON_Geometry* object = 0;
  object = ON_Geometry::Cast((ON_Object*)model->m_object_table[globalObjectIndex].m_object);
  
  if( object ){
    ON_Xform s;
    s.Scale( x, y, z );
    object->Transform(s);
  }
}


void Geometry::scale( double x, double y, double z )
{
  int i;
  for( i=0;i<global_object_indices.size();i++ )
    scaleObject( global_object_indices[i], x, y, z );
}


void Geometry::rotateObject( int globalObjectIndex, double angle, double ax, double ay, double az, double cx, double cy, double cz )
{
  ON_Geometry* object = 0;
  object = ON_Geometry::Cast((ON_Object*)model->m_object_table[globalObjectIndex].m_object);

  if( object ) {
    ON_3dVector axis = ON_3dVector(ax, ay, az);
    ON_3dPoint center = ON_3dPoint(cx, cy, cz);
    
    object->Rotate(angle, axis, center);
  }
}


void Geometry::rotate( double angle, double ax, double ay, double az, double cx, double cy, double cz )
{
  int i;
  for( i=0;i<global_object_indices.size();i++ )
    rotateObject( global_object_indices[i], angle, ax, ay, az, cx, cy, cz );
}


bool Geometry::contains( int globalObjectIndex )
{
  int i;

  for( i=0;i<global_object_indices.size();i++ ){
    if( globalObjectIndex == global_object_indices[i] ){
      printf("Found an object. The index is %d.\n", i);
      return true;
    }
  }

  return false;
}


bool Geometry::selectGeometry( int globalObjectIndex )
{
  int i;
  bool sel = false;
  
  // The parent part has to know if an object it owns is selected. So we have to loop 
  // through the global_object_indices table to see if this global index is here.
  for( i=0;i<global_object_indices.size();i++ ){
    
    if( globalObjectIndex == global_object_indices[i] ){
      printf("Found an object. The index is %d.\n", i);
      
      model->m_object_table[globalObjectIndex].m_attributes.m_material_index = 1;
      selected_objects[i] = 1;
      sel = true;
      
      printf("Adding to selection: %d\n", globalObjectIndex);
    }
  }
  return sel;
}


void Geometry::unselectGeometry( int globalObjectIndex )
{
  int i;
  
  for( i=0;i<global_object_indices.size();i++ ){
    if( globalObjectIndex == global_object_indices[i] ){
      selected_objects[i] = 0;
      model->m_object_table[globalObjectIndex].m_attributes.m_material_index = 0;
    }
  }
}


void Geometry::selectAll()
{
  int i;
  for( i=0;i<global_object_indices.size();i++ ){
    selected_objects[i] = 1;
    model->m_object_table[global_object_indices[i]].m_attributes.m_material_index = 1;
  }
}


void Geometry::unselectAll()
{
  int i;
  for( i=0;i<global_object_indices.size();i++ ){
    selected_objects[i] = 0;
    model->m_object_table[global_object_indices[i]].m_attributes.m_material_index = 0;
  }
}


void Geometry::cube(float s)
{
  GLfloat mat_specular[] = { 1.0, 1.0, 1.0, 1.0 };
  GLfloat mat_shininess[] = { 100.0 };
  glMaterialfv( GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular );
  glMaterialfv( GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess );
  
  glBegin(GL_QUADS);
  {
    glVertex3f(  s, -s, -s );
    glVertex3f( -s, -s, -s );
    glVertex3f( -s,  s, -s );
    glVertex3f(  s,  s, -s );
    
    glVertex3f(  s,  s,  s );
    glVertex3f( -s,  s,  s );
    glVertex3f( -s, -s,  s );
    glVertex3f(  s, -s,  s );
    
    glVertex3f(  s,  s, -s );
    glVertex3f( -s,  s, -s );
    glVertex3f( -s,  s,  s );
    glVertex3f(  s,  s,  s );
    
    glVertex3f( -s,  s, -s );
    glVertex3f( -s, -s, -s );
    glVertex3f( -s, -s,  s );
    glVertex3f( -s,  s,  s );
    
    glVertex3f( -s, -s, -s );
    glVertex3f(  s, -s, -s );
    glVertex3f(  s, -s,  s );
    glVertex3f( -s, -s,  s );
    
    glVertex3f(  s, -s, -s );
    glVertex3f(  s,  s, -s );
    glVertex3f(  s,  s,  s );
    glVertex3f(  s, -s,  s );
  }
  glEnd();
  
}




void Geometry::drawParameterLines( bool select )
{
  int i, u, v;
  
  glLineStipple(1, 0xF0F0);
  glEnable(GL_LINE_STIPPLE);
  glDisable(GL_LIGHTING);
  glColor3f(1.0,1.0,1.0);
  
  for(i=0;i<surfaces_table.size();i++){
    
    for( u=0;u<surfaces_table[i]->CVCount(0);u++ ){
      glBegin(GL_LINE_STRIP);
      for( v=0;v<surfaces_table[i]->CVCount(1);v++ ){
        ON_3dPoint pt;
        pt = surfaces_table[i]->CV(u,v);
        glVertex3f(pt.x, pt.y, pt.z);
      }
      glEnd();
    }
    
    for( v=0;v<surfaces_table[i]->CVCount(1);v++ ){
      glBegin(GL_LINE_STRIP);
      for( u=0;u<surfaces_table[i]->CVCount(0);u++ ){
        ON_3dPoint pt;
        pt = surfaces_table[i]->CV(u,v);
        glVertex3f(pt.x, pt.y, pt.z);
      }
      glEnd();
    }
    
  } // end surface loop
  
  for( i=0; i<curves_table.size(); i++ ){
    glBegin(GL_LINE_STRIP);
    for( u=0; u<curves_table[i]->CVCount(); u++ ){
      ON_3dPoint pt;
      pt = curves_table[i]->CV(u);
      glVertex3f(pt.x, pt.y, pt.z);
    }
    glEnd();
  }
  
  glDisable(GL_LINE_STIPPLE);
  glEnable(GL_LIGHTING);
  
}

int Geometry::getSurfaceCount()
{
  return surfaces_table.size();
}

int Geometry::getGeometryCount( int type )
{
  if( type == SURFACE )
    return surfaces_table.size();
  if( type == CURVE )
    return curves_table.size();
  if( type == LINE )
    return lines_table.size();
  return 0;
}


int Geometry::getObjectCount()
{
  return global_object_indices.size();
}


char* Geometry::getUUID( int globalObjectIndex )
{
  int i;
  for( i=0;i<global_object_indices.size();i++ ){
    if( globalObjectIndex == global_object_indices[i] ){
      char* uuid;
      ON_UuidToString(model->m_object_table[globalObjectIndex].m_attributes.m_uuid, uuid );
      return uuid;
    }
  }
  return NULL;
}

int* Geometry::getObjectIndicies()
{
  return &global_object_indices[0];
}

int* Geometry::getSelected()
{
  return &selected_objects[0];
}
