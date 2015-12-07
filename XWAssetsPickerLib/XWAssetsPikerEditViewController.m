//
//  XWAssetsPikerEditViewController.m
//  XWAssetsPicker
//
//  Created by zengchao on 15/12/4.
//  Copyright © 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import "XWAssetsPikerEditViewController.h"

@interface XWAssetsPikerEditViewController ()

@end

@implementation XWAssetsPikerEditViewController

- (void)loadView
{
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
//        self.edgesForExtendedLayout = UIRectEdgeAll;
//    }
//    
    [super loadView];
 
    self.view.backgroundColor = [UIColor blackColor];
    
    XWAssetEditScrollView *scrollView   = [[XWAssetEditScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//    scrollView.dataSource           = self.dataSource;
//    scrollView.adelegate             = self;
    scrollView.editAsset = self.asset;
    [self.view addSubview:scrollView];
    
    CGFloat height = ([UIScreen mainScreen].bounds.size.height-[UIScreen mainScreen].bounds.size.width)*0.5;
    
    UIImageView *topCrop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    topCrop.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.view addSubview:topCrop];
    
    UIImageView *bottomCrop = [[UIImageView alloc] initWithFrame:CGRectMake(0, height+[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width, height)];
    bottomCrop.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.view addSubview:bottomCrop];

//    topCrop.alpha = bottomCrop.alpha = 0;
//    
//    [UIView animateWithDuration:0.32 animations:^{
//        topCrop.alpha = bottomCrop.alpha = 1;
//    }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
