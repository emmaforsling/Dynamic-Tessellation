#ifndef TESSELLATIONSHADERMANAGER_H
#define TESSELLATIONSHADERMANAGER_H

GLuint LoadShaders(const char * vertex_file_path,
                   const char * tessellation_control_file_path,
                   const char * tessellation_evaluation_file_path,
                   const char * geometry_file_path,
                   const char * fragment_file_path );

#endif
