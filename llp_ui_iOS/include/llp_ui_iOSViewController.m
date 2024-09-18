//
//  llp_ui_iOSOCViewController.m
//  llp_ui_iOS
//
//  Created by AppFactory on 2023/4/13.
//

#import "llp_ui_iOSViewController.h"
#import "llp_ui_iOSHelper.h"
#import "llp_ui_iOSModel.h"

@interface llp_ui_iOSViewController ()

@end

@implementation llp_ui_iOSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"llp_ui_iOS ObjC Example";
    self.view.backgroundColor = [UIColor whiteColor];

    // 为了维护方便不要使用 xib 与 storyboard 形式
    CGRect rect = CGRectMake(0.f, 0.f, 128.f, 128.f);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect];
    imgView.center = self.view.center;
    [self.view addSubview:imgView];
    
    llp_ui_iOSModel *model = [[llp_ui_iOSModel alloc] init];
    model.name = @"李四";
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.center.x -14, imgView.center.y - 100, 100, 30)];
    label.text= model.name;
    [self.view addSubview:label];

    // 延时一秒后从网上异步展示头像
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://cdncs.101.com/v0.1/static/cscommon/avatar/734819/734819.jpg"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                imgView.image = image;
            });
        });
    }];
    [task resume];
}

@end
