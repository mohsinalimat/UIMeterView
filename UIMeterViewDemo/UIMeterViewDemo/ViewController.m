//
//  ViewController.m
//  UIMeterViewDemo
//
//  Created by guiq on 16/7/18.
//  Copyright © 2016年 com.guiq. All rights reserved.
//

#import "ViewController.h"
#import "UIMeterView.h"

@interface ViewController ()
{
    UIMeterView *meterView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    meterView = [[UIMeterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*0.8, self.view.frame.size.width*0.8)];
    meterView.center = self.view.center;
    [self.view addSubview:meterView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    meterView.value = 120;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
