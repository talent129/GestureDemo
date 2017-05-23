//
//  ViewController.m
//  GestureTest
//
//  Created by mac on 17/5/23.
//  Copyright © 2017年 cai. All rights reserved.
//

#import "ViewController.h"
#import "GestureView.h"

#define SCREEN_Width    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_Height   ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()<GestureViewDelegate>

@property (nonatomic, strong) GestureView *gestureView;

@end

@implementation ViewController

#pragma mark -
- (GestureView *)gestureView
{
    if (!_gestureView) {
        _gestureView = [[GestureView alloc] initWithFrame:CGRectMake(30, (SCREEN_Height - (SCREEN_Width - 60))/2.0, SCREEN_Width - 60, SCREEN_Width - 60)];
        _gestureView.backgroundColor = [UIColor clearColor];
        _gestureView.delegate = self;//代理对象
    }
    return _gestureView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self createUI];
    
}

#pragma mark -createUI
- (void)createUI
{
    [self.view addSubview:self.gestureView];
}

#pragma mark -GestureViewDelegate
- (BOOL)gestureViewCheckPassword:(GestureView *)gestureView password:(NSString *)password
{
    if ([password isEqualToString:@"012"]) {
        return YES;
    }else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
