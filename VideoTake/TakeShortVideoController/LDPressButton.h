//
//  LDPressButton.h
//  VideoTake
//
//  Created by zzg on 2018/2/28.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    White,
    Gray,
    Black,
} LDPressButtonStyle;


typedef enum : NSUInteger {
    Begin,
    Moving,
    WillCancle,
    DidCancle,
    End,
    Click
} LDPressButtonState;


typedef void(^actionState)(LDPressButtonState state);


@interface LDPressButton : UIView
@property (nonatomic, copy) actionState  buttonAction;
@end
