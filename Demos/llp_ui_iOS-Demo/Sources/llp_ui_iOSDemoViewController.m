//
//  llp_ui_iOSDemoViewController.m
//  llp_ui_iOSDemo
//
//  Created by QYChu on 2023/4/26.
//

#import "llp_ui_iOSDemoViewController.h"
#import <llp_ui_iOS/llp_ui_iOS.h>
#import <Masonry/Masonry.h>

@interface llp_ui_iOSDemoViewController ()

@end

@implementation llp_ui_iOSDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Example";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"跳转页面" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)goPage {
    [self.navigationController pushViewController:[[llp_ui_iOSViewController alloc] init] animated:YES];
}

@end
