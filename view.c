/* StonerView: An eccentric visual toy.
   Copyright 1998-2001 by Andrew Plotkin (erkyrath@eblong.com)
   http://www.eblong.com/zarf/stonerview.html
   This program is distributed under the GPL.
   See main.c, the Copying document, or the above URL for details.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

#include "general.h"
#include "osc.h"
#include "view.h"

static GLfloat view_rotx = -45.0, view_roty = 0.0, view_rotz = 15.0;
static GLfloat view_scale = 4.0;

// static Display *dpy;
// static Window window;
static int wireframe = FALSE;
static int addedges = FALSE;
static int shape = 0;
static GLuint theShapesFull[NUM_SHAPES+1];
static GLuint theShapesWire[NUM_SHAPES+1];

#define random_sh	0
#define quads		1
#define triangles	2
#define hexagons	3
#define discs		4
#define spheres		5
#define cubes		6
#define cones		7
#define torus		8

__private_extern__ void setup_window()
{
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);

    glEnable(GL_NORMALIZE);

    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glEnable(GL_LINE_SMOOTH);
    glEnable(GL_BLEND);
    // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);    
    glBlendFunc(GL_SRC_ALPHA,GL_ONE);	// Set The Blending Function For Translucency
    setup_shapes();
}

__private_extern__ void setup_shapes()
{
    int i;
    
    for ( i=1; i<=NUM_SHAPES; ++i ) {
        if( glIsList( theShapesWire[i] ) )
            glDeleteLists( theShapesWire[i], 1 );
        theShapesWire[i] = glGenLists(1);
        if( glIsList( theShapesFull[i] ) )
            glDeleteLists( theShapesFull[i], 1 );
        theShapesFull[i] = glGenLists(1);
    }

    /* quads */
    glNewList( theShapesWire[quads], GL_COMPILE );
    glBegin(GL_LINE_LOOP);
    glVertex3f( -0.11,  -0.00, 0.0);
    glVertex3f( +0.00,  -0.11, 0.0);
    glVertex3f( +0.11,  +0.00, 0.0);
    glVertex3f( -0.00,  +0.11, 0.0);
    glEnd();
    glEndList();

    glNewList( theShapesFull[quads], GL_COMPILE );
    glBegin(GL_QUADS);
    glVertex3f( -0.11,  -0.00, 0.0);
    glVertex3f( +0.00,  -0.11, 0.0);
    glVertex3f( +0.11,  +0.00, 0.0);
    glVertex3f( -0.00,  +0.11, 0.0);
    glEnd();
    glEndList();

    /* triangles */
#define tri_up 0.11
#define tri_lo 0.055
#define tri_la 0.095
    glNewList( theShapesWire[triangles], GL_COMPILE );
    glBegin(GL_LINE_LOOP);
    glVertex3f( 0.0     ,  + tri_up, 0.0);
    glVertex3f( - tri_la,  - tri_lo, 0.0);
    glVertex3f( + tri_la,  - tri_lo, 0.0);
    glEnd();
    glEndList();

    glNewList( theShapesFull[triangles], GL_COMPILE );
    glBegin(GL_TRIANGLES);
    glVertex3f( 0.0     ,  + tri_up, 0.0);
    glVertex3f( - tri_la,  - tri_lo, 0.0);
    glVertex3f( + tri_la,  - tri_lo, 0.0);
    glEnd();
    glEndList();

    /* hexagons */
#define hex_up   0.06350852961086
#define hex_l2   0.055
#define hex_la   0.11
    glNewList( theShapesWire[hexagons], GL_COMPILE );
    glBegin(GL_LINE_LOOP);
    glVertex3f( - hex_l2,  + hex_up, 0.0);
    glVertex3f( - hex_la,  0.0     , 0.0);
    glVertex3f( - hex_l2,  - hex_up, 0.0);
    glVertex3f( + hex_l2,  - hex_up, 0.0);
    glVertex3f( + hex_la,  0.0     , 0.0);
    glVertex3f( + hex_l2,  + hex_up, 0.0);
    glEnd();
    glEndList();

    glNewList( theShapesFull[hexagons], GL_COMPILE );
    glBegin(GL_POLYGON);
    glVertex3f( - hex_l2,  + hex_up, 0.0);
    glVertex3f( - hex_la,  0.0     , 0.0);
    glVertex3f( - hex_l2,  - hex_up, 0.0);
    glVertex3f( + hex_l2,  - hex_up, 0.0);
    glVertex3f( + hex_la,  0.0     , 0.0);
    glVertex3f( + hex_l2,  + hex_up, 0.0);
    glEnd();
    glEndList();

    /* discs */
#define vertex   30
    glNewList( theShapesWire[discs], GL_COMPILE );
    glBegin(GL_LINE_LOOP);
    for( i=0; i<vertex; i++ )
        glVertex3f( 0.09*(cos((2*M_PI*i)/vertex)),  0.09*(sin((2*M_PI*i)/vertex)), 0.0 );
    glEnd();
    glEndList();

    glNewList( theShapesFull[discs], GL_COMPILE );
    glBegin(GL_TRIANGLE_FAN);
    glVertex3f( 0.0,  0.0, 0.0 );
    for( i=0; i<vertex; i++ )
        glVertex3f( 0.09*(cos((2*M_PI*i)/vertex)),  0.09*(sin((2*M_PI*i)/vertex)), 0.0 );
    glVertex3f( 0.09*(cos(0)),  0.09*(sin(0)), 0.0 );
    glEnd();
    glEndList();

    /* spheres */
    glNewList( theShapesWire[spheres], GL_COMPILE );
    glutWireSphere(0.11, 10, 10);
    glEndList();

    glNewList( theShapesFull[spheres], GL_COMPILE );
    glutSolidSphere(0.11, 10, 10);
    glEndList();

    /* cubes */
    glNewList( theShapesWire[cubes], GL_COMPILE );
    glutWireCube(0.11);
    glEndList();

    glNewList( theShapesFull[cubes], GL_COMPILE );
    glutSolidCube(0.11);
    glEndList();

    /* cones */
    glNewList( theShapesWire[cones], GL_COMPILE );
    glutWireCone(0.11, 0.11, 10, 10);
    glEndList();

    glNewList( theShapesFull[cones], GL_COMPILE );
    glutSolidCone(0.11, 0.11, 10, 10);
    glEndList();

    /* torus */
    glNewList( theShapesWire[torus], GL_COMPILE );
    glutWireTorus(0.055, 0.11, 10, 10);
    glEndList();

    glNewList( theShapesFull[torus], GL_COMPILE );
    glutSolidTorus(0.055, 0.11, 10, 10);
    glEndList();
}

/* callback: draw everything */
__private_extern__ void win_draw(elem_t elist[])
{
    int ix;
    int display_shape;

    static GLfloat white[] = { 1.0, 1.0, 1.0, 1.0 };
    static GLfloat grey[] =  { 0.6, 0.6, 0.6, 1.0 };

    glDrawBuffer(GL_BACK);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glPushMatrix();
    glScalef(view_scale, view_scale, view_scale);
    glRotatef(view_rotx, 1.0, 0.0, 0.0);
    glRotatef(view_roty, 0.0, 1.0, 0.0);
    glRotatef(view_rotz, 0.0, 0.0, 1.0);

    glShadeModel(GL_FLAT);
    
    for (ix=0; ix<NUM_ELS; ix++) {
        elem_t *el = &elist[ix];
        
        display_shape = (shape == 0) ? el->shape+1 : shape;

        glNormal3f(0.0, 0.0, 1.0);
	glTranslatef(el->pos[0], el->pos[1], el->pos[2]);

        if (addedges || wireframe) {

            glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, (wireframe ? white : grey));
            glCallList(theShapesWire[display_shape]);
        }

        if (!wireframe) {

            glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, el->col);
            // glMaterialfv(GL_FRONT, GL_EMISSION, el->col);
            glCallList(theShapesFull[display_shape]);
            
        }
        
	glTranslatef(-el->pos[0], -el->pos[1], -el->pos[2]);
    }

    glPopMatrix();

    glFinish();
    glFlush();
    // glXSwapBuffers(dpy, window);
}

/* callback: new window size or exposure */
__private_extern__ void win_reshape(int width, int height)
{
    GLfloat h = (GLfloat) height / (GLfloat) width;

    glViewport(0, 0, (GLint) width, (GLint) height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-1.0, 1.0, -h, h, 5.0, 60.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0.0, 0.0, -40.0);
}

__private_extern__ void params_update(int upd_wireframe, int upd_edges, int upd_shape)
{
    wireframe = upd_wireframe;
    addedges = upd_edges;

    if( upd_shape == random_sh || upd_shape > NUM_SHAPES )
        shape = 0;
    else
        shape = upd_shape;
}

