//
//  RecordToolBar.h
//  VideoTake
//
//  Created by zzg on 2018/3/5.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TakePressButton.h"

@protocol RecordToolBarDelegate<NSObject>

/**
 重新拍摄
 */
- (void)reMakeVideo;

/**
 完成拍摄
 */
- (void)finishTakeVideo;
@end

typedef void(^actionState)(LDPressButtonState state);

@interface RecordToolBar : UIView

@property (nonatomic, copy) actionState  buttonAction;

@property (nonatomic, weak) id<RecordToolBarDelegate>  delegate;

@end
