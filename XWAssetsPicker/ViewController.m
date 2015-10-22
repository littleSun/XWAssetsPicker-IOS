//
//  ViewController.m
//  XWAssetsPicker
//
//  Created by zengchao on 15/8/20.
//  Copyright (c) 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import "ViewController.h"
#import "XWAssetsPikerViewController.h"

@interface ViewController ()<XWAssetsPickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"XWAssetsPickerDemo";
}

- (IBAction)buttonClick:(id)sender
{
    XWAssetsPikerViewController *piker = [[XWAssetsPikerViewController alloc] init];
    piker.delegate = self;
    piker.assetsFilter = [ALAssetsFilter allAssets];
    [self presentViewController:piker animated:YES completion:NULL];
}

- (void)assetsPickerController:(XWAssetsPikerViewController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"%@ \n",assets.description);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:assets.description delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)assetsPickerControllerDidCancel:(XWAssetsPikerViewController *)picker
{

}

- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldSelectAsset:(ALAsset *)asset
{
    return YES;
}

- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldShowAsset:(ALAsset *)asset
{
    return YES;
}

- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldCompressAsset:(ALAsset *)asset
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
