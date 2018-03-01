//
//  LDPressButton.m
//  VideoTake
//
//  Created by zzg on 2018/2/28.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import "TakePressButton.h"



@interface TakePressButton ()
/* 计时时长 */
@property (nonatomic, assign) float  interval;

/* 中间圆心颜色 */
@property (nonatomic, strong) UIColor *  centerColor;
/* 圆环颜色 */
@property (nonatomic, strong) UIColor *  ringColor;
@property (nonatomic, strong) UIColor * progressColor;

@property (nonatomic, strong) CAShapeLayer * centerLayer;
@property (nonatomic, strong) CAShapeLayer * ringLayer;
@property (nonatomic, strong) CAShapeLayer * progressLayer;

@property (nonatomic, strong) CADisplayLink * link;

@property (nonatomic, assign) CGFloat  tempInterval;
@property (nonatomic, assign) CGFloat  progress;
@property (nonatomic, assign) BOOL  isTimeOut;
@property (nonatomic, assign) BOOL  isPressed;
@property (nonatomic, assign) BOOL  isCancel;
@property (nonatomic, assign) CGRect  ringFram;


@end

@implementation TakePressButton


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initView];
    }
    return self;
}
-(void)dealloc {
    [self.link invalidate];
}
-(void)initView {
    [self.layer addSublayer:self.ringLayer];
    [self.layer addSublayer:self.centerLayer];
    self.backgroundColor = [UIColor clearColor];
    UILongPressGestureRecognizer * lognPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self addGestureRecognizer:lognPress];
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self addGestureRecognizer:tap];
}
-(void)tapGesture {
    if (self.buttonAction) {
        self.buttonAction(Click);
    }
}

-(void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint  point = [gesture locationInView:self];
            BOOL isContains = CGRectContainsPoint(self.ringFram,point);
            if (isContains) {
                [self.link setPaused:NO];
                self.isPressed = YES;
                [self.layer addSublayer:self.progressLayer];
                if (self.buttonAction) {
                    self.buttonAction(Begin);
                }
            }
        }
        break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint  point = [gesture locationInView:self];
            BOOL isContains = CGRectContainsPoint(self.ringFram,point);
            if (isContains) {
                self.isCancel = NO;
                if (self.buttonAction) {
                    self.buttonAction(Moving);
                }
            }else {
                self.isCancel = YES;
                if (self.buttonAction) {
                    self.buttonAction(WillCancle);
                }
            }
        }
        break;
        case UIGestureRecognizerStateEnded:
        {
            [self stop];
            if (self.isCancel) {
                if (self.buttonAction) {
                    self.buttonAction(DidCancle);
                }
            }else if(self.isTimeOut == NO){
                if (self.buttonAction) {
                    self.buttonAction(End);
                }
            }
            self.isTimeOut = NO;
        }
        break;
            
        default:
            [self stop];
            self.isCancel = YES;
            if (self.buttonAction) {
                self.buttonAction(DidCancle);
            }
            break;
    }
    [self setNeedsDisplay];
}

-(void)linkRun {
    self.tempInterval += 1/60.0;
    self.progress = self.tempInterval/self.interval;
    
    if (self.tempInterval >= self.interval) {
        [self stop];
        self.isTimeOut = YES;
        if (self.buttonAction) {
            self.buttonAction(End);
        }
    }
    [self setNeedsDisplay];
}

-(void)stop {
    self.isPressed = NO;
    self.tempInterval = 0.0f;
    self.progress = 0;
    
    self.progressLayer.strokeEnd = 0;
    [self.progressLayer removeFromSuperlayer];
    [self.link setPaused:YES];
    [self setNeedsDisplay];
}

-(void)actionWithClosure:(actionState)closure{
    self.buttonAction = closure;
}


-(void)initData {
    self.interval = 10.0f;
    
    self.centerColor = [UIColor whiteColor];
    self.ringColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
    
    self.progressColor = [UIColor colorWithRed:31/255.0 green:185/255.0 blue:34/255.0 alpha:1];
    self.progressLayer.strokeColor = self.progressColor.CGColor;
    
    self.tempInterval = 0.0f;
    self.progress = 0.0f;
    self.isTimeOut = NO;
    self.isPressed =NO;
    self.isCancel = NO;
    self.ringFram = CGRectZero;
    
}

-(CAShapeLayer *)centerLayer {
    if (!_centerLayer) {
        _centerLayer = [[CAShapeLayer alloc] init];
        _centerLayer.frame = self.bounds;
        _centerLayer.fillColor = self.centerColor.CGColor;
    }
    return _centerLayer;
}

-(CAShapeLayer *)ringLayer {
    if (!_ringLayer) {
        _ringLayer = [[CAShapeLayer alloc] init];
        _ringLayer.frame = self.bounds;
        _ringLayer.fillColor = self.ringColor.CGColor;
    }
    return _ringLayer;
}
-(CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [[CAShapeLayer alloc] init];
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = self.progressColor.CGColor;
        _progressLayer.lineWidth = 4;
        _progressLayer.lineCap = kCALineCapRound;
    }
    return _progressLayer;
}

-(CADisplayLink *)link {
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkRun)];
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [_link setPaused:YES];
    }
    return _link;
}

-(void)setButtonAction:(actionState)buttonAction {
    _buttonAction = [buttonAction copy];
}


-(void)drawRect:(CGRect)rect {
//    [self releaseView];
    [self debugView];
}
-(void)debugView {
    CGFloat width = self.bounds.size.width;
    CGFloat mainWidth = width * 0.5;
    CGRect mainFrame = CGRectMake(mainWidth * 0.5, mainWidth * 0.5 , mainWidth, mainWidth);
    CGRect ringFrame = CGRectInset(mainFrame,-0.4 * mainWidth / 2.0,-0.4 * mainWidth / 2.0);
    self.ringFram = ringFrame;
    if (self.isPressed) {
        ringFrame = CGRectInset(mainFrame,-0.6*mainWidth/2.0,-0.6 * mainWidth/2.0);
    }
    UIBezierPath * ringPath = [UIBezierPath bezierPathWithRoundedRect:ringFrame cornerRadius:ringFrame.size.width / 2.0];
    self.ringLayer.path = ringPath.CGPath;
    if (self.isPressed) {
        mainWidth *= 0.8;
        mainFrame = CGRectMake((width - mainWidth) * 0.5, (width - mainWidth) * 0.5, mainWidth, mainWidth);
    }
    UIBezierPath * mainPath = [UIBezierPath bezierPathWithRoundedRect:mainFrame cornerRadius:mainWidth * 0.5];
    self.centerLayer.path = mainPath.CGPath;
    
    if (self.isPressed) {
        CGRect progressFrame = CGRectInset(ringFrame,2.0,2.0);
        UIBezierPath * progressPath = [UIBezierPath bezierPathWithRoundedRect:progressFrame cornerRadius:progressFrame.size.width * 0.5];
        self.progressLayer.path = progressPath.CGPath;
        self.progressLayer.strokeEnd = self.progress;
    }
}


-(void)releaseView {
    CGFloat width = self.bounds.size.width;
    CGFloat mainWidth = width * 0.5;
    CGRect mainFrame = CGRectMake(mainWidth * 0.5, mainWidth * 0.5 , mainWidth, mainWidth);
    CGRect ringFrame = CGRectInset(mainFrame,-0.2 * mainWidth / 2.0,-0.2 * mainWidth / 2.0);
    self.ringFram = ringFrame;
    if (self.isPressed) {
        ringFrame = CGRectInset(mainFrame,-0.4*mainWidth/2.0,-0.4 * mainWidth/2.0);
    }
    UIBezierPath * ringPath = [UIBezierPath bezierPathWithRoundedRect:ringFrame cornerRadius:ringFrame.size.width / 2.0];
    self.ringLayer.path = ringPath.CGPath;
    if (self.isPressed) {
        mainWidth *= 0.8;
        mainFrame = CGRectMake((width - mainWidth) * 0.5, (width - mainWidth) * 0.5, mainWidth, mainWidth);
    }
    UIBezierPath * mainPath = [UIBezierPath bezierPathWithRoundedRect:mainFrame cornerRadius:mainWidth * 0.5];
    self.centerLayer.path = mainPath.CGPath;
    
    if (self.isPressed) {
        CGRect progressFrame = CGRectInset(ringFrame,2.0,2.0);
        UIBezierPath * progressPath = [UIBezierPath bezierPathWithRoundedRect:progressFrame cornerRadius:progressFrame.size.width * 0.5];
        self.progressLayer.path = progressPath.CGPath;
        self.progressLayer.strokeEnd = self.progress;
    }
}


@end
