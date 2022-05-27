//
//  CYColorViewDelegate.h
//  ColorView
//
//  Created by 金石教育 on 2021/2/7.
//

#import <Foundation/Foundation.h>
@class CYColorView;
#import "CYColorItemView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CYColorViewDelegate <NSObject>
-(void)didSelectColorView:(CYColorView*)colorView withIndex:(NSInteger)index withColorItemView:(CYColorItemView *)itemView;
@end

NS_ASSUME_NONNULL_END
