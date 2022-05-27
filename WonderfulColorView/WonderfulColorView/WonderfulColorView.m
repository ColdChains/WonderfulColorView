//
//  WonderfulColorView.h
//  WonderfulColorView
//
//  Created by lax on 2022/5/27.
//

#import "WonderfulColorView.h"

@interface WonderfulColorView()
{
    CGFloat circleRadius;
    CGPoint circleCenter;
    CGFloat circleMargin;
    
    CGFloat itemWidth;
    CGFloat itemMargin;
    CGFloat itemAngle;
    
    CGFloat startAngle;
    CGFloat endAngle;
    CGFloat showStartAngle;
    CGFloat showEndAngle;
    CGFloat showItemCount;
    
    CGFloat scrollSpeed;
    BOOL canMove;
    BOOL isOpen;
}

@property (nonatomic, strong) NSMutableArray<UIView *> *subViewArray;
//扇形区域
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) CAShapeLayer *calayer;
//蒙层
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation WonderfulColorView

- (NSMutableArray *)subViewArray {
    if (!_subViewArray) {
        _subViewArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _subViewArray;
}

- (void)setDataArray:(NSArray<UIColor *> *)dataArray {
    _dataArray = dataArray;
    [self initSubViews];
}

- (void)setItemBorderColor:(UIColor *)itemBorderColor {
    _itemBorderColor = itemBorderColor;
    for (int i = 0; i < _dataArray.count; i++) {
        _subViewArray[i].backgroundColor = itemBorderColor;
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (selectIndex < 0 || selectIndex >= _subViewArray.count) {
        _selectIndex = -1;
    } else {
        _selectIndex = selectIndex;
    }
    //设置阴影及边框
    if (isOpen == YES) {
        for (int i = 0; i < _subViewArray.count; i++) {
            UIView *view = _subViewArray[i];
            view.layer.shadowOpacity = 0.2;
            view.layer.borderWidth = 0;
        }
        if (_selectIndex >= 0 && _selectIndex < self.subViewArray.count) {
            _subViewArray[_selectIndex].layer.borderWidth = 2;
        }
    } else {
        for (int i = 0; i < _subViewArray.count; i++) {
            UIView *view = _subViewArray[i];
            view.layer.shadowOpacity = 0;
            view.layer.borderWidth = 0;
        }
        if (_selectIndex < 0 || _selectIndex >= _subViewArray.count) {
            _subViewArray.firstObject.layer.shadowOpacity = 0.2;
        } else {
            UIView *view = _subViewArray[_selectIndex];
            view.layer.shadowOpacity = 0.2;
        }
    }
    //设置层级
    [self bringSelectViewToFront];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 338) / 2, 100, 338, 124) radius:300 showStartAngle:62.5 showEndAngle:117.5];
}

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat angle = [self getAngleWithArcLength:self.frame.size.width - circleMargin * 2];
        [self initViewWithRadius:radius showStartAngle:90 - angle / 2 showEndAngle:90 + angle / 2];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius showStartAngle:(CGFloat)angle1 showEndAngle:(CGFloat)angle2 {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewWithRadius:radius showStartAngle:angle1 showEndAngle:angle2];
    }
    return self;
}

- (void)initViewWithRadius:(CGFloat)radius showStartAngle:(CGFloat)angle1 showEndAngle:(CGFloat)angle2 {
    circleMargin = 47;
    circleRadius = radius - circleMargin;
    circleCenter = CGPointMake(self.frame.size.width / 2, circleRadius + circleMargin);
    
    itemWidth = 50;
    itemMargin = 11;
    itemAngle = [self getAngleWithArcLength:itemWidth + itemMargin];
    
    startAngle = 0;
    endAngle = 180;
    showStartAngle = angle1;
    showEndAngle = angle2;
    showStartAngle = showStartAngle <= startAngle ? (startAngle + 1) : showStartAngle;
    showEndAngle = showEndAngle >= endAngle ? (endAngle - 1) : showEndAngle;
    showItemCount = (showEndAngle - showStartAngle + itemAngle) / itemAngle;
    
    scrollSpeed = 1.4;
    
    _itemBorderColor = [UIColor whiteColor];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.imageView];
    self.clipsToBounds = YES;
    
    [self drawShape];
//    [self redPointTest];
    
}

//绘制扇形
- (void)drawShape {
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPath];
    //起始中心点改一下
    [path moveToPoint:circleCenter];
    CGFloat start = M_PI * (2 - (showStartAngle - itemAngle / 2) / 180);
    CGFloat end = M_PI * (2 - (showEndAngle + itemAngle / 2) / 180);
    [path addArcWithCenter:circleCenter radius:circleRadius + 30 startAngle:start endAngle:end clockwise:NO];
    [path addArcWithCenter:circleCenter radius:circleRadius - 30 startAngle:end endAngle:start clockwise:YES];
    
    [path closePath];
    layer.fillColor = [UIColor clearColor].CGColor;

    layer.path = path.CGPath;
    [self.layer addSublayer:layer];
    
    self.path = path;
    [self.calayer removeFromSuperlayer];
    self.calayer = layer;
    
}

//测试 辅助线
- (void)redPointTest {
    for (int i = 0; i <= 300; i++) {
        if (i % 10 != 0) { continue; }
        CGPoint arcPoint = [self getCirclePointWithAngle:i];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
        label.center = arcPoint;
        label.layer.cornerRadius = 1;
        label.backgroundColor = [UIColor redColor];
        [self addSubview:label];
//        CGFloat angle = [self getAngleWithPoint:arcPoint];
//        NSLog(@"%f", angle);
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
    label.center = circleCenter;
    label.layer.cornerRadius = 1;
    label.backgroundColor = [UIColor redColor];
    [self addSubview:label];
}

//设置响应区域
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([super pointInside:point withEvent:event]) {
        if (self.path && [self.path containsPoint:point]) {
            return YES;
        }
        return NO;//CGRectContainsPoint(self.bounds, point);
    }
    return NO;
}

//选中视图置顶
- (void)bringSelectViewToFront {
    if (_selectIndex < 0 || _selectIndex >= _subViewArray.count) {
        [self bringSubviewToFront:_subViewArray.firstObject];
    } else {
        UIView *view = _subViewArray[_selectIndex];
        [self bringSubviewToFront:view];
    }
    [self bringSubviewToFront:self.imageView];
}

#pragma mark 展开
- (void)open {
    if (self.imageView.alpha > 0) { return; }
    if (isOpen == YES) { return; }
    isOpen = YES;
    [self initSubViewsPositionWithIndex:self.selectIndex isAnimation:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initSubViewsPositionWithIndex:self.selectIndex isAnimation:NO];
        self.selectIndex = self->_selectIndex;
    });
    
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.alpha = 1;
    }];
}

#pragma mark 收起
- (void)close {
    if (self.imageView.alpha < 1) { return; }
    if (isOpen == NO) { return; }
    isOpen = NO;
    [self bringSelectViewToFront];
    [self closeSubViewsPositionWithAnimation:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self closeSubViewsPositionWithAnimation:NO];
        self.selectIndex = self->_selectIndex;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.alpha = 0;
        }];
    });
}

#pragma mark 初始化子视图
- (void)initSubViews {
    for (UIView *view in self.subViewArray) {
        [view removeFromSuperview];
    }
    [self.subViewArray removeAllObjects];

    for (int i = 0; i < self.dataArray.count; i++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * (itemWidth + itemMargin), 0, itemWidth, itemWidth)];
        view.backgroundColor = self.itemBorderColor;
        view.tag = i + 100;
        view.layer.cornerRadius = itemWidth / 2;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(0, 0);
        view.layer.shadowOpacity = 0.2;
        view.layer.borderWidth = 0;
        NSMutableArray<UIColor *> *tempColorArr = [NSMutableArray array];
        for (id dic in self.dataArray) {
//            if ([dic isKindOfClass:[HangtagClolorList class]]) {
//                UIColor *c = [UIColor colorWithHexString:((HangtagClolorList *)dic).tagColor];
//                [tempColorArr addObject:c];
//            }
            if ([dic isKindOfClass:[UIColor class]]) {
                [tempColorArr addObject:dic];
            }
//            if ([dic isKindOfClass:[ThreelabelColorList class]]) {
//                UIColor *c = [UIColor colorWithHexString:((ThreelabelColorList *)dic).labelColor];
//                [tempColorArr addObject:c];
//            }
        }
        if (tempColorArr.count >0 ) {
            view.layer.borderColor = tempColorArr[i].CGColor;
        }else{
            view.layer.borderColor = self.dataArray[i].CGColor;
        }
        [self addSubview:view];

        [self.subViewArray addObject:view];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7.5, 7.5, itemWidth - 15, itemWidth - 15)];
        
        if (tempColorArr.count >0 ) {
            label.backgroundColor = tempColorArr[i];

        }else{
            label.backgroundColor = self.dataArray[i];
        }
        
//        label.backgroundColor = self.dataArray[i];
        label.tag = 200 + i;
//        label.text = [NSString stringWithFormat:@"%d", i];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = (itemWidth - 15) / 2;
        label.layer.masksToBounds = YES;
        [view addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [view addGestureRecognizer:tap];
        [self sendSubviewToBack:view];
    }

    [self bringSubviewToFront:self.imageView];
    [self closeSubViewsPositionWithAnimation:NO];
    
    if (self.subViewArray.count <= 1) {
        self.imageView.image = nil;
    } else if (self.subViewArray.count <= 4) {
        self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"maskimage%ld", (long)self.subViewArray.count]];
    } else {
        self.imageView.image = [UIImage imageNamed:@"maskimage5"];
    }
    self.imageView.alpha = 0;
    self.selectIndex = -1;
}

//收起状态
- (void)closeSubViewsPositionWithAnimation:(BOOL)isAnimation {
    isOpen = NO;
    canMove = NO;
    for (int i = 0; i < self.subViewArray.count; i++) {
        UIView *view = self.subViewArray[i];
        if (isAnimation) {
            [self addCircleAnimationToView:view withEndAngle:90];
        } else {
            [self moveView:self.subViewArray[i] toAngle:90];
        }
    }
}

#pragma mark 初始化位置
//展开状态
- (void)initSubViewsPositionWithAnimation:(BOOL)isAnimation {
    canMove = YES;
    CGFloat firstAngle = showEndAngle;
    if (showItemCount >= self.subViewArray.count) {
        firstAngle = 90 + itemAngle * (self.subViewArray.count - 1) / 2;
        canMove = NO;
    }
    for (int i = 0; i < self.subViewArray.count; i++) {
        UIView *view = self.subViewArray[i];
        CGFloat newAngle = firstAngle - i * itemAngle;
        if (isAnimation) {
            [self addCircleAnimationToView:view withEndAngle:newAngle];
        } else {
            [self moveView:view toAngle:newAngle];
        }
    }
}

//展开状态 定位到指定下标
- (void)initSubViewsPositionWithIndex:(NSInteger)index isAnimation:(BOOL)isAnimation {
    canMove = YES;
    //数量不足时不可滑动
    if (showItemCount >= self.subViewArray.count) {
        [self initSubViewsPositionWithAnimation:isAnimation];
        return;
    }
    for (int i = 0; i < self.subViewArray.count; i++) {
        UIView *view = self.subViewArray[i];
        CGFloat offsetAngle = 0;
        NSInteger index = self.selectIndex;
        if (index < 0 || index >= self.subViewArray.count) {
            index = 0;
        }
        CGFloat otherAngle = 0;
        //左侧不足需增加偏移量
        if ((showEndAngle - 90) / itemAngle > index) {
            otherAngle = -((showEndAngle - 90) / itemAngle - index) * itemAngle;
        }
        //右侧不足需增加偏移量
        if ((90 - showStartAngle) / itemAngle > (self.subViewArray.count - 1 - index)) {
            otherAngle = ((90 - showStartAngle) / itemAngle - (self.subViewArray.count - 1 - index)) * itemAngle;
        }
        if (i <= index) {
            offsetAngle = -(index - i) * itemAngle;
            offsetAngle += otherAngle;
            offsetAngle = offsetAngle < -(endAngle - 90) ? -(endAngle - 90) : offsetAngle;
        } else if (i >= index) {
            offsetAngle = (i - index) * itemAngle;
            offsetAngle += otherAngle;
            offsetAngle = offsetAngle > (90 - startAngle) ? (90 - startAngle) : offsetAngle;
        }
        
        if (isAnimation) {
            [self animationMoveView:view offsetAngle:offsetAngle];
        } else {
            [self moveView:view offsetAngle:offsetAngle];
        }
    }
}

#pragma mark 点击事件
- (void)tapAction:(UITapGestureRecognizer *)tap {
    if (isOpen == NO) {
        [self open];
        return;
    }
    self.selectIndex = tap.view.tag - 100;
    if (self.selectItemBlock) {
        self.selectItemBlock([NSString stringWithFormat:@"%ld", (long)self.selectIndex]);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (self.subViewArray.count <= 0 || !canMove) { return ;}
    
    UITouch *touch = touches.anyObject;
    
    CGPoint curPoint = [touch locationInView:self];
    CGPoint prePoint = [touch precisePreviousLocationInView:self];
    CGFloat offsetX = curPoint.x - prePoint.x;
    
    //计算移动的角度 正右 负左
    CGFloat offsetAngle = [self getAngleWithArcLength:offsetX * scrollSpeed];
//    NSLog(@"%.1f, %f", offsetX, offsetAngle);
    [self moveSubViewsWith:offsetAngle isAnimation:NO];
}
    
#pragma mark 移动视图指定的角度
- (void)moveSubViewsWith:(CGFloat)offsetAngle isAnimation:(BOOL)isAnimation {
    
    if (offsetAngle < 0) {
        
        //判断右侧showStartAngle
        UIView *view = self.subViewArray.lastObject;
        CGFloat angle = [self getAngleWithPoint:view.center];
        UIView *preView = self.subViewArray[self.subViewArray.count - 2];
        CGFloat preAngle = [self getAngleWithPoint:preView.center];
        if ((preAngle - itemAngle - offsetAngle) >= showStartAngle && (angle - offsetAngle) >= showStartAngle) {
            offsetAngle = angle - showStartAngle;
        }
        
        for (int i = 0; i < self.subViewArray.count; i++) {
            UIView *view = self.subViewArray[i];
            
            //判断右侧视图是否可以左移 与左侧相邻的间距不足时不移动
            if (i > 0 && view.center.x >= [self getCirclePointWithAngle:startAngle].x) {
                UIView *preView = self.subViewArray[i - 1];
                CGFloat distance = [self getArcLengthWith:view.center andPoint:preView.center];
                if (distance < itemWidth + itemMargin) {
                    continue;;
                } else {
                    CGFloat arcLength = [self getArcLengthWith:view.center andPoint:preView.center];
                    CGFloat arcAngle = [self getAngleWithArcLength:arcLength];
                    //移动并设置偏差
                    offsetAngle = itemAngle - arcAngle;
                    [self moveView:view offsetAngle:offsetAngle];
                    continue;
                }
            }
            
            //移动
            [self moveView:view offsetAngle:offsetAngle];
            
        }
        
    } else if (offsetAngle > 0) {
        
        //判断左侧showEndAngle
        UIView *view = self.subViewArray.firstObject;
        CGFloat angle = [self getAngleWithPoint:view.center];
        UIView *preView = self.subViewArray[1];
        CGFloat preAngle = [self getAngleWithPoint:preView.center];
        if ((preAngle + itemAngle - offsetAngle) <= showEndAngle && (angle - offsetAngle) <= showEndAngle) {
            offsetAngle = angle - showEndAngle;
        }
        
        for (NSInteger i = self.subViewArray.count - 1; i >= 0; i--) {
            UIView *view = self.subViewArray[i];
            
            //判断左侧视图是否可以右移 与右侧相邻的间距不足时不移动
            if (i < self.subViewArray.count - 1 && view.center.x <= [self getCirclePointWithAngle:endAngle].x) {
                UIView *preView = self.subViewArray[i + 1];
                CGFloat distance = [self getArcLengthWith:view.center andPoint:preView.center];
                
                if (distance < itemWidth + itemMargin) {
                    continue;
                } else {
                    CGFloat arcLength = [self getArcLengthWith:view.center andPoint:preView.center];
                    CGFloat arcAngle = [self getAngleWithArcLength:arcLength];
                    offsetAngle = arcAngle - itemAngle;
                    //移动并设置偏差
                    [self moveView:view offsetAngle:offsetAngle];
                    continue;
                }
            }
            
            //移动
            [self moveView:view offsetAngle:offsetAngle];
            
        }
    }
}

- (void)moveView:(UIView *)view toAngle:(CGFloat)newAngle {
    newAngle = newAngle < startAngle ? startAngle : newAngle;
    newAngle = newAngle > endAngle ? endAngle : newAngle;
    CGPoint newPoint = [self getCirclePointWithAngle:newAngle];
    view.center = newPoint;
}

- (void)moveView:(UIView *)view offsetAngle:(CGFloat)offsetAngle {
    CGFloat angle = [self getAngleWithPoint:view.center];
    CGFloat newAngle = angle - offsetAngle;
    newAngle = newAngle < startAngle ? startAngle : newAngle;
    newAngle = newAngle > endAngle ? endAngle : newAngle;
    CGPoint newPoint = [self getCirclePointWithAngle:newAngle];
    view.center = newPoint;
}

- (void)animationMoveView:(UIView *)view toAngle:(CGFloat)newAngle {
    newAngle = newAngle < startAngle ? startAngle : newAngle;
    newAngle = newAngle > endAngle ? endAngle : newAngle;
    [self addCircleAnimationToView:view withEndAngle:newAngle];
}

- (void)animationMoveView:(UIView *)view offsetAngle:(CGFloat)offsetAngle {
    CGFloat angle = [self getAngleWithPoint:view.center];
    CGFloat newAngle = angle - offsetAngle;
    newAngle = newAngle < startAngle ? startAngle : newAngle;
    newAngle = newAngle > endAngle ? endAngle : newAngle;
    [self addCircleAnimationToView:view withEndAngle:newAngle];
}

- (void)addCircleAnimationToView:(UIView *)view withEndAngle:(CGFloat)angle2 {
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    CGFloat angle1 = [self getAngleWithPoint:view.center];
    BOOL clockwise = angle1 > angle2 ? YES : NO;
//    NSLog(@"%f, %f", angle1, angle2);
    //0-180 0-PI 2PI-PI
    angle1 = 2 * M_PI - angle1 / 180 * M_PI;
    angle2 = 2 * M_PI - angle2 / 180 * M_PI;
    angle1 = angle1 < M_PI ? M_PI : angle1;
    angle1 = angle1 > (2 * M_PI) ? (2 * M_PI) : angle1;
    angle2 = angle2 < M_PI ? M_PI : angle2;
    angle2 = angle2 > (2 * M_PI) ? (2 * M_PI) : angle2;
    [path1 addArcWithCenter:circleCenter radius:circleRadius startAngle:angle1 endAngle:angle2 clockwise:clockwise];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path1.CGPath;
    animation.duration = 0.5;
    animation.removedOnCompletion = YES;
//    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:animation forKey:@"animation"];
    
}

#pragma mark 获取某个角度的坐标
- (CGPoint)getCirclePointWithAngle:(CGFloat)angle {
    //(0, PI)
    angle = angle * M_PI / 180;
    CGFloat x2 = circleRadius * cosf(angle);
    CGFloat y2 = circleRadius * sinf(angle);
    return CGPointMake(circleCenter.x + x2, circleCenter.y - y2);
}

#pragma mark 获取某个点的角度
- (CGFloat)getAngleWithPoint:(CGPoint)point {
    CGPoint arcPoint = point;
    //计算坐标点对应的角度 (0, PI)
    CGFloat angle = acos((arcPoint.x - circleCenter.x) / circleRadius);
    //(0, 180)
    angle = angle / M_PI * 180;
    if (point.y > circleCenter.y) {
        return isnan(angle) ? 0 : (360 - angle);
    }
    return isnan(angle) ? 0 : angle;
}

#pragma mark 获取两点的弧长
- (CGFloat)getArcLengthWith:(CGPoint)point andPoint:(CGPoint)point2 {
    CGFloat angle = fabs([self getAngleWithPoint:point] - [self getAngleWithPoint:point2]);
    // l = a * PI * R / 180
    return angle * M_PI * circleRadius / 180;
}

//获取两点的直线距离
- (CGFloat)getDistanceWith:(CGPoint)point andPoint:(CGPoint)point2 {
    return sqrt(fabs(point.x - point2.x) * fabs(point.x - point2.x) + fabs(point.y - point2.y) * fabs(point.y - point2.y));
}

#pragma mark 获取弧长对应的角度
- (CGFloat)getAngleWithArcLength:(CGFloat)length {
    //a = l / (2 * PI * R) * 360
    return length / (2 * M_PI * circleRadius) * 360;
}

@end


