//
//  UITableViewCell+Option.h
//  KBCardShop
//
//  Created by KB_CARD_MINI_5 on 2014. 10. 9..
//  Copyright (c) 2014년 Seeroo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TableViewDelegate <UITableViewDelegate>
@optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath optionIndex:(NSInteger)index;
@end

@interface UITableViewCell (Option)
-(void)sendDelegateEvent;
-(void)didSelectOptionIndex:(NSInteger)optionIndex;
-(UITableView*)tableView;
-(NSIndexPath*)indexPath;
-(CGFloat)rowHeight;
-(void)reloadData;
@end
