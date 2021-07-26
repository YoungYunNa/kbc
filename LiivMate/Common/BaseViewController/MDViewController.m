//
//  MDViewController.m
//  LiivMate
//
//  Created by KB on 17/03/2020.
//  Copyright © 2020 KBCard. All rights reserved.
//

#import "MDViewController.h"

@interface MDViewController ()

@end

@implementation MDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.customNavigationBar = [KCLCustomNavigationBarView instance];
    self.customNavigationBar.currentViewController = self;
    [self.view addSubview:self.customNavigationBar];
}

-(void)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSLog(@"%s",__FUNCTION__);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
