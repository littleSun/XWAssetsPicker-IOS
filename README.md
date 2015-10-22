For example ：

1 初始化 init

XWAssetsPikerViewController *piker = [[XWAssetsPikerViewController alloc] init];
piker.delegate = self;
piker.assetsFilter = [ALAssetsFilter allAssets];
[self presentViewController:piker animated:YES completion:NULL];

2. 回调

//取消 ，cancel
- (void)assetsPickerControllerDidCancel:(XWAssetsPikerViewController *)picker;


//返回结果 ，return result
- (void)assetsPickerController:(XWAssetsPikerViewController *)picker didFinishPickingAssets:(NSArray *)assets;

//是否显示 , should show
- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldShowAsset:(ALAsset *)asset;

//是否可选择 ，should select
- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldSelectAsset:(ALAsset *)asset;


//是否启用压缩 ，should compress
- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldCompressAsset:(ALAsset *)asset；






                                                                        by 卖火柴的一点阳光