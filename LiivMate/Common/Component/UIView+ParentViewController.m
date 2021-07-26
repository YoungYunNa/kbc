//
//  UIView+ParentViewController.m
//  NewKBCardWallet
//
//

#import "UIView+ParentViewController.h"
#import <objc/runtime.h>

#define maskViewTag  10248
#if 0
//#ifdef DEBUG

@interface UIWindow (Cursor)
-(void)showCursor:(UIEvent*)event;
@end

@implementation UIWindow (Cursor)

static NSMutableDictionary *viewPool = nil;

-(void)showCursor:(UIEvent*)event
{
	NSSet *set = [event touchesForWindow:self];
	
	for(UITouch *t in set.allObjects)
	{
		CGPoint center = [t locationInView:self];
		NSString *keyStr = [NSString stringWithFormat:@"%d",(int)t];
		UIView *_cursor = [viewPool objectForKey:keyStr];
		switch (t.phase) {
			case UITouchPhaseBegan:
			{
				if(viewPool == nil)
				{
					viewPool = [[NSMutableDictionary alloc] init];
				}
				
				if(_cursor == nil)
				{
					_cursor = [[UIView alloc] initWithFrame:CGRectMake(center.x-5, center.y-5, 10, 10)];
					_cursor.userInteractionEnabled = NO;
					_cursor.backgroundColor = [UIColor clearColor];
					_cursor.layer.borderWidth = 2;
					_cursor.layer.cornerRadius = 5;
					_cursor.layer.borderColor = UIColorFromRGB(keyStr.intValue & 0xFFFFFF).CGColor;
					_cursor.alpha = 0;
					[self addSubview:_cursor];
					[viewPool setValue:_cursor forKey:keyStr];
					
					
					[UIView animateWithDuration:0.5 animations:^{
						_cursor.alpha = 0.4;
						_cursor.transform = CGAffineTransformMakeScale(2, 2);
					}];
				}
			}
				break;
			case UITouchPhaseMoved:
			case UITouchPhaseStationary:
			{
				_cursor.center = center;
			}
				break;
			default:
			{
				[viewPool removeObjectForKey:keyStr];
				if(_cursor)
				{
					_cursor.tag = 0;
					[UIView animateWithDuration:0.5 animations:^{
						_cursor.alpha = 0;
						if(t.tapCount != 0)
							_cursor.transform = CGAffineTransformMakeScale(2.5, 2.5);
						else
						{
							_cursor.transform = CGAffineTransformMakeScale(0.5, 0.5);
							_cursor.center = center;
						}
						
					} completion:^(BOOL finished) {
						[_cursor removeFromSuperview];
					}];
				}
				
				if(set.allObjects.count == 1)
				{
					for(NSString *key in viewPool.allKeys)
					{
						_cursor = [viewPool objectForKey:key];
						_cursor.tag = 0;
						[_cursor removeFromSuperview];
					}
					[viewPool removeAllObjects];
					viewPool = nil;
				}
			}
				break;
		}
	}
}

-(void)removeCurser:(UIView*)curser
{
	curser.tag = 0;
	[UIView animateWithDuration:0.5 animations:^{
		curser.alpha = 0;
		curser.transform = CGAffineTransformMakeScale(0.5, 0.5);
	} completion:^(BOOL finished) {
		[curser removeFromSuperview];
	}];
}

@end

@interface UIApplication (Cursor)
@end

@implementation UIApplication (Cursor)

+ (void)initialize
{
	
	[super initialize];
	Method m1 = class_getInstanceMethod(self, @selector(sendEvent:));
	Method m2 = class_getInstanceMethod(self, @selector(mk_sendEvent:));
	
	method_exchangeImplementations(m1, m2);
}

- (void)mk_sendEvent:(UIEvent *)event
{
	UITouch *touch = event.allTouches.anyObject;
	if([touch respondsToSelector:@selector(window)])
		[[(UITouch*)event.allTouches.anyObject window] showCursor:event];
	[self mk_sendEvent:event];
}

@end
#endif

#ifdef DEBUG
@interface LayoutGestureRecognizer : UILongPressGestureRecognizer

@end

@implementation LayoutGestureRecognizer

@end

@interface DEBUGView : UIView

@end

@implementation DEBUGView

@end

@interface UIView (DEBUG_UI)

@end

@implementation UIView (DEBUG_UI)

+(void)load
{
	[super load];
	
	Method m1 = class_getInstanceMethod(self, @selector(setFrame:));
	Method m2 = class_getInstanceMethod(self, @selector(mk_setFrame:));
	
	method_exchangeImplementations(m1, m2);
}

-(void)mk_setFrame:(CGRect)rect
{
	[self mk_setFrame:rect];

	if([self isKindOfClass:[UIWindow class]] || [self isKindOfClass:[DEBUGView class]]) return;
	
	for (id gesture in self.gestureRecognizers)
	{
		if([gesture isKindOfClass:[LayoutGestureRecognizer class]])
			return;
	}
	
	[self UI_DEBUG_SET];
}

-(void)UI_DEBUG_SET
{
	for (id gesture in self.gestureRecognizers)
	{
		if([gesture isKindOfClass:[LayoutGestureRecognizer class]])
			return;
	}
	
	LayoutGestureRecognizer *ges = [[LayoutGestureRecognizer alloc] initWithTarget:self action:@selector(RUN_UIDEBUG:)];
	ges.minimumPressDuration = 4;
	[self addGestureRecognizer:ges];
}

-(void)RUN_UIDEBUG:(UIGestureRecognizer *)ges
{
	if(ges.state == UIGestureRecognizerStateBegan)
	{
		UIView *markView = self.parentViewController.view;
		NSString *viewNm = NSStringFromClass(self.parentViewController.class);
		if(viewNm)
		{
			UIView *view = [[UIView alloc] initWithFrame:markView.bounds];
			view.layer.borderWidth = 2;
			view.layer.borderColor = [UIColor redColor].CGColor;
			[markView addSubview:view];
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 20)];
			label.font = [UIFont systemFontOfSize:15];
			label.textAlignment = NSTextAlignmentCenter;
			label.layer.borderWidth = 0.5;
			label.layer.cornerRadius = 5;
			label.clipsToBounds = YES;
			label.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
			label.text = viewNm;
			[label sizeToFit];
			[view addSubview:label];
			
			[view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:5];
		}
	}
}


@end

#endif

@implementation UIView (ParentViewController)

- (UIViewController*)parentViewController
{
    UIResponder *responder = self;
    while (![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return (UIViewController *)responder;
}

-(void)removeMaskView
{
	UIView *maskView = [self viewWithTag:maskViewTag];
	if(maskView)
	{
		maskView.tag = 0;
		[UIView animateWithDuration:0.2 animations:^{
			maskView.alpha = 0;
		} completion:^(BOOL finished) {
			UIActivityIndicatorView * indicator = (id)[maskView viewWithTag:maskViewTag-1];
			[indicator stopAnimating];
			[maskView removeFromSuperview];
		}];
	}
}

-(void)showMaskView:(BOOL)autoRemove
{
    UIView *maskView = [self viewWithTag:maskViewTag];
	if(maskView)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:maskView selector:@selector(removeFromSuperview) object:nil];
    }
    else
    {
        maskView = [[UIView alloc] initWithFrame:self.bounds];
        maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.15];
		NSArray *images = [UIImage splashLoadingImages];
		UIImageView * indicator = [[UIImageView alloc] initWithFrame:
								   CGRectMake(CGRectGetMidX(maskView.bounds)-25,
											  CGRectGetMidY(maskView.bounds)-25, 50, 50)];
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
		indicator.image = images.lastObject;
		indicator.animationImages = images;
		indicator.animationDuration = 1;
        indicator.tag = maskViewTag - 1;
        [maskView addSubview:indicator];
        [indicator startAnimating];
        maskView.tag = maskViewTag;
        [self addSubview:maskView];
    }
    
    if (autoRemove) {
        [maskView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:60];
    }
}

-(BOOL)isShowMaskView
{
    return [self viewWithTag:maskViewTag] != nil;
}

-(void)selectView
{
    
}

-(void)deSelectView
{
    
}

-(CGRect)superRectWithView:(UIView*)view visibleRect:(BOOL)visibleRect
{
    CGRect rect = view.bounds;
    do {
        
        if (nil == view) {
            break;
        }

        if([view.superview isKindOfClass:[UIScrollView class]] && visibleRect)
        {
            UIScrollView *scrollView = (id)view.superview;
            rect.origin.x -= scrollView.contentOffset.x;
            rect.origin.y -= scrollView.contentOffset.y;
        }

        CGRect rect2 = view.frame;
        rect.origin.y += rect2.origin.y;
        rect.origin.x += rect2.origin.x;
        
    } while ((view = view.superview) != self);
    
    return rect;
}

-(CGRect)getVisibleRect
{
    CGRect rect = self.frame;
    if(self.superview != self.window)
    {
        if([self.superview isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scrollView = (id)self.superview;
            rect.origin.x -= scrollView.contentOffset.x;
            rect.origin.y -= scrollView.contentOffset.y;
        }
        
        CGRect rect2 = [self.superview getVisibleRect];
        rect.origin.y += rect2.origin.y;
        rect.origin.x += rect2.origin.x;
    }
    
    return rect;
}

-(NSArray*)searchView:(NSString*)className depth:(NSInteger)depth
{
	NSMutableArray *array = [NSMutableArray array];
	for(UIView *view in self.subviews)
	{
		if([view isKindOfClass:NSClassFromString(className)])
			[array addObject:view];
	}
	
	if(depth > 0)
	{
		for(UIView *view in self.subviews)
		{
			if([view isKindOfClass:NSClassFromString(className)] == NO)
				[array addObjectsFromArray:[view searchView:className depth:depth-1]];
		}
	}
	return array;
}

-(void)unLoadView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for(UIView *view in self.subviews)
    {
        if([view isKindOfClass:[UIControl class]] == NO)
            [view unLoadView];
    }
}

@end
