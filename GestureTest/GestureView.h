//
//  GestureView.h
//  GestureTest
//
//  Created by mac on 17/5/23.
//  Copyright © 2017年 cai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GestureView;

@protocol GestureViewDelegate <NSObject>

- (BOOL)gestureViewCheckPassword:(GestureView *)gestureView password:(NSString *)password;

@end

@interface GestureView : UIView

@property (nonatomic, weak) id<GestureViewDelegate> delegate;

@end
