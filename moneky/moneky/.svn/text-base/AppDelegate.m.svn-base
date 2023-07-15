//
//  AppDelegate.m
//  moneky
//
//  Created by Sood, Abhishek on 8/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameMenuLayer.h"
#import "RootViewController.h"
#import "MonkeyNotificationDefinitions.h"
#import "Appirater.h"
#import "SimpleAudioEngine.h"
#import "Flurry.h"

#define kFlurryTestID @"DP9954FKSVCFBTZ54DZB"
#define kFlurryProd @"YDXVBWZDVMB569WNYCQ5"

@implementation AppDelegate

@synthesize window=window_;
@synthesize viewController=viewController_;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if your Application only supports landscape mode
	//

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
}

void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#if 0
    [Flurry setDebugLogEnabled:YES];
    [Flurry setShowErrorInLogEnabled:YES];
     
#endif
#if DEBUG
    [Flurry startSession:kFlurryTestID];
#else
    [Flurry startSession:kFlurryProd];
#endif
    
	[Appirater setAppId:@"590050149"];
    [Appirater setShowCancelButton:YES];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setSignificantEventsUntilPrompt:5];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setUsesUntilPrompt:-1];
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [Appirater setVersion:[version floatValue]];
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController_ = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
	viewController_.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
		
	[director setAnimationInterval:1.0/100];
#if DEBUG
	[director setDisplayFPS:NO];
    [Appirater setDebug:YES];
#endif
//	[Appirater setShowCancelButton:NO];
	// make the OpenGLView a child of the view controller
	//[viewController_ setView:glView];
    [viewController_.view addSubview:glView];
    [viewController_.view sendSubviewToBack:glView];
	
	// make the View Controller a child of the main window
    [window_ setRootViewController:viewController_];
//	[window_ addSubview: viewController_.view];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	
	// PVR Textures have alpha premultiplied
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// Removes the startup flicker
	[self removeStartupFlicker];
    srand(time(NULL));
	
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [GameMenuLayer scene]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adRunning) name:MonkeyNotificationAdRunning object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adFinished) name:MonkeyNotificationAdFinished object:nil];
    [Appirater appLaunched:YES];
    if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled"))
        NSLog(@" **** WARNING **** NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
    [window_ makeKeyAndVisible];
}

-(void)adRunning{
	[[CCDirector sharedDirector] pause];    
}

-(void)adFinished{
	[[CCDirector sharedDirector] resume];    
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationLeavingApp object:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
    [Appirater appEnteredForeground:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController_ release];
	
	[window_ release];
	
	[director end];	
    NSError *error = nil;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // todo
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }

}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];

	[window_ release];
	[viewController_ release];
    
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
	[super dealloc];
}

#pragma mark -
#pragma mark Core Data
-(NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return _managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *storeUrl = [NSURL fileURLWithPath: [path stringByAppendingPathComponent: @"monkey.sqlite"]];
	
	NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		DLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return _persistentStoreCoordinator;
}

-(NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;

}


@end
