//
//  XWAssetScrollView.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "XWAssetScrollView.h"
#import "ALAsset+assetType.h"
#import "ALAsset+accessibilityLabel.h"
#import "UIImage+created.h"
#import <AVFoundation/AVFoundation.h>

//NSString * const CTAssetScrollViewTappedNotification = @"CTAssetScrollViewTappedNotification";



@interface XWAssetScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, assign) CGSize        imageSize;

@property (nonatomic, assign) CGPoint       pointToCenterAfterResize;
@property (nonatomic, assign) CGFloat       scaleToRestoreAfterResize;

@property (nonatomic, strong) UIButton                  *playButton;
@property (nonatomic, strong) MPMoviePlayerController   *player;

@end

@implementation XWAssetScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.showsVerticalScrollIndicator   = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom                    = YES;
        self.decelerationRate               = UIScrollViewDecelerationRateFast;
        self.delegate                       = self;
        
//        [self addNotificationObserver];        
    }
    
    return self;
}

- (void)dealloc
{
    [self removeNotificationObserver];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize       = self.bounds.size;
    CGRect frameToCenter    = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame    = frameToCenter;
    self.player.view.frame  = frameToCenter;
}

- (void)setIndex:(NSUInteger)index
{
    _index = index;
    [self displayImageAtIndex:index];

}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging)
        [self prepareToResize];
    
    [super setFrame:frame];
    
    if (sizeChanging)
        [self recoverFromResizing];
}



#pragma mark - Notification Observer

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    
    if (_player) {
//        [center addObserver:self
//                   selector:@selector(playbackStateDidChange:)
//                       name:MPMoviePlayerPlaybackDidFinishNotification
//                     object:_player];
        
        [center addObserver:self
                   selector:@selector(playbackDidFinish:)
                       name:MPMoviePlayerPlaybackDidFinishNotification
                     object:_player];
        
        [center addObserver:self
                   selector:@selector(playerWillExitFullscreen:)
                       name:MPMoviePlayerWillExitFullscreenNotification
                     object:_player];
        
        [center addObserver:self
                   selector:@selector(playerDidExitFullscreen:)
                       name:MPMoviePlayerDidExitFullscreenNotification
                     object:_player];
    }

}

- (void)removeNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

//    [center removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [center removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [center removeObserver:self name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [center removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
}



#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}



#pragma mark - Configure scrollView to display new image

- (void)displayImageAtIndex:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(assetAtIndex:)])
    {
        // scale image properly
        ALAsset *asset = [self.dataSource assetAtIndex:index];
        CGFloat scale  = ([asset isVideo]) ? 0.5f : 1.0f;
        
        UIImage *image;
        
        if (asset.defaultRepresentation)
        {
            image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:scale
                                  orientation:UIImageOrientationUp];
        }
        
        // clear the previous image
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        
        // reset our zoomScale to 1.0 before doing any further calculations
        self.zoomScale = 1.0;
        
        // make a new UIImageView for the new image
        self.imageView = [[UIImageView alloc] initWithImage:image];
        
        self.imageView.isAccessibilityElement   = YES;
        self.imageView.accessibilityTraits      = UIAccessibilityTraitImage;
        self.imageView.accessibilityLabel       = asset.accessibilityLabel;
        self.imageView.tag                      = 1;
        
        [self addSubview:self.imageView];        
        [self configureForImageSize:image.size];
        
        if ([asset isVideo])
            [self addVideoPlayButton];
        else
            [self addGestureRecognizers];
    }
}


- (void)configureForImageSize:(CGSize)imageSize
{
    self.imageSize      = imageSize;
    self.contentSize    = imageSize;
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
    self.zoomScale      = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    
    CGFloat xScale = boundsSize.width  / self.imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / self.imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    CGFloat minScale = MIN(xScale, yScale);
    CGFloat maxScale = 2.0 * minScale;
    
    ALAsset *asset = [self.dataSource assetAtIndex:self.index];
    
    if ([asset isVideo] || !asset.defaultRepresentation)
    {
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = minScale;
    }
    
    else
    {
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = maxScale;
    }
}



#pragma mark - Rotation support

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.pointToCenterAfterResize = [self convertPoint:boundsCenter toView:self.imageView];
    
    self.scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (self.scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        self.scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, self.scaleToRestoreAfterResize));
    
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:self.pointToCenterAfterResize fromView:self.imageView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}



#pragma mark - Gesture Recognizer

- (void)addGestureRecognizers
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapping:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapping:)];
    
    [doubleTap setNumberOfTapsRequired:2.0];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:doubleTap];
}



#pragma mark - Handle Tapping

- (void)handleTapping:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.numberOfTapsRequired == 1) {
        //
        if (_adelegate && [_adelegate respondsToSelector:@selector(xwAssetScrollViewTap:)]) {
            [self.adelegate xwAssetScrollViewTap:self];
        }
        
    }
    else if (recognizer.numberOfTapsRequired == 2) {
     
        [self toggleZooming:recognizer];
    }
}



#pragma mark - Toggle Zooming

- (void)toggleZooming:(UITapGestureRecognizer *)recognizer
{
    if (self.minimumZoomScale == self.maximumZoomScale)
    {
        return;
    }
    else if (self.zoomScale > self.minimumZoomScale)
    {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else
    {
        CGRect zoomRect =
        [self zoomRectWithScale:self.maximumZoomScale
                     withCenter:[recognizer locationInView:recognizer.view]];
        
        [self zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectWithScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [self.imageView frame].size.height / scale;
    zoomRect.size.width  = [self.imageView frame].size.width  / scale;
    
    center = [self.imageView convertPoint:center fromView:self];
    
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}



#pragma mark - Video Player

- (void)createVideoPlayer
{
    ALAsset *asset = [self.dataSource assetAtIndex:self.index];
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:asset.defaultRepresentation.url];
    self.player.controlStyle    = MPMovieControlStyleFullscreen;
    self.player.shouldAutoplay  = NO;

    [self addNotificationObserver];
    
    [self insertSubview:self.player.view belowSubview:self.imageView];
    [self layoutIfNeeded];
}


- (void)addVideoPlayButton
{
    UIImage *image   = [UIImage imageFromBundle:@"asset_videoplay_btn"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, ([UIScreen mainScreen].bounds.size.height-[UIScreen mainScreen].bounds.size.width+200)*0.5, [UIScreen mainScreen].bounds.size.width-200, [UIScreen mainScreen].bounds.size.width-200);
//    button.center = self.center;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    
//    button.accessibilityLabel = @"播放";
//    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.playButton = button;
    
    [self addSubview:self.playButton];
}



#pragma mark - Play Video

- (void)playVideo:(id)sender
{
    if (!self.player)
        [self createVideoPlayer];

    [self.player setControlStyle:MPMovieControlStyleFullscreen];
    [self.player setFullscreen:YES animated:YES];
    [self.player prepareToPlay];
    [self.player play];
}



#pragma mark - Notifications

- (void)playbackStateDidChange:(NSNotification *)notification
{
//    [self.player.view removeFromSuperview];
//    self.player = nil;
//    [self sendSubviewToBack:self.imageView];
//    [self bringSubviewToFront:self.playButton];
}

- (void)playbackDidFinish:(NSNotification *)notification
{
    MPMoviePlayerController *player = notification.object;
    [player setFullscreen:NO animated:YES];
    

}

- (void)playerWillExitFullscreen:(NSNotification *)notification
{
    MPMoviePlayerController *player = notification.object;
    [player setControlStyle:MPMovieControlStyleNone];

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:player.contentURL options:nil];
    
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CFTimeInterval thumbnailImageTime = player.currentPlaybackTime;
    NSError *thumbnailImageGenerationError = nil;
    CGImageRef thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(thumbnailImageTime, NSEC_PER_SEC) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [UIImage imageWithCGImage:thumbnailImageRef] : nil;
    
    if (thumbnailImageRef) {
        CGImageRelease(thumbnailImageRef);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        //
        self.imageView.image = thumbnailImage;
    });

}

- (void)playerDidExitFullscreen:(NSNotification *)notification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [center removeObserver:self name:MPMoviePlayerWillExitFullscreenNotification object:self.player];
    [center removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:self.player];
    
    [self.player.view removeFromSuperview];
    self.player = nil;
}

@end
