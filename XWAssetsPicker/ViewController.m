//
//  ViewController.m
//  XWAssetsPicker
//
//  Created by zengchao on 15/8/20.
//  Copyright (c) 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import "ViewController.h"
#import "XWAssetsPikerViewController.h"
#import "ALAsset+assetType.h"

@interface ViewController ()<XWAssetsPickerControllerDelegate>

@property (nonatomic ,assign) NSInteger max;

@property (nonatomic ,strong) NSMutableArray *records;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"XWAssetsPickerDemo";
    
    self.records = [NSMutableArray array];
    self.max = 10;
}

- (IBAction)buttonClick:(id)sender
{
    
    XWAssetsPikerViewController *piker = [[XWAssetsPikerViewController alloc] init];
    piker.canEdit = YES;
    piker.delegate = self;
    piker.assetsFilter = [ALAssetsFilter allPhotos];
    [self presentViewController:piker animated:YES completion:NULL];
}

- (void)assetsPickerController:(XWAssetsPikerViewController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [self.records removeAllObjects];
    [self.records addObjectsFromArray:picker.selectedAssets];
    
    NSLog(@"%@ \n",assets.description);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:assets.description delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)assetsPickerControllerDidCancel:(XWAssetsPikerViewController *)picker
{

}

- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldSelectAsset:(ALAsset *)asset
{
    if (picker.selectedAssets.count >= self.max) {
        //...Alert
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reach to Max" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
        return NO;
    }
    return YES;
}

- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldShowAsset:(ALAsset *)asset
{
    return YES;
}

- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldShowSelectAsset:(ALAsset *)asset
{
    for (ALAsset *tmp in self.records) {
        if ([tmp.url isEqual:asset.url]) {
            return YES;
        }
    }
    return NO;
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
