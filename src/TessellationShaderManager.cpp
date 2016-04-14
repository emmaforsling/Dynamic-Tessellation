#include <stdio.h>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>
#include <algorithm>
using namespace std;

#include <stdlib.h>
#include <string.h>

#include <GL/glew.h>

#include "../include/TessellationShaderManager.h"

/**
 * Function LoadShaders(...) - Tessellation shaders
 **/
GLuint LoadShaders(const char * vertex_file_path,
                   const char * Tessellation_control_file_path,
                   const char * Tessellation_evaluation_file_path,
                   const char * geometry_file_path,
                   const char * fragment_file_path )
{
    // Create the shaders
    GLuint VertexShaderID = glCreateShader(GL_VERTEX_SHADER);
    GLuint TessellationControlID     = glCreateShader(GL_TESS_CONTROL_SHADER);
    GLuint TessellationEvaluationID  = glCreateShader(GL_TESS_EVALUATION_SHADER);
    GLuint GeometryShaderID         = glCreateShader(GL_GEOMETRY_SHADER);
    GLuint FragmentShaderID         = glCreateShader(GL_FRAGMENT_SHADER);
    
    /************************** READ THE SHADERS  ****************************/
    // 1. Read the Vertex Shader code from the file
    std::string VertexShaderCode;
    std::ifstream VertexShaderStream(vertex_file_path, std::ios::in);
    if(VertexShaderStream.is_open()){
        std::string Line = "";
        while(getline(VertexShaderStream, Line))
            VertexShaderCode += "\n" + Line;
        VertexShaderStream.close();
    }else{
        printf("Impossible to open %s. Are you in the right directory ? Don't forget to read the FAQ !\n", vertex_file_path);
        getchar();
        return 0;
    }
    
    // 2. Read the Tessellation Control Shader code from the file
    std::string TessellationControlShaderCode;
    std::ifstream TessellationControlShaderStream(Tessellation_control_file_path, std::ios::in);
    if(TessellationControlShaderStream.is_open()){
        std::string Line = "";
        while(getline(TessellationControlShaderStream, Line))
            TessellationControlShaderCode += "\n" + Line;
        TessellationControlShaderStream.close();
    }
    
    // 3. Read the Tessellation Evaluation Shader code from the file
    std::string TessellationEvaluationShaderCode;
    std::ifstream TessellationEvaluationShaderStream(Tessellation_evaluation_file_path, std::ios::in);
    if(TessellationEvaluationShaderStream.is_open()){
        std::string Line = "";
        while(getline(TessellationEvaluationShaderStream, Line))
            TessellationEvaluationShaderCode += "\n" + Line;
        TessellationEvaluationShaderStream.close();
    }
    
    // 4. Read the Geometry Shader code from the file
    std::string GeometryShaderCode;
    std::ifstream GeometryShaderStream(geometry_file_path, std::ios::in);
    if(GeometryShaderStream.is_open()){
        std::string Line = "";
        while(getline(GeometryShaderStream, Line))
            GeometryShaderCode += "\n" + Line;
        GeometryShaderStream.close();
    }
    
    // 5. Read the Fragment Shader code from the file
    std::string FragmentShaderCode;
    std::ifstream FragmentShaderStream(fragment_file_path, std::ios::in);
    if(FragmentShaderStream.is_open()){
        std::string Line = "";
        while(getline(FragmentShaderStream, Line))
            FragmentShaderCode += "\n" + Line;
        FragmentShaderStream.close();
    }
    
    /************************** COMPILE THE SHADERS  ****************************/
    GLint Result = GL_FALSE;
    int InfoLogLength;
    
    // 1. Compile Vertex Shader
    printf("Compiling shader : %s\n", vertex_file_path);
    char const * VertexSourcePointer = VertexShaderCode.c_str();
    glShaderSource(VertexShaderID, 1, &VertexSourcePointer , NULL);
    glCompileShader(VertexShaderID);
    
    // 1. Check Vertex Shader
    glGetShaderiv(VertexShaderID, GL_COMPILE_STATUS, &Result);
    glGetShaderiv(VertexShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
    if ( InfoLogLength > 0 ){
        std::vector<char> VertexShaderErrorMessage(InfoLogLength+1);
        glGetShaderInfoLog(VertexShaderID, InfoLogLength, NULL, &VertexShaderErrorMessage[0]);
        printf("%s\n", &VertexShaderErrorMessage[0]);
    }
    
    // 2. Compile Tessellation Control Shader
    printf("Compiling shader : %s\n", Tessellation_control_file_path);
    char const * TessellationControlSourcePointer = TessellationControlShaderCode.c_str();
    glShaderSource(TessellationControlID, 1, &TessellationControlSourcePointer , NULL);
    glCompileShader(TessellationControlID);
    
    // 2. Check Tessellation Control Shader
    glGetShaderiv(TessellationControlID, GL_COMPILE_STATUS, &Result);
    glGetShaderiv(TessellationControlID, GL_INFO_LOG_LENGTH, &InfoLogLength);
    if ( InfoLogLength > 0 ){
        std::vector<char> TessellationControlShaderErrorMessage(InfoLogLength+1);
        glGetShaderInfoLog(TessellationControlID, InfoLogLength, NULL, &TessellationControlShaderErrorMessage[0]);
        printf("%s\n", &TessellationControlShaderErrorMessage[0]);
    }
    
    // 3. Compile Tessellation Evaluation Shader
    printf("Compiling shader : %s\n", Tessellation_evaluation_file_path);
    char const * TessellationEvaluationSourcePointer = TessellationEvaluationShaderCode.c_str();
    glShaderSource(TessellationEvaluationID, 1, &TessellationEvaluationSourcePointer , NULL);
    glCompileShader(TessellationEvaluationID);
    
    // 3. Check Tessellation Evaluation Shader
    glGetShaderiv(TessellationEvaluationID, GL_COMPILE_STATUS, &Result);
    glGetShaderiv(TessellationEvaluationID, GL_INFO_LOG_LENGTH, &InfoLogLength);
    if ( InfoLogLength > 0 ){
        std::vector<char> TessellationEvaluationShaderErrorMessage(InfoLogLength+1);
        glGetShaderInfoLog(TessellationEvaluationID, InfoLogLength, NULL, &TessellationEvaluationShaderErrorMessage[0]);
        printf("%s\n", &TessellationEvaluationShaderErrorMessage[0]);
    }
    
    // 4. Compile Geometry Shader
    printf("Compiling shader : %s\n", geometry_file_path);
    char const * GeometrySourcePointer = GeometryShaderCode.c_str();
    glShaderSource(GeometryShaderID, 1, &GeometrySourcePointer , NULL);
    glCompileShader(GeometryShaderID);
    
    // 4. Check Geometry Shader
    glGetShaderiv(GeometryShaderID, GL_COMPILE_STATUS, &Result);
    glGetShaderiv(GeometryShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
    if ( InfoLogLength > 0 ){
        std::vector<char> GeometryShaderErrorMessage(InfoLogLength+1);
        glGetShaderInfoLog(GeometryShaderID, InfoLogLength, NULL, &GeometryShaderErrorMessage[0]);
        printf("%s\n", &GeometryShaderErrorMessage[0]);
    }
    
    // 5. Compile Fragment Shader
    printf("Compiling shader : %s\n", fragment_file_path);
    char const * FragmentSourcePointer = FragmentShaderCode.c_str();
    glShaderSource(FragmentShaderID, 1, &FragmentSourcePointer , NULL);
    glCompileShader(FragmentShaderID);
    
    // 5. Check Fragment Shader
    glGetShaderiv(FragmentShaderID, GL_COMPILE_STATUS, &Result);
    glGetShaderiv(FragmentShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
    if ( InfoLogLength > 0 ){
        std::vector<char> FragmentShaderErrorMessage(InfoLogLength+1);
        glGetShaderInfoLog(FragmentShaderID, InfoLogLength, NULL, &FragmentShaderErrorMessage[0]);
        printf("%s\n", &FragmentShaderErrorMessage[0]);
    }
    
    /************************** LINK THE SHADERS TO THE PROGRAM  ****************************/
    // Link the program
    printf("Linking program\n");
    GLuint ProgramID = glCreateProgram();
    glAttachShader(ProgramID, VertexShaderID);          // 1. Vertex Shader
    glAttachShader(ProgramID, TessellationControlID);   // 2. Tessellation Control Shader
    glAttachShader(ProgramID, TessellationEvaluationID);// 3. Tessellation Evaluation Shader
    glAttachShader(ProgramID, GeometryShaderID);        // 4. Geometry Shader
    glAttachShader(ProgramID, FragmentShaderID);        // 5. Fragment Shader
    glLinkProgram(ProgramID);
    
    /************************** CHECK THE PROGRAM  ****************************/
    // Check the program
    glGetProgramiv(ProgramID, GL_LINK_STATUS, &Result);
    glGetProgramiv(ProgramID, GL_INFO_LOG_LENGTH, &InfoLogLength);
    if ( InfoLogLength > 0 ){
        std::vector<char> ProgramErrorMessage(InfoLogLength+1);
        glGetProgramInfoLog(ProgramID, InfoLogLength, NULL, &ProgramErrorMessage[0]);
        printf("%s\n", &ProgramErrorMessage[0]);
    }
    
    /************************** DELETE THE SHADERS ****************************/
    glDeleteShader(VertexShaderID);
    glDeleteShader(TessellationControlID);
    glDeleteShader(TessellationEvaluationID);
    glDeleteShader(GeometryShaderID);
    glDeleteShader(FragmentShaderID);
    
    return ProgramID;
}