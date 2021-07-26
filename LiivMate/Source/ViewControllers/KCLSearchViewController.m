//
//  KCLSearchViewController.m
//  LiivMate
//
//  Created by KB on 2021/05/28.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLSearchViewController.h"

#define LIST_MENU_ID   @"menuId"
#define LIST_MENU_NAME @"menuName"

#define menuCellHeightDefault 50 // 메뉴 셀 높이
#define menuCellTopBottomSpacing 15 // 메뉴 셀 상단 하단 간격

#define keywordCellHeight 33 // 키워드 셀 높이
#define keywordCellSpacing 12 // 키워드 셀 간격
#define keywordCellLineSpacing 16 // 키워드 셀 라인 간격
#define keywordLabelInset 16 // 키워드 라벨 inset
#define keywordLabelFontSize 14.0f // 키워드 라벨 폰트 사이즈

// 메뉴 검색 키워드
#define LIST_KEYWORD_NAME @"keyWords"
#define LIST_KEYWORD_MENUID @"menuIds"

@interface KCLSearchViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate> {
    
    NSMutableArray *menuArray;
    
    NSMutableArray *keywordSections; // 키워드 컬렉션뷰의 섹션수와 각 섹션의 아이템 수 저장
    
    BOOL isKeywordMode;
}

@end

@implementation KCLSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _searchTextField.tintColor = UIColor.whiteColor;
    [_searchTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    
    [_searchTableView setContentInset:UIEdgeInsetsMake(menuCellTopBottomSpacing, 0, menuCellTopBottomSpacing, 0)];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [_keywordCollectionView setCollectionViewLayout:flowLayout];
    
    _keywordScrollView.hidden = NO;
    _searchTableView.hidden = YES;
    
    isKeywordMode = NO;
    
    // 메뉴 검색 키워드 파싱
    _menuKeywordList = [NSMutableArray array];
    for (NSDictionary *keywordDic in [[AllMenu menu].appMenu objectForKey:MenuSearch_keyWordList]) {
        NSLog(@"keyWordList == %@",keywordDic);

        for (NSString *keyword in [keywordDic valueForKey:LIST_KEYWORD_NAME]) {
            [_menuKeywordList addObject:@[keyword, [keywordDic valueForKey:LIST_KEYWORD_MENUID]]];
        }
    }
}

- (void)viewWillLayoutSubviews {
    
    [UIView setAnimationsEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [AllMenu setStatusBarStyle:YES viewController:self];
    
//    [WebViewController sendGa360Native:NO p1:@"메뉴검색" p2:@"ME1102" p3:@"전체메뉴>메뉴검색" campainUrl:nil];
    
    menuArray = [NSMutableArray array];
    
    for (NSArray *array in self.menuTotalList) {
        for (NSString *name in array[1]) {
            [menuArray addObject:name];
        }
    }
    
//    [self keywordRandomSet];
    [self keywordCollectionViewDataSettings];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 키보드 닫기
    [self.view endEditing:YES];
}

/**
@var linearHangul
@brief 입력한 문자열의 초성, 중성, 종성 분해
@param 문자열
@return 초성, 중성, 종성 문자열
*/
- (NSString *)linearHangul:(NSString *)str {
    
    NSArray *cho = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];
    NSArray *jung = [[NSArray alloc] initWithObjects:@"ㅏ",@"ㅐ",@"ㅑ",@"ㅒ",@"ㅓ",@"ㅔ",@"ㅕ",@"ㅖ",@"ㅗ",@"ㅘ",@"ㅙ",@"ㅚ",@"ㅛ",@"ㅜ",@"ㅝ",@"ㅞ",@"ㅟ",@"ㅠ",@"ㅡ",@"ㅢ",@"ㅣ",nil];
    NSArray *jong = [[NSArray alloc] initWithObjects:@"",@"ㄱ",@"ㄲ",@"ㄳ",@"ㄴ",@"ㄵ",@"ㄶ",@"ㄷ",@"ㄹ",@"ㄺ",@"ㄻ",@"ㄼ",@"ㄽ",@"ㄾ",@"ㄿ",@"ㅀ",@"ㅁ",@"ㅂ",@"ㅄ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅊ",@"ㅋ",@" ㅌ",@"ㅍ",@"ㅎ",nil];
    
    NSString *result = @"";
    
    for (int i=0; i<[str length]; i++) {
        NSInteger code = [str characterAtIndex:i] - 44032;
        if (code > -1 && code < 11172) {
            NSInteger choIdx = code / 21 / 28;
            NSInteger jungIdx = code % (21 * 28) / 28;
            NSInteger jongIdx = code % 28;
            result = [NSString stringWithFormat:@"%@%@%@%@", result, [cho objectAtIndex:choIdx], [jung objectAtIndex:jungIdx], [jong objectAtIndex:jongIdx]];
        }
        else {
            result = [NSString stringWithFormat:@"%@%@", result, [str substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return result;
}

/**
@var linearHangulCho
@brief 입력한 문자열의 초성 추출
@param 문자열
@return 초성 문자열
*/
- (NSString *)linearHangulCho:(NSString *)str {
    
    NSArray *cho = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];

    NSString *result = @"";
    
    for (int i=0; i<[str length]; i++) {
        NSInteger code = [str characterAtIndex:i] - 44032;
        if (code > -1 && code < 11172) {
            NSInteger choIdx = code / 21 / 28;
            result = [NSString stringWithFormat:@"%@%@", result, [cho objectAtIndex:choIdx]];
        }
        else {
            result = [NSString stringWithFormat:@"%@%@", result, [str substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return result;
}

/**
@var isInitialConsonants
@brief 입력 문자열이 초성인지 확인
@param 문자열
@return 초성 여부
*/
- (BOOL)isInitialConsonants:(NSString *)str {
    
    for (int i=0; i<[str length]; i++) {
        NSInteger code = [str characterAtIndex:i] - 44032;
        if (code > -1 && code < 11172) {
            return NO;
        }
    }
    return YES;
}

/**
@var keywordCollectionViewDataSettings
@brief 키워드 컬렉션뷰의 데이터 설정
@param
@return
*/
- (void)keywordCollectionViewDataSettings {
    
    // 각 섹션의 아이템 수 계산
    CGFloat keywordCellRowWidth = 0; // 키워드 셀의 Row 너비
    int keywordItemsCount = 0;
    keywordSections = [NSMutableArray array];
    
    for (int i=0; i<_menuKeywordList.count; i++) {
        
        NSArray *keywordArray = [_menuKeywordList objectAtIndex:i];
        
        keywordCellRowWidth += [keywordArray.firstObject sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:keywordLabelFontSize]}].width;
        keywordCellRowWidth += keywordLabelInset * 2;
        keywordCellRowWidth += keywordCellSpacing;
        
        if ((keywordCellRowWidth + keywordCellSpacing) < kScreenBoundsWidth) {
            // 현재 섹션에 추가
            keywordItemsCount++;
        } else {
            // 줄바꿈 (다음 섹션에 추가)
            [keywordSections addObject:[NSNumber numberWithInt:keywordItemsCount]];
            keywordItemsCount = 1;
            keywordCellRowWidth = [keywordArray.firstObject sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:keywordLabelFontSize]}].width;
            keywordCellRowWidth += keywordLabelInset * 2;
            keywordCellRowWidth += keywordCellSpacing;
        }
    }
    // 마지막줄 (다음 섹션에 추가)
    [keywordSections addObject:[NSNumber numberWithInt:keywordItemsCount]];
    
    // 키워드 컬렉션뷰의 높이 설정
    CGFloat collectionViewBottom = 15;
    _keywordCollectionViewHeight.constant = keywordSections.count * (keywordCellHeight + keywordCellLineSpacing) + collectionViewBottom;
}


#pragma mark - Button Event

// 전체메뉴 화면 닫기
- (IBAction)didTouchClose:(id)sender {
    
    [self.navigationController popViewControllerAnimated:NO];
}

// 입력한 검색어 삭제
- (IBAction)didTouchRemove:(id)sender {
    
    _searchTextField.text = @"";
    
    _keywordScrollView.hidden = NO;
    _searchTableView.hidden = YES;
    
    _clearButton.hidden = YES;
    
    _noSearchView.hidden = YES;
    [_searchTableView reloadData];
}

// 돋보기 버튼 클릭
- (IBAction)didTouchSearch:(id)sender {
    
    [_searchTextField resignFirstResponder];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 키보드 닫기
    [self.view endEditing:YES];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isKeywordMode) {
        return menuCellHeightDefault;
    }
    
    NSDictionary *menuDic =  [menuArray objectAtIndex:indexPath.row];
    
    NSString *keyword = [self linearHangul:_searchTextField.text];
    NSString *menuName = [self linearHangul:[menuDic valueForKey:LIST_MENU_NAME]];
    NSString *initialSounds = [self linearHangulCho:[menuDic valueForKey:LIST_MENU_NAME]];
    
    if ([self isInitialConsonants:_searchTextField.text]) {
        if ([[initialSounds lowercaseString] containsString:[keyword lowercaseString]]) {
            _noSearchView.hidden = YES;
            return menuCellHeightDefault;
        }
    }
    else {
        if ([menuName containsString:keyword]) {
            _noSearchView.hidden = YES;
            return menuCellHeightDefault;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *selectedMenuDic = [NSDictionary dictionary];
    
    if (isKeywordMode) {
        NSString *menuId = [_menuKeywordMapList objectAtIndex:indexPath.row];
        for (NSDictionary *menuDic in menuArray) {
            if ([[menuDic valueForKey:LIST_MENU_ID] isEqualToString:menuId]) {
                selectedMenuDic = menuDic;
            }
        }
    }
    else {
        selectedMenuDic = [menuArray objectAtIndex:indexPath.row];
    }
    
    
    NSString *selectedMenuID;
    
    if (selectedMenuDic[K_VIEWID]) {
        selectedMenuID = selectedMenuDic[K_VIEWID];
    } else {
        return;
    }
    
    // 메인(자산/소비/톡톡) 메뉴는 메인으로 이동
    if ([selectedMenuID isEqualToString:MenuID_V4_ASSETLINKAGE_MainPage] ||
        [selectedMenuID isEqualToString:MenuID_V4_PayMngCnsmRpt] ||
        [selectedMenuID isEqualToString:MenuID_V4_TocToc]) {
        
        [APP_DELEGATE mainViewController].menuID_main = selectedMenuID;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [[AllMenu delegate] sendBirdDetailPage:selectedMenuID callBack:^(ViewController *vc) {}];
    }
    
    NSString *categoryName = [self getCategoryNameWithMenuName:selectedMenuDic[LIST_MENU_NAME]];
    [WebViewController sendGa360Native:YES p1:@"메뉴검색" p2:categoryName p3:selectedMenuDic[LIST_MENU_NAME] campainUrl:nil];
}

/**
@var getCategoryNameWithMenuName
@brief 메뉴가 속해있는 카테고리 이름 가져오기
@param 메뉴 이름
@return 메뉴가 속해있는 카테고리 이름
*/
- (NSString *)getCategoryNameWithMenuName:(NSString *)menuName {
    
    int categoryIdx = 0;
    for (NSArray *array in _menuTotalList) {
        for (NSString *name in [array objectAtIndex:1]) {
            if ([menuName isEqualToString:name]) {
                NSArray *menuCategoryArray = [_menuTotalList objectAtIndex:categoryIdx];
                return menuCategoryArray[0];
            }
        }
        categoryIdx++;
    }
    return @"";
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (isKeywordMode) {
        if (_menuKeywordMapList.count > 0 || _searchTextField.text.length == 0) {
            _noSearchView.hidden = YES;
        } else {
            _noSearchView.hidden = NO;
        }
        return _menuKeywordMapList.count;
    }
    
    return menuArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchMenuTableViewCell"];
    cell.menuTitleLabel.text = @"";
    
    if (isKeywordMode) {
        NSString *menuId = [_menuKeywordMapList objectAtIndex:indexPath.row];
        for (NSDictionary *menuDic in menuArray) {
            if ([[menuDic valueForKey:LIST_MENU_ID] isEqualToString:menuId]) {
                cell.menuTitleLabel.text = [menuDic valueForKey:LIST_MENU_NAME];
                return cell;
            }
        }
        // 임시로 전체메뉴에 해당 메뉴아이디가 없을경우 메뉴이름 대신 메뉴 아이디 표시
        if ([cell.menuTitleLabel.text isEqualToString:@""]) {
            cell.menuTitleLabel.text = menuId;
            return cell;
        }
    }
    else {
        NSDictionary *menuDic =  [menuArray objectAtIndex:indexPath.row];
        cell.menuTitleLabel.text = [menuDic valueForKey:LIST_MENU_NAME];
    }
    
    return cell;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return keywordSections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [[keywordSections objectAtIndex:section] integerValue];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    KeywordCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KeywordCollectionViewCell" forIndexPath:indexPath];
    
    // 전체 메뉴리스트에서의 인덱스
    NSInteger indexPathRow = 0;
    
    for (int i=0; i<indexPath.section; i++) {
        indexPathRow += [[keywordSections objectAtIndex:i] intValue];
    }
    indexPathRow += indexPath.row;
    
    cell.keywordLabel.text = [[_menuKeywordList objectAtIndex:indexPathRow] objectAtIndex:0];
    [cell.keywordLabel sizeToFit];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    // 전체 메뉴리스트에서의 인덱스
    NSInteger indexPathRow = 0;
    
    for (int i=0; i<indexPath.section; i++) {
        indexPathRow += [[keywordSections objectAtIndex:i] intValue];
    }
    indexPathRow += indexPath.row;
    
    NSArray *keywordArray = [_menuKeywordList objectAtIndex:indexPathRow];
    CGSize targetSize = [keywordArray.firstObject sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:keywordLabelFontSize]}];
    
    CGFloat itemWidth = targetSize.width + keywordLabelInset*2;
    
    return CGSizeMake(itemWidth, keywordCellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

    // 현재 섹션의 첫 아이템의 인덱스
    int itemIndex = 0;
    for (int i=0; i<keywordSections.count; i++) {
        if (i < section) {
            itemIndex += [[keywordSections objectAtIndex:i] intValue];
        }
    }
    
    // 현재 섹션의 컨텐츠 너비
    CGFloat itemsWidth = 0;
    
    for (int i=itemIndex; i<itemIndex+[[keywordSections objectAtIndex:section] intValue]; i++) {

        NSArray *keywordArray = [_menuKeywordList objectAtIndex:i];
        itemsWidth += [keywordArray.firstObject sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:keywordLabelFontSize]}].width;
        itemsWidth += keywordLabelInset * 2;
        itemsWidth += keywordCellSpacing;
    }
    itemsWidth -= keywordCellSpacing;
    
    CGFloat horizontalInset = (collectionView.bounds.size.width - itemsWidth) / 2;
    
    // 계산상 소수점 오차 방지
    horizontalInset -= 1;
    
    return UIEdgeInsetsMake(0, horizontalInset, keywordCellLineSpacing, horizontalInset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    isKeywordMode = YES;
    
    _keywordScrollView.hidden = YES;
    _searchTableView.hidden = NO;
    
    // 전체 메뉴리스트에서의 인덱스
    NSInteger indexPathRow = 0;
    
    for (int i=0; i<indexPath.section; i++) {
        indexPathRow += [[keywordSections objectAtIndex:i] intValue];
    }
    indexPathRow += indexPath.row;
    
    _searchTextField.text = [[_menuKeywordList objectAtIndex:indexPathRow] objectAtIndex:0];
    _clearButton.hidden = NO;
    
    _menuKeywordMapList = [[_menuKeywordList objectAtIndex:indexPathRow] objectAtIndex:1];
    [_searchTableView reloadData];
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _searchTableView);
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //최대 20자까지만 허용.
    if( [string length] > 0 && [textField.text length] > 19 )
        return NO;
    
    return YES;
}

- (IBAction)textFieldEditingChanged:(id)sender {
    
    isKeywordMode = NO;
    
    UITextField *textField = (UITextField *)sender;
    if (textField.text.length > 0) {
        _keywordScrollView.hidden = YES;
        _searchTableView.hidden = NO;
        _clearButton.hidden = NO;
        _noSearchView.hidden = NO;
    } else {
        _keywordScrollView.hidden = NO;
        _searchTableView.hidden = YES;
        _clearButton.hidden = YES;
        _noSearchView.hidden = YES;
    }
    
    [_searchTableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

@end


@implementation SearchMenuTableViewCell

@end

@implementation KeywordCollectionViewCell

@end
