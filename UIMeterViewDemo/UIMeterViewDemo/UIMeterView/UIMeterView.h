//
//  AYMeterView.h
//  test
//
//  Created by guiq on 16/7/14.
//  Copyright © 2016年 com.guiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICountingLabel.h"


@interface UIMeterView : UIView

@property (nonatomic, strong) UICountingLabel *textLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *unitLabel;

/**
 *  值
 */
@property (assign, nonatomic) CGFloat value;

/**
 *  刻度数
 */
@property (assign, nonatomic) NSInteger scaleCount;

/**
 *  显示的刻度值[@"title",@(index)]
 */
@property (strong, nonatomic) NSArray *scales;

/**
 *  开始弧度
 */
@property (assign, nonatomic) CGFloat startAngle;

/**
 *  结束弧度
 */
@property (assign, nonatomic) CGFloat endAngle;

/**
 *  左边初始颜色
 */
@property (strong, nonatomic) UIColor *startColor;

/**
 *  右边初始颜色
 */
@property (strong, nonatomic) UIColor *endColor;

/**
 *  所有刻度CAShapeLayer
 */
@property (strong, nonatomic) NSArray *scaleLayers;

/**
 *  所有刻度label
 */
@property (strong, nonatomic) NSArray *scaleLabels;

@end
