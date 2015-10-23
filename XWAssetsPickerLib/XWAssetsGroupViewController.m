//
//  XWAssetsGroupViewController.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import "XWAssetsGroupViewController.h"
#import "XWAssetsPikerViewController.h"
#import "XWAssetsViewCell.h"
#import "XWAssetsSupplementaryView.h"
#import "ALAssetsGroup+attribute.h"
#import "XWAssetsPageViewController.h"

#define ASSETS_SPACE    4

static NSString * XWAssetsViewCellIdentifier = @"XWAssetsViewCellIdentifier";
static NSString * XWAssetsSupplementaryViewIdentifier = @"XWAssetsSupplementaryViewIdentifier";

@interface XWAssetsPikerViewController ()<UIGestureRecognizerDelegate>

- (void)dismiss:(id)sender;
- (void)finishPickingAssets:(id)sender;

@end

@interface XWAssetsGroupViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,XWAssetsViewCellDelegate,XWToolBarDelegate,UIGestureRecognizerDelegate>
{
    NSIndexPath *slideAtIndexPath;
    CGPoint slideAtPoint;
    UIPanGestureRecognizer *panGes;
}

@property (nonatomic ,strong) NSMutableDictionary *assets;

@property (nonatomic ,strong) NSMutableArray *groups;

@end

@implementation XWAssetsGroupViewController

@synthesize pickerCollectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        //
        [self setup];
    }
    return self;
}

/**
 @method
 @brief 初始化缺省数据
 @discussion
 @param
 @result
 */
- (void)setup
{
    self.title = XWASSET_TITLE;
    
    self.assets = [NSMutableDictionary dictionary];
    self.groups = [NSMutableArray array];
    
    [self trimGroup];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)trimGroup
{
    __weak XWAssetsGroupViewController *weakSelf = self;
    
    ALAssetsFilter *assetsFilter = self.picker.assetsFilter;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        __strong XWAssetsGroupViewController *strongSelf = weakSelf;
        
        if (group)
        {
            if (group.numberOfAssets > 0) {
                
                if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldShowAssetsGroup:)]) {
                    if ([self.picker.delegate assetsPickerController:self.picker shouldShowAssetsGroup:group]){
                        
                        [group setAssetsFilter:assetsFilter];
                        [weakSelf.groups addObject:group];
                        [weakSelf trimAssets:group];
                    }
                }
                else {
                    [group setAssetsFilter:assetsFilter];
                    [weakSelf.groups addObject:group];
                    [weakSelf trimAssets:group];
                }
            }
        }
        else {
            [strongSelf->pickerCollectionView reloadData];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
    {

    };
    
    // Enumerate Camera roll first
    [self.picker.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                             usingBlock:resultsBlock
                                           failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type =
    ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent |
    ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    
    [self.picker.assetsLibrary enumerateGroupsWithTypes:type
                                             usingBlock:resultsBlock
                                           failureBlock:failureBlock];
}

- (void)trimAssets:(ALAssetsGroup *)group
{
    __weak XWAssetsGroupViewController *weakSelf = self;
    
    if (group) {
        
        __block NSMutableArray *results = [NSMutableArray array];
        NSURL *url = group.url;
        
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            //
            if (result) {
                
                if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldShowAsset:)]) {
                    if ([self.picker.delegate assetsPickerController:self.picker shouldShowAsset:result]){
                        
                        [results insertObject:result atIndex:0];
                    }
                }
                else {
                    [results insertObject:result atIndex:0];
                }
            }
            else {
                [weakSelf.assets setObject:results forKey:url];
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBackButton];
    
    CGFloat width = (self.view.frame.size.width-ASSETS_SPACE*3-4) / 4.0;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    layout.itemSize             = CGSizeMake(width, width);
    layout.headerReferenceSize  = CGSizeMake(self.view.frame.size.width, 60.0);
    layout.footerReferenceSize  = CGSizeMake(0, 5.0);
    layout.sectionInset            = UIEdgeInsetsMake(5.0, 2.0, 0, 2.0);
    layout.minimumInteritemSpacing = ASSETS_SPACE;
    layout.minimumLineSpacing      = ASSETS_SPACE;
    
    pickerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44) collectionViewLayout:layout];
    pickerCollectionView.backgroundColor = [UIColor whiteColor];
    pickerCollectionView.delegate = self;
    pickerCollectionView.dataSource = self;

    panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureFrom:)];
    panGes.minimumNumberOfTouches = 1;
    panGes.maximumNumberOfTouches = 1;
    panGes.delegate = self;
    [pickerCollectionView addGestureRecognizer:panGes];

    [self.view addSubview:pickerCollectionView];
    
    [pickerCollectionView registerClass:[XWAssetsViewCell class] forCellWithReuseIdentifier:XWAssetsViewCellIdentifier];
    [pickerCollectionView registerClass:[XWAssetsSupplementaryView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:XWAssetsSupplementaryViewIdentifier];
    [pickerCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"haha"];
    
    _assetToolBar = [[XWToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44) andPicker:self.picker];
    self.assetToolBar.tbdelegate = self;
    [self.view addSubview:self.assetToolBar];
    
    [self.assetToolBar setupToolBar:YES];
    
    [self trimGroup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerSelectedAssetsChanged:) name:XWAssetsChangedNotificationKey object:nil];
}

- (void)setupBackButton
{
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:(@"返回")
                                                              style:UIBarButtonItemStylePlain
                                                             target:self.picker
                                                             action:@selector(dismiss:)];

    right.tintColor = self.picker.assetColor;
    self.navigationItem.rightBarButtonItem = right;
}

#pragma mark -- CollectionDataSourse

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        XWAssetsSupplementaryView *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:XWAssetsSupplementaryViewIdentifier forIndexPath:indexPath];
        
        ALAssetsGroup *group = self.groups[indexPath.section];
        
        NSArray *assets = [self.assets objectForKey:group.url];
        
        [view bind:group andAsset:assets];
        
        if (self.assets.count == 0)
            view.hidden = YES;
        
        return view;
    }
    else {
        UICollectionReusableView *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"haha" forIndexPath:indexPath];
        
        view.hidden = YES;
        
        return view;
    }
}

/**
@brief 定义展示的UICollectionViewCell的个数
 */
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ALAssetsGroup *group = self.groups[section];
    
    return [group numberOfAssets];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.groups.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XWAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XWAssetsViewCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    ALAssetsGroup *group = self.groups[indexPath.section];
    
    NSArray *assets = [self.assets objectForKey:group.url];
    
    ALAsset *asset = assets[indexPath.row];
    
    cell.enabled = YES;
  
    if ([self.picker.selectedAssets containsObject:asset]) {
        cell.assetSelected = YES;
    }
    else {
        cell.assetSelected = NO;
    }
    
    [cell bind:asset];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

///@brief 多选 
- (void)xwAssetsViewCellChecked:(XWAssetsViewCell *)target
{
    if ([self.picker.selectedAssets containsObject:target.asset]) {
        [self.picker removeObjectFromArr:target.asset];
    }
    else {
        [self.picker insertObject:target.asset];
    }
}

- (void)xwAssetsViewCellTap:(XWAssetsViewCell *)target
{
    ALAssetsGroup *group = self.groups[target.indexPath.section];
    
    NSArray *assets = [self.assets objectForKey:group.url];
    
    NSArray *assets_ = [NSArray arrayWithArray:assets];
    
    XWAssetsPageViewController *vc = [[XWAssetsPageViewController alloc] initWithAssets:assets_];
    vc.pageIndex = target.indexPath.row;
    vc.isPreview = NO;
    
    [self.navigationController pushViewController:vc animated:YES];
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
    
    [pickerCollectionView reloadData];
}

- (NSPredicate *)predicateOfAssetType:(NSString *)type
{
    return [NSPredicate predicateWithBlock:^BOOL(ALAsset *asset, NSDictionary *bindings) {
        return [[asset valueForProperty:ALAssetPropertyType] isEqual:type];
    }];
}

- (void)toolbarPreview:(XWToolBar *)target
{
    if (self.picker.selectedAssets.count == 0) {
        return;
    }
    
    NSArray *assets_ = [NSArray arrayWithArray:self.picker.selectedAssets];
    
    XWAssetsPageViewController *vc = [[XWAssetsPageViewController alloc] initWithAssets:assets_];
    vc.pageIndex = 0;
    vc.isPreview = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toolbarSend:(XWToolBar *)target
{
    [self.picker finishPickingAssets:NULL];
}

#pragma mark -- PanGestureDelegate
- (void)handlePanGestureFrom:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled) {
        slideAtPoint = CGPointZero;
        slideAtIndexPath = nil;
        return;
    }
    
    CGPoint point = [recognizer locationInView:recognizer.view];
    NSIndexPath *indexPath = [self.pickerCollectionView indexPathForItemAtPoint:point];

    if (CGPointEqualToPoint(slideAtPoint, CGPointZero)) {
        slideAtPoint = point;
        slideAtIndexPath = nil;
    }
    else if (recognizer.state == UIGestureRecognizerStateBegan) {
        slideAtPoint = CGPointZero;
        slideAtIndexPath = nil;
    }
    
    if (indexPath) {
        //
        
        if (ABS(slideAtPoint.x-point.x) >= 16) {
          
            
            if (!slideAtIndexPath || (slideAtIndexPath && (slideAtIndexPath.section == indexPath.section && slideAtIndexPath.row != indexPath.row))) {
                //
      
                slideAtIndexPath = indexPath;
                slideAtPoint = point;
                
                ALAssetsGroup *group = self.groups[indexPath.section];
                NSArray *assets = [self.assets objectForKey:group.url];
                ALAsset *asset = assets[indexPath.row];
                
                if ([self.picker.selectedAssets containsObject:asset]) {
                    [self.picker removeObjectFromArr:asset];
                }
                else {
                    [self.picker insertObject:asset];
                }
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isEqual:panGes] && [otherGestureRecognizer isEqual:self.pickerCollectionView.panGestureRecognizer]){
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (!self.picker.openSlideSelectGesture) {
        return NO;
    }
    
    if (panGes == gestureRecognizer) {
        CGPoint translation = [panGes velocityInView:self.pickerCollectionView];
        return fabs(translation.y) < fabs(translation.x);
    }
    return YES;
}

@end
