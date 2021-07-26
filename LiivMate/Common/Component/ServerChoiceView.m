//
//  ServerChoiceView.m
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 26/07/2019.
//  Copyright © 2019 KBCard. All rights reserved.
//

#import "ServerChoiceView.h"

@interface ServerChoiceView()

@property (weak, nonatomic) IBOutlet UIButton * btnCheckNone;
@property (weak, nonatomic) IBOutlet UIButton * btnCheck2222;

@end

@implementation ServerChoiceView

+ (ServerChoiceView *)makeView
{
    ServerChoiceView *theView = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Component" owner:nil options:nil];
    for (id obj in objects)
    {
        if ([obj isKindOfClass:[ServerChoiceView class]])
        {
            theView = obj;
            break;
        }
    }
    
    theView.frame = CGRectMake(0, 0, 320, 220);
    return theView;
}

- (IBAction)selectCheck:(id)sender
{
    if (sender == _btnCheckNone) {
        [self setSelPort:NO];
    } else {
        [self setSelPort:YES];
    }
}

- (IBAction)pressDev:(id)sender
{
    [[BlockAlertView currentAlert] dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)pressStaging:(id)sender
{
    [[BlockAlertView currentAlert] dismissWithClickedButtonIndex:1 animated:YES];
}

- (BOOL)isExistPort
{
    return _btnCheck2222.selected;
}

- (void)setSelPort:(BOOL)isSel
{
    if (isSel) {
        _btnCheckNone.selected = NO;
        _btnCheck2222.selected = YES;
    } else {
        _btnCheckNone.selected = YES;
        _btnCheck2222.selected = NO;
    }
}

@end
