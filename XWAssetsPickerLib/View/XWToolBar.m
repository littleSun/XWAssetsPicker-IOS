//
//  XWToolBar.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import "XWToolBar.h"
#import "XWAssetsPikerViewController.h"

@interface XWToolBar()

@property (nonatomic ,strong) UIBarButtonItem *sendItem;

@property (nonatomic ,strong) UIBarButtonItem *previewItem;

@property (nonatomic ,strong) UIBarButtonItem *labelItem;

@property (nonatomic ,strong) UIBarButtonItem *fixItem;

@end

@implementation XWToolBar

- (id)initWithFrame:(CGRect)frame andPicker:(XWAssetsPikerViewController *)picker
{
    if (self = [super initWithFrame:frame]) {
        self.picker = picker;
        self.backgroundColor = [UIColor whiteColor];
        
        [self setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny                      barMetrics:UIBarMetricsDefault];

        self.clipsToBounds = YES;
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
    }
    return self;
}

- (UIBarButtonItem *)previewItem
{
    if (!_previewItem) {
        _previewItem = [self createBarButtonWithTitle:PREVIEW_BTN_TITLE andColor:self.picker.assetColor andImage:nil andTag:100];
        self.previewBtn = (UIButton *)_previewItem.customView;
    }
    return _previewItem;
}

- (UIBarButtonItem *)labelItem
{
    if (!_labelItem) {
        _recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        _recordLabel.font = [UIFont systemFontOfSize:15];
        _recordLabel.textColor = [UIColor blackColor];
        _labelItem = [[UIBarButtonItem alloc] initWithCustomView:self.recordLabel];
    }
    return _labelItem;
}

- (UIBarButtonItem *)fixItem
{
    if (!_fixItem) {
        _fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:NULL];
    }
    return _fixItem;
}

- (UIBarButtonItem *)sendItem
{
    if (!_sendItem) {
        
        _sendItem = [self createBarButtonWithTitle:SEND_BTN_TITLE andColor:self.picker.assetColor andImage:nil andTag:101];
        
        UIButton *sendBtn = (UIButton *)_sendItem.customView;
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    }
    return _sendItem;
}

#pragma mark -- ButtonEvent
- (void)buttonClick:(UIButton *)sender
{
    if (sender.tag == 100) {
        if (_tbdelegate && [_tbdelegate respondsToSelector:@selector(toolbarPreview:)]) {
            [self.tbdelegate toolbarPreview:self];
        }
    }
    else if (sender.tag == 101) {
        if (_tbdelegate && [_tbdelegate respondsToSelector:@selector(toolbarSend:)]) {
            [self.tbdelegate toolbarSend:self];
        }
    }
}

#pragma mark -- Util
- (UIBarButtonItem *)createBarButtonWithTitle:(NSString *)title andColor:(UIColor *)color  andImage:(UIImage *)image andTag:(NSInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 30);
    button.tag = tag;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:title forState:UIControlStateNormal];
    
    if (color) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }

    if (image) {
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setBackgroundImage:image forState:UIControlStateHighlighted];
    }
    else {
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
    
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return item;
}


- (void)setupToolBar:(BOOL)isShow
{
    NSMutableArray *myToolBarItems = [NSMutableArray array];
    if (isShow) {
        [myToolBarItems addObject:self.previewItem];
    }
    [myToolBarItems addObject:self.labelItem];
    [myToolBarItems addObject:self.fixItem];
    [myToolBarItems addObject:self.sendItem];
    
    self.previewItem.enabled = NO;
    self.sendItem.enabled = NO;
    
    [self setItems:myToolBarItems animated:NO];
}

- (void)setActionEnable:(BOOL)actionEnable
{
    _actionEnable = actionEnable;
    
    if (actionEnable) {
        self.previewItem.enabled = YES;
        self.sendItem.enabled = YES;
    }
    else {
        self.previewItem.enabled = NO;
        self.sendItem.enabled = NO;
    }
}

@end
