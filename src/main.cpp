// Include standard headers
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

// OpenGL includes
#include <GL/glew.h>
#include <GLFW/glfw3.h>

// GLM includes
#include <glm/glm.hpp>
using namespace glm;

// AntTweakBar includes
#include <AntTweakBar.h>

// Source includes
#include "../extern/OpenGL_Graphics_Engine/include/Scene.h"

// Include Tesselation ShaderManager
#include "../include/TessellationShaderManager.h"

// Functions
bool initOpenGL(void);
bool initScene(void);
void initAntTweakBar(void);
void updateTweakBar(void);

// Controls
void magicTwMouseButtonWrapper(GLFWwindow *, int, int, int);
void magicTwMouseHoverWrapper(GLFWwindow *, double, double);
void myFunction(void *clientData);


// Variables
GLFWwindow* window;
Scene* scene;
TwBar* tweakbar;


//
Mesh* tessellatedMesh;

// AntTweakBar variables
float tessScale;


// Constants
#define WIDTH 1024
#define HEIGHT 768

int main(void)
{
	if(!initOpenGL())
	{
		return -1;
	}

	printf("Supported GLSL version is %s.\n", (char *)glGetString(GL_SHADING_LANGUAGE_VERSION));
	
	// Initialize the scene
	initScene();

	// Initialize the AntTweakBar window 
	initAntTweakBar();

	// Render the window
	do
	{
		// Clear the screen and depth buffer
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		updateTweakBar();

		scene->render(window);

		// Render the AntTweakBar (after the meshes)
		TwDraw();

		// Swap buffers
		glfwSwapBuffers(window);
		glfwPollEvents();
	} // Check if the ESC key was pressed or the window was closed
	while( glfwGetKey(window, GLFW_KEY_ESCAPE ) != GLFW_PRESS &&
		   glfwWindowShouldClose(window) == 0 );

	// Remove AntTweakBar
    TwTerminate();

	// Close OpenGL window and terminate GLFW
	glfwTerminate();

	return 0;
}

bool initOpenGL(void)
{
	// Initialise GLFW
	if(!glfwInit())
	{
		fprintf( stderr, "Failed to initialize GLFW\n" );
		getchar();
		return false;
	}

	glfwWindowHint(GLFW_SAMPLES, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // To make MacOS happy; should not be needed
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

	// Open a window and create its OpenGL context
	window = glfwCreateWindow( 1024, 768, "Dynamic Tessellation", NULL, NULL);
	if( window == NULL )
	{
		fprintf( stderr, "Failed to open GLFW window. If you have an Intel GPU, they are not 3.3 compatible. Try the 2.1 version of the tutorials.\n" );
		getchar();
		glfwTerminate();
		return false;
	}
	glfwMakeContextCurrent(window);

	// Ensure we can capture the escape key being pressed below
	glfwSetInputMode(window, GLFW_STICKY_KEYS, GL_TRUE);

	// Initialize GLEW
	glewExperimental = true; // Needed for core profile
	if(glewInit() != GLEW_OK)
	{
		fprintf(stderr, "Failed to initialize GLEW\n");
		getchar();
		glfwTerminate();
		return false;
	}
	return true;
}

bool initScene(void)
{
	// Initialize scene
	scene = new Scene();

	// Create and add a mesh to the scene
	tessellatedMesh = new Mesh();
	tessellatedMesh->initShaders("shaders/vertexshader.glsl", "shaders/fragmentshader.glsl");
	
    tessellatedMesh->setProgramID(LoadShaders( "shaders/tessellation/vertexshader.glsl",
                                         "shaders/tessellation/tessellationcontrolshader.glsl",
                                         "shaders/tessellation/tessellationevaluationshader.glsl",
                                         "shaders/tessellation/geometryshader.glsl",
                                         "shaders/tessellation/fragmentshader.glsl" ));
    
    tessellatedMesh->setIsTessellationActive(true);
	tessellatedMesh->initOBJ("extern/OpenGL_Graphics_Engine/assets/sphere.obj");
	tessellatedMesh->setDispMap("assets/textures/dispMap.png");
	tessellatedMesh->setNormMap("assets/textures/normMap.png");
	tessellatedMesh->setColorMap("assets/textures/bunny_tex.png");
	tessellatedMesh->setMaterialProperties(0.5, 0.5, 40.0);	// diffuse and specular coeff, specular power
	tessellatedMesh->setPosition(-1.5, 0.0, 0.0);
	tessellatedMesh->addFloatUniform("tessScale", 1.0);
	scene->addMesh(tessellatedMesh);

	// Create and add a mesh to the scene
	Mesh* notTessellatedMesh = new Mesh();
	notTessellatedMesh->initShaders("shaders/vertexshader.glsl", "shaders/fragmentshader.glsl");
	notTessellatedMesh->initOBJ("assets/sphere.obj");
	notTessellatedMesh->setDispMap("assets/textures/dispMap.png");
	notTessellatedMesh->setNormMap("assets/textures/normMap.png");
	notTessellatedMesh->setColorMap("assets/textures/bunny_tex.png");
	notTessellatedMesh->setMaterialProperties(0.50, 0.50, 40.0);	// diffuse and specular coeff, specular power
	notTessellatedMesh->setPosition(2.0, 0.0, 0.0);
	scene->addMesh(notTessellatedMesh);

	// Mesh* cameraMesh = new Mesh();
	// cameraMesh->initCube(0.25);
	// cameraMesh->setTexture("assets/textures/bunny_tex.png");
	// cameraMesh->setMaterialProperties(0.50, 0.50, 40.0);	// diffuse and specular coeff, specular power
	// cameraMesh->setPosition(0.0, 0.0, 2.0);
	// scene->addMesh(cameraMesh);
}

/****************************** <AntTweakBar> *********************************/

float testVariable = 10.0f;
/**
 *   Initialize the AntTweakBar window and add its variables
**/
void initAntTweakBar(void)
{

	// Get the values for the tesselated mesh
	tessScale = tessellatedMesh->getTessellationScale(); 	   

    // Scale the font, since AntTweakBar doesn't like retina displays
    TwDefine(" GLOBAL fontscaling=2 ");

    // Initialize AntTweakBar
    TwInit(TW_OPENGL_CORE, NULL);       // for core profile

    // Set the size of the graphic window
    TwWindowSize(WIDTH * 1.96, HEIGHT * 1.96);			// for mac retina 13
    // TwWindowSize(WIDTH * 1.99, HEIGHT * 1.99);			// for mac retina 15

    // // Create a new tweak bar (by calling TWNewBar) and set its size
    tweakbar = TwNewBar("Properties");
    TwDefine("Properties size='400 700'");

    /**
    * Add variables to the tweak bar
    **/
    TwAddVarRW( tweakbar,           		// my tweak bar
            	"Tesselation Scale",        // name of my variable
            	TW_TYPE_FLOAT,      		// tweak bar type
            	&tessScale,       			// my variable
           		"min=0 max=2 step=0.05 help=':D'" 
           		);

    TwAddVarRW( tweakbar,           		// my tweak bar
            	"Martin",        			// name of my variable
            	TW_TYPE_FLOAT,      		// tweak bar type
            	&testVariable,       		// my variable
           		" group='Stockholm' label='Martin' min=0 max=2 step=0.05 help='man' "
           		);

    TwAddButton( tweakbar, 
    			 "comment1",
    			 &myFunction,
    			 NULL,
    			 " label='Life is like a box a chocolates' "
    			 ); 
	
	glfwSetMouseButtonCallback(window, magicTwMouseButtonWrapper);
    glfwSetCursorPosCallback(window, magicTwMouseHoverWrapper);

}

void myFunction(void *clientData)
{
	std::cout << "Hej på mig igen " << std::endl;	
}

void magicTwMouseButtonWrapper(GLFWwindow* window, int button, int action, int mods)
{
 	TwEventMouseButtonGLFW(button, action);
}

void magicTwMouseHoverWrapper(GLFWwindow * window, double x, double y)
{
    TwEventMousePosGLFW(x * 2, y * 2);
}

void updateTweakBar(void){
	tessellatedMesh->setTessellationScale(tessScale);
}

/****************************** </AntTweakBar> *********************************/
