//
//  PressButton.m
//  VideoTake
//
//  Created by zzg on 2018/2/26.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import "PressButton.h"

@interface PressButton()
/* 背景层 */
@property (nonatomic, strong) CAShapeLayer * maskShapLayer;
/* 按钮层 */
@property (nonatomic, strong) CAShapeLayer * pressShapLayer;


@property (nonatomic, strong) UIView * maskShapView;
@property (nonatomic, strong) UIView * pressShapView;


@property (nonatomic, strong) UIView * redView;
@end

@implementation PressButton

-(CAShapeLayer *)maskShapLayer {
    if (!_maskShapLayer) {
        _maskShapLayer = [CAShapeLayer layer];
        _maskShapLayer.fillColor = [UIColor redColor].CGColor;
    }
    return _maskShapLayer;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

-(void)initView {
    self.backgroundColor = [UIColor lightGrayColor];
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressClick:)];
    [self addGestureRecognizer:longPress];
    
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:view];
    
    self.redView = view;
}

-(void)longPressClick:(UILongPressGestureRecognizer *)gestureRecognizer {
    NSLog(@"-----------%ld",gestureRecognizer.state);
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self setupStateBeginState];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self setNeedsDisplay];
        }
            break;
            
        default:
            break;
    }
}

-(void)drawRect:(CGRect)rect {
    self.maskShapView = [[UIView alloc] init];
    self.maskShapView.center = self.center;
    self.maskShapView.layer.cornerRadius = 50;
    self.maskShapView.layer.masksToBounds = YES;
    self.maskShapView.backgroundColor = [UIColor whiteColor];
    self.maskShapView.bounds = CGRectMake(0, 0, 100, 100);
    [self addSubview:self.maskShapView];
    
    self.pressShapView = [[UIView alloc] init];
    self.pressShapView.center = self.maskShapView.center;
    self.pressShapView.layer.cornerRadius = 30;
    self.pressShapView.layer.masksToBounds = YES;
    self.pressShapView.backgroundColor = [UIColor greenColor];
    self.pressShapView.bounds = CGRectMake(0, 0, 60, 60);
    [self addSubview:self.pressShapView];
    
    
    
    //    // 按钮背景
    //    UIBezierPath * maskBezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(200, 200) radius:40 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    //    CAShapeLayer *  maskShapLayer = [CAShapeLayer layer];
    //    maskShapLayer.backgroundColor = [UIColor clearColor].CGColor;
    //    maskShapLayer.path = maskBezier.CGPath;
    //    maskShapLayer.fillColor = [UIColor whiteColor].CGColor;
    //    [self.layer addSublayer:maskShapLayer];
    //    self.maskShapLayer = maskShapLayer;
    //
    //
    //    //  按钮
    //    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(200, 200) radius:30 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    //    CAShapeLayer *  pressShapLayer = [CAShapeLayer layer];
    //    pressShapLayer.backgroundColor = [UIColor clearColor].CGColor;
    //    pressShapLayer.path = bezierPath.CGPath;
    //    pressShapLayer.fillColor = [UIColor greenColor].CGColor;
    //    [self.layer addSublayer:pressShapLayer];
    //    self.pressShapLayer = pressShapLayer;
}

/**
 设置点击开始视图状态
 */
-(void)setupStateBeginState {
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @(1);
    scale.toValue = @(1.2);
    scale.autoreverses = YES;
    scale.duration = 3;
    [self.maskShapView.layer addAnimation:scale forKey:@"mask"];
    
    
    
    CGFloat between = 5.0;
    CGFloat radius = (100-2*between)/3;
    
    //    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    //    shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(200, 200, 50, 50)].CGPath;
    //    shapeLayer.fillColor = [UIColor redColor].CGColor;
    //
    //
    //    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //    scale.fromValue = @(1);
    //    scale.toValue = @(10);
    //    scale.autoreverses = YES;
    //    scale.repeatCount = HUGE;
    //    scale.duration = 0.6;
    ////
    //
    //    [shapeLayer addAnimation:scale forKey:@"scaleAnimation"];
    //    [self.layer addSublayer:shapeLayer];
    
    
    
    //使用CABasicAnimation创建基础动画
    //    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //
    //    anima.toValue = @0.5;
    //    anima.duration = 1.0f;
    //    //anima.fillMode = kCAFillModeForwards;
    //    //anima.removedOnCompletion = NO;
    //    [self.maskShapLayer addAnimation:anima forKey:@"positionAnimation"];
    
    
    //    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    //    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.redView.bounds];
    //    shapeLayer.path = path.CGPath;
    //    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    //    shapeLayer.lineWidth = 4.0f;
    //    shapeLayer.strokeStart = 0.1f;
    //    shapeLayer.strokeEnd = 0.7f;
    //    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    //    [self.redView.layer addSublayer:shapeLayer];
    //
    //    CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    //    pathAnima.duration = 3.0f;
    //    pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    pathAnima.fromValue = [NSNumber numberWithFloat:0.0f];
    //    pathAnima.toValue = [NSNumber numberWithFloat:1.0f];
    //    pathAnima.fillMode = kCAFillModeForwards;
    //    pathAnima.removedOnCompletion = NO;
    //    [shapeLayer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
    
    
    
    //    CALayer  * layer = [self replicatorLayer_Wave];
    //    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    //    [self addSubview:view];
    //    [view.layer addSublayer:layer];
    
    //    self.pressShapLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(200, 200) radius:30 startAngle:0 endAngle:M_PI * 2 clockwise:YES] .CGPath;
    //    CABasicAnimation *pressAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    //    pressAnimation.fromValue = @0;
    //    pressAnimation.duration = .25f;
    //    pressAnimation.repeatCount = 0;
    //    [pressAnimation setValue:@"BasicAnimationEnd" forKey:@"animationName"];
    //    [self.pressShapLayer addAnimation:animation forKey:@"BasicAnimationEnd"];
}

// 波动动画
- (CALayer *)replicatorLayer_Wave{
    CGFloat between = 5.0;
    CGFloat radius = (100-2*between)/3;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = CGRectMake(0, (100-radius)/2, radius, radius);
    shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)].CGPath;
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    [shapeLayer addAnimation:[self scaleAnimation1] forKey:@"scaleAnimation"];
    
    return shapeLayer;
    
    //    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    //    replicatorLayer.frame = CGRectMake(0, 0, 100, 100);
    //    replicatorLayer.instanceDelay = 0.2;
    //    replicatorLayer.instanceCount = 3;
    //    replicatorLayer.instanceTransform = CATransform3DMakeTranslation(between*2+radius,0,0);
    //    [replicatorLayer addSublayer:shapeLayer];
    
    //    return replicatorLayer;
}


- (CABasicAnimation *)scaleAnimation1{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //scale.fromValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0.0)];
    //scale.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 0.2, 0.2, 0.0)];
    scale.fromValue = @(1);
    scale.toValue = @(20);
    scale.autoreverses = YES;
    scale.repeatCount = HUGE;
    scale.duration = 0.6;
    return scale;
}

@end

