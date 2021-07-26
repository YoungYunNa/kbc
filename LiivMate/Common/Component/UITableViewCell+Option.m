//
//  UITableViewCell+Option.m
//  KBCardShop
//
//  Created by KB_CARD_MINI_5 on 2014. 10. 9..
//  Copyright (c) 2014년 Seeroo Inc. All rights reserved.
//

#import "UITableViewCell+Option.h"

@implementation UITableViewCell (Option)

-(UITableView*)tableView
{
    UITableView *tableView = (id)self.nextResponder;
    while (tableView)
    {
        if([tableView isKindOfClass:[UITableView class]])
        {
            return tableView;
        }
        tableView = (id)tableView.nextResponder;
    };
    return nil;
}

-(NSIndexPath*)getIndexPath:(UITableView*)tableView
{
	return [tableView indexPathForRowAtPoint:self.center];
}

-(void)reloadData
{
	UITableView *tableView = self.tableView;
	NSIndexPath *indexPath = [self getIndexPath:tableView];
	[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
}

-(CGFloat)rowHeight
{
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [self getIndexPath:tableView];
    if([tableView.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)] && indexPath)
        return [tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    return tableView.rowHeight;
}

-(void)sendDelegateEvent
{
	UITableView *tableView = self.tableView;
	NSIndexPath *indexPath = [self getIndexPath:tableView];
	if([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)] && indexPath)
		[(id)tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

-(void)didSelectOptionIndex:(NSInteger)optionIndex
{
    UITableView *tableView = self.tableView;
	NSIndexPath *indexPath = [self getIndexPath:tableView];
    if([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:optionIndex:)] && indexPath)
        [(id)tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath optionIndex:optionIndex];
}

-(NSIndexPath*)indexPath
{
    UITableView *tableView = self.tableView;
	return [self getIndexPath:tableView];
}
@end
