//
//  StonerView.h
//  http://eblong.com/zarf/stonerview.html
//
//  Copyright 1998-2011 by Andrew Plotkin, <erkyrath@eblong.com>.
//  Ported to Mac by Tommaso Pecorella, <t.pecorella@inwind.it>.
//	Modified by Alexander von Below, <alex@vonbelow.com> Wed Jul 11 2007
//	  (Changes are prefixed 'avb')
//	Further modified by Andrew Plotkin, Mar 24 2011
//

#import <AppKit/AppKit.h>
#import <ScreenSaver/ScreenSaver.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "move.h"
#import "view.h"
#import "osc.h"


@interface StonerView : ScreenSaverView {

    BOOL mainMonitorOnly;
    BOOL thisScreenIsOn;

    NSOpenGLView *_view;
    BOOL _initedGL;
    elem_t elist[NUM_ELS];
    float alpha;
    
    BOOL wireframe;
    BOOL edges;
    int shape;
    float speed;
    NSTimeInterval default_speed;
    
    IBOutlet id configureSheet;
    IBOutlet id IBversionNumberField;
    
    IBOutlet id IBview;
    IBOutlet id IBwireframe;
    IBOutlet id IBedges;

    IBOutlet id IBshapeTxt;
    IBOutlet id IBshape;

    IBOutlet id IBspeedTxt;
    IBOutlet id IBspeed;
    IBOutlet id IBslow;
    IBOutlet id IBfast;

    IBOutlet id IBalphaTxt;
    IBOutlet id IBalpha;

    IBOutlet id IBmainMonitorOnly;
    IBOutlet id IBCheckVersion;
    IBOutlet id IBCancel;
    IBOutlet id IBSave;
    IBOutlet id IBUpdatesInfo;
}

- (IBAction) closeSheet_save:(id) sender;
- (IBAction) closeSheet_cancel:(id) sender;
- (IBAction) updateConfigureSheet:(id) sender;
- (IBAction) checkUpdates:(id)sender;

@end
