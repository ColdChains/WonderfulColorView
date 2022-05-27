//
//  CYColorItemView.m
//  ColorView
//
//  Created by 金石教育 on 2021/2/6.
//

#import "CYColorItemView.h"
#import "UIViewExt.h"
@interface CYColorItemView()

@end
@implementation CYColorItemView
-(instancetype)initWithFrame:(CGRect)frame withIndex:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        _index = index;
        self.backgroundColor = [UIColor clearColor];
        self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentView];
    }
    return self;
}
-(void)clear{
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.clickBlock) {
        self.clickBlock();
    }
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if ([self.contentView pointInside:point withEvent:event]) {
        return self;
    }
    return nil;
}
@end
