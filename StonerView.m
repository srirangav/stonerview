//
//  StonerView.m
//  http://eblong.com/zarf/stonerview.html
//
//  Copyright 1998-2011 by Andrew Plotkin, <erkyrath@eblong.com>.
//  Ported to Mac by Tommaso Pecorella, <t.pecorella@inwind.it>.
//	Modified by Alexander von Below, <alex@vonbelow.com>
//      Wed Jul 11 10:09:26 CEST 2007 (Changes are prefixed 'avb')
//	Further modified by Andrew Plotkin, Mar 24 2011
//  Updated for BigSur (MacOSX 11) by Sriranga Veeraraghavan
//      <ranga@calalum.org>, May 16, 2021
//

#import "StonerView.h"
#include <unistd.h>

#define kName		@"stonerview"
#define kCurrentVersionsFile @"http://eblong.com/zarf/ftp/MacSoftwareVersions.plist"

// avb: Re-defined kVersion to an actual call to retrieve the version
#define kVersion (NSString*)CFBundleGetValueForInfoDictionaryKey (\
CFBundleGetBundleWithIdentifier(CFSTR("com.eblong.screensaver.stonerview")),CFSTR("CFBundleVersion"))

// #define LOG_DEBUG

@implementation StonerView

- (id)initWithFrame:(NSRect)frameRect isPreview:(BOOL) preview
{
    NSString* version;

    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kName];

    if (![super initWithFrame:frameRect isPreview:preview]) return nil;
    
    // Do your subclass initialization here
    
#ifdef LOG_DEBUG
    NSLog( @"initWithFrame" );
#endif

    if (self) {
	NSOpenGLPixelFormatAttribute attribs[] =
        {	NSOpenGLPFAAccelerated,
//		NSOpenGLPFADepthSize, 16,
                NSOpenGLPFAColorSize, 16,
		NSOpenGLPFAMinimumPolicy,
		NSOpenGLPFAMaximumPolicy,
//		NSOpenGLPFAClosestPolicy,
                0
        };
	
	NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attribs] autorelease];
		
    /* enable OpenGL hi-res display support
     https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/CapturingScreenContents/CapturingScreenContents.html#//apple_ref/doc/uid/TP40012302-CH10-SW35
     */
        
    [self  setWantsBestResolutionOpenGLSurface: YES];
        
        _view = [[[NSOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:format] autorelease];
        
        [self addSubview:_view];
    }
    

	// avb: There is a way to set factory defaults
	// This will have to be tweaked when a new version wants to definitely change the users preferences
/*
 if( ![version isEqualToString:kVersion] || (version == NULL) ) {
	 // first time ever !! 
*/
	NSDictionary * applicationDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
			kVersion, @"version",
			kCFBooleanFalse, @"mainMonitorOnly",
			kCFBooleanFalse,@"wireframe",
			kCFBooleanFalse, @"edges",
			[NSNumber numberWithInt:0], @"shape",
			[NSNumber numberWithFloat:1.0], @"speed",
			[NSNumber numberWithFloat:0.75], @"alpha",
			nil];
	
	[defaults registerDefaults:applicationDefaults];
	[defaults synchronize];

	version   = [defaults stringForKey:@"version"];
    mainMonitorOnly = [defaults boolForKey:@"mainMonitorOnly"];
    wireframe = [defaults boolForKey:@"wireframe"];
    edges     = [defaults boolForKey:@"edges"];
    shape     = (int)[defaults integerForKey:@"shape"];
    speed     = [defaults floatForKey:@"speed"];
    alpha     = [defaults floatForKey:@"alpha"];
    
    return self;
}

- (void)animateOneFrame
{
    // Do your animation stuff here.
    // If you want to use drawRect: just add setNeedsDisplay:YES to this method
    
#ifdef LOG_DEBUG
    // NSLog( @"animateOneFrame" );
#endif

    if( thisScreenIsOn == FALSE ) {
        [self stopAnimation];
        return;
    }

    [[_view openGLContext] makeCurrentContext];
    
    if (!_initedGL) {
        setup_window();

        /*  support for high resolution displays
            https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/CapturingScreenContents/CapturingScreenContents.html#//apple_ref/doc/uid/TP40012302-CH10-SW35
         */
        NSRect backingBounds =
            [self convertRectToBacking:[self bounds]];
        GLsizei backingPixelWidth  = (GLsizei)(backingBounds.size.width);
        GLsizei backingPixelHeight = (GLsizei)(backingBounds.size.height);
        
        win_reshape(backingPixelWidth, backingPixelHeight);
        if( init_move() ) {
            params_update(wireframe, edges, shape);
            move_increment(elist);
            move_increment(elist);
            move_increment(elist);
            set_transparency(alpha);
        }
        _initedGL = YES;
    }

    move_increment(elist);
    win_draw(elist);
    
    return;
}

- (void)startAnimation
{
    NSOpenGLContext *context;
    int mainScreen;
    int thisScreen;

#ifdef LOG_DEBUG
    NSLog( @"startAnimation" );
#endif

    thisScreenIsOn = TRUE;
    if( mainMonitorOnly ) {
        thisScreen = [[[[[self window] screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
        mainScreen = [[[[NSScreen mainScreen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
        // NSLog( @"test this %d - main %d", thisScreen, mainScreen );
        if( thisScreen != mainScreen ) {
            thisScreenIsOn = FALSE;
        }
    }

    // Do your animation initialization here
    
    context = [_view openGLContext];
    [context makeCurrentContext];
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glFlush();

    default_speed = [self animationTimeInterval];
    [self setAnimationTimeInterval:default_speed/speed];
    [super startAnimation];
}

- (void)stopAnimation
{
    // Do your animation termination here
#ifdef LOG_DEBUG
    NSLog( @"stopAnimation" );
#endif

    [super stopAnimation];
}

- (BOOL) hasConfigureSheet
{
    // Return YES if your screensaver has a ConfigureSheet
    return YES;
}

- (void) dealloc {

#ifdef LOG_DEBUG
    NSLog( @"dealloc" );
#endif
    [_view removeFromSuperview];
    [super dealloc];
}

- (void)setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
    [_view setFrameSize:newSize];
    _initedGL = NO;

}

- (NSWindow*)configureSheet
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];

#ifdef LOG_DEBUG
    NSLog( @"configureSheet" );
#endif
    
    // If your screensaver has a ConfigureSheet, load it here
    // update to new version of loadNibName for 10.8+
    if( ! configureSheet ) {
            [thisBundle loadNibNamed: @"StonerView"
                               owner: self
                     topLevelObjects: nil];
    }
    
    [IBversionNumberField setStringValue:kVersion];
    [IBUpdatesInfo setStringValue:@""];

    [IBview setTitle:[thisBundle localizedStringForKey:@"View" value:@"" table:@""]];
    [IBwireframe setTitle:[thisBundle localizedStringForKey:@"Wireframe" value:@"" table:@""]];
    [IBwireframe setState:(wireframe ? NSOnState : NSOffState)];
    [IBedges setTitle:[thisBundle localizedStringForKey:@"Edges" value:@"" table:@""]];
    [IBedges setState:(edges ? NSOnState : NSOffState)];

    [IBshapeTxt setStringValue:
        [thisBundle localizedStringForKey:@"Shape" value:@"" table:@""]];
    [IBshape addItemWithTitle:
        [thisBundle localizedStringForKey:@"Random" value:@"" table:@""]];
    [IBshape addItemWithTitle:
        [thisBundle localizedStringForKey:@"Quads" value:@"" table:@""]];
    [IBshape addItemWithTitle:
        [thisBundle localizedStringForKey:@"Triangles" value:@"" table:@""]];
    [IBshape addItemWithTitle:
        [thisBundle localizedStringForKey:@"Hexagons" value:@"" table:@""]];
    [IBshape addItemWithTitle:
        [thisBundle localizedStringForKey:@"Discs" value:@"" table:@""]];
    [IBshape addItemWithTitle:
        [thisBundle localizedStringForKey:@"Spheres" value:@"" table:@""]];
    [IBshape addItemWithTitle:
        [thisBundle localizedStringForKey:@"Cubes" value:@"" table:@""]];
    [IBshape addItemWithTitle:
        [thisBundle localizedStringForKey:@"Cones" value:@"" table:@""]];
    [IBshape addItemWithTitle:
        [thisBundle localizedStringForKey:@"Toruses" value:@"" table:@""]];
    [IBshape selectItemAtIndex:shape];

    [IBspeedTxt setStringValue:
        [thisBundle localizedStringForKey:@"Speed" value:@"" table:@""]];
    [IBspeed setFloatValue:speed];
    [IBslow setStringValue:
        [thisBundle localizedStringForKey:@"slow" value:@"" table:@""]];
    [IBfast setStringValue:
        [thisBundle localizedStringForKey:@"fast" value:@"" table:@""]];

    [IBalphaTxt setStringValue:
        [thisBundle localizedStringForKey:@"Transp." value:@"" table:@""]];
    [IBalpha setFloatValue:alpha*10];

    [IBmainMonitorOnly setState:(mainMonitorOnly ? NSOnState : NSOffState)];
    [IBmainMonitorOnly setTitle:[thisBundle localizedStringForKey:@"Main monitor only" value:@"" table:@""]];
    [IBCheckVersion setTitle:[thisBundle localizedStringForKey:@"Check updates" value:@"" table:@""]];
    [IBCancel setTitle:[thisBundle localizedStringForKey:@"Cancel" value:@"" table:@""]];
    [IBSave setTitle:[thisBundle localizedStringForKey:@"Save" value:@"" table:@""]];

    return configureSheet;
}

- (IBAction) closeSheet_save:(id) sender {

    int thisScreen;
    int mainScreen;

    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kName];
    
#ifdef LOG_DEBUG
    NSLog( @"closeSheet_save" );
#endif

    mainMonitorOnly = ( [IBmainMonitorOnly state] == NSOnState ) ? true : false;

    wireframe	 = ( [IBwireframe state] == NSOnState ) ? true : false;
    edges	 = ( [IBedges state] == NSOnState ) ? true : false;
    shape        = (int)[IBshape indexOfSelectedItem];
    speed        = [IBspeed floatValue];
    alpha        = [IBalpha floatValue]/10.0;

    [defaults setBool: mainMonitorOnly forKey: @"mainMonitorOnly"];
    [defaults setBool:wireframe forKey:@"wireframe"];
    [defaults setBool:edges forKey:@"edges"];
    [defaults setInteger:shape forKey:@"shape"];
    [defaults setFloat:speed forKey:@"speed"];
    [defaults setFloat:alpha forKey:@"alpha"];
    [defaults synchronize];

#ifdef LOG_DEBUG
    NSLog(@"Canged params" );
#endif

    if( mainMonitorOnly ) {
        thisScreen = [[[[[self window] screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
        mainScreen = [[[[NSScreen mainScreen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
        // NSLog( @"test this %d - main %d", thisScreen, mainScreen );
        if( thisScreen != mainScreen ) {
            thisScreenIsOn = FALSE;
        }
    }
    if( (thisScreenIsOn == FALSE) && (mainMonitorOnly == FALSE) ) {
        thisScreenIsOn = TRUE;
        [self startAnimation];
    }
    
    params_update(wireframe, edges, shape);
    set_transparency(alpha);
    [self setAnimationTimeInterval:default_speed/speed];

    [NSApp endSheet:configureSheet];
}

- (IBAction) closeSheet_cancel:(id) sender {

#ifdef LOG_DEBUG
    NSLog( @"closeSheet_cancel" );
#endif
    
    [NSApp endSheet:configureSheet];
    
    params_update(wireframe, edges, shape);
    set_transparency(alpha);
    [self setAnimationTimeInterval:default_speed/speed];
}

- (IBAction)updateConfigureSheet:(id) sender
{
    BOOL wireframe_test, edges_test;
    int shape_test;
    float speed_test;
    float alpha_test;
    
#ifdef LOG_DEBUG
    NSLog( @"updateConfigureSheet" );
#endif
    
    wireframe_test = ( [IBwireframe state] == NSOnState ) ? true : false;
    edges_test	   = ( [IBedges state] == NSOnState ) ? true : false;
    shape_test     = (int)[IBshape indexOfSelectedItem];
    speed_test     = [IBspeed floatValue];
    alpha_test     = [IBalpha floatValue]/10.0;
    
    params_update(wireframe_test, edges_test, shape_test);
    set_transparency(alpha_test);    
    [self setAnimationTimeInterval:default_speed/speed_test];
}

- (IBAction) checkUpdates:(id)sender
{
    NSString *testVersionString;
    NSDictionary *theVersionDict;
    NSString *theVersion;
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];

    testVersionString = [NSString stringWithContentsOfURL:[NSURL URLWithString:kCurrentVersionsFile] encoding:kCFStringEncodingUTF8 error:nil];

    if( testVersionString == nil ) {
        // no connection with the server
        [IBUpdatesInfo setStringValue:
            [thisBundle localizedStringForKey:@"Couldn't download version information." value:@"" table:@""]];
    }
    else {
        theVersionDict = [testVersionString propertyList];
        theVersion = [theVersionDict objectForKey:kName];

        if ( ![theVersion isEqualToString:kVersion] ) {
            //hopefully our version numbers will never be going down...
            //also takes care of going from MyGreatApp? 7.5 to SuperMyGreatApp? Pro 1.0
            [IBUpdatesInfo setStringValue:
                [thisBundle localizedStringForKey:@"New version available!" value:@"" table:@""]];
        }
        else {
            [IBUpdatesInfo setStringValue:
                [thisBundle localizedStringForKey:@"You're up-to-date!" value:@"" table:@""]];
        }
    }
}


@end
