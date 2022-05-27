//
//  CYColorView.h
//  ColorView
//
//  Created by 金石教育 on 2021/2/5.
//

#import <UIKit/UIKit.h>
#import "CYColorViewDataSource.h"
#import "CYColorViewDelegate.h"
#import "CYColorItemView.h"
NS_ASSUME_NONNULL_BEGIN

@interface CYColorView : UIView
@property(nonatomic,strong)id <CYColorViewDataSource>datasource;
@property(nonatomic,strong)id <CYColorViewDelegate>delegate;

/// 根据索引获取一个色块视图
/// @param index 色块的索引
-(CYColorItemView *)itemViewWithIndex:(NSInteger)index;
@property(nonatomic,assign,readonly)BOOL isClose;
-(void)openWithAnimal:(BOOL)animal;
-(void)closeWithAnimal:(BOOL)animal;
-(void)reloadData;
@end

NS_ASSUME_NONNULL_END
