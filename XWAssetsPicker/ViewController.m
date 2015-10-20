//
//  ViewController.m
//  XWAssetsPicker
//
//  Created by zengchao on 15/8/20.
//  Copyright (c) 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import "ViewController.h"
#import "XWAssetsPikerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonClick:(id)sender
{
    XWAssetsPikerViewController *piker = [[XWAssetsPikerViewController alloc] init];
    piker.assetsFilter = [ALAssetsFilter allPhotos];
    [self presentViewController:piker animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
