//
//  CrashController.m
//  CrashKit
//
//  Created by Oh seung yong on 13. 10. 18..
//  Copyright (c) 2013년 Lilac Studio. All rights reserved.
//
#ifdef DEBUG
#import "CrashController.h"
#include <signal.h>
#include <execinfo.h>

@interface CrashLogger : NSObject
{
	BOOL finishPump;
}

- (void)sendCrash:(NSDictionary*)crash;
- (void)pumpRunLoop;

@property BOOL finishPump;

@end

@implementation CrashLogger
@synthesize finishPump;

- (id)init
{
	if ((self = [super init]))
	{
		finishPump = NO;
	}
	
	return self;
}

- (void)sendCrash:(NSDictionary*)crash
{
	// Do nothing
}

- (void)pumpRunLoop
{
	self.finishPump = NO;
	
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef runLoopModesRef = CFRunLoopCopyAllModes(runLoop);
	NSArray * runLoopModes = (__bridge NSArray *)runLoopModesRef;
	
	while (self.finishPump == NO)
	{
		for (NSString *mode in runLoopModes)
		{
			CFStringRef modeRef = (__bridge CFStringRef)mode;
			CFRunLoopRunInMode(modeRef, 1.0f/120.0f, false);  // Pump the loop at 120 FPS
		}
	}
	
	CFRelease(runLoopModesRef);
}

@end

static CrashController *sharedInstance = nil;

@interface CrashController ()
{
	CrashLogger *logger;
	SEL _selector;
	id _target;
}

+ (CrashController*)sharedInstance;

- (NSArray*)callstackAsArray;
- (void)handleSignal:(NSDictionary*)userInfo;
- (void)handleNSException:(NSDictionary*)userInfo;
-(void)addTarget:(id)target sel:(SEL)selector;

@end

#pragma mark C Functions 
void sighandler(int signal);
void sighandler(int signal)
{
  const char* names[NSIG];
  names[SIGABRT] = "SIGABRT";
  names[SIGBUS] = "SIGBUS";
  names[SIGFPE] = "SIGFPE";
  names[SIGILL] = "SIGILL";
  names[SIGPIPE] = "SIGPIPE";
  names[SIGSEGV] = "SIGSEGV";
  
  CrashController *crash = [CrashController sharedInstance];
  NSArray *arr = [crash callstackAsArray];
  NSString *title = [NSString stringWithFormat:@"Crash: %@", [arr objectAtIndex:6]];  // The 6th frame is where the crash happens
  
  NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:arr, @"Callstack",
                                                                      title, @"Title",
                                                                      [NSNumber numberWithInt:signal], @"Signal",
                                                                      [NSString stringWithUTF8String:names[signal]], @"Signal Name",
                                                                      nil];
  [crash performSelectorOnMainThread:@selector(handleSignal:) withObject:userInfo waitUntilDone:YES];
}
void uncaughtExceptionHandler(NSException *exception);
void uncaughtExceptionHandler(NSException *exception)
{
	CrashController *crash = [CrashController sharedInstance];
	NSArray *arr = [crash callstackAsArray];
	NSString *title = [NSString stringWithFormat:@"Exception: %@", [arr objectAtIndex:8]];  // The 8th frame is where the exception is thrown
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 [exception callStackSymbols], @"callStackSymbols",
									 [exception name],@"CrashName",
									 title, @"Title",
									 [exception reason], @"Exception",
									 nil];
	[crash performSelectorOnMainThread:@selector(handleNSException:) withObject:userInfo waitUntilDone:YES];
}

@interface CrashController()
@property (nonatomic, retain) CrashLogger *logger;
@end

@implementation CrashController
@synthesize logger;

#pragma mark Singleton methods

-(void)onCrashWithInfo:(NSMutableDictionary*)crashInfo
{
    UINavigationController *mainCon;
   
    KCLAppMainNavigationController *navi = (id)[AllMenu delegate];
    mainCon = navi;
	
	//MainNavigationController *mainCon = [APP_DELEGATE mainController];
	printf("=========================================================\n");
	[crashInfo setObject:[NSString stringWithFormat:@"%@_%@_%@",[(ViewController*)mainCon.topViewController viewID],mainCon.visibleViewController,mainCon.viewControllers] forKey:@"A_CrashInfo"];
	NSLog(@"%@",crashInfo);
	UITextView *tv = [[UITextView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	tv.editable = NO;
	tv.text = crashInfo.jsonStringPrint;
	tv.font = FONTSIZE(8);
	[BlockAlertView didReceiveMemoryWarning];
	[BlockAlertView dismissAllAlertViews];
	
	BlockAlertView *alert =  [[BlockAlertView alloc] initWithTitle:@"다잉메세지"
															message:(id)tv
												  dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
													  alertView.tag = buttonIndex;
												  } cancelButtonTitle:nil
												  otherButtonTitles:@"종료",@"이미지저장",nil];
ShowAlert:
	alert.tag = NSNotFound;
	if([alert showOtherButton:YES])
	{
		while(alert.tag == NSNotFound)
		{
			[[NSRunLoop currentRunLoop] acceptInputForMode:NSDefaultRunLoopMode beforeDate:[[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode]];
		}
	}
	
	if(alert.tag == 1)
	{
		UIImage *image1 = [UIImage screenCapture];
		UIImage *image2 = [UIImage captureView:tv];
		CGRect rect = [UIScreen mainScreen].bounds;
		rect.size.width += CGRectGetWidth(rect);
		UIView *view = [[UIView alloc] initWithFrame:rect];
		rect = [UIScreen mainScreen].bounds;
		UIImageView *imageView1 = [[UIImageView alloc] initWithImage:image1];
		imageView1.frame = rect;
		[view addSubview:imageView1];
		
		rect.origin.x = CGRectGetMaxX(rect);
		UIImageView *imageView2 = [[UIImageView alloc] initWithImage:image2];
		imageView2.frame = rect;
		[view addSubview:imageView2];
		
		UIImage *captureImage = [UIImage captureView:view];
		
		if(captureImage)
		{
			UIImageWriteToSavedPhotosAlbum(captureImage, nil, nil, nil);
			alert =  [[BlockAlertView alloc] initWithTitle:nil
													message:@"저장완료"
										  dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
											  alertView.tag = buttonIndex;
										  } cancelButtonTitle:nil
										  otherButtonTitles:@"종료",nil];
			goto ShowAlert;
		}
	}
}

+(void)start
{
	CrashController *crash = [CrashController sharedInstance];
	[crash addTarget:crash sel:@selector(onCrashWithInfo:)];
}

+ (CrashController*)sharedInstance
{
  @synchronized(self)
  {
    if (sharedInstance == nil)
      sharedInstance = [[CrashController alloc] init];
  }
  
  return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
  @synchronized(self)
  {
    if (sharedInstance == nil)
    {
      sharedInstance = [super allocWithZone:zone];
      return sharedInstance;
    }
  }
  
  return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}


#pragma mark Lifetime methods

- (id)init
{
  if ((self = [super init]))
  {
    signal(SIGABRT, sighandler);
    signal(SIGBUS, sighandler);
    signal(SIGFPE, sighandler);
    signal(SIGILL, sighandler);
    signal(SIGPIPE, sighandler);    
    signal(SIGSEGV, sighandler);
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    logger = [[CrashLogger alloc] init];
  }
  
  return self;
}

- (void)dealloc
{
  signal(SIGABRT, SIG_DFL);
  signal(SIGBUS, SIG_DFL);
  signal(SIGFPE, SIG_DFL);
  signal(SIGILL, SIG_DFL);
  signal(SIGPIPE, SIG_DFL);
  signal(SIGSEGV, SIG_DFL);
  
  NSSetUncaughtExceptionHandler(NULL);
}

#pragma mark methods

- (NSArray*)callstackAsArray
{
	void* callstack[128];
	const int numFrames = backtrace(callstack, 128);
	char **symbols = backtrace_symbols(callstack, numFrames);
	
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:numFrames];
	for (int i = 0; i < numFrames; ++i)
	{
		[arr addObject:[NSString stringWithUTF8String:symbols[i]]];
	}
	
	free(symbols);
	
	return arr;
}

-(void)addTarget:(id)target sel:(SEL)selector
{
	_target = target;
	_selector = selector;
}

- (void)handleSignal:(NSDictionary*)userInfo
{  
	if([_target respondsToSelector:_selector])
	{
        [_target performSelectorOnMainThread:_selector withObject:userInfo waitUntilDone:YES];
	}
}

- (void)handleNSException:(NSDictionary*)userInfo
{
	if([_target respondsToSelector:_selector])
	{
        [_target performSelectorOnMainThread:_selector withObject:userInfo waitUntilDone:YES];
	}
}

@end
#endif
