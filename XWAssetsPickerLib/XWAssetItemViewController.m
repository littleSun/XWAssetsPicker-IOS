//
//  XWAssetItemViewController.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import "XWAssetItemViewController.h"
#import "XWAssetScrollView.h"

@interface XWAssetItemViewController ()

@end

@implementation XWAssetItemViewController

+ (XWAssetItemViewController *)assetItemViewControllerForPageIndex:(NSInteger)pageIndex;
{
    return [[self alloc] initWithPageIndex:pageIndex];
}

- (id)initWithPageIndex:(NSInteger)pageIndex
{
    if (self = [super init])
    {
        self.pageIndex = pageIndex;
    }
    
    return self;
}

- (void)loadView
{
    XWAssetScrollView *scrollView   = [[XWAssetScrollView alloc] init];
    scrollView.dataSource           = self.dataSource;
    scrollView.adelegate             = self.delegate;
    scrollView.index                = self.pageIndex;
    
    self.view = scrollView;
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
