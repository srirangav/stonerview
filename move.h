/* StonerView: An eccentric visual toy.
   Copyright 1998-2001 by Andrew Plotkin (erkyrath@eblong.com)
   http://www.eblong.com/zarf/stonerview.html
   This program is distributed under the GPL.
   See main.c, the Copying document, or the above URL for details.
*/

typedef struct elem_struct {
  GLfloat pos[3];
  GLfloat vervec[2];
  GLfloat col[4];
  int shape;
} elem_t;

__private_extern__ void set_transparency(float theTransparency);
__private_extern__ int init_move(void);
__private_extern__ void move_increment(elem_t elist[]);
