//
//  CYColorView.m
//  ColorView
//
//  Created by 金石教育 on 2021/2/5.
//

#import "CYColorView.h"
#import <UIKit/UIBezierPath.h>
#import "UIViewExt.h"
@interface CYColorView()<UIScrollViewDelegate>
@end
@implementation CYColorView{
    //整体视图弧度
    CGFloat viewRadian;
    //整体视图的半径
    CGFloat viewRadius;
    //整体视图的高度，即圆弧的粗细
    CGFloat viewHeight;
    //整体圆弧距离父视图顶部的距离
    CGFloat viewTop;
    //所有色块的父视图
    UIView *colorSuperView;
    //展开时显示的色块个数
    NSInteger showItemNum;
    //所有需要展示的色块个数
    NSInteger itemTotalNum;

    //所有色块数组
    NSMutableArray <CYColorItemView *>*colorItemViews;
    //当前显示色块数组
    NSMutableArray <CYColorItemView *>*currentShowColorItemViews;

    //阴影背景视图
    UIView *shadowBackView;
    CAShapeLayer *shadowLayer;
    //色块选择背景视图
    UIView *colorBackView;
    CAShapeLayer *maskLayer;
    
    //用来捕获滑动事件
    UIScrollView *scrollView;
    bool isSelect;
    bool isScroll;
    //转动的圈数
    NSInteger numberOfTurns;
    //选中的色块 此色块会在收起时显示在视图中间
    CYColorItemView *selectItem;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //整体视图弧度 必须可以被360整除 否则会有错位的现象
         viewRadian = 60;
        //整体视图的半径
         viewRadius = 350;
        //整体视图的高度，即圆弧的粗细
         viewHeight = 70;
        //整体圆弧距离父视图顶部的距离
         viewTop = 10;
        numberOfTurns = 0;
        self.backgroundColor = [UIColor clearColor];
        shadowBackView = [[UIView alloc]initWithFrame:self.bounds];
        shadowBackView.backgroundColor = [UIColor clearColor];
        shadowLayer = [self getBaseLayer];
        shadowLayer.shadowColor = [UIColor grayColor].CGColor;
        shadowLayer.shadowOffset = CGSizeMake(0, 0);
        shadowLayer.shadowOpacity = 0.2;
        [shadowBackView.layer addSublayer:shadowLayer];
        [self addSubview:shadowBackView];
        colorBackView = [[UIView alloc]initWithFrame:self.bounds];
        colorBackView.backgroundColor = [UIColor clearColor];
        colorItemViews = [[NSMutableArray alloc]initWithCapacity:1];
        colorSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewRadius*2, viewRadius*2)];
        colorSuperView.center = CGPointMake(self.width / 2, viewRadius + viewTop);
        [colorBackView addSubview:colorSuperView];
        [self rotateWithRadian:0];
        maskLayer = [self getBaseLayer];
        colorBackView.layer.mask = maskLayer;
        colorBackView.layer.masksToBounds = YES;
    }
    return self;
}
-(void)setDatasource:(id<CYColorViewDataSource>)datasource{
    _datasource = datasource;
    //展开时显示的色块个数
    showItemNum = 5;
    if (self.datasource && [self.datasource respondsToSelector:@selector(itemTotalNumWithColorView:)]) {
        itemTotalNum = [self.datasource itemTotalNumWithColorView:self];
    }else{
        itemTotalNum = 1;
    }
    currentShowColorItemViews = [[NSMutableArray alloc]initWithCapacity:1];
    for (int i = 0; i < (360 / viewRadian * (showItemNum - 1)); i++) {
        CYColorItemView *itemView = [[CYColorItemView alloc]initWithFrame:CGRectMake(colorSuperView.width / 2 - viewHeight /2, 0, viewHeight, colorSuperView.width) withIndex:i];
        __block CYColorView *blockSelf = self;
        __block CYColorItemView *blockitemView = itemView;
        [itemView setClickBlock:^{
            [blockSelf selectActionWithItemView:blockitemView];
        }];
        if (i< showItemNum + 1 && self.datasource && [self.datasource respondsToSelector:@selector(loadColorView:withIndex:withColorItemView:)]) {
            [currentShowColorItemViews addObject:itemView];
           [self.datasource loadColorView:self withIndex:i % itemTotalNum withColorItemView:itemView];
        }
        [colorItemViews addObject:itemView];
        [colorSuperView addSubview:itemView];
        itemView.transform = CGAffineTransformMakeRotation(M_PI/180 * viewRadian / (showItemNum - 1) * (i - (showItemNum - 1)/2));
    }
    selectItem = currentShowColorItemViews[0];
    scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    scrollView.contentSize = CGSizeMake( self.width * itemTotalNum / showItemNum, self.height);
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    [scrollView addSubview:colorBackView];
}
-(void)selectActionWithItemView:(CYColorItemView *)itemView{
    if (isScroll) {
        return;
    }
    [self updateViewLocation];
    NSInteger index = itemView.index + numberOfTurns * colorItemViews.count;
    if (index > itemTotalNum) {
        return;
    }
    selectItem = itemView;
    [currentShowColorItemViews removeAllObjects];
    for (NSInteger i = index - (showItemNum - 1)/2; i <= index + (showItemNum - 1)/2; i++) {
        if (i >= 0 && i < itemTotalNum && self.datasource && [self.datasource respondsToSelector:@selector(loadColorView:withIndex:withColorItemView:)]) {
            CYColorItemView *itemView =colorItemViews[i%colorItemViews.count];
            [currentShowColorItemViews addObject:itemView];
            [self.datasource loadColorView:self withIndex:i withColorItemView:itemView];
        }else{
            [colorItemViews[i%colorItemViews.count] clear];
        }
    }
    isSelect = YES;
    [UIView animateWithDuration:0.35 animations:^{
        self->scrollView.contentOffset = CGPointMake(self.width / self->showItemNum * (index - (self->showItemNum - 1)/2), 0);
    }completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectColorView:withIndex:withColorItemView:)]) {
            [self.delegate didSelectColorView:self withIndex:index withColorItemView:self->colorItemViews[index % self->colorItemViews.count]];
        }
        self->isSelect = NO;
    }];
    
}
-(CAShapeLayer *)getBaseLayer{
    UIBezierPath *bezierPath = [self getPathWithRadian:viewRadian];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = bezierPath.CGPath;
    layer.strokeColor = UIColor.clearColor.CGColor;
    layer.fillColor = UIColor.whiteColor.CGColor;
    layer.masksToBounds = NO;
    return layer;
}
-(UIBezierPath *)getPathWithRadian:(CGFloat )radian{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    //上面圆弧的圆心
    CGPoint arcCenter = CGPointMake(self.width / 2, viewRadius + viewTop);
    //将上面的圆弧路径添加进去
    [bezierPath addArcWithCenter:arcCenter radius:viewRadius startAngle:-M_PI/180 * (90 + radian/ 2)  endAngle:-M_PI/180 *(90 - radian / 2) clockwise:YES];
    //右面的圆弧圆心坐标
    CGFloat rightArcCenterX = self.width / 2 + (viewRadius - viewHeight / 2) * sin(radian/2 *M_PI  / 180);
    CGFloat rightArcCenterY = arcCenter.y - (viewRadius - viewHeight / 2) * cos(radian/2 * M_PI /180);
    //右面圆弧的圆心
    CGPoint rigttArcCenter = CGPointMake(rightArcCenterX, rightArcCenterY);
    CGFloat rightStartAngle = -M_PI/180 * (90 - radian / 2);
    CGFloat rightEndAngle = -M_PI/180 * (270 - radian / 2);
    //右面的圆弧
    [bezierPath addArcWithCenter:rigttArcCenter radius: viewHeight / 2 startAngle:rightStartAngle endAngle:rightEndAngle clockwise:YES];
    //下面的圆弧
    [bezierPath addArcWithCenter:arcCenter radius:viewRadius - viewHeight startAngle:-M_PI/180 *(90 - radian / 2) endAngle:-M_PI/180 *(90 + radian / 2) clockwise:NO];
    //左面的圆弧
    CGFloat leftArcCenterX = self.width / 2 - (viewRadius - viewHeight / 2) * sin(radian/2 * M_PI / 180);
    CGFloat leftArcCenterY = arcCenter.y - (viewRadius - viewHeight / 2) * cos(radian/2 * M_PI /180);
    //左面圆弧的圆心
    CGPoint leftArcCenter = CGPointMake(leftArcCenterX, leftArcCenterY);
    CGFloat leftStartAngle = M_PI/180 * (90 - radian / 2);
    CGFloat leftEndAngle = M_PI/180 * (270 - radian / 2);
    [bezierPath addArcWithCenter:leftArcCenter radius: viewHeight / 2 startAngle:leftStartAngle endAngle:leftEndAngle clockwise:YES];
    return bezierPath;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    isScroll = YES;
}

/// 刷线视图位置
-(void)updateViewLocation{
    CGFloat radian = -scrollView.contentOffset.x / self.width * viewRadian * showItemNum / (showItemNum - 1);
    colorSuperView.transform = CGAffineTransformMakeRotation( M_PI/180*radian);
    colorBackView.left =  scrollView.contentOffset.x;
    CGFloat floatNum = scrollView.contentOffset.x / (self.width *colorItemViews.count/showItemNum);
    if (floatNum>0) {
        numberOfTurns =floor(floatNum);
    }else{
        numberOfTurns =ceil(floatNum);
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateViewLocation];
    if (isSelect) {
        return;
    }
    if (self.datasource && [self.datasource respondsToSelector:@selector(loadColorView:withIndex:withColorItemView:)]) {
        NSInteger index = floor(scrollView.contentOffset.x / self.width * showItemNum);
        CYColorItemView *firstItem;
        CYColorItemView *lastItem;
        if (index >= 0 && index < itemTotalNum) {
            firstItem = colorItemViews[index % colorItemViews.count];
        }else{
            if (index < 0) {
                [colorItemViews[(colorItemViews.count+index)%colorItemViews.count] clear];
            }else{
                [colorItemViews[index % colorItemViews.count] clear];
            }
        }
        if ((index + showItemNum) > 0 && (index + showItemNum) < itemTotalNum ) {
            lastItem = colorItemViews[(index + showItemNum)%colorItemViews.count];
        }else{
            [colorItemViews[(index + showItemNum)%colorItemViews.count] clear];
        }
        if (firstItem && ![currentShowColorItemViews containsObject:firstItem]) {
            [currentShowColorItemViews removeLastObject];
            [currentShowColorItemViews insertObject:firstItem atIndex:0];
            [self.datasource loadColorView:self withIndex:index withColorItemView:firstItem];
        }
        if (lastItem && ![currentShowColorItemViews containsObject:lastItem]) {
            [currentShowColorItemViews removeObjectAtIndex:0];
            [currentShowColorItemViews addObject:lastItem];
            [self.datasource loadColorView:self withIndex:index+showItemNum withColorItemView:lastItem];
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    isScroll = NO;
    NSInteger index = ceil(scrollView.contentOffset.x / (self.width/showItemNum));
    if (index > itemTotalNum - 1) {
        index = itemTotalNum - 1;
    }else if (index < 0){
        index = 0;
    }
    [UIView animateWithDuration:0.2 animations:^{
        scrollView.contentOffset = CGPointMake(index * (self.width/self->showItemNum), 0);
    }completion:^(BOOL finished) {
    }];
}

/// 旋转弧度
/// @param radian 弧度 单位 °
-(void)rotateWithRadian:(CGFloat)radian{
    colorSuperView.transform = CGAffineTransformRotate(colorSuperView.transform, M_PI/180*radian);
}
-(void)openWithAnimal:(BOOL)animal{
    if (!_isClose) {
        return;
    }
    _isClose = NO;
    [self updateViewLocation];
    scrollView.scrollEnabled = YES;

    if (animal) {
        __block CGFloat timeOut = 0;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 0.005 * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(timer,
        ^{
            if(timeOut >= self->viewRadian)
            { //倒计时结束，关闭
                dispatch_source_cancel(timer);
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    self->shadowLayer.path = [self getPathWithRadian:self->viewRadian].CGPath;
                    self->maskLayer.path = [self getPathWithRadian:self->viewRadian].CGPath;
                });
            }
            else
            {
                timeOut = timeOut + self->viewRadian / 60;
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    self->shadowLayer.path = [self getPathWithRadian:timeOut].CGPath;
                    self->maskLayer.path = [self getPathWithRadian:timeOut].CGPath;
                });
            }
        });
        dispatch_resume(timer);
        [UIView animateWithDuration:0.3 animations:^{
            for (int i = 0; i < self->colorItemViews.count; i++) {
                CYColorItemView *itemView = self->colorItemViews[i];
                itemView.transform = CGAffineTransformMakeRotation(M_PI/180 *( self->viewRadian / (self->showItemNum - 1) * (i - 2)));
                itemView.alpha = 1;
            }
        }completion:^(BOOL finished) {
            
        }];
    }else{
        shadowLayer.path = [self getPathWithRadian:viewRadian].CGPath;
        maskLayer.path = [self getPathWithRadian:viewRadian].CGPath;
        for (int i = 0; i < colorItemViews.count; i++) {
            CYColorItemView *itemView = colorItemViews[i];
            itemView.transform = CGAffineTransformMakeRotation(M_PI/180 *( viewRadian / (showItemNum - 1) * (i - 2)));
            itemView.alpha = 1;
        }
    }
    
}
-(void)closeWithAnimal:(BOOL)animal{
    if (_isClose) {
        return;
    }
    _isClose = YES;
    [self updateViewLocation];
    scrollView.scrollEnabled = NO;
    if (animal) {
        __block CGFloat timeOut = viewRadian;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 0.005 * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(timer,
        ^{
            if(timeOut <= 0)
            { //倒计时结束，关闭
                dispatch_source_cancel(timer);
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    self->shadowLayer.path = [self getPathWithRadian:0].CGPath;
                    self->maskLayer.path = [self getPathWithRadian:0].CGPath;
                });
            }
            else
            {
                timeOut = timeOut - self->viewRadian / 60;
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    self->shadowLayer.path = [self getPathWithRadian:timeOut].CGPath;
                    self->maskLayer.path = [self getPathWithRadian:timeOut].CGPath;
                });
            }
        });
        dispatch_resume(timer);
        CGFloat radian = - atan2f(colorSuperView.transform.b, colorSuperView.transform.a) / (M_PI / 180);
        [UIView animateWithDuration:0.3 animations:^{
            for (CYColorItemView *itemView in self->colorItemViews) {
                itemView.transform = CGAffineTransformMakeRotation(radian * M_PI/180);
                if (itemView != self->selectItem) {
                    itemView.alpha = 0;
                }else{
                    itemView.alpha = 1;
                }
            }
        }completion:^(BOOL finished) {
            
        }];
    }else{
        shadowLayer.path = [self getPathWithRadian:0].CGPath;
        maskLayer.path = [self getPathWithRadian:0].CGPath;
        CGFloat radian = - atan2f(colorSuperView.transform.b, colorSuperView.transform.a) / (M_PI / 180);
        for (CYColorItemView *itemView in self->colorItemViews) {
            itemView.transform = CGAffineTransformMakeRotation(radian * M_PI/180);
            if (itemView != self->selectItem) {
                itemView.alpha = 0;
            }else{
                itemView.alpha = 1;
            }
        }
    }
}

-(CYColorItemView *)itemViewWithIndex:(NSInteger)index{
    return colorItemViews[index % colorItemViews.count];
}
-(void)reloadData{
    for (CYColorItemView *itemView in currentShowColorItemViews) {
        if (self.datasource && [self.datasource respondsToSelector:@selector(loadColorView:withIndex:withColorItemView:)]) {
            [self.datasource loadColorView:self withIndex:itemView.index withColorItemView:itemView];
        }
    }
}
@end
