//
//  RecordToolBar.m
//  VideoTake
//
//  Created by zzg on 2018/3/5.
//  Copyright © 2018年 zzg. All rights reserved.
//

// 屏幕宽高
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define C_TRANSFER_FORCE(x) rintf((x) * SCREEN_WIDTH / 750)
#define C_TRANSFER(x) ((SCREEN_WIDTH>320)?((x)/2):rintf((x) * SCREEN_WIDTH / 750))

#import "RecordToolBar.h"
@interface RecordToolBar()
@property (nonatomic, strong) TakePressButton * press;

@property (strong, nonatomic) UIButton *dismissButton;//取消拍摄
@property (strong, nonatomic) UIButton *reMakeButton;//重新拍摄
@property (strong, nonatomic) UIButton *doneButton;//完成拍摄

@end

@implementation RecordToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    CGFloat pW = 100;
    CGFloat pH = 100;
    CGFloat pX = self.bounds.size.width * 0.5 - pW * 0.5;
    CGFloat pY = self.bounds.size.height * 0.5 - pH * 0.5;
    
    self.press = [[TakePressButton alloc] initWithFrame:CGRectMake(pX, pY, pW, pH)];
    self.press.backgroundColor = [UIColor redColor];
    [self addSubview:self.press];
    __weak typeof(self) WeakSelf = self;
    [self.press setButtonAction:^(LDPressButtonState state) {
        if (WeakSelf.buttonAction) {
            WeakSelf.buttonAction(state);
        }
        if (End == state || DidCancle == state) {
            [WeakSelf onActiondone];
        }
    }];
}


/**
 结束录制弹出两侧按钮
 */
- (void)onActiondone {
    self.press.hidden = YES;

    [UIView animateWithDuration:0.25 animations:^{
        self.reMakeButton.alpha = 1;
        self.reMakeButton.center = CGPointMake(SCREEN_WIDTH/4, _press.center.y);

        self.doneButton.alpha = 1;
        self.doneButton.center = CGPointMake(SCREEN_WIDTH*3/4, _press.center.y);
    } completion:^(BOOL finished) {

    }];
}

#pragma amrk - 撤销操作
- (void)reMakeButtonClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(reMakeVideo)]) {
        [self.delegate reMakeVideo];
    }
    _press.hidden = NO;
    _dismissButton.hidden = NO;
    _reMakeButton.alpha = 0;
    _reMakeButton.center = _press.center;
    _doneButton.alpha = 0;
    _doneButton.center = _press.center;
    _doneButton.userInteractionEnabled = YES;
}


- (void)doneButtonClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishTakeVideo)]) {
        [self.delegate finishTakeVideo];
    }
    _doneButton.userInteractionEnabled = NO;
}


-(void)setButtonAction:(actionState)buttonAction {
    _buttonAction = [buttonAction copy];
}


#pragma mark -- property
- (UIButton *)reMakeButton {
    if (!_reMakeButton) {
        _reMakeButton = [[UIButton alloc] initWithFrame:
                         CGRectMake(_press.center.x - C_TRANSFER(130)/2,
                                    _press.center.y - C_TRANSFER(130)/2,
                                    C_TRANSFER(130),
                                    C_TRANSFER(130))];
        [_reMakeButton setBackgroundImage:[UIImage imageNamed:@"take_retry"]
                                 forState:UIControlStateNormal];
        _reMakeButton.alpha = 0;
        [_reMakeButton addTarget:self
                          action:@selector(reMakeButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_reMakeButton];
    }
    return _reMakeButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] initWithFrame:
                       CGRectMake(_press.center.x - C_TRANSFER(130)/2,
                                  _press.center.y - C_TRANSFER(130)/2,
                                  C_TRANSFER(130),
                                  C_TRANSFER(130))];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"take_done"]
                               forState:UIControlStateNormal];
        _doneButton.center = _press.center;
        _doneButton.alpha = 0;
        [_doneButton addTarget:self
                        action:@selector(doneButtonClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_doneButton];
    }
    return _doneButton;
}

@end
