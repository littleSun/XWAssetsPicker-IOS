//
//  XWAssetsPageViewController.m
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.

#import "XWAssetsPageViewController.h"
#import "XWAssetItemViewController.h"
#import "XWAssetScrollView.h"
#import "XWAssetsPikerViewController.h"
#import "XWToolBar.h"

@interface XWAssetsPikerViewController ()

- (void)dismiss:(id)sender;
- (void)finishPickingAssets:(id)sender;

@end

@interface XWAssetsPageViewController ()
<UIPageViewControllerDataSource, UIPageViewControllerDelegate, XWAssetItemViewControllerDataSource,XWAssetScrollViewDelegate,XWToolBarDelegate>

@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, assign, getter = isStatusBarHidden) BOOL statusBarHidden;
@property (nonatomic ,strong) XWToolBar *assetToolBar;

@end

@implementation XWAssetsPageViewController

- (id)initWithAssets:(NSArray *)assets
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:@{UIPageViewControllerOptionInterPageSpacingKey:@30.f}];
    if (self)
    {
        self.assets                 = assets;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    __weak XWAssetsPageViewController *weakSelf = self;
    
    self.dataSource             = weakSelf;
    self.delegate               = weakSelf;


    barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    barButton.frame = CGRectMake(0, 0, 34, 44);
    [barButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:barButton];
    self.navigationItem.rightBarButtonItem = barItem;
    
    _assetToolBar = [[XWToolBar alloc] initWithFrame:CGRectMake(0, XWAssets_ScreenHeightSafe-44, self.view.frame.size.width, 44) andPicker:self.picker];

    self.assetToolBar.tbdelegate = self;
    [self.view addSubview:self.assetToolBar];
    
    [self.assetToolBar setupToolBar:NO];
    
    [self setTitleIndex:self.pageIndex];
    
    if (!self.picker.multiSelect) {
        [self.picker.selectedAssets removeAllObjects];
        [self.picker insertObject:[self assetAtIndex:self.pageIndex]];
    }
    
    [self updateBarItemIndex:self.pageIndex];
    [self pickerSelectedAssetsChanged:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerSelectedAssetsChanged:) name:XWAssetsChangedNotificationKey object:nil];
}

- (void)buttonClick:(id)sender
{
    
    ALAsset *asset = [self assetAtIndex:_pageIndex];
    if (asset) {
        
        if ([self.picker.selectedAssets containsObject:asset]) {
            
            [self.picker removeObjectFromArr:asset];
        }
        else {
            [self.picker insertObject:asset];
        }
    }
    [self updateBarItemIndex:_pageIndex];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden
{
    return self.isStatusBarHidden;
}

#pragma mark - Update Title

- (void)setTitleIndex:(NSInteger)index
{
    _pageIndex = index;
    
    NSInteger count = self.assets.count;
    self.title      = [NSString stringWithFormat:(@"%d / %d"), (int)_pageIndex+1, (int)count];
}

- (void)updateBarItemIndex:(NSUInteger)index
{
    if ([self.picker.selectedAssets containsObject:[self assetAtIndex:index]]) {

        UIImage *image = [UIImage imageFromAssetBundle:@"asset_select_icon"];
        if (image) {
            [barButton setImage:image forState:UIControlStateNormal];
        }
    }
    else {
        
        UIImage *image = [UIImage imageFromAssetBundle:@"asset_unselect_icon"];
        if (image) {
            [barButton setImage:image forState:UIControlStateNormal];
        }
        
    }
}

#pragma mark - Page Index
- (void)setPageIndex:(NSInteger)pageIndex
{
    _pageIndex = pageIndex;
    
    NSInteger count = self.assets.count;
    
    if (pageIndex >= 0 && pageIndex < count)
    {
        XWAssetItemViewController *page = [XWAssetItemViewController assetItemViewControllerForPageIndex:pageIndex];
        page.dataSource = self;
        page.delegate = self;
        
        [self setViewControllers:@[page]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((XWAssetItemViewController *)viewController).pageIndex;
    
    if (index > 0)
    {
        XWAssetItemViewController *page = [XWAssetItemViewController assetItemViewControllerForPageIndex:(index - 1)];
        page.dataSource = self;
        page.delegate = self;
        
        return page;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger count = self.assets.count;
    NSInteger index = ((XWAssetItemViewController *)viewController).pageIndex;
    
    if (index < count - 1)
    {
        XWAssetItemViewController *page = [XWAssetItemViewController assetItemViewControllerForPageIndex:(index + 1)];
        page.dataSource = self;
        page.delegate = self;
        
        return page;
    }
    
    return nil;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        XWAssetItemViewController *vc   = (XWAssetItemViewController *)pageViewController.viewControllers[0];
        NSInteger index                 = vc.pageIndex;
        
        [self setTitleIndex:index];
        
        if (!self.picker.multiSelect) {
            [self.picker.selectedAssets removeAllObjects];
            [self.picker insertObject:[self assetAtIndex:self.pageIndex]];
        }
        
        [self updateBarItemIndex:index];
    }
}

#pragma mark - Fade in / away navigation bar

- (void)toogleNavigationBar:(id)sender
{
	if (self.isStatusBarHidden)
		[self fadeNavigationBarIn];
    else
		[self fadeNavigationBarAway];
}

- (void)fadeNavigationBarAway
{
    self.statusBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.assetToolBar setHidden:YES];
}

- (void)fadeNavigationBarIn
{
    self.statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.assetToolBar setHidden:NO];
}


#pragma mark - AssetItemViewControllerDataSource

- (ALAsset *)assetAtIndex:(NSUInteger)index;
{
    return [self.assets objectAtIndex:index];
}

- (void)xwAssetScrollViewTap:(XWAssetScrollView *)target
{
    [self toogleNavigationBar:nil];
}

#pragma mark - Util
- (XWAssetsPikerViewController *)picker
{
    return (XWAssetsPikerViewController *)self.navigationController.parentViewController;
}

-(void)pickerSelectedAssetsChanged:(id)sender
{
    if (self.picker.selectedAssets.count > 0) {

        NSPredicate *photoPredicate = [self predicateOfAssetType:ALAssetTypePhoto];
        NSPredicate *videoPredicate = [self predicateOfAssetType:ALAssetTypeVideo];
        
        NSInteger numberOfPhotos = [self.picker.selectedAssets filteredArrayUsingPredicate:photoPredicate].count;
        NSInteger numberOfVideos = [self.picker.selectedAssets filteredArrayUsingPredicate:videoPredicate].count;
        
        if (numberOfVideos == 0)
            self.assetToolBar.recordLabel.text = [NSString stringWithFormat:@"已选%d%@", (int)numberOfPhotos,XWASSET_PIC_TAG];
        else if (numberOfPhotos == 0)
            self.assetToolBar.recordLabel.text = [NSString stringWithFormat:@"已选%d%@", (int)numberOfVideos,XWASSET_VIDEO_TAG];
        else
            self.assetToolBar.recordLabel.text = [NSString stringWithFormat:@"已选%d%@,%d%@", (int)numberOfPhotos,XWASSET_PIC_TAG, (int)numberOfVideos,XWASSET_VIDEO_TAG];
        
        self.assetToolBar.actionEnable = YES;
    }
    else {
        self.assetToolBar.recordLabel.text = nil;
        self.assetToolBar.actionEnable = NO;
    }
}

- (NSPredicate *)predicateOfAssetType:(NSString *)type
{
    return [NSPredicate predicateWithBlock:^BOOL(ALAsset *asset, NSDictionary *bindings) {
        return [[asset valueForProperty:ALAssetPropertyType] isEqual:type];
    }];
}

- (void)toolbarSend:(XWToolBar *)target
{
    [self.picker finishPickingAssets:NULL];
}

@end
