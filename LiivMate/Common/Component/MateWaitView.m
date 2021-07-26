//
//  MateWaitView.m
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2018. 4. 17..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "MateWaitView.h"
#import "EtcUtil.h"

@implementation MateWaitView {
    UILabel *_lblWaitCnt;
//    UILabel *_lblWaitTime;  // 리브메이트3.0 유량제어(타임표시제거) - KB운영 요구사항 반영
    
    UIView *_underLine2;
    
    UILabel*_lblInfo;
    
//    UIImageView *_lineV;   // 리브메이트3.0 유량제어(타임표시제거) - KB운영 요구사항 반영
    UIButton * _btnInfo;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
		
       
        UIImage *image = [UIImage imageNamed:@"waitingIcon"];
		_imgSandglass = [[UIImageView alloc] initWithImage:image];
		[_imgSandglass setIsAccessibilityElement:YES];
		[_imgSandglass setAccessibilityLabel:@"접속대기중"];
		[_imgSandglass setAccessibilityTraits:(UIAccessibilityTraitNone)];
		[self addSubview:_imgSandglass];		
        
        // 대기자수
        _lblWaitCnt = [[UILabel alloc] initWithFrame:CGRectZero];
        [_lblWaitCnt setText:@"대기자 : 99999명"];
        [_lblWaitCnt setTextAlignment:NSTextAlignmentCenter]; // 리브메이트3.0 유량제어(타임표시제거) - KB운영 요구사항 반영 (NSTextAlignmentLeft -> NSTextAlignmentCenter)
        _lblWaitCnt.textColor = UIColorFromRGB(0x666666);
        _lblWaitCnt.font = FONTSIZE(14);
        [self addSubview:_lblWaitCnt];
		
        // 리브메이트3.0 유량제어(타임표시제거) - KB운영 요구사항 반영 start
//		_lineV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_divide_line.png"]];
//		[self addSubview:_lineV];
//        // 대기시간
//        _lblWaitTime = [[UILabel alloc] initWithFrame:CGRectZero];
//        [_lblWaitTime setText:@"예상대기시간 : 10000초"];
//        [_lblWaitTime setTextAlignment:NSTextAlignmentLeft];
//        _lblWaitTime.textColor = UIColorFromRGB(0x666666);
//        _lblWaitTime.font = FONTSIZE(14);
//        [self addSubview:_lblWaitTime];
        // 리브메이트3.0 유량제어(타임표시제거) - KB운영 요구사항 반영 end
        
        // 언더라인2
        _underLine2 = [[UIView alloc] initWithFrame:CGRectZero];
        _underLine2.backgroundColor = UIColorFromRGB(0xdddddd);
        [self addSubview:_underLine2];
        
        _lblInfo = [[UILabel alloc] initWithFrame:CGRectZero];
        [_lblInfo setText:@"현재 접속 사용자가 많아 대기 중이며,\n대기하시면 서비스로 자동 접속됩니다."];
        [_lblInfo setTextAlignment:NSTextAlignmentCenter];
        _lblInfo.textColor = UIColorFromRGB(0x000000);
        _lblInfo.font = FONTSIZE(16);
        _lblInfo.numberOfLines = 0;
        [self addSubview:_lblInfo];
        
		_btnInfo = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _btnInfo.userInteractionEnabled = NO;
		_btnInfo.accessibilityTraits = UIAccessibilityTraitStaticText;
        [_btnInfo setImage:[UIImage imageNamed:@"icon_addr_info.png"] forState:UIControlStateNormal];
        [_btnInfo setTitle:@"재 접속하시면 대기시간이 더 길어집니다." forState:UIControlStateNormal];
//        [_btnInfo setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
        [_btnInfo setTitleColor:UIColorFromRGB(0x888888) forState:UIControlStateNormal];
        [_btnInfo.titleLabel setFont:FONTSIZE(12)];
        [_btnInfo setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 6)];
        [self addSubview:_btnInfo];
    }
    
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    int fullWidth = CGRectGetWidth(self.bounds);
    // 모래시계이미지
	CGRect rect = CGRectMake((fullWidth/2) - (93/2), 75, 93, 93);
    _imgSandglass.frame = rect;
	
	// info
	rect = CGRectMake(0, CGRectGetMaxY(rect) + 20, fullWidth, 40);
	_lblInfo.frame = rect;
	
    // 대기자수
	rect.origin.y = CGRectGetMaxY(rect) + 30;
    rect.origin.x = 33;
    rect.size.width = fullWidth - (rect.origin.x *2);
    rect.size.height = 16;
    _lblWaitCnt.frame = rect;

    // 리브메이트3.0 유량제어(타임표시제거) - KB운영 요구사항 반영 start
//	//구분선
//	_lineV.center = CGPointMake(136, CGRectGetMidY(rect));

//    // 대기시간
//	rect.origin.x = CGRectGetMaxX(_lineV.frame) + 30;
//    rect.size.width = 200;
//    rect.size.height = 16;
//    _lblWaitTime.frame = rect;
    // 리브메이트3.0 유량제어(타임표시제거) - KB운영 요구사항 반영 end
    
    // 언더라인 2
    rect = CGRectMake(21, CGRectGetMaxY(rect) + 21, fullWidth-(21*2), 1);
    _underLine2.frame = rect;
    
    // point Info
    rect = CGRectMake(0, CGRectGetMaxY(rect), fullWidth, 44);
    _btnInfo.frame = rect;
	
}

- (void)reloadWaitData:(int)waitTime waitCnt:(int)waitCnt
{
    NSString *text = [NSString stringWithFormat:@"대기자 : %d명", waitCnt];
    NSDictionary * attriDic = @{NSFontAttributeName:FONTSIZE(14), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)};
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text attributes:attriDic];
    
    attString = [EtcUtil setAttributeWithColorString:attString subStr:[NSString stringWithFormat:@"%d",waitCnt] subColor:UIColorFromRGB(0x8d9cfd) subFont:FONTSIZE(14)];
    [_lblWaitCnt setAttributedText:attString];
    
    // 리브메이트3.0 유량제어(타임표시제거) - KB운영 요구사항 반영 start
//    NSString *text2 = [NSString stringWithFormat:@"예상대기시간 : %d초", waitTime];
//    NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] initWithString:text2 attributes:attriDic];
//
//    attString2 = [EtcUtil setAttributeWithColorString:attString2 subStr:[NSString stringWithFormat:@"%d",waitTime] subColor:UIColorFromRGB(0x8d9cfd) subFont:FONTSIZE(14)];
//    [_lblWaitTime setAttributedText:attString2];
    // 리브메이트3.0 유량제어(타임표시제거) - KB운영 요구사항 반영 end
}


@end
