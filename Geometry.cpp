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

#import "/Users/awmartin/Dropbox/OpenManifold/src/opennurbs/opennurbs.h"
#import "/Users/awmartin/Dropbox/OpenManifold/src/opennurbs/opennurbs_gl.h"
#import "opennurbs_interface.h"
#import "Geometry.h"


Geometry::Geometry( ONX_Model* mo )
{
  model = mo;
	uCount = 11;
	vCount = 11;
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


int Geometry::addEmptySurface( int dim, int u_cv_count, int v_cv_count, int u_degree, int v_degree )
{
  // Always assume these for now.
  const int bIsRational = false;
  //const int u_degree = 3;
  //const int v_degree = 3;
  
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

vector<int> Geometry::thickenSurface( int surface_index, float thickness )
{
	
	ON_NurbsSurface* surface = surfaces_table[surface_index];
	
  vector<ON_3dPoint> topPts;
  vector<ON_3dPoint> bottomPts;
    
	double uMin, uMax, vMin, vMax;
	
	surface->GetDomain(0, &uMin, &uMax);
	surface->GetDomain(1, &vMin, &vMax);
	
	double uStep = (uMax-uMin)/(double)(uCount-1);
	double vStep = (vMax-vMin)/(double)(vCount-1);
	
	double u, v;
	
	for( int uc=0; uc<=uCount-1; uc++ ){
		for( int vc=0; vc<=vCount-1; vc++ ){
			
			ON_3dPoint pt;
			ON_3dVector vec;
			
			u = uStep * (double)uc + uMin;
			v = vStep * (double)vc + vMin;
			
			surface->EvNormal(u, v, pt, vec);
			addPoint( pt.x, pt.y, pt.z );
			
			addLine( pt.x, pt.y, pt.z, pt.x + thickness*vec.x, pt.y + thickness*vec.y, pt.z + thickness*vec.z );
			addLine( pt.x, pt.y, pt.z, pt.x - thickness*vec.x, pt.y - thickness*vec.y, pt.z - thickness*vec.z );
			
      ON_3dPoint t, b;
            
			t.x = pt.x + thickness*vec.x;
			t.y = pt.y + thickness*vec.y;
			t.z = pt.z + thickness*vec.z;
			
			b.x = pt.x - thickness*vec.x;
			b.y = pt.y - thickness*vec.y;
			b.z = pt.z - thickness*vec.z;
            
      topPts.push_back(t);
      bottomPts.push_back(b);
		}
	}
	
	vector<int> indices;
	
	for( int uc=0; uc<uCount-1; uc++ ){
		for( int vc=0; vc<vCount-1; vc++ ){
			int i = addSimpleSurface( topPts[vc*uCount+uc], topPts[(vc+1)*uCount+uc], topPts[vc*uCount+uc+1], topPts[(vc+1)*uCount+uc+1] );
			indices.push_back(i);
		}
	}
	
	for( int uc=0; uc<uCount-1; uc++ ){
		for( int vc=0; vc<vCount-1; vc++ ){
			int i = addSimpleSurface( bottomPts[vc*uCount+uc], bottomPts[(vc+1)*uCount+uc], bottomPts[vc*uCount+uc+1], bottomPts[(vc+1)*uCount+uc+1] );
			indices.push_back(i);
		}
	}
	
	for( int u=0; u<uCount-1; u++ ){
		int i = addSimpleSurface( topPts[u], topPts[u+1], bottomPts[u], bottomPts[u+1] );
		indices.push_back(i);
	}
	
	for( int u=0; u<uCount-1; u++ ){
		int i = addSimpleSurface( topPts[(vCount-1)*uCount+u], topPts[(vCount-1)*uCount+u+1], bottomPts[(vCount-1)*uCount+u], bottomPts[(vCount-1)*uCount+u+1] );
		indices.push_back(i);
	}
	
	for( int v=0; v<vCount-1; v++ ){
		int i = addSimpleSurface( topPts[v*uCount], topPts[(v+1)*uCount], bottomPts[v*uCount], bottomPts[(v+1)*uCount] );
		indices.push_back(i);
	}
	
	for( int v=0; v<vCount-1; v++ ){
		int i = addSimpleSurface( topPts[v*uCount+uCount-1], topPts[(v+1)*uCount+uCount-1], bottomPts[v*uCount+uCount-1], bottomPts[(v+1)*uCount+uCount-1] );
		indices.push_back(i);
	}
	
	return indices;
}

void Geometry::updateThickenedSurface( int surface_index, double thickness, vector<int>& indices ){
	ON_NurbsSurface* surface = surfaces_table[surface_index];
	
  vector<ON_3dPoint> topPts;
  vector<ON_3dPoint> bottomPts;
    
	double uMin, uMax, vMin, vMax;
	
	surface->GetDomain(0, &uMin, &uMax);
	surface->GetDomain(1, &vMin, &vMax);
	
	double uStep = (uMax-uMin)/(double)(uCount-1);
	double vStep = (vMax-vMin)/(double)(vCount-1);
	
	double u, v;
	
	for( int uc=0; uc<=uCount-1; uc++ ){
		for( int vc=0; vc<=vCount-1; vc++ ){
			
			ON_3dPoint pt;
			ON_3dVector vec;
			
			u = uStep * (double)uc + uMin;
			v = vStep * (double)vc + vMin;
			
			surface->EvNormal(u, v, pt, vec);
      
      ON_3dPoint t, b;
      
			t.x = pt.x + thickness*vec.x;
			t.y = pt.y + thickness*vec.y;
			t.z = pt.z + thickness*vec.z;
			
			b.x = pt.x - thickness*vec.x;
			b.y = pt.y - thickness*vec.y;
			b.z = pt.z - thickness*vec.z;
      
      topPts.push_back(t);
      bottomPts.push_back(b);
		}
	}
	
	int i=0;
	
	for( int uc=0; uc<uCount-1; uc++ ){
		for( int vc=0; vc<vCount-1; vc++ ){
			updateSimpleSurface( indices[i], topPts[vc*uCount+uc], topPts[(vc+1)*uCount+uc], topPts[vc*uCount+uc+1], topPts[(vc+1)*uCount+uc+1] );
			i++;
		}
	}
	
	for( int uc=0; uc<uCount-1; uc++ ){
		for( int vc=0; vc<vCount-1; vc++ ){
			updateSimpleSurface( indices[i], bottomPts[vc*uCount+uc], bottomPts[(vc+1)*uCount+uc], bottomPts[vc*uCount+uc+1], bottomPts[(vc+1)*uCount+uc+1] );
			i++;
		}
	}
	
	for( int u=0; u<uCount-1; u++ ){
		updateSimpleSurface( indices[i], topPts[u], topPts[u+1], bottomPts[u], bottomPts[u+1] );
		i++;
	}
	
	for( int u=0; u<uCount-1; u++ ){
		updateSimpleSurface( indices[i], topPts[(vCount-1)*uCount+u], topPts[(vCount-1)*uCount+u+1], bottomPts[(vCount-1)*uCount+u], bottomPts[(vCount-1)*uCount+u+1] );
		i++;
	}
	
	for( int v=0; v<vCount-1; v++ ){
		updateSimpleSurface( indices[i], topPts[v*uCount], topPts[(v+1)*uCount], bottomPts[v*uCount], bottomPts[(v+1)*uCount] );
		i++;
	}
	
	for( int v=0; v<vCount-1; v++ ){
		updateSimpleSurface( indices[i], topPts[v*uCount+uCount-1], topPts[(v+1)*uCount+uCount-1], bottomPts[v*uCount+uCount-1], bottomPts[(v+1)*uCount+uCount-1] );
		i++;
	}
	
}

int Geometry::getNodeIndex( int u, int v, int side ){
	//return u*vCount + v + side*(uCount*vCount);
  return v*uCount + u + side*(uCount*vCount);
}

void Geometry::getMesh( int surface_index, double thickness, vector<Node>& nodes, vector<Face>& faces){
	ON_NurbsSurface* surface = surfaces_table[surface_index];
	
  vector<ON_3dPoint> topPts;
  vector<ON_3dPoint> bottomPts;
	
	double uMin, uMax, vMin, vMax;
	
	surface->GetDomain(0, &uMin, &uMax);
	surface->GetDomain(1, &vMin, &vMax);
	
	double uStep = (uMax-uMin)/(double)(uCount-1);
	double vStep = (vMax-vMin)/(double)(vCount-1);
	
	double u, v;
	
	for( int uc=0; uc<=uCount-1; uc++ ){
		for( int vc=0; vc<=vCount-1; vc++ ){
			
			ON_3dPoint pt;
			ON_3dVector vec;
			
			u = uStep * (double)uc + uMin;
			v = vStep * (double)vc + vMin;
			
			surface->EvNormal(u, v, pt, vec);
			addPoint( pt.x, pt.y, pt.z );
			
			addLine( pt.x, pt.y, pt.z, pt.x + thickness*vec.x, pt.y + thickness*vec.y, pt.z + thickness*vec.z );
			addLine( pt.x, pt.y, pt.z, pt.x - thickness*vec.x, pt.y - thickness*vec.y, pt.z - thickness*vec.z );
			
      ON_3dPoint t, b;
            
			t.x = pt.x + thickness*vec.x;
			t.y = pt.y + thickness*vec.y;
			t.z = pt.z + thickness*vec.z;
			
			b.x = pt.x - thickness*vec.x;
			b.y = pt.y - thickness*vec.y;
			b.z = pt.z - thickness*vec.z;
            
      topPts.push_back(t);
      bottomPts.push_back(b);
		}
	}
	
	// Put the nodes into the node list.
	for( int uc=0; uc<=uCount-1; uc++ ){
		for( int vc=0; vc<=vCount-1; vc++ ){
			Node n;
			n.x = topPts[vc*uCount+uc].x;
			n.y = topPts[vc*uCount+uc].y;
			n.z = topPts[vc*uCount+uc].z;
			nodes.push_back( n );
		}
	}
	
	for( int uc=0; uc<=uCount-1; uc++ ){
		for( int vc=0; vc<=vCount-1; vc++ ){
			Node n;
			n.x = bottomPts[vc*uCount+uc].x;
			n.y = bottomPts[vc*uCount+uc].y;
			n.z = bottomPts[vc*uCount+uc].z;
			nodes.push_back( n );
		}
	}
	
	
	// Put the faces into the face list.
	for( int uc=0; uc<uCount-1; uc++ ){
		for( int vc=0; vc<vCount-1; vc++ ){
			Face f;
			f.pt0 = getNodeIndex(uc, vc, 0);
			f.pt1 = getNodeIndex(uc, vc+1, 0);
			f.pt2 = getNodeIndex(uc+1, vc, 0);
			faces.push_back(f);
			
			Face g;
			// Reversed order.
			g.pt2 = getNodeIndex(uc, vc+1, 0);
			g.pt1 = getNodeIndex(uc+1, vc, 0);
			g.pt0 = getNodeIndex(uc+1, vc+1, 0);
			faces.push_back(g);
		}
	}
	
	for( int uc=0; uc<uCount-1; uc++ ){
		for( int vc=0; vc<vCount-1; vc++ ){
			Face f;
			f.pt0 = getNodeIndex(uc, vc, 1);
			f.pt1 = getNodeIndex(uc, vc+1, 1);
			f.pt2 = getNodeIndex(uc+1, vc, 1);
			faces.push_back(f);
			
			Face g;
			// reversed order
			g.pt2 = getNodeIndex(uc, vc+1, 1);
			g.pt1 = getNodeIndex(uc+1, vc, 1);
			g.pt0 = getNodeIndex(uc+1, vc+1, 1);
			faces.push_back(g);
		}
	}
	
	for( int u=0; u<uCount-1; u++ ){
		Face f;
		f.pt0 = getNodeIndex(u, 0, 0);
		f.pt1 = getNodeIndex(u+1, 0, 0);
		f.pt2 = getNodeIndex(u, 0, 1);
		faces.push_back(f);
		
		Face g;
		// reversed order
		g.pt2 = getNodeIndex(u+1, 0, 0);
		g.pt1 = getNodeIndex(u, 0, 1);
		g.pt0 = getNodeIndex(u+1, 0, 1);
		faces.push_back(g);
	}
	
	for( int u=0; u<uCount-1; u++ ){
		Face f;
		f.pt0 = getNodeIndex(u, vCount-1, 0);
		f.pt1 = getNodeIndex(u+1, vCount-1, 0);
		f.pt2 = getNodeIndex(u, vCount-1, 1);
		faces.push_back(f);
		
		Face g;
		// reversed order
		g.pt2 = getNodeIndex(u+1, vCount-1, 0);
		g.pt1 = getNodeIndex(u, vCount-1, 1);
		g.pt0 = getNodeIndex(u+1, vCount-1, 1);
		faces.push_back(g);
	}
	
	for( int v=0; v<vCount-1; v++ ){
		Face f;
		f.pt0 = getNodeIndex(0, v, 0);
		f.pt1 = getNodeIndex(0, v+1, 0);
		f.pt2 = getNodeIndex(0, v, 1);
		faces.push_back(f);
		
		Face g;
		// reversed order
		g.pt2 = getNodeIndex(0, v+1, 0);
		g.pt1 = getNodeIndex(0, v, 1);
		g.pt0 = getNodeIndex(0, v+1, 1);
		faces.push_back(g);
	}
	
	for( int v=0; v<vCount-1; v++ ){
		Face f;
		f.pt0 = getNodeIndex(uCount-1, v, 0);
		f.pt1 = getNodeIndex(uCount-1, v+1, 0);
		f.pt2 = getNodeIndex(uCount-1, v, 1);
		faces.push_back(f);
		
		Face g;
		// reversed order
		g.pt2 = getNodeIndex(uCount-1, v+1, 0);
		g.pt1 = getNodeIndex(uCount-1, v, 1);
		g.pt0 = getNodeIndex(uCount-1, v+1, 1);
		faces.push_back(g);
	}
	
}


bool Geometry::generateMesh( vector<Node>& nodes, vector<Face>& faces, vector<Color>& colors ){
	bool bHasVertexNormals = false;
  bool bHasTexCoords = false;
  const int vertex_count = nodes.size();
  const int face_count = faces.size();
	
  ON_Mesh* mesh = new ON_Mesh( face_count, vertex_count, bHasVertexNormals, bHasTexCoords);
	
  for( int i=0; i<nodes.size(); i++ ){
    mesh->SetVertex( i, ON_3dPoint( nodes[i].x,  nodes[i].y,  nodes[i].z) );
  }

  if( colors.size() == nodes.size() ){
    for( int i=0; i<nodes.size(); i++ ){
      mesh->m_C.Append( ON_Color( colors[i].r, colors[i].g, colors[i].b ) );
    }
  }

  for( int i=0; i<faces.size(); i++ ){
    mesh->SetTriangle( i, faces[i].pt0, faces[i].pt1, faces[i].pt2 );
  }

  bool ok = false;
    
  if ( mesh->IsValid() ) 
  {
    if ( !mesh->HasVertexNormals() )
      mesh->ComputeVertexNormals();
		
		int local_object_index = meshes_table.size();
		local_object_indices.push_back( local_object_index );
		
		meshes_table.push_back( mesh );
		object_types.push_back( MESH );
		
		int global_object_index = model->m_object_table.Count(); // So se can keep track of this object globally.
		global_object_indices.push_back( global_object_index );
		
		selected_objects.push_back( 0 );
		
		ONX_Model_Object& object = model->m_object_table.AppendNew();
    
    object.m_object = meshes_table.back();
    object.m_bDeleteObject = false;
    object.m_attributes.m_layer_index = 0;
    object.m_attributes.m_name = "mesh";
    
    object.m_attributes.m_material_index = 0;
    object.m_attributes.SetMaterialSource(ON::material_from_object);
    
    ON_CreateUuid( object.m_attributes.m_uuid );
    model->m_object_id_index.AddUuidIndex(object.m_attributes.m_uuid, global_object_index, false);
    
		ok = true;
  }
	
  return ok;
}

void Geometry::updateSimpleSurface( int surface_index, ON_3dPoint& pt00, ON_3dPoint& pt01, ON_3dPoint& pt10, ON_3dPoint& pt11 ){
	surfaces_table[surface_index]->SetCV( 0, 0, pt00 );
	surfaces_table[surface_index]->SetCV( 0, 1, pt01 );
	surfaces_table[surface_index]->SetCV( 1, 0, pt10 );
	surfaces_table[surface_index]->SetCV( 1, 1, pt11 );
}


int Geometry::addSimpleSurface( ON_3dPoint& pt00, ON_3dPoint& pt01, ON_3dPoint& pt10, ON_3dPoint& pt11 ){

	int surface_index = addEmptySurface( 3, 2, 2, 1, 1 );
	//int global_index = getGlobalIndex(surface_index, SURFACE);
  int i, j;
	
	// Knot vectors.
	double u_knot[ 2 ];
  double v_knot[ 2 ];
	u_knot[0] = 0;
	u_knot[1] = 1;
	v_knot[0] = 0;
	v_knot[1] = 1;
	
  for ( i = 0; i < 2; i++ )
    setSurfaceKnot( surface_index, 0, i, u_knot[i] );
  
  for ( j = 0; j < 2; j++ )
    setSurfaceKnot( surface_index, 1, j, v_knot[j] );
	
	surfaces_table[surface_index]->SetCV( 0, 0, pt00 );
	surfaces_table[surface_index]->SetCV( 0, 1, pt01 );
	surfaces_table[surface_index]->SetCV( 1, 0, pt10 );
	surfaces_table[surface_index]->SetCV( 1, 1, pt11 );
	
	if( finishSurface( surface_index ) ){
		return surface_index;
	} else {
		return 0;
	}
	return 0;
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
