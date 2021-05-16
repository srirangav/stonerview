/* StonerView: An eccentric visual toy.
   Copyright 1998-2001 by Andrew Plotkin (erkyrath@eblong.com)
   http://www.eblong.com/zarf/stonerview.html
   This program is distributed under the GPL.
   See main.c, the Copying document, or the above URL for details.
*/

#import "move.h"

__private_extern__ void setup_window(void);
__private_extern__ void setup_shapes(void);
__private_extern__ void win_draw(elem_t elist[]);
__private_extern__ void win_reshape(int width, int height);
__private_extern__ void params_update(int upd_wireframe, int upd_edges, int upd_shape);
