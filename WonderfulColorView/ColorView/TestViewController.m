//
//  ViewController.m
//  ColorView
//
//  Created by 金石教育 on 2021/2/5.
//

#import "TestViewController.h"
#import "CYColorView.h"
#import "UIViewExt.h"
@interface TestViewController ()<CYColorViewDataSource,CYColorViewDelegate>

@end

@implementation TestViewController{
    CYColorView *showView;
    NSArray *colorArr;
    UIColor *selectColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    colorArr = @[
        [UIColor blackColor]
        ,[UIColor darkGrayColor]
        ,[UIColor lightGrayColor]
        ,[UIColor grayColor]
        ,[UIColor redColor]
        ,[UIColor greenColor]
        ,[UIColor blueColor]
        ,[UIColor cyanColor]
        ,[UIColor yellowColor]
        ,[UIColor magentaColor]
        ,[UIColor orangeColor]
        ,[UIColor purpleColor]
        ,[UIColor brownColor]
    ];
    showView = [[CYColorView alloc] initWithFrame:(CGRectMake(10, 100, self.view.frame.size.width-20,  150))];
    showView.datasource = self;
    showView.delegate = self;
    [self.view addSubview:showView];
    
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, showView.bottom, showView.width/2, 50)];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UIButton *openButton = [[UIButton alloc]initWithFrame:CGRectMake(closeButton.right, showView.bottom, showView.width/2, closeButton.height)];
    [openButton setTitle:@"打开" forState:UIControlStateNormal];
    [openButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [openButton addTarget:self action:@selector(openAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openButton];
}
-(void)openAction{
    [showView openWithAnimal:YES];
}
-(void)closeAction{
    [showView closeWithAnimal:YES];
}
- (void)loadColorView:(nonnull CYColorView *)colorView withIndex:(NSInteger)index withColorItemView:(nonnull CYColorItemView *)itemView{
    UIView *_backArcView = [itemView.contentView viewWithTag:111];
    if (!_backArcView) {
        _backArcView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, itemView.contentView.width - 20, itemView.contentView.width  - 20)];
        _backArcView.tag = 111;
        _backArcView.layer.shadowColor = [[UIColor grayColor] CGColor];
        _backArcView.backgroundColor = [UIColor whiteColor];
        _backArcView.layer.shadowOffset = CGSizeMake(0, 0);
        _backArcView.layer.cornerRadius = _backArcView.width/2;
        _backArcView.layer.shadowOpacity = 0.2;
        _backArcView.clipsToBounds = NO;
        [itemView.contentView addSubview:_backArcView];
        UILabel *_colorArcView = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, _backArcView.width - 20, _backArcView.width  - 20)];
        _colorArcView.tag = 222;
        _colorArcView.layer.cornerRadius = _colorArcView.width/2;
        _colorArcView.clipsToBounds = NO;
        _colorArcView.backgroundColor = [UIColor grayColor];
        _colorArcView.textColor = [UIColor whiteColor];
        _colorArcView.textAlignment = NSTextAlignmentCenter;
        _colorArcView.clipsToBounds = YES;
        [_backArcView addSubview:_colorArcView];
    }
    UILabel *arcColorView = [_backArcView viewWithTag:222];
    arcColorView.backgroundColor = colorArr[index];
    arcColorView.text = [NSString stringWithFormat:@"%ld",index];
    if (colorArr[index] == selectColor) {
        _backArcView.backgroundColor = [UIColor redColor];
    }else{
        _backArcView.backgroundColor = [UIColor whiteColor];
    }
}
- (NSInteger)itemTotalNumWithColorView:(nonnull CYColorView *)colorView {
    return colorArr.count;
}
-(void)didSelectColorView:(CYColorView *)colorView withIndex:(NSInteger)index withColorItemView:(CYColorItemView *)itemView{
    NSLog(@"选中了第%ld个",index);
    selectColor = colorArr[index];
    [colorView reloadData];
}
@end
