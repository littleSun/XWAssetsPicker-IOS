//
//  XWPhotoEditView.h
//  XWAssetsPicker
//
//  Created by zengchao on 15/12/8.
//  Copyright © 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CropView;

@interface PhotoContentView : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@end

@protocol CropViewDelegate <NSObject>

- (void)cropEnded:(CropView *)cropView;
- (void)cropMoved:(CropView *)cropView;

@end

@interface CropView : UIView
@end

@interface XWPhotoEditView : UIView

@property (assign, nonatomic) CGFloat angle;
@property (strong, nonatomic) PhotoContentView *photoContentView;
//@property (assign, nonatomic) CGPoint photoContentOffset;
@property (strong, nonatomic) CropView *cropView;
@property (strong, nonatomic) UIColor *themeColor;
@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) CGPoint originalPoint;
//@property (nonatomic, strong, readonly) UISlider *slider;
//@property (nonatomic, strong, readonly) UIButton *resetBtn;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (CGPoint)photoTranslation;

- (void)resetBtnTapped:(id)sender;

@end

