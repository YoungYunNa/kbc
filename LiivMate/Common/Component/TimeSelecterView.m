//
//  TimeSelecterView.m
//  ios_user
//
//  Created by HD7650 on 2018. 5. 18..
//  Copyright © 2018년 Dongbu NTS. All rights reserved.
//

#import "TimeSelecterView.h"
void processInMainThread(dispatch_block_t block)
{
    if ([NSThread isMainThread]) block();
    else dispatch_async(dispatch_get_main_queue(), block);
}


void delayProcessInMainThread(NSTimeInterval interval, dispatch_block_t block)
{
    // ver.1
    /*
    {
        if (interval > 0)
        {
            dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 0.05 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(timer, block);
            dispatch_resume(timer);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
    */
    
    // ver.2
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
    }
}

@interface DCCDatePicker () <UIPickerViewDelegate, UIPickerViewDataSource> {
}

@property (strong , nonatomic) NSMutableArray<NSDate *> * days;
@property (strong , nonatomic) NSMutableArray<NSDate *> * hours;
@property (strong , nonatomic) NSMutableArray<NSDate *> * minutes;

@property (strong , nonatomic) UIPickerView * daysPicker;
@property (strong , nonatomic) UIPickerView * hoursPicker;
@property (strong , nonatomic) UIPickerView * minutesPicker;
@property (strong , nonatomic) UIView * daysDividerTop;
@property (strong , nonatomic) UIView * daysDividerBottom;
@property (strong , nonatomic) UIView * hoursDividerTop;
@property (strong , nonatomic) UIView * hoursDividerBottom;
@property (strong , nonatomic) UIView * minutesDividerTop;
@property (strong , nonatomic) UIView * minutesDividerBottom;

@property (strong , nonatomic) NSDate * currentDate;

@property (assign , nonatomic) long minutesTotal;

@property (assign , nonatomic) long dayWidth;
@property (assign , nonatomic) long hourWidth;
@property (assign , nonatomic) long minuteWidth;

@end

@implementation DCCDatePicker

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)updateWithForReturn:(BOOL)forReturn {
    self.forReturn = forReturn;
//    if(forReturn) {
//        NSString *min = [DelcarSettings shared].serviceGroup.getMinTimeHHmm;
//        NSString *max = [DelcarSettings shared].serviceGroup.getMaxTimeHHmm;
//        NSString *endDay = [Utility timeStringFromDate:self.date format:@"yyyyMMdd"];
//        NSString *endHHmn = [Utility timeStringFromDate:self.date format:@"HHmm"];
//
//        if([[DelcarSettings shared].serviceGroup.svcGrpClsfCd isEqualToString:@"SGC03"]) {
//            if(min.integerValue != @"0000".integerValue || max.integerValue != @"2400".integerValue)
//            {
//                //서비스이 안된 시간이면
//                if(min.integerValue > endHHmn.integerValue)
//                {
//                    endHHmn = min;
//                    self.date = [Utility dateFromString:[NSString stringWithFormat:@"%@ %@:%@", endDay, [min substringToIndex:2], [min substringFromIndex:2]] format:nil];
//                }
//                //서비스 시간을 지났으며 다음 날로
//                if(max.integerValue < endHHmn.integerValue)
//                {
//                    self.date = [self.date dateByAddingTimeInterval:(24 * 60 * 60)];
//                }
//            }
//        }
//    }
    [self update];
}

- (void)update {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if(self.visibleRows == 0)
        self.visibleRows = 5;
    
    CGSize size = self.frame.size;
    
    if(!self.daysDividerTop) {
        self.backgroundColor = UIColor.clearColor;
        self.clipsToBounds = YES;
        [self setNeedsDisplay];
        [self layoutIfNeeded];
        
        float height = 1;
        float gap = 8;
        float top = size.height / self.visibleRows * 2 - height;
        float bottom = size.height / self.visibleRows * 3;
        float w1 = gap; //size.width / 4 * 2 - gap;
        float w2 = size.width / 4 * 1 - gap;
        float w3 = w2;
//        float x1 = 7;
        float x1 = 7;
        float x2 = x1 + w1 + 4.75;
        float x3 = x2 + w2 + 4.75;
        
        //피커 별 넓이 설정
        self.dayWidth = 0; //w1;
        self.hourWidth = w2;
        self.minuteWidth = w3;
//        if(!self.daysPicker) {
//            self.daysPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(x1, 0, self.dayWidth, size.height)];
//            self.daysPicker.backgroundColor = UIColor.clearColor;
//            self.daysPicker.showsSelectionIndicator = false;
//            self.daysPicker.delegate = self;
//            [self addSubview:self.daysPicker];
//        }
        if(!self.hoursPicker) {
            self.hoursPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(x2, 0, self.hourWidth, size.height)];
            self.hoursPicker.backgroundColor = UIColor.clearColor;
            self.hoursPicker.showsSelectionIndicator = false;
            self.hoursPicker.delegate = self;
            [self addSubview:self.hoursPicker];
        }
        if(!self.minutesPicker) {
            self.minutesPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(x3, 0, self.minuteWidth, size.height)];
            self.minutesPicker.backgroundColor = UIColor.clearColor;
            self.minutesPicker.showsSelectionIndicator = false;
            self.minutesPicker.delegate = self;
            [self addSubview:self.minutesPicker];
        }
        
//        self.daysDividerTop = [[UIView alloc] initWithFrame:CGRectMake(x1, top, self.dayWidth, height)];
//        [self addSubview:self.daysDividerTop];
//        self.daysDividerBottom = [[UIView alloc] initWithFrame:CGRectMake(x1, bottom, self.dayWidth, height)];
//        [self addSubview:self.daysDividerBottom];

        self.hoursDividerTop = [[UIView alloc] initWithFrame:CGRectMake(x2, top, self.hourWidth, height)];
        [self addSubview:self.hoursDividerTop];
        self.hoursDividerBottom = [[UIView alloc] initWithFrame:CGRectMake(x2, bottom, self.hourWidth, height)];
        [self addSubview:self.hoursDividerBottom];

        self.minutesDividerTop = [[UIView alloc] initWithFrame:CGRectMake(x3, top, self.minuteWidth, height)];
        [self addSubview:self.minutesDividerTop];
        self.minutesDividerBottom = [[UIView alloc] initWithFrame:CGRectMake(x3, bottom, self.minuteWidth, height)];
        [self addSubview:self.minutesDividerBottom];
    }
    
    UIColor *color;
    if (!self.forReturn) {
        color = COLOR_BLACK; //UIColorRGB(0x2CC1CC);
    } else {
        //color = UIColorRGB(0xFD4825);
        color = COLOR_WHITE; //UIColorRGB(0x2CC1CC);
    }
    
    self.daysDividerTop.backgroundColor
    = self.daysDividerBottom.backgroundColor
    = self.hoursDividerTop.backgroundColor
    = self.hoursDividerBottom.backgroundColor
    = self.minutesDividerTop.backgroundColor
    = self.minutesDividerBottom.backgroundColor
    = color;
    
    self.days = [[NSMutableArray alloc] init];
    self.hours = [[NSMutableArray alloc] init];
    self.minutes = [[NSMutableArray alloc] init];
    
    // 시간 배열 생성
    
    {
        NSDate *sDate = [self.baseDate dateByAddingTimeInterval:self.minDateIntervalMinutes * 60];
        NSDate *eDate = [self.baseDate dateByAddingTimeInterval:self.maxDateIntervalMinutes * 60];
        
        long interval = (eDate.timeIntervalSince1970 - sDate.timeIntervalSince1970);
        long minCnt = interval / 600;// + 1;
        
        NSDate *minute = nil;
        
        for(long i = 0; i <= minCnt ; i++) {
            long intervalTmp = [sDate dateByAddingTimeInterval:i * 600].timeIntervalSince1970;
            NSDate *day = [[NSDate alloc] initWithTimeIntervalSince1970:intervalTmp];
            [formatter setDateFormat:@"yyyyMMdd"];
            NSString *strData = [formatter stringFromDate:day];
            day = [formatter dateFromString:strData];
            
            NSDate *hour = [[NSDate alloc] initWithTimeIntervalSince1970:intervalTmp - (intervalTmp % (60 * 60))];
            minute = [[NSDate alloc] initWithTimeIntervalSince1970:intervalTmp];
            
//            if(!self.forReturn || !self.useOutboundury)
//            {
//                [formatter setDateFormat:@"HHmm"];
//                NSString *HHmm = [formatter stringFromDate:minute];
//                if(self.minPossibleTime != @"0000".integerValue || self.maxPossibleTime != @"2400".integerValue)
//                {
//                    if(self.maxPossibleTime != @"2400".integerValue) {
//                        if(self.minPossibleTime < self.maxPossibleTime){
//                            if(self.minPossibleTime <= HHmm.integerValue && self.maxPossibleTime >= HHmm.integerValue) {
//                                if(self.hours.lastObject == nil || self.hours.lastObject.timeIntervalSince1970 < hour.timeIntervalSince1970) {
//                                    if(self.days.lastObject == nil || self.days.lastObject.timeIntervalSince1970 < day.timeIntervalSince1970) {
//                                        [self.days addObject:day];
//                                    }
//                                    [self.hours addObject:minute];
//                                }
//                                [self.minutes addObject:minute];
//                            }
//                        } else if(self.minPossibleTime > self.maxPossibleTime){
//                            if(self.minPossibleTime >= HHmm.integerValue || self.maxPossibleTime <= HHmm.integerValue) {
//                                if(self.hours.lastObject == nil || self.hours.lastObject.timeIntervalSince1970 < hour.timeIntervalSince1970) {
//                                    if(self.days.lastObject == nil || self.days.lastObject.timeIntervalSince1970 < day.timeIntervalSince1970) {
//                                        [self.days addObject:day];
//                                    }
//                                    [self.hours addObject:minute];
//                                }
//                                [self.minutes addObject:minute];
//                            }
//                        }
//                    } else if(self.maxPossibleTime == @"2400".integerValue) {
//                        if(0 == HHmm.integerValue) {
//                            if(self.days.lastObject == nil || self.days.lastObject.timeIntervalSince1970 < day.timeIntervalSince1970) {
//                                [self.days addObject:day];
//                            }
//                            [self.hours addObject:minute];
//                            [self.minutes addObject:minute];
//                        } else if(self.minPossibleTime <= HHmm.integerValue){
//                            if(self.hours.lastObject == nil || self.hours.lastObject.timeIntervalSince1970 < hour.timeIntervalSince1970) {
//                                if(self.days.lastObject == nil || self.days.lastObject.timeIntervalSince1970 < day.timeIntervalSince1970) {
//                                    [self.days addObject:day];
//                                }
//                                [self.hours addObject:minute];
//                            }
//                            [self.minutes addObject:minute];
//                        }
//                    }
//                } else {
//                    if(self.hours.lastObject == nil || self.hours.lastObject.timeIntervalSince1970 < hour.timeIntervalSince1970)
//                    {
//                        if(self.days.lastObject == nil || self.days.lastObject.timeIntervalSince1970 < day.timeIntervalSince1970)
//                        {
//                            [self.days addObject:day];
//                        }
//                        [self.hours addObject:minute];
//                    }
//                    [self.minutes addObject:minute];
//                }
//            } else {
                if(self.hours.lastObject == nil || self.hours.lastObject.timeIntervalSince1970 < hour.timeIntervalSince1970) {
                    if(self.days.lastObject == nil || self.days.lastObject.timeIntervalSince1970 < day.timeIntervalSince1970) {
                        [self.days addObject:day];
                    }
                    [self.hours addObject:minute];
                }
                [self.minutes addObject:minute];
//            }
        }
    }
    
    [self reloadAllComponents];
    
//    for(UIView *view in self.daysPicker.subviews) {
//        if(view.frame.size.height < 2)
//            view.hidden = YES;
//        view.backgroundColor = UIColor.clearColor;
//        for(UIView *view2 in view.subviews) {
//            view2.backgroundColor = UIColor.clearColor;
//        }
//    }
    for(UIView *view in self.hoursPicker.subviews) {
        if(view.frame.size.height < 2)
            view.hidden = YES;
        view.backgroundColor = UIColor.clearColor;
        for(UIView *view2 in view.subviews) {
            view2.backgroundColor = UIColor.clearColor;
        }
    }
    for(UIView *view in self.minutesPicker.subviews) {
        if(view.frame.size.height < 2)
            view.hidden = YES;
        view.backgroundColor = UIColor.clearColor;
        for(UIView *view2 in view.subviews) {
            view2.backgroundColor = UIColor.clearColor;
        }
    }
    
    if(self.date) {
        NSLog(@"%@",self.date);
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSInteger dd = [formatter stringFromDate:self.date].integerValue / 1000000;
        for (int i = 0 ; i < self.days.count ; i++) {
            NSInteger t = [formatter stringFromDate:self.days[i]].integerValue / 1000000;
            if(t == dd) {
                [self.daysPicker selectRow:i inComponent:0 animated:NO];
                break;
            }
        }
        NSInteger hh = [formatter stringFromDate:self.date].integerValue / 10000;
        for (int i = 0 ; i < self.hours.count ; i++) {
            NSInteger t = [formatter stringFromDate:self.hours[i]].integerValue / 10000;
            if(t == hh) {
                [self.hoursPicker selectRow:i inComponent:0 animated:NO];
                break;
            }
        }
        NSInteger mm = [formatter stringFromDate:self.date].integerValue / 100;
        for (int i = 0 ; i < self.minutes.count ; i++) {
            NSInteger t = [formatter stringFromDate:self.minutes[i]].integerValue / 100;
            if(t == mm) {
                [self.minutesPicker selectRow:i inComponent:0 animated:NO];
                break;
            }
        }
    }
    
    [self performSelector:@selector(validate) withObject:nil afterDelay:0.1];
}


- (void)reloadAllComponents {
    if(self.daysPicker) [self.daysPicker reloadAllComponents];
    if(self.hoursPicker) [self.hoursPicker reloadAllComponents];
    if(self.minutesPicker) [self.minutesPicker reloadAllComponents];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView == self.daysPicker){
        return self.days.count;
    }
    if(pickerView == self.hoursPicker){
        return self.hours.count;
    }
    if(pickerView == self.minutesPicker){
        return self.minutes.count;
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return self.frame.size.height / self.visibleRows;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(view == nil) {
        CGFloat width = 0;
        CGFloat height = self.frame.size.height / self.visibleRows;
        if(pickerView == self.daysPicker){
            width = self.dayWidth;
        }
        if(pickerView == self.hoursPicker){
            width = self.hourWidth;
        }
        if(pickerView == self.minutesPicker){
            width = self.minuteWidth;
        }
        view = [[UIView alloc] init];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [label setFont:[UIFont systemFontOfSize:19.0]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [view addSubview:label];
    }
    if(label == nil) {
        label = label.subviews[0];
    }
    if(pickerView == self.daysPicker){
        self.hoursPicker.userInteractionEnabled = YES;
        self.minutesPicker.userInteractionEnabled = YES;
        [formatter setDateFormat:@"M월 d일 (EEE)"];
        label.text = [formatter stringFromDate:self.days[row]];
    }
    if(pickerView == self.hoursPicker){
        self.daysPicker.userInteractionEnabled = YES;
        self.minutesPicker.userInteractionEnabled = YES;
        [formatter setDateFormat:@"HH"];
        label.text = [formatter stringFromDate:self.hours[row]];
    }
    if(pickerView == self.minutesPicker){
        self.daysPicker.userInteractionEnabled = YES;
        self.hoursPicker.userInteractionEnabled = YES;
        [formatter setDateFormat:@"mm"];
        label.text = [formatter stringFromDate:self.minutes[row]];
    }
    [self performSelector:@selector(releaseView) withObject:nil afterDelay:0.1];
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.daysPicker.userInteractionEnabled = YES;
    self.hoursPicker.userInteractionEnabled = YES;
    self.minutesPicker.userInteractionEnabled = YES;
    
    NSDate *sDate = [self.baseDate dateByAddingTimeInterval:self.minDateIntervalMinutes * 60];
    NSDate *eDate = [sDate dateByAddingTimeInterval:self.maxDateIntervalMinutes * 60];
    
    NSDate *tmpDD = nil;
    NSDate *tmpDH = nil;
    NSDate *tmpDM = nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSMutableString *td = [[NSMutableString alloc] init];
    
    if(pickerView == self.daysPicker) {
        tmpDD = self.days[row];
        tmpDH = self.hours[[self.hoursPicker selectedRowInComponent:0]];
        tmpDM = self.minutes[[self.minutesPicker selectedRowInComponent:0]];
        
        [formatter setDateFormat:@"yyyyMMdd"];
        [td appendString:[formatter stringFromDate:tmpDD]];
        [formatter setDateFormat:@"HH"];
        [td appendString:[formatter stringFromDate:tmpDH]];
        [formatter setDateFormat:@"mmss"];
        [td appendString:[formatter stringFromDate:tmpDM]];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSDate *d = [formatter dateFromString:td];
        NSInteger di = d.timeIntervalSince1970;
        NSInteger ds = sDate.timeIntervalSince1970;
        NSInteger de = eDate.timeIntervalSince1970;
        if(ds > di) {
            di = ds;
        } else if(de < di) {
            di = de;
        }
        NSDate * dd = [[NSDate alloc] initWithTimeIntervalSince1970:di];
        [formatter setDateFormat:@"yyyyMMddHH"];
        NSInteger dh2 = [formatter stringFromDate:dd].integerValue;
        NSInteger hoursIndex = 0;
        BOOL sethours = NO;
        for (int i = 0 ; i < self.hours.count ; i++) {
            NSInteger dh1 = [formatter stringFromDate:self.hours[i]].integerValue;
            if(dh1 == dh2) {
                hoursIndex = i;
                [self.hoursPicker selectRow:i inComponent:0 animated:NO];
                sethours = YES;
                continue;
            }
        }
        if(!sethours) {
            hoursIndex = self.hours.count - 1;
            [self.hoursPicker selectRow:hoursIndex inComponent:0 animated:NO];
        }
        
        BOOL setminutes = NO;
        for (int i = 0 ; i < self.minutes.count ; i++) {
            NSDate *mDate = self.minutes[i];
            if(mDate.timeIntervalSince1970 == dd.timeIntervalSince1970) {
                [self.minutesPicker selectRow:i inComponent:0 animated:NO];
                setminutes = YES;
                continue;
            }
        }
        if(!setminutes) {
            [self.minutesPicker selectRow:self.minutes.count - 1 inComponent:0 animated:NO];
        }
    }
    if(pickerView == self.hoursPicker) {
        tmpDD = self.days[[self.daysPicker selectedRowInComponent:0]];
        tmpDH = self.hours[row];
        tmpDM = self.minutes[[self.minutesPicker selectedRowInComponent:0]];
        
        [formatter setDateFormat:@"yyyyMMddHH"];
        [td appendString:[formatter stringFromDate:tmpDH]];
        [formatter setDateFormat:@"mmss"];
        [td appendString:[formatter stringFromDate:tmpDM]];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSInteger di = [formatter dateFromString:td].timeIntervalSince1970;
        NSInteger ds = sDate.timeIntervalSince1970;
        NSInteger de = eDate.timeIntervalSince1970;
        if(ds > di) {
            di = ds;
        } else if(de < di) {
            di = de;
        }
        NSDate * dd = [[NSDate alloc] initWithTimeIntervalSince1970:di];
        
        [formatter setDateFormat:@"yyyyMMdd"];
        NSInteger dd2 = [formatter stringFromDate:dd].integerValue;
        for (int i = 0 ; i < self.days.count ; i++) {
            NSInteger dd1 = [formatter stringFromDate:self.days[i]].integerValue;
            if(dd1 == dd2) {
                [self.daysPicker selectRow:i inComponent:0 animated:NO];
                continue;
            }
        }
        
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSInteger dm2 = [formatter stringFromDate:dd].integerValue;
        BOOL set = NO;
        for (int i = 0 ; i < self.minutes.count ; i++) {
            NSDate *tm = self.minutes[i];
            NSInteger dm1 = [formatter stringFromDate:tm].integerValue;
            if(dm1 == dm2) {
                [self.minutesPicker selectRow:i inComponent:0 animated:NO];
                set = YES;
                continue;
            }
        }
        if(!set) {
            dm2 = tmpDH.timeIntervalSince1970;
            for (int i = 0 ; i < self.minutes.count ; i++) {
                NSInteger dm1 = self.minutes[i].timeIntervalSince1970;
                if(dm1 == dm2) {
                    [self.minutesPicker selectRow:i inComponent:0 animated:NO];
                    continue;
                }
            }
        }
    }
    if(pickerView == self.minutesPicker) {
        tmpDM = self.minutes[row];
        
        NSInteger di = tmpDM.timeIntervalSince1970;
        NSInteger ds = sDate.timeIntervalSince1970;
        NSInteger de = eDate.timeIntervalSince1970;
        if(ds > di) {
            di = ds;
        } else if(de < di) {
            di = de;
        }
        NSDate * dd = [[NSDate alloc] initWithTimeIntervalSince1970:di];
        
        [formatter setDateFormat:@"yyyyMMdd"];
        NSInteger dd2 = [formatter stringFromDate:dd].integerValue;
        for (int i = 0 ; i < self.days.count ; i++) {
            NSInteger dd1 = [formatter stringFromDate:self.days[i]].integerValue;
            if(dd1 == dd2) {
                [self.daysPicker selectRow:i inComponent:0 animated:NO];
                continue;
            }
        }
        
        [formatter setDateFormat:@"yyyyMMddHH"];
        NSInteger dh2 = [formatter stringFromDate:dd].integerValue;
        for (int i = 0 ; i < self.hours.count ; i++) {
            NSInteger dh1 = [formatter stringFromDate:self.hours[i]].integerValue;
            if(dh1 == dh2) {
                [self.hoursPicker selectRow:i inComponent:0 animated:NO];
                continue;
            }
        }
    }
    [self performSelector:@selector(validate) withObject:nil afterDelay:0.1];
    
}

- (void) releaseView {
    self.daysPicker.userInteractionEnabled = YES;
    self.hoursPicker.userInteractionEnabled = YES;
    self.minutesPicker.userInteractionEnabled = YES;
}

- (void) validate {
    [self releaseView];
    if(self.blockValidateHandler) {
//        if(self.blockValidateHandler) self.blockValidateHandler(bValide, message);
    }
}

@end

@implementation TimeSelecterView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self dataBinding];
    
    delayProcessInMainThread(0.05, ^{
        [self openAnimation];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initUI {
    [self.datePickerButton setEnabled:YES];
    [self.datePickerButton setSelected:NO];
    self.BackgroundView.alpha = 0;
    self.datePickerBottom.constant = -430;
}

static ValidateHandler validateHandler;

- (void)dataBinding {
    
    validateHandler = ^(BOOL isValidate,NSString *description){
        __block BOOL validate = isValidate;
        __block NSString *desc = description;
        self.icon.hidden = (desc == nil || desc.length == 0);
        
        
        self.Descryption.text = desc;
        self.Descryption.text = desc;
        self.icon.hidden = (desc == nil || desc.length == 0);
        
        
        if(validate)
        {
            
            
            self.Descryption.text = desc;
            self.icon.hidden = (desc == nil || desc.length == 0);

            [self.datePickerButton setEnabled:YES];
            [self.datePickerButton setSelected:YES];
        }
        else
        {
            [self.datePickerButton setEnabled:NO];
            [self.datePickerButton setSelected:NO];
        }
    };
    _datePicker.blockValidateHandler = validateHandler;
}

- (void)openAnimation {
    [UIView animateWithDuration:.3
                     animations:^{
                         self.BackgroundView.alpha = 0.2;
                         self.datePickerBottom.constant = 0;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished)
     {
         if(finished) {
         }
     }];
}

- (void)closeAnimationWithCompletion:(void (^)(void))completion {
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3
                     animations:^{
                         self.BackgroundView.alpha = 0;
                         self.datePickerBottom.constant = -430;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished)
     {
         if(finished && completion) {
             completion();
         }
     }];
}

- (IBAction)OnCancel:(id)sender
{
    [self closeAnimationWithCompletion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)OnOK:(id)sender
{
    [self closeAnimationWithCompletion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end

