//
//  AYMeterView.m
//  test
//
//  Created by guiq on 16/7/14.
//  Copyright © 2016年 com.guiq. All rights reserved.
//

#import "UIMeterView.h"

#define DEGREES_TO_RADIANS(degrees) (degrees) / 180.0 * M_PI

@interface UIMeterView ()
{
    CGFloat lineWidth; //圆弧宽度
    CGFloat radius;//圆弧radius
    
    CGFloat scaleWidth; //刻度宽度
    CGFloat scaleRadius;//刻度radius
    CGFloat perAngle;
    
    NSInteger turnCount; //转动的可度数
    NSInteger currentScale;  //转动的当前刻度
}
@property (nonatomic, strong) UIView *needleView;
@property (nonatomic, strong) CAShapeLayer *needle;
@property (nonatomic, strong) CADisplayLink *timer;
@property (nonatomic, assign) CGFloat duration; //动画时间

@end

@implementation UIMeterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _startAngle = -220;
    _endAngle = 40;
    _startColor =  [UIColor colorWithRed:239/255.0 green:122/255.0 blue:107/255.0 alpha:1];
    _endColor = [UIColor colorWithRed:75/255.0 green:152/255.0 blue:119/255.0 alpha:1];
    lineWidth = 14;
    scaleWidth = 10;
    radius = self.bounds.size.width * 0.3;
    scaleRadius = self.bounds.size.width * 0.4;
    currentScale = 0;
    _duration = 2.0f;
    
    self.scaleCount = 30;
    self.scales =  @[@[@"0",@(0)],@[@"10",@(5)],@[@"50",@(15)],@[@"100",@(24)],@[@"150",@(29)]];
    
    // 画圆弧
    [self drawCicrle];
    
    // 画刻度
    [self drawCalibration];
    
    // 显示值的label
    [self addSubview:self.textLabel];
    
    // 显示日期的label
    [self addSubview:self.tipsLabel];
    
    // 显示单位的label
    [self addSubview:self.unitLabel];
    
    // 箭头
    [self drawNeedle];

}

#pragma mark - setter
- (UICountingLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UICountingLabel alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
        _textLabel.center = CGPointMake(self.center.x,self.center.y-10);
        _textLabel.font = [UIFont boldSystemFontOfSize:40.0f];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = _startColor;
        _textLabel.text = @"0";
        _textLabel.format = @"%.1f%";
        _textLabel.animationDuration = _duration+0.2;
        _textLabel.method = UILabelCountingMethodLinear;
    }
    return _textLabel;
}

-(UILabel *)tipsLabel
{
    if (!_tipsLabel) {
        
        CGRect f = _textLabel.frame;
        f.origin.y = f.origin.y + _textLabel.frame.size.height;
        UILabel *label = [[UILabel alloc] initWithFrame:f];
        _tipsLabel = label;
        _tipsLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _tipsLabel.text = @"截止5.23 13:00";
    }
    return _tipsLabel;
}

-(UILabel *)unitLabel
{
    if (!_unitLabel) {
        
        CGRect f = _tipsLabel.frame;
        f.size.width = 105;
        f.size.height = 26;
        f.origin.x = (_tipsLabel.frame.size.width - f.size.width)/2 + _textLabel.frame.origin.x;
        f.origin.y = f.origin.y + _tipsLabel.frame.size.height;
        UILabel *label = [[UILabel alloc] initWithFrame:f];
        _unitLabel = label;
        _unitLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _unitLabel.textAlignment = NSTextAlignmentCenter;
        _unitLabel.textColor = [UIColor whiteColor];
        _unitLabel.backgroundColor = _startColor;
        _unitLabel.layer.cornerRadius = 10;
        _unitLabel.layer.masksToBounds = YES;
        _unitLabel.text = @"剩余电费(万元)";
    }
    return _unitLabel;
}

// 画圆弧
- (void)drawCicrle {
    
    CALayer *_bgLayer = [CALayer layer];
    _bgLayer.frame = self.bounds;
    [self.layer addSublayer:_bgLayer];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame =  self.bounds;
    gradientLayer.colors = @[(__bridge id)_startColor.CGColor, (__bridge id)_endColor.CGColor];
    gradientLayer.startPoint = CGPointMake(0.3 ,0);
    gradientLayer.endPoint = CGPointMake(0.7, 0);
    [_bgLayer addSublayer:gradientLayer];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.position = self.center;
    maskLayer.bounds = _bgLayer.bounds;
    maskLayer.fillColor = [UIColor clearColor].CGColor;
    maskLayer.strokeColor = [UIColor redColor].CGColor;
    maskLayer.lineCap = kCALineCapRound;
    maskLayer.lineWidth = lineWidth;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:radius startAngle:DEGREES_TO_RADIANS(_startAngle) endAngle:DEGREES_TO_RADIANS(_endAngle) clockwise:YES];
    maskLayer.path = maskPath.CGPath;
    _bgLayer.mask = maskLayer;

}

// 画刻度
- (void)drawCalibration {
    
    NSInteger count = _scaleCount;
    
    perAngle = (_endAngle-_startAngle) / _scaleCount;
    //刻度宽
    CGFloat w = DEGREES_TO_RADIANS(perAngle)/30;
    
    NSMutableArray *scaleArray = [NSMutableArray new];
    NSMutableArray *scaleLabels = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        CGFloat startAngel = DEGREES_TO_RADIANS(_startAngle + perAngle*i);
        CGFloat endAngel = startAngel + w;
        
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:scaleRadius startAngle:startAngel endAngle:endAngel clockwise:YES];
        
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        perLayer.strokeColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0].CGColor;
        perLayer.lineWidth = scaleWidth;
        perLayer.path = tickPath.CGPath;
    
        [scaleArray addObject:perLayer];
        [self.layer addSublayer:perLayer];
        
        //显示刻度数值的label
        [_scales enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[1] integerValue] == i) {
                CGPoint point = [self pointWithAngle:startAngel radius:scaleRadius+25];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(point.x-10, point.y, 0, 0)];
                label.text = obj[0];
                label.font = [UIFont systemFontOfSize:13.f];
                [label sizeToFit];
                label.textColor = _endColor;
                label.textAlignment = NSTextAlignmentLeft;
                [scaleLabels addObject:label];
                [self addSubview:label];
            }
        }];

    }
    
    
    self.scaleLayers = scaleArray;
    self.scaleLabels = scaleLabels;
}


// 指针
- (void)drawNeedle {
    
    CGFloat h = scaleRadius - scaleWidth-2;
    _needleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1,h*2)];
    _needleView.center = self.center;
    _needleView.backgroundColor = [UIColor clearColor];
    _needleView.transform=CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(_startAngle) +  DEGREES_TO_RADIANS(90));
    [self addSubview:_needleView];
    
    _needle = [CAShapeLayer layer];
    _needle.frame = CGRectMake(0, 0, 1, h);
    //画尖角
    UIBezierPath *needlePath = [UIBezierPath bezierPath];
    [needlePath moveToPoint:CGPointMake(0,1)];
    [needlePath addLineToPoint:CGPointMake(0-3,_needle.bounds.size.height-radius-7)];
    [needlePath addLineToPoint:CGPointMake(0+3,_needle.bounds.size.height-radius-7)];
    [needlePath closePath];

    _needle.path = needlePath.CGPath;
    _needle.fillColor = _startColor.CGColor;
    _needle.strokeColor = _startColor.CGColor;
    _needle.lineWidth = 3.0;
    [_needleView.layer addSublayer:_needle];
    
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    [_textLabel countFrom:0 to:_value];

    __block NSInteger count = 0;
    [_scales enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (value <= [obj[0] floatValue]) {
            
            if (idx > 1) {
                //前一个刻度值有多少个刻度
                count = [_scales[idx-1][1] integerValue];
                
                //当前区间值域
                NSInteger range = ([_scales[idx][0] floatValue] - [_scales[idx-1][0] floatValue]);
                
                //当前区间刻度总数
                NSInteger num = ([_scales[idx][1] integerValue] - [_scales[idx-1][1] integerValue]);
                
                //一个刻度的值表示多大
                CGFloat perValue =  range / num;
                
                //共占用多少个刻度
                count = count + ( _value - [_scales[idx-1][0] floatValue]) / perValue;
                
            }
           
             *stop = YES;
        }
        else{
            count = _scaleCount;
            
            //改变label颜色
            UILabel *label = _scaleLabels[idx];
            label.textColor = _startColor;
        }
        
        
    }];
    
    turnCount = count;
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(valueChanged)];
    _timer.frameInterval = 5;
    [_timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    //用Rotation动画超过180°会逆时针
    //    [UIView animateWithDuration:duration animations:^{
    //        _needleView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(_startAngle + turnCount * perAngle) +  DEGREES_TO_RADIANS(90));
    //    }];

}

- (void)valueChanged
{
    //获取圆环上的某点
    CGPoint point = [self pointWithAngle:DEGREES_TO_RADIANS(_startAngle + perAngle*currentScale) radius:radius];
    
    //指针旋转动画
    [UIView animateWithDuration:_duration/turnCount+0.1 animations:^{
        _needleView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(_startAngle + perAngle*currentScale) +  DEGREES_TO_RADIANS(90));
        
        //根据圆环上的某点颜色改变指针颜色
        UIColor *color = [self colorOfPoint:point];
        _needle.fillColor = color.CGColor;
        _needle.strokeColor = color.CGColor;
        _textLabel.textColor = color;
    
    }];
    
    //改变刻度颜色
    CAShapeLayer *layer = _scaleLayers[currentScale];
    layer.strokeColor = _startColor.CGColor;
    currentScale ++;
    
    if (currentScale > turnCount) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark 计算圆圈上点在IOS系统中的坐标
- (CGPoint)pointWithAngle:(CGFloat)angle radius:(CGFloat)r
{
    CGFloat x = CGRectGetWidth(self.frame)/2 + r * cosf(angle);
    CGFloat y = CGRectGetHeight(self.frame)/2 + r * sinf(angle);
    
    return CGPointMake(x, y);
}

//获取某点颜色
- (UIColor *)colorOfPoint:(CGPoint)point {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}


@end
