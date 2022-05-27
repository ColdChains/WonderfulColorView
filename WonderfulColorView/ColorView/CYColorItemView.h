//
//  CYColorItemView.h
//  ColorView
//
//  Created by 金石教育 on 2021/2/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYColorItemView : UIView
-(instancetype)initWithFrame:(CGRect)frame withIndex:(NSInteger)index;
@property(nonatomic,retain)UIView *contentView;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)void(^clickBlock)(void);
-(void)clear;
@end

NS_ASSUME_NONNULL_END
