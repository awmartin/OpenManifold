/*
 *  opennurbs_interface.cpp
 *  opennurbstesting
 *
 *  Created by Allan William Martin on 6/17/09.
 *  Copyright 2009 Anomalus. All rights reserved.
 *
 */

#import "/Users/awmartin/Dropbox/OpenManifold/src/opennurbs/opennurbs.h"
#import "/Users/awmartin/Dropbox/OpenManifold/src/opennurbs/opennurbs_gl.h"

#import "opennurbs_interface.h"



static GLuint glb_display_list_number = 1;

GLUnurbsObj* pTheGLNURBSRender; // OpenGL NURBS rendering context



ON_Wrapper::ON_Wrapper(){
  ON::Begin();
  pTheGLNURBSRender = NULL;
  
  model = new ONX_Model();
  
  // set revision history information
  model->m_properties.m_RevisionHistory.NewRevision();
  
  // set application information
  model->m_properties.m_Application.m_application_name = "OpenNURBS testing on Mac";
  model->m_properties.m_Application.m_application_URL = "http://www.opennurbs.org";
  model->m_properties.m_Application.m_application_details = "Example program using OpenNURBS on Mac with Cocoa.";
  
  // some notes
  model->m_properties.m_Notes.m_notes = "This file was made with love.";
  model->m_properties.m_Notes.m_bVisible = true;
  
  // file settings (units, tolerances, views, ...)
  model->m_settings.m_ModelUnitsAndTolerances.m_unit_system = ON::inches;
  model->m_settings.m_ModelUnitsAndTolerances.m_absolute_tolerance = 0.001;
  model->m_settings.m_ModelUnitsAndTolerances.m_angle_tolerance = ON_PI/180.0; // radians
  model->m_settings.m_ModelUnitsAndTolerances.m_relative_tolerance = 0.01; // 1%
  
  // layer table
  {
    model->m_layer_table.Reserve(3);
    
    // OPTIONAL - define some layers
    ON_Layer layer[3];
    
    layer[0].SetLayerName("Default");
    layer[0].SetVisible(true);
    layer[0].SetLocked(false);
    layer[0].SetColor( ON_Color(0,0,0) );
    layer[0].SetLayerIndex(0);
    
    layer[1].SetLayerName("Layer 1");
    layer[1].SetVisible(true);
    layer[1].SetLocked(false);
    layer[1].SetLayerIndex(1);
    layer[1].SetColor( ON_Color(0,255,0) );
    
    layer[2].SetLayerName("Layer 2");
    layer[2].SetVisible(true);
    layer[2].SetLocked(false);
    layer[2].SetLayerIndex(2);
    layer[2].SetColor( ON_Color(0,0,255) );
    
    model->m_layer_table.Append(layer[0]);
    model->m_layer_table.Append(layer[1]);
    model->m_layer_table.Append(layer[2]);
  }
  
  // materials
  {
    /*generic->SetMaterialIndex(0);
    generic->SetAmbient(  ON_Color(  40,  40,  40 ) );
    generic->SetDiffuse(  ON_Color( 220, 220, 220 ) );
    generic->SetEmission( ON_Color(   0,   0,   0 ) );
    generic->SetSpecular( ON_Color( 180, 180, 180 ) );
    generic->SetMaterialName( L"generic material" );
    
    selected->SetMaterialIndex(1);
    selected->SetAmbient(  ON_Color(  40,  40,  0 ) );
    selected->SetDiffuse(  ON_Color( 220, 220, 0 ) );
    selected->SetEmission( ON_Color(   0,   0,   0 ) );
    selected->SetSpecular( ON_Color( 180, 180, 0 ) );
    selected->SetMaterialName( L"selection material" );*/
    
    ON_Material generic;
    generic.SetMaterialIndex(0);
    generic.SetAmbient(  ON_Color(  40,  40,  40 ) );
    generic.SetDiffuse(  ON_Color( 220, 220, 220 ) );
    generic.SetEmission( ON_Color(   0,   0,   0 ) );
    generic.SetSpecular( ON_Color( 180, 180, 180 ) );
    generic.SetMaterialName( L"generic material" );
    
    ON_Material selected;
    selected.SetMaterialIndex(1);
    selected.SetAmbient(  ON_Color(  40,  40,  0 ) );
    selected.SetDiffuse(  ON_Color( 220, 220, 0 ) );
    selected.SetEmission( ON_Color(   0,   0,   0 ) );
    selected.SetSpecular( ON_Color( 180, 180, 0 ) );
    selected.SetMaterialName( L"selection material" );
    
    model->m_material_table.Reserve(2);
    model->m_material_table.Append(generic);
    model->m_material_table.Append(selected);
  }
}

void ON_Wrapper::dumpModel(){
  ON_TextLog dump_to_stdout;
  ON_TextLog* dump = &dump_to_stdout;
  model->Dump( *dump );
}

void ON_Wrapper::load( const char* sFileName ){
  

  
  ON_TextLog error_log;
  
  // read the file
  printf("Attempting to read the file: %s\n", sFileName);
  
  if ( !model->Read( sFileName, &error_log ) )
  {
    // read failed
    error_log.Print("Unable to read file %s\n",sFileName);
    return;
  }
  
  render_nurbs_gl();
  
  {
    printf("Attempting a dump at loading time...\n");
    ON_TextLog dump_to_stdout;
    ON_TextLog* dump = &dump_to_stdout;
    model->Dump( *dump );
  }
  
}


void ON_Wrapper::save( const char* sFileName ){
  FILE* fp = ON::OpenFile( sFileName, "wb" );
  ON_TextLog error_log;
  
  printf( "Saving object count: %d\n", model->m_object_table.Count() );
  
  int version = 4;
  ON_BinaryFile archive( ON::write3dm, fp );
  const char* sStartSectionComment = __FILE__ "save testing" __DATE__;
  
  model->Polish();
  bool ok = model->Write(archive, version, sStartSectionComment, &error_log );
  
  if (ok)
    printf("Successfully wrote %s.\n", sFileName);
  else
    printf("Errors while writing %s.\n", sFileName);
  
  ON::CloseFile( fp );
}


void ON_Wrapper::drawModel()
{
  if ( pTheGLNURBSRender ) {
    GLfloat renderMode;
    gluGetNurbsProperty(pTheGLNURBSRender, GLU_DISPLAY_MODE, &renderMode);
    if( renderMode == GLU_OUTLINE_POLYGON )
      glDisable(GL_LIGHTING);
  }
  glCallList( glb_display_list_number );
}


void ON_Wrapper::refreshModel()
{
  render_nurbs_gl();
}


/** This converts the OpenNURBS objects in the model and converts them to an 
  * openGL-friendly form. 
**/
void ON_Wrapper::render_nurbs_gl(){
  BOOL bOK;
  
  // setup model view matrix, GL defaults, and the GL NURBS renderer
  if( pTheGLNURBSRender == NULL ) {
    bOK = myInitGL();
  
    if ( bOK ) {
      // build display list
      myBuildDisplayList( glb_display_list_number );
    }
  } else {
    myBuildDisplayList( glb_display_list_number );
  }
  
  //gluDeleteNurbsRenderer( pTheGLNURBSRender );
}

void error( GLenum errorCode );

BOOL ON_Wrapper::myInitGL()
{
  // GL rendering of NURBS objects requires a GLUnurbsObj.
  pTheGLNURBSRender = gluNewNurbsRenderer();
  if ( !pTheGLNURBSRender )
    return false;
  
  gluNurbsProperty( pTheGLNURBSRender, GLU_SAMPLING_TOLERANCE,   100.0f );
  gluNurbsProperty( pTheGLNURBSRender, GLU_PARAMETRIC_TOLERANCE, 0.5f );
	
	//gluNurbsProperty( pTheGLNURBSRender, GLU_NURBS_MODE, GLU_NURBS_TESSELLATOR );
  
  //gluNurbsProperty( pTheGLNURBSRender, GLU_DISPLAY_MODE,         (GLfloat)GLU_FILL );
  gluNurbsProperty( pTheGLNURBSRender, GLU_DISPLAY_MODE,         GLU_OUTLINE_POLYGON );
  //gluNurbsProperty( pTheGLNURBSRender, GLU_DISPLAY_MODE,         GLU_OUTLINE_PATCH );
  
  //gluNurbsProperty( pTheGLNURBSRender, GLU_SAMPLING_METHOD,      (GLfloat)GLU_PATH_LENGTH );
  //gluNurbsProperty( pTheGLNURBSRender, GLU_SAMPLING_METHOD,      GLU_PARAMETRIC_ERROR );
  
  gluNurbsProperty( pTheGLNURBSRender, GLU_SAMPLING_METHOD,      GLU_DOMAIN_DISTANCE );
  gluNurbsProperty( pTheGLNURBSRender, GLU_U_STEP, 10 );
  gluNurbsProperty( pTheGLNURBSRender, GLU_V_STEP, 10 );
  
  gluNurbsProperty( pTheGLNURBSRender, GLU_CULLING,              (GLfloat)GL_FALSE );
  
  // register GL NURBS error callback
  gluNurbsCallback( pTheGLNURBSRender, GLU_ERROR, (GLvoid (*)()) error );
  
	glShadeModel(GL_SMOOTH);
	
  return true;
}

void error( GLenum errorCode ){
  const GLubyte *estring;
  
  estring = gluErrorString(errorCode);
  fprintf (stderr, "Nurbs Error: %s\n", estring);
}

void ON_Wrapper::displayModeFill()
{
  if ( !pTheGLNURBSRender )
    return;
  gluNurbsProperty( pTheGLNURBSRender, GLU_DISPLAY_MODE, (GLfloat)GLU_FILL );
  refreshModel();
}


void ON_Wrapper::displayModeOutline()
{
  if ( !pTheGLNURBSRender )
    return;
  gluNurbsProperty( pTheGLNURBSRender, GLU_DISPLAY_MODE, GLU_OUTLINE_POLYGON );
  refreshModel();
}


/* Utility method used for the selection and picking process. Allows us to build
 the display list manually when rendering with GL_SELECT. */
void ON_Wrapper::build()
{
  myBuildDisplayList( glb_display_list_number );
}

void ON_Wrapper::buildExampleMaterial()
{
  // rendering material with a texture map.
  ON_Material material;
  
  material.SetMaterialIndex(0);
  material.SetAmbient(  ON_Color(  40,  40,  40 ) );
  material.SetDiffuse(  ON_Color( 220, 220, 220 ) );
  material.SetEmission( ON_Color(   0,   0,   0 ) );
  material.SetSpecular( ON_Color( 180, 180, 180 ) );
  
  material.SetShine( 0.35*ON_Material::MaxShine() ); // 0 = flat
  // MaxShine() = shiney
  
  material.SetTransparency( 0.2 );  // 0 = opaque, 1 = transparent
  
  // Texture and bump bitmaps can be Windows bitmap (.BMP), Targa (.TGA),
  // JPEG (.JPG), PCX or PNG files.  Version 1 of Rhino will not support
  // filenames using unicode or multibyte character sets.  As soon as
  // Rhino supports these character sets, the const char* filename will
  // changed to const _TCHAR*.
  
  // For Rhino to find the texture bitmap, the .3dm file and the
  // .bmp file need to be in the same directory.
  //ON_Texture texture;
  //texture.m_filename = L"example_texture.bmp";
  //material.AddTexture( texture );
  
  // The render material name is a string used to identify rendering
  // materials in RIB, POV, OBJ, ..., files.  In Rhino, the render
  // material name is set with the SetObjectMaterial command and can
  // be viewed in the Info tab of the dialog displayed by the
  // Properties command.
  material.SetMaterialName( L"generic material" );
}



void ON_Wrapper::myBuildDisplayList( GLuint display_list_number )
{
  ON_Material material;
  material.Default();
  
  // Check for the rendering mode to see if we have to select anything.
  GLint mode;
  glGetIntegerv(GL_RENDER_MODE, &mode);
  
  glNewList( display_list_number, GL_COMPILE );
  
  glColor3f( 1.0, 1.0, 1.0 );
  
  if( mode == GL_SELECT ) glPushName(1); // All the objects are wrapped with name '1'.
  
  int i;
  const int object_count = model->m_object_table.Count();
  
  for ( i = 0; i < object_count; i++ )
  {
    const ONX_Model_Object& mo = model->m_object_table[i];
    if ( 0 != mo.m_object )
    {
      model->GetRenderMaterial( mo.m_attributes, material );
      
      // If the gl engine is in select mode, then add the name as the global object index.
      if( mode == GL_SELECT ) glPushName(i);
      
      myDisplayObject( *mo.m_object, material );
      
      if( mode == GL_SELECT ) glPopName();
    }
  }
  
  if( mode == GL_SELECT ) glPopName();
  glEndList();
}


void ON_Wrapper::myDisplayObject( const ON_Object& geometry, const ON_Material& material )
{
  // Uses ON_GL() functions found in rhinoio_gl.cpp.
  const ON_Point* point=0;
  const ON_PointCloud* cloud=0;
  const ON_Brep* brep=0;
  const ON_Mesh* mesh=0;
  const ON_Curve* curve=0;
  const ON_Surface* surface=0;
  
  brep = ON_Brep::Cast(&geometry);
  if ( brep ) 
  {
		ON_GL( material );
    ON_GL(*brep, pTheGLNURBSRender);
    return;
  }
  
  mesh = ON_Mesh::Cast(&geometry);
  if ( mesh ) 
  {
		ON_GL( material );
    //ON_GL(*mesh);
		// Render meshes manually to incorporate color.
		ON_GL_MESH(*mesh);
    return;
  }
  
  curve = ON_Curve::Cast(&geometry);
  if ( curve ) 
  {
		ON_GL( material );
    ON_GL( *curve, pTheGLNURBSRender );
    return;
  }
  
  surface = ON_Surface::Cast(&geometry);
  if ( surface ) 
  {
		ON_GL( material );
    gluBeginSurface( pTheGLNURBSRender );
    ON_GL( *surface, pTheGLNURBSRender );
    gluEndSurface( pTheGLNURBSRender );
    return;
  }
  
  point = ON_Point::Cast(&geometry);
  if ( point ) 
  {
		ON_GL( material );
    ON_GL(*point);
    return;
  }
  
  cloud = ON_PointCloud::Cast(&geometry);
  if ( cloud ) 
  {
		ON_GL( material );
    ON_GL(*cloud);
    return;
  }
  
}


void ON_Wrapper::ON_GL_MESH( const ON_Mesh& mesh )
{
  int i0, i1, i2, j0, j1, j2;
  int fi;
  ON_3fPoint v[4];
  ON_3fVector n[4];
  ON_2fPoint t[4];
	ON_Color c[4];
	
  const int face_count = mesh.FaceCount();
  const BOOL bHasNormals = mesh.HasVertexNormals();
  const BOOL bHasTCoords = mesh.HasTextureCoordinates();
	const BOOL bHasVertexColors = mesh.HasVertexColors();
	
	/*if( bHasVertexColors )
		printf("The mesh has colors...\n");
	else
		printf("The mesh doesn't have any colors...\n");*/
	
  glBegin(GL_TRIANGLES);
  for ( fi = 0; fi < face_count; fi++ ) {
    const ON_MeshFace& f = mesh.m_F[fi];
		
    v[0] = mesh.m_V[f.vi[0]];
    v[1] = mesh.m_V[f.vi[1]];
    v[2] = mesh.m_V[f.vi[2]];
		
		
    if ( bHasNormals ) {
      n[0] = mesh.m_N[f.vi[0]];
      n[1] = mesh.m_N[f.vi[1]];
      n[2] = mesh.m_N[f.vi[2]];
    }
		
    if ( bHasTCoords ) {
      t[0] = mesh.m_T[f.vi[0]];
      t[1] = mesh.m_T[f.vi[1]];
      t[2] = mesh.m_T[f.vi[2]];
    }
		
		if ( bHasVertexColors ){
			c[0] = mesh.m_C[f.vi[0]];
      c[1] = mesh.m_C[f.vi[1]];
      c[2] = mesh.m_C[f.vi[2]];
		}
		
    if ( f.IsQuad() ) {
      // quadrangle - render as two triangles
      v[3] = mesh.m_V[f.vi[3]];
      if ( bHasNormals )
        n[3] = mesh.m_N[f.vi[3]];
      if ( bHasTCoords )
        t[3] = mesh.m_T[f.vi[3]];
			if ( bHasVertexColors )
				c[3] = mesh.m_C[f.vi[3]];
      if ( v[0].DistanceTo(v[2]) <= v[1].DistanceTo(v[3]) ) {
        i0 = 0; i1 = 1; i2 = 2;
        j0 = 0; j1 = 2; j2 = 3;
      }
      else {
        i0 = 1; i1 = 2; i2 = 3;
        j0 = 1; j1 = 3; j2 = 0;
      }
    }
    else {
      // single triangle
      i0 = 0; i1 = 1; i2 = 2;
      j0 = j1 = j2 = 0;
    }
		
    // first triangle
    if ( bHasNormals )
      glNormal3f( n[i0].x, n[i0].y, n[i0].z );
    if ( bHasTCoords )
      glTexCoord2f( t[i0].x, t[i0].y );
		if ( bHasVertexColors )
			glColor3f( c[i0].Red()/255.0, c[i0].Green()/255.0, c[i0].Blue()/255.0 );
    glVertex3f( v[i0].x, v[i0].y, v[i0].z );
		
    if ( bHasNormals )
      glNormal3f( n[i1].x, n[i1].y, n[i1].z );
    if ( bHasTCoords )
      glTexCoord2f( t[i1].x, t[i1].y );
		if ( bHasVertexColors )
			glColor3f( c[i1].Red()/255.0, c[i1].Green()/255.0, c[i1].Blue()/255.0 );
    glVertex3f( v[i1].x, v[i1].y, v[i1].z );
		
    if ( bHasNormals )
      glNormal3f( n[i2].x, n[i2].y, n[i2].z );
    if ( bHasTCoords )
      glTexCoord2f( t[i2].x, t[i2].y );
		if ( bHasVertexColors )
			glColor3f( c[i2].Red()/255.0, c[i2].Green()/255.0, c[i2].Blue()/255.0 );
    glVertex3f( v[i2].x, v[i2].y, v[i2].z );
		
    if ( j0 != j1 ) {
      // if we have a quad, second triangle
      if ( bHasNormals )
        glNormal3f( n[j0].x, n[j0].y, n[j0].z );
      if ( bHasTCoords )
        glTexCoord2f( t[j0].x, t[j0].y );
			if ( bHasVertexColors )
				glColor3f( c[j0].Red()/255.0, c[j0].Green()/255.0, c[j0].Blue()/255.0 );
      glVertex3f( v[j0].x, v[j0].y, v[j0].z );
			
      if ( bHasNormals )
        glNormal3f( n[j1].x, n[j1].y, n[j1].z );
      if ( bHasTCoords )
        glTexCoord2f( t[j1].x, t[j1].y );
			if ( bHasVertexColors )
				glColor3f( c[j1].Red()/255.0, c[j1].Green()/255.0, c[j1].Blue()/255.0 );
      glVertex3f( v[j1].x, v[j1].y, v[j1].z );
			
      if ( bHasNormals )
        glNormal3f( n[j2].x, n[j2].y, n[j2].z );
      if ( bHasTCoords )
        glTexCoord2f( t[j2].x, t[j2].y );
			if ( bHasVertexColors )
				glColor3f( c[j2].Red()/255.0, c[j2].Green()/255.0, c[j2].Blue()/255.0 );
      glVertex3f( v[j2].x, v[j2].y, v[j2].z );
    }
		
  }
  glEnd();
}

/* The basic selection method. The call should really be routed to an Part object. */
void ON_Wrapper::selectObject(int objectIndex)
{
  ONX_Model_Object& mo = model->m_object_table[objectIndex];
  mo.m_attributes.m_material_index = 1;
}

void ON_Wrapper::cleanUp()
{
  gluDeleteNurbsRenderer( pTheGLNURBSRender );
  model->Destroy();
  ON::End();
}
