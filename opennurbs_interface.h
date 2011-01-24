/*
 *  opennurbs_interface.h
 *  opennurbstesting
 *
 *  Created by Allan William Martin on 6/17/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


class ONX_Model;
class ON_NurbsSurface;
class ON_Object;
class ON_Material;
class ON_Mesh;

class ON_Wrapper {
public:
  ON_Wrapper();
  
  void dumpModel();
  void load( const char* );
  void addSurface();
  void save( const char* );
  
  void randomizeFirstSurface();
  
  ONX_Model* model;
  //ON_Material generic;
  //ON_Material selected;
  
  void drawModel();
  void refreshModel();
  
  void render_nurbs_gl();
  BOOL myInitGL();
  
  void displayModeFill();
  void displayModeOutline();
  
  void buildExampleMaterial();
  
  void build();
  void myBuildDisplayList( GLuint );
  void myDisplayObject( const ON_Object&, const ON_Material& );
  
  void cleanUp();
  
  void selectObject(int);
	
	void ON_GL_MESH( const ON_Mesh& mesh );
};
