//
//  KCLSearchViewController.h
//  LiivMate
//
//  Created by KB on 2021/05/28.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KCLSearchViewController : ViewController

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@property (weak, nonatomic) IBOutlet UIScrollView *keywordScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *keywordCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keywordCollectionViewHeight;

@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet UIView *noSearchView;

// 전체 메뉴 리스트
@property (nonatomic,strong) NSMutableArray *menuTotalList;

// 메뉴검색 키워드 리스트
@property (nonatomic,strong) NSMutableArray *menuKeywordList;

// 메뉴검색 키워드 맵핑메뉴 리스트
@property (nonatomic,strong) NSArray *menuKeywordMapList;

@end


@interface SearchMenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;

@end

@interface KeywordCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *keywordLabel;

@end

NS_ASSUME_NONNULL_END
