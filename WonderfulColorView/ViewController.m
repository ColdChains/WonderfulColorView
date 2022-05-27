//
//  ViewController.m
//  WonderfulColorView
//
//  Created by lax on 2022/5/27.
//

#import "ViewController.h"
#import "WonderfulColorView.h"
#import "TestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WonderfulColorView *colorView = [[WonderfulColorView alloc] init];
    [self.view addSubview:colorView];
    [self.view sendSubviewToBack:colorView];
    
    colorView.itemBorderColor = [UIColor lightGrayColor];
    colorView.selectItemBlock = ^(id obj) {
        NSString *index = obj;
        NSLog(@"%@", index);
    };
    
    colorView.dataArray = @[[UIColor greenColor], [UIColor redColor], [UIColor orangeColor], [UIColor cyanColor], [UIColor yellowColor], [UIColor blackColor]];
    colorView.selectIndex = 0;
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    TestViewController *vc = [[TestViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
