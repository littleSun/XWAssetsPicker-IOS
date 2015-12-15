//
//  XWPhotoEditView.m
//  XWAssetsPicker
//
//  Created by zengchao on 15/12/8.
//  Copyright © 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import "XWPhotoEditView.h"
#import <math.h>
#import "UIImage+assets.h"

//static const int kCropLines = 0;
//static const int kGridLines = 0;

//static const CGFloat kCropViewHotArea = 10;
//static const CGFloat kMinimumCropArea = 60;
static const CGFloat kMaximumCanvasWidthRatio = 0.9;
static const CGFloat kMaximumCanvasHeightRatio = 0.7;
static const CGFloat kCanvasHeaderHeigth = 60;
static const CGFloat kCropViewCornerLength = 22;

//static CGFloat distanceBetweenPoints(CGPoint point0, CGPoint point1)
//{
//    return sqrt(pow(point1.x - point0.x, 2) + pow(point1.y - point0.y, 2));
//}

//#define kInstruction

@implementation PhotoContentView

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        _image = image;
    
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.image = self.image;
        _imageView.userInteractionEnabled = YES;
        _imageView.layer.shouldRasterize = YES;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end

@interface PhotoScrollView : UIScrollView

@property (strong, nonatomic) PhotoContentView *photoContentView;

@end

@implementation PhotoScrollView

- (void)setContentOffsetY:(CGFloat)offsetY
{
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = offsetY;
    self.contentOffset = contentOffset;
}

- (void)setContentOffsetX:(CGFloat)offsetX
{
    CGPoint contentOffset = self.contentOffset;
    contentOffset.x = offsetX;
    self.contentOffset = contentOffset;
}

- (CGFloat)zoomScaleToBound
{
    CGFloat scaleW = self.bounds.size.width * 1.0 / self.photoContentView.bounds.size.width;
    CGFloat scaleH = self.bounds.size.height * 1.0 / self.photoContentView.bounds.size.height;
    CGFloat max = MAX(scaleW, scaleH);
    
    return max;
}

@end

typedef NS_ENUM(NSInteger, CropCornerType) {
    CropCornerTypeUpperLeft,
    CropCornerTypeUpperRight,
    CropCornerTypeLowerRight,
    CropCornerTypeLowerLeft
};

@interface CropCornerView : UIView

@end

@implementation CropCornerView

- (instancetype)initWithCornerType:(CropCornerType)type
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kCropViewCornerLength, kCropViewCornerLength);
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat lineWidth = 2;
        UIView *horizontal = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropViewCornerLength, lineWidth)];
        horizontal.backgroundColor = [UIColor orangeColor];
        [self addSubview:horizontal];
        
        UIView *vertical = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lineWidth, kCropViewCornerLength)];
        vertical.backgroundColor = [UIColor orangeColor];
        [self addSubview:vertical];
        
        if (type == CropCornerTypeUpperLeft) {
            horizontal.center = CGPointMake(kCropViewCornerLength / 2, lineWidth / 2);
            vertical.center = CGPointMake(lineWidth / 2, kCropViewCornerLength / 2);
        } else if (type == CropCornerTypeUpperRight) {
            horizontal.center = CGPointMake(kCropViewCornerLength / 2, lineWidth / 2);
            vertical.center = CGPointMake(kCropViewCornerLength - lineWidth / 2, kCropViewCornerLength / 2);
        } else if (type == CropCornerTypeLowerRight) {
            horizontal.center = CGPointMake(kCropViewCornerLength / 2, kCropViewCornerLength - lineWidth / 2);
            vertical.center = CGPointMake(kCropViewCornerLength - lineWidth / 2, kCropViewCornerLength / 2);
        } else if (type == CropCornerTypeLowerLeft) {
            horizontal.center = CGPointMake(kCropViewCornerLength / 2, kCropViewCornerLength - lineWidth / 2);
            vertical.center = CGPointMake(lineWidth / 2, kCropViewCornerLength / 2);
        }
    }
    return self;
}

@end

@interface CropView ()

@property (nonatomic, strong) CropCornerView *upperLeft;
@property (nonatomic, strong) CropCornerView *upperRight;
@property (nonatomic, strong) CropCornerView *lowerRight;
@property (nonatomic, strong) CropCornerView *lowerLeft;

@property (nonatomic, strong) NSMutableArray *horizontalCropLines;
@property (nonatomic, strong) NSMutableArray *verticalCropLines;

@property (nonatomic, strong) NSMutableArray *horizontalGridLines;
@property (nonatomic, strong) NSMutableArray *verticalGridLines;

@property (nonatomic, weak) id<CropViewDelegate> delegate;

@property (nonatomic, assign) BOOL cropLinesDismissed;
@property (nonatomic, assign) BOOL gridLinesDismissed;

@end

@implementation CropView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _cropLinesDismissed = YES;
        _gridLinesDismissed = YES;
        
        _upperLeft = [[CropCornerView alloc] initWithCornerType:CropCornerTypeUpperLeft];
        _upperLeft.center = CGPointMake(kCropViewCornerLength / 2, kCropViewCornerLength / 2);
        _upperLeft.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:_upperLeft];
        
        _upperRight = [[CropCornerView alloc] initWithCornerType:CropCornerTypeUpperRight];
        _upperRight.center = CGPointMake(self.frame.size.width - kCropViewCornerLength / 2, kCropViewCornerLength / 2);
        _upperRight.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_upperRight];
        
        _lowerRight = [[CropCornerView alloc] initWithCornerType:CropCornerTypeLowerRight];
        _lowerRight.center = CGPointMake(self.frame.size.width - kCropViewCornerLength / 2, self.frame.size.height - kCropViewCornerLength / 2);
        _lowerRight.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_lowerRight];
        
        _lowerLeft = [[CropCornerView alloc] initWithCornerType:CropCornerTypeLowerLeft];
        _lowerLeft.center = CGPointMake(kCropViewCornerLength / 2, self.frame.size.height - kCropViewCornerLength / 2);
        _lowerLeft.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_lowerLeft];
    }
    return self;
}


- (void)updateCropLines:(BOOL)animate
{
    // show crop lines
    if (self.cropLinesDismissed) {
        [self showCropLines];
    }
    
    void (^animationBlock)(void) = ^(void) {
        [self updateLines:self.horizontalCropLines horizontal:YES];
        [self updateLines:self.verticalCropLines horizontal:NO];
    };
    
    if (animate) {
        [UIView animateWithDuration:0.25 animations:animationBlock];
    } else {
        animationBlock();
    }
}

- (void)updateGridLines:(BOOL)animate
{
    // show grid lines
    if (self.gridLinesDismissed) {
        [self showGridLines];
    }
    
    void (^animationBlock)(void) = ^(void) {
        
        [self updateLines:self.horizontalGridLines horizontal:YES];
        [self updateLines:self.verticalGridLines horizontal:NO];
    };
    
    if (animate) {
        [UIView animateWithDuration:0.25 animations:animationBlock];
    } else {
        animationBlock();
    }
}

- (void)updateLines:(NSArray *)lines horizontal:(BOOL)horizontal
{
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *line = (UIView *)obj;
        if (horizontal) {
            line.frame = CGRectMake(0,
                                    (self.frame.size.height / (lines.count + 1)) * (idx + 1),
                                    self.frame.size.width,
                                    1 / [UIScreen mainScreen].scale);
        } else {
            line.frame = CGRectMake((self.frame.size.width / (lines.count + 1)) * (idx + 1),
                                    0,
                                    1 / [UIScreen mainScreen].scale,
                                    self.frame.size.height);
        }
    }];
}

- (void)dismissCropLines
{
    [UIView animateWithDuration:0.2 animations:^{
        [self dismissLines:self.horizontalCropLines];
        [self dismissLines:self.verticalCropLines];
    } completion:^(BOOL finished) {
        self.cropLinesDismissed = YES;
    }];
}

- (void)dismissGridLines
{
    [UIView animateWithDuration:0.2 animations:^{
        [self dismissLines:self.horizontalGridLines];
        [self dismissLines:self.verticalGridLines];
    } completion:^(BOOL finished) {
        self.gridLinesDismissed = YES;
    }];
}

- (void)dismissLines:(NSArray *)lines
{
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UIView *)obj).alpha = 0.0f;
    }];
}

- (void)showCropLines
{
    self.cropLinesDismissed = NO;
    [UIView animateWithDuration:0.2 animations:^{
        [self showLines:self.horizontalCropLines];
        [self showLines:self.verticalCropLines];
    }];
}

- (void)showGridLines
{
    self.gridLinesDismissed = NO;
    [UIView animateWithDuration:0.2 animations:^{
        [self showLines:self.horizontalGridLines];
        [self showLines:self.verticalGridLines];
    }];
}

- (void)showLines:(NSArray *)lines
{
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UIView *)obj).alpha = 1.0f;
    }];
}

@end

@interface XWPhotoEditView () <UIScrollViewDelegate, CropViewDelegate>
{
    UITapGestureRecognizer *tapLeft;
    UITapGestureRecognizer *tapRight;
    UILongPressGestureRecognizer *longLeft;
    UILongPressGestureRecognizer *longRight;
}
@property (nonatomic ,assign) float slideValue;

@property (nonatomic, strong) PhotoScrollView *scrollView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL manualZoomed;

// masks
@property (nonatomic, strong) UIView *topMask;
@property (nonatomic, strong) UIView *leftMask;
@property (nonatomic, strong) UIView *bottomMask;
@property (nonatomic, strong) UIView *rightMask;

// constants
@property (nonatomic, assign) CGSize maximumCanvasSize;
@property (nonatomic, assign) CGFloat centerY;

// rotate
@property (nonatomic, strong) UIImageView *rotateLeft;
@property (nonatomic, strong) UIImageView *rotateRight;

@property (nonatomic, strong) NSTimer *editTimer;

@property (nonatomic, assign) BOOL editUpOrDown;


@end

@implementation XWPhotoEditView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    if (self = [super init]) {
        
        _slideValue = 0.5;
        
        self.frame = frame;
        
        _image = image;
        
        // scale the image
        _maximumCanvasSize = CGSizeMake(kMaximumCanvasWidthRatio * self.frame.size.width,
                                        kMaximumCanvasHeightRatio * self.frame.size.height - kCanvasHeaderHeigth);
        
        CGFloat scaleX = image.size.width / self.maximumCanvasSize.width;
        CGFloat scaleY = image.size.height / self.maximumCanvasSize.height;
        CGFloat scale = MAX(scaleX, scaleY);
        CGRect bounds = CGRectMake(0, 0, image.size.width / scale, image.size.height / scale);
        _originalSize = bounds.size;
        
        _centerY = self.maximumCanvasSize.height / 2 + kCanvasHeaderHeigth;
        
        _scrollView = [[PhotoScrollView alloc] initWithFrame:bounds];
        _scrollView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
        _scrollView.bounces = YES;
        _scrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 10;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.clipsToBounds = NO;
        _scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
//        _scrollView.backgroundColor = [UIColor blackColor];
        [self addSubview:_scrollView];
        
        _photoContentView = [[PhotoContentView alloc] initWithImage:image];
        _photoContentView.frame = self.scrollView.bounds;
//        _photoContentView.backgroundColor = [UIColor blackColor];
        _photoContentView.userInteractionEnabled = YES;
        _photoContentView.tag = 100;
        _scrollView.photoContentView = self.photoContentView;
        [self.scrollView addSubview:_photoContentView];
        
        CGFloat width = self.scrollView.frame.size.width<self.scrollView.frame.size.height?self.scrollView.frame.size.width:self.scrollView.frame.size.height;
        CGRect rect = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, width, width);
        _cropView = [[CropView alloc] initWithFrame:rect];
        _cropView.tag = 101;
        _cropView.center = self.scrollView.center;
        _cropView.delegate = self;
//        _cropView.userInteractionEnabled = NO;
        [self addSubview:_cropView];
        
//        NSLog(@"%@",NSStringFromCGRect(rect));
        
        UIColor *maskColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        _topMask = [UIView new];
        _topMask.backgroundColor = maskColor;
        [self addSubview:_topMask];
        _leftMask = [UIView new];
        _leftMask.backgroundColor = maskColor;
        [self addSubview:_leftMask];
        _bottomMask = [UIView new];
        _bottomMask.backgroundColor = maskColor;
        [self addSubview:_bottomMask];
        _rightMask = [UIView new];
        _rightMask.backgroundColor = maskColor;
        [self addSubview:_rightMask];
        [self updateMasks:NO];
        
        _rotateLeft = [[UIImageView alloc] initWithFrame:CGRectMake(40, self.frame.size.height-130, 75*0.8, 51*0.8)];
        _rotateLeft.image = [UIImage imageFromAssetBundle:@"asset_rotate_left"];
        [self addSubview:_rotateLeft];
        
        _rotateRight = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-75*0.8-40, self.frame.size.height-130, 75*0.8, 51*0.8)];
        _rotateRight.image = [UIImage imageFromAssetBundle:@"asset_rotate_right"];
        [self addSubview:_rotateRight];
        
        _rotateLeft.userInteractionEnabled = _rotateRight.userInteractionEnabled = YES;
        
        tapLeft = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        tapRight = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        
        longLeft = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGes:)];
        longRight = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGes:)];
        
        [tapLeft requireGestureRecognizerToFail:longLeft];
        [tapRight requireGestureRecognizerToFail:longRight];
        
        longLeft.minimumPressDuration = longRight.minimumPressDuration = 0.2;

        [_rotateLeft addGestureRecognizer:tapLeft];
        [_rotateLeft addGestureRecognizer:longLeft];
        
        [_rotateRight addGestureRecognizer:tapRight];
        [_rotateRight addGestureRecognizer:longRight];
        
        _originalPoint = [self convertPoint:self.scrollView.center toView:self];
        
        [self cropEnded:_cropView];
    }
    return self;
}

- (void)longGes:(UIGestureRecognizer *)ges
{
    if (longLeft == ges) {
       
        self.editUpOrDown = NO;
        
        if (ges.state == UIGestureRecognizerStateBegan) {
            [self setupTimer];
        }
        else if (ges.state == UIGestureRecognizerStateEnded || ges.state == UIGestureRecognizerStateCancelled) {
            [self clearTimer];
        }
    }
    else if (longRight == ges) {
        
        self.editUpOrDown = YES;
        
        if (ges.state == UIGestureRecognizerStateBegan) {
            [self setupTimer];
        }
        else if (ges.state == UIGestureRecognizerStateEnded || ges.state == UIGestureRecognizerStateCancelled) {
            [self clearTimer];
        }
    }
}

- (void)tapGes:(UIGestureRecognizer *)ges
{
    if (tapLeft == ges) {
        self.slideValue -= 0.05;
    }
    else if (tapRight == ges) {
        //
        self.slideValue += 0.05;
    }
}

- (void)setSlideValue:(float)slideValue
{
    if (slideValue >= 0 && slideValue <= 1) {
        if (_slideValue != slideValue) {
            _slideValue = slideValue;
            [self sliderValueChanged:nil];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.rotateLeft.frame, point)) {
        return self.rotateLeft;
    }
    else if (CGRectContainsPoint(self.rotateRight.frame, point)) {
        return self.rotateRight;
    }
    return self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoContentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.manualZoomed = YES;
}

#pragma mark - Crop View Delegate

- (void)cropMoved:(CropView *)cropView
{
    [self updateMasks:NO];
}

- (void)cropEnded:(CropView *)cropView
{
    CGFloat scaleX = self.originalSize.width / cropView.bounds.size.width;
    CGFloat scaleY = self.originalSize.height / cropView.bounds.size.height;
    CGFloat scale = MIN(scaleX, scaleY);
    
    // calculate the new bounds of crop view
    CGRect newCropBounds = CGRectMake(0, 0, scale * cropView.frame.size.width, scale * cropView.frame.size.height);
    
    // calculate the new bounds of scroll view
    CGFloat width = cos(fabs(self.angle)) * newCropBounds.size.width + sin(fabs(self.angle)) * newCropBounds.size.height;
    CGFloat height = sin(fabs(self.angle)) * newCropBounds.size.width + cos(fabs(self.angle)) * newCropBounds.size.height;
    
    // calculate the zoom area of scroll view
    CGRect scaleFrame = cropView.frame;
    if (scaleFrame.size.width >= self.scrollView.bounds.size.width) {
        scaleFrame.size.width = self.scrollView.bounds.size.width - 1;
    }
    if (scaleFrame.size.height >= self.scrollView.bounds.size.height) {
        scaleFrame.size.height = self.scrollView.bounds.size.height - 1;
    }
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGPoint contentOffsetCenter = CGPointMake(contentOffset.x + self.scrollView.bounds.size.width / 2, contentOffset.y + self.scrollView.bounds.size.height / 2);
    CGRect bounds = self.scrollView.bounds;
    bounds.size.width = width;
    bounds.size.height = height;
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    CGPoint newContentOffset = CGPointMake(contentOffsetCenter.x - self.scrollView.bounds.size.width / 2, contentOffsetCenter.y - self.scrollView.bounds.size.height / 2);
    self.scrollView.contentOffset = newContentOffset;
    
    [UIView animateWithDuration:0.25 animations:^{
        // animate crop view
        cropView.bounds = CGRectMake(0, 0, newCropBounds.size.width, newCropBounds.size.height);
        cropView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
        
        // zoom the specified area of scroll view
        CGRect zoomRect = [self convertRect:scaleFrame toView:self.scrollView.photoContentView];
        
        [self.scrollView zoomToRect:zoomRect animated:NO];
    }];
    
    self.manualZoomed = YES;
    
    // update masks
    [self updateMasks:YES];
    
    [self.cropView dismissCropLines];
    
    CGFloat scaleH = self.scrollView.bounds.size.height / self.scrollView.contentSize.height;
    CGFloat scaleW = self.scrollView.bounds.size.width / self.scrollView.contentSize.width;
    __block CGFloat scaleM = MAX(scaleH, scaleW);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (scaleM > 1) {
            scaleM = scaleM * self.scrollView.zoomScale;
            [self.scrollView setZoomScale:scaleM animated:NO];
        }
        [UIView animateWithDuration:0.2 animations:^{
            [self checkScrollViewContentOffset];
        }];
    });
}

- (void)updateMasks:(BOOL)animate
{
    void (^animationBlock)(void) = ^(void) {
        self.topMask.frame = CGRectMake(0, 0, self.cropView.frame.origin.x + self.cropView.frame.size.width, self.cropView.frame.origin.y);
        self.leftMask.frame = CGRectMake(0, self.cropView.frame.origin.y, self.cropView.frame.origin.x, self.frame.size.height - self.cropView.frame.origin.y);
        self.bottomMask.frame = CGRectMake(self.cropView.frame.origin.x, self.cropView.frame.origin.y + self.cropView.frame.size.height, self.frame.size.width - self.cropView.frame.origin.x, self.frame.size.height - (self.cropView.frame.origin.y + self.cropView.frame.size.height));
        self.rightMask.frame = CGRectMake(self.cropView.frame.origin.x + self.cropView.frame.size.width, 0, self.frame.size.width - (self.cropView.frame.origin.x + self.cropView.frame.size.width), self.cropView.frame.origin.y + self.cropView.frame.size.height);
    };
    
    if (animate) {
        [UIView animateWithDuration:0.25 animations:animationBlock];
    } else {
        animationBlock();
    }
}

- (void)checkScrollViewContentOffset
{
    self.scrollView.contentOffsetX = MAX(self.scrollView.contentOffset.x, 0);
    self.scrollView.contentOffsetY = MAX(self.scrollView.contentOffset.y, 0);
    
    if (self.scrollView.contentSize.height - self.scrollView.contentOffset.y <= self.scrollView.bounds.size.height) {
        self.scrollView.contentOffsetY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    
    if (self.scrollView.contentSize.width - self.scrollView.contentOffset.x <= self.scrollView.bounds.size.width) {
        self.scrollView.contentOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    }
}

- (void)sliderValueChanged:(id)sender
{
    // update masks
    [self updateMasks:NO];
    
    // update grids
    [self.cropView updateGridLines:NO];
    
    // rotate scroll view
    self.angle = self.slideValue - 0.5;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        //
        self.scrollView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,  self.angle);
        
        // position scroll view
        CGFloat width = cos(fabs(self.angle)) * self.cropView.frame.size.width + sin(fabs(self.angle)) * self.cropView.frame.size.height;
        CGFloat height = sin(fabs(self.angle)) * self.cropView.frame.size.width + cos(fabs(self.angle)) * self.cropView.frame.size.height;
        CGPoint center = self.scrollView.center;
        
        CGPoint contentOffset = self.scrollView.contentOffset;
        CGPoint contentOffsetCenter = CGPointMake(contentOffset.x + self.scrollView.bounds.size.width / 2.0, contentOffset.y + self.scrollView.bounds.size.height / 2.0);
        self.scrollView.bounds = CGRectMake(0, 0, width, height);
        CGPoint newContentOffset = CGPointMake(contentOffsetCenter.x - self.scrollView.bounds.size.width / 2.0, contentOffsetCenter.y - self.scrollView.bounds.size.height / 2.0);
        self.scrollView.contentOffset = newContentOffset;
        self.scrollView.center = center;
        
        // scale scroll view
        BOOL shouldScale = self.scrollView.contentSize.width / self.scrollView.bounds.size.width <= 1.0 || self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0;
        if (!self.manualZoomed || shouldScale) {
            
            CGFloat scaleSize = [self.scrollView zoomScaleToBound];
            self.scrollView.minimumZoomScale = scaleSize;
            [self.scrollView setZoomScale:scaleSize];
            
            self.manualZoomed = NO;
        }
        
        [self checkScrollViewContentOffset];
        
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)sliderTouchEnded:(id)sender
{
    [self.cropView dismissGridLines];
}

- (void)resetBtnTapped:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.angle = 0;
        self.slideValue = 0.5;
        
        self.scrollView.transform = CGAffineTransformIdentity;
        self.scrollView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
        self.scrollView.bounds = CGRectMake(0, 0, self.originalSize.width, self.originalSize.height);
        self.scrollView.minimumZoomScale = 1;
        [self.scrollView setZoomScale:1 animated:NO];

        [self updateMasks:NO];

    }];
}

- (CGPoint)photoTranslation
{
    CGRect rect = [self.photoContentView convertRect:self.photoContentView.bounds toView:self];
    CGPoint point = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    CGPoint zeroPoint = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
    return CGPointMake(point.x - zeroPoint.x, point.y - zeroPoint.y);
}

- (void)setupTimer
{
    [self clearTimer];
    
    if (!_editTimer) {
        self.editTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(timerGo) userInfo:nil repeats:YES];
    }
}

- (void)clearTimer
{
    if (_editTimer) {
        if ([_editTimer isValid]) {
            [_editTimer invalidate];
        }
    }
    _editTimer = nil;
}

- (void)timerGo
{
    if (self.editUpOrDown) {
        self.slideValue += 0.05;
    }
    else {
        self.slideValue -= 0.05;
    }
    
    if (self.slideValue == 1 || self.slideValue == 0) {
        [self clearTimer];
    }
}

- (void)dealloc
{
    [self clearTimer];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
