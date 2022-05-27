//
//  CYColorViewDataSource.h
//  ColorView
//
//  Created by 金石教育 on 2021/2/7.
//

#import <Foundation/Foundation.h>
@class CYColorView;
#import "CYColorItemView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol CYColorViewDataSource <NSObject>
@optional
//可选实现方法
@required
//必须实现方法

/// 加载颜色视图
/// @param colorView 颜色视图
/// @param index 加载色块的索引
/// @param itemView 加载色块的单元格
-(void)loadColorView:(CYColorView *)colorView withIndex:(NSInteger)index withColorItemView:(CYColorItemView *)itemView;

-(NSInteger)itemTotalNumWithColorView:(CYColorView *)colorView;

@end

NS_ASSUME_NONNULL_END
