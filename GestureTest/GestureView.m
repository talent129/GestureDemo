//
//  GestureView.m
//  GestureTest
//
//  Created by mac on 17/5/23.
//  Copyright © 2017年 cai. All rights reserved.
//

#import "GestureView.h"

@interface GestureView ()

//保存所有按钮
@property (nonatomic, strong) NSArray *buttons;

//保存所有碰过的按钮
@property (nonatomic, strong) NSMutableArray *selectedButtons;

//线条颜色
@property (nonatomic, strong) UIColor *lineColor;

//记录当前触摸点
@property (nonatomic, assign) CGPoint current_point;

@end

@implementation GestureView

#pragma mark -懒加载
- (NSArray *)buttons
{
    if (_buttons == nil) {
        
        NSMutableArray *mArr = [NSMutableArray array];
        //创建9个按钮
        for (int i = 0; i < 9; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.layer.cornerRadius = 30;
            btn.layer.masksToBounds = YES;
            
            //为每个按钮加tag值
            btn.tag = i;
            
            //不允许交互事件 否则点击按钮时 响应事件不会传给view 则不会响应touchesBegan方法
            btn.userInteractionEnabled = NO;
            
            /*
             setBackgroundImage:
                image会随着button的大小而改变，图片自动会拉伸来适应button的大小
             setImage:
                图片不会进行拉伸，原比例的显示在button上
             */
            
            //默认状态
            [btn setBackgroundImage:[UIImage imageNamed:@"normal"] forState:UIControlStateNormal];

            //选中状态
            [btn setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateSelected];
            
            //禁用状态
            [btn setBackgroundImage:[UIImage imageNamed:@"error"] forState:UIControlStateDisabled];
            
            [self addSubview:btn];
            
            [mArr addObject:btn];
        }
        
        _buttons = mArr.copy;
    }
    return _buttons;
}

- (NSMutableArray *)selectedButtons
{
    if (!_selectedButtons) {
        _selectedButtons = [NSMutableArray array];
    }
    return _selectedButtons;
}

- (UIColor *)lineColor
{
    if (_lineColor == nil) {
        _lineColor = [UIColor greenColor];
    }
    return _lineColor;
}

#pragma mark -重写layoutSubviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //设置一个按钮大小
    CGFloat buttonWidth = 60;
    CGFloat buttonHeight = buttonWidth;
    
    int columns = 3;
    
    CGFloat margin = (self.bounds.size.width - columns * buttonWidth) / (columns - 1);
    
    //设置每个按钮的frame
    //这里调用了懒加载
    for (int i = 0; i < self.buttons.count; i ++) {
        
        UIButton *btn = self.buttons[i];
        btn.backgroundColor = [UIColor redColor];
        //计算每个按钮的行索引和列索引
        int col_idx = i % columns;
        int row_idx = i / columns;
        
        //设置每个按钮的frame
        CGFloat buttonX = col_idx * (buttonWidth + margin);
        CGFloat buttonY = row_idx * (buttonHeight + margin);
        
        btn.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
    
}

//触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //获取当前按下的点
//    UITouch *touch = touches.anyObject;
//    CGPoint point = [touch locationInView:touch.view];
    CGPoint point = [self pointWithTouches:touches.anyObject];
    
    //循环9个按钮  判断当前点在哪个按钮范围之内
//    for (UIButton *btn in self.buttons) {
//        //判断某个点是否在某个按钮的frame之内
//        if (CGRectContainsPoint(btn.frame, point) && !btn.isSelected) {
//            [self.selectedButtons addObject:btn];
//            btn.selected = YES;
//            break;
//        }
//    }
    [self checkCurrentPointWithPoint:point];
}

//移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //获取当前按下的点
//    UITouch *touch = touches.anyObject;
//    CGPoint point = [touch locationInView:touch.view];
    CGPoint point = [self pointWithTouches:touches.anyObject];
    
    //当前用户触摸点
    self.current_point = point;
    
    //循环9个按钮  判断当前点在哪个按钮范围之内
//    for (UIButton *btn in self.buttons) {
//        //判断某个点是否在某个按钮的frame之内
//        if (CGRectContainsPoint(btn.frame, point) && !btn.isSelected) {
//            
//            [self.selectedButtons addObject:btn];
//            btn.selected = YES;
//            break;
//        }
//    }
    [self checkCurrentPointWithPoint:point];
    
    //重绘
    [self setNeedsDisplay];
}

//返回point
- (CGPoint)pointWithTouches:(UITouch *)touch
{
    return [touch locationInView:touch.view];
}

//循环9个按钮  判断当前点在哪个按钮范围之内
- (void)checkCurrentPointWithPoint:(CGPoint)point
{
    for (UIButton *btn in self.buttons) {
        //判断某个点是否在某个按钮的frame之内
        if (CGRectContainsPoint(btn.frame, point) && !btn.isSelected) {
            
            [self.selectedButtons addObject:btn];
            btn.selected = YES;
            break;
        }
    }
}

//手指抬起 -
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //防止出错后 无法让current point 变成最后一个按钮的中心点
    self.current_point = [[self.selectedButtons lastObject] center];
    
    //判断用户绘制的密码是否正确
    //获取用户绘制的密码
    NSMutableString *password = [NSMutableString string];
    for (UIButton *btn in self.selectedButtons) {
        [password appendFormat:@"%@", @(btn.tag)];
    }
    NSLog(@"password: %@", password);
    
    //判断用户密码是否正确 密码需要在控制器中得到
    BOOL pwdBool = NO;
    if ([self.delegate respondsToSelector:@selector(gestureViewCheckPassword:password:)]) {
        NSLog(@"--password: %@", password);
        pwdBool = [self.delegate gestureViewCheckPassword:self password:password];
    }
    
    if (pwdBool) {
        //密码正确
        [self clearUnlockView];
    }else {
        //密码错误
        NSLog(@"密码错误");
        
        //否则快速操作 还能绘制
        self.userInteractionEnabled = NO;
        
        //设置线条颜色为红色
        self.lineColor = [UIColor redColor];
        
        //设置所有选中按钮的状态为disabled状态
        for (UIButton *btn in self.selectedButtons) {
            btn.selected = NO;
            btn.enabled = NO;
        }
        
        //重绘
        [self setNeedsDisplay];
        
        //保持0.5秒后消失
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self clearUnlockView];
            self.userInteractionEnabled = YES;
        });
    }
}

//让clearUnlockView回到默认状态
- (void)clearUnlockView
{
    //把所有的选中按钮的状态变为NO
    for (UIButton *btn in self.selectedButtons) {
        btn.selected = NO;
        btn.enabled = YES;
    }
    
    self.lineColor = nil;
    
    //将self.selectedButtons所有按钮清空
    [self.selectedButtons removeAllObjects];
    
    //    self.current_point = [[self.selectedButtons lastObject] center];
    
    //重绘
    [self setNeedsDisplay];
}

//重写drawRect: 方法 --画线
- (void)drawRect:(CGRect)rect
{
    //如果没有选中的按钮 不需要绘图
    if (self.selectedButtons.count == 0) {
        return;
    }
    
    //获取上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    //绘制路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //循环所有选中的按钮
    for (int i = 0; i < self.selectedButtons.count; i ++) {
        UIButton *btn = self.selectedButtons[i];
        if (i == 0) {
            [path moveToPoint:btn.center];
        }else {
            [path addLineToPoint:btn.center];
        }
    }
    
    //还未到达下一个点之前 显示的线(小尾巴)
    [path addLineToPoint:self.current_point];
    
    //把路径添加到上下文中
    CGContextAddPath(ref, path.CGPath);
    
    //设置颜色
    [self.lineColor set];
    
    //渲染
    CGContextDrawPath(ref, kCGPathStroke);
    
}

@end
