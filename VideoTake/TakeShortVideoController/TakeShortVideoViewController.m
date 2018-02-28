//
//  TakeShortVideoViewController.m
//  VideoTake
//
//  Created by zzg on 2018/2/26.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import "TakeShortVideoViewController.h"
#import "PressButton.h"
#import "LDPressButton.h"

@interface TakeShortVideoViewController ()
@property (nonatomic, strong) CAShapeLayer * presButtonLayer;


@end

@implementation TakeShortVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = @"拍摄短视频";
    
    LDPressButton * press = [[LDPressButton alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    [self.view addSubview:press];
    [press setButtonAction:^(LDPressButtonState state) {
        switch (state) {
            case Begin:
                NSLog(@"-------begin");
                break;
            case Moving:
                NSLog(@"-------moving");
                break;
            case WillCancle:
                NSLog(@"-------WillCancle");
                break;
            case DidCancle:
                NSLog(@"-------DidCancle");
                break;
            case End:
                NSLog(@"-------End");
                break;
            case Click:
                NSLog(@"-------Click");
                break;
            default:
                break;
        }
    }];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self dractFunc];
//    [self takeRecodeButton];
    
    
    
}
- (void)takeRecodeButton {
    
}




-(void)dractFunc {
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:self.view.center radius:100 startAngle: - M_PI_2 endAngle:M_PI * 2 clockwise:YES];
   CAShapeLayer *  maskLayer = [CAShapeLayer layer];
    maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    maskLayer.path = bezierPath.CGPath;
    maskLayer.strokeColor = [UIColor greenColor].CGColor;
    maskLayer.fillColor = [UIColor whiteColor].CGColor;
    maskLayer.lineWidth = 20;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.lineCap = kCALineCapRound;
    [self.view.layer addSublayer:maskLayer];
    

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @0.0;
    animation.duration = 2.0f;
    animation.repeatCount = 0;
    [animation setValue:@"BasicAnimationEnd" forKey:@"animationName"];
    [maskLayer addAnimation:animation forKey:@"BasicAnimationEnd"];
}


@end

