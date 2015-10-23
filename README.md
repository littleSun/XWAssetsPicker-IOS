#XWAssetsPicker简介
XWAssetsPicker 用于IOS开发者方便地获取相机库。  
省去了系统的第一层相册抽屉，一页展示所有资源。  
用户可以清楚的识别图片，GIF动态图片和视频资源。  
可以方便的用滑动手势选择资源  
也可以在取出资源前，对资源进行压缩，图片资源大约控制在  500K以内，视频资源自动转码成mp4格式。  

#例子 For example ：

##1. 初始化 init

XWAssetsPikerViewController *piker=[[XWAssetsPikerViewController alloc] init];  
piker.delegate = self;  
piker.assetsFilter = [ALAssetsFilter allAssets];  
[self presentViewController:piker animated:YES completion:NULL];  

##2. 回调

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