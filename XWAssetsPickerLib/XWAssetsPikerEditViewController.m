//
//  XWAssetsPikerEditViewController.m
//  XWAssetsPicker
//
//  Created by zengchao on 15/12/4.
//  Copyright © 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import "XWAssetsPikerEditViewController.h"
#import "XWAssetsPikerViewController.h"
#import "XWPhotoEditView.h"
#import "UIImage+assets.h"

#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f

@interface XWAssetsPikerEditViewController ()

@property (strong, nonatomic) XWPhotoEditView *photoView;

@property (nonatomic, strong, readonly) UIImage *image;

@end

@implementation XWAssetsPikerEditViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    
    [self setupSubviews];
}

- (void)setupSubviews
{
    if (self.asset.defaultRepresentation)
    {
        //            image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:scale
        //                                  orientation:UIImageOrientationUp];
        ALAssetRepresentation *rep = self.asset.defaultRepresentation;
        
        Byte *imageBuffer = (Byte*)malloc((size_t)rep.size);
        NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:(long)rep.size error:nil];
        NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
        
        _image = [UIImage animatedGIFWithData:imageData isCompress:YES];
    }
    
    self.photoView = [[XWPhotoEditView alloc] initWithFrame:self.view.bounds image:self.image];
    self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.photoView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(8, CGRectGetHeight(self.view.frame) - 44, 60, 44);
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [cancelBtn addTarget:self action:@selector(cancelBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resetBtn.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame)+10, CGRectGetHeight(self.view.frame) - 44, 60, 44);
//    cancelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    [resetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resetBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
    resetBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [resetBtn addTarget:self action:@selector(resetBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
    
    UIButton *cropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cropBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    cropBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 60, CGRectGetHeight(self.view.frame) - 44, 60, 44);
    [cropBtn setTitle:@"完成" forState:UIControlStateNormal];
    [cropBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cropBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
    cropBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [cropBtn addTarget:self action:@selector(saveBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cropBtn];
}

- (void)resetBtnTapped
{
    [self.photoView resetBtnTapped:nil];
}

- (void)cancelBtnTapped
{
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
//    [self.delegate photoTweaksControllerDidCancel:self];
}

- (void)saveBtnTapped
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // translate
    CGPoint translation = [self.photoView photoTranslation];
    transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
    
    // rotate
    transform = CGAffineTransformRotate(transform, self.photoView.angle);
    
    // scale
    CGAffineTransform t = self.photoView.photoContentView.transform;
    CGFloat xScale =  sqrt(t.a * t.a + t.c * t.c);
    CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    transform = CGAffineTransformScale(transform, xScale, yScale);
    
    
    if (self.image.images.count > 0) {
        
        NSMutableArray *images = [NSMutableArray array];
        
        for (UIImage *image_ in self.image.images) {
            CGImageRef imageRef = [self newTransformedImage:transform
                                                sourceImage:image_.CGImage
                                                 sourceSize:image_.size
                                          sourceOrientation:image_.imageOrientation
                                                outputWidth:self.photoView.cropView.frame.size.width
                                                   cropSize:self.photoView.cropView.frame.size
                                              imageViewSize:self.photoView.photoContentView.bounds.size];
            [images addObject:[UIImage imageWithCGImage:imageRef scale:2.0 orientation:UIImageOrientationUp]];
        }
    
        UIImage *image = [UIImage animatedImageWithImages:images duration:self.image.duration];
        
        if (_delegate && [_delegate respondsToSelector:@selector(assetsPikerEditViewController:output:)]) {
            [self.delegate assetsPikerEditViewController:self output:image];
        }
    }
    else {
        CGImageRef imageRef = [self newTransformedImage:transform
                                            sourceImage:self.image.CGImage
                                             sourceSize:self.image.size
                                      sourceOrientation:self.image.imageOrientation
                                            outputWidth:self.photoView.cropView.frame.size.width
                                               cropSize:self.photoView.cropView.frame.size
                                          imageViewSize:self.photoView.photoContentView.bounds.size];
        
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        if (_delegate && [_delegate respondsToSelector:@selector(assetsPikerEditViewController:output:)]) {
            [self.delegate assetsPikerEditViewController:self output:image];
        }
    }
}

- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8,  //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst  //CGImageGetBitmapInfo(source)
                                                 );
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize
{
    CGImageRef source = [self newScaledImage:sourceImage
                             withOrientation:sourceOrientation
                                      toSize:sourceSize
                                 withQuality:kCGInterpolationMedium];
    
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width,
                                                            outputSize.height / cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       , source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return resultRef;
}


#pragma mark - Util
- (XWAssetsPikerViewController *)picker
{
    return (XWAssetsPikerViewController *)self.navigationController.parentViewController;
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
