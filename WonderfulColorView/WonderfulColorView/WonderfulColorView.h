//
//  WonderfulColorView.h
//  WonderfulColorView
//
//  Created by lax on 2022/5/27.
//

#import <UIKit/UIKit.h>

typedef void (^WonderfulViewBlock)(id _Nullable);

NS_ASSUME_NONNULL_BEGIN

@interface WonderfulColorView : UIView

@property (nonatomic, copy) WonderfulViewBlock selectItemBlock;

//数据源 item内圆的颜色
@property (nonatomic, strong) NSArray<UIColor *> *dataArray;
//item外圆的颜色
@property (nonatomic, strong) UIColor *itemBorderColor;
//当前选中的item
@property (nonatomic, assign) NSInteger selectIndex;

//radius半径 showStartAngle展示的扇形的起始角度 showEndAngle展示的扇形的终止角度 角度范围从右向左0-180
- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius;
- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius showStartAngle:(CGFloat)angle1 showEndAngle:(CGFloat)angle2;

- (void)open;
- (void)close;

@end

NS_ASSUME_NONNULL_END
