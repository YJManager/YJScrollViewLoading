//
//  YJMainViewController.m
//  YJScrollViewLoadingDemo
//
//  Created by YJHou on 16/10/9.
//  Copyright © 2016年 YJHou. All rights reserved.
//

#import "YJMainViewController.h"
#import "YJScrollViewLoading.h"

@interface YJMainViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataSouce;

@end

@implementation YJMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setUpNavView];
    [self _setUpMainView];
}

- (void)_setUpNavView{
    
    self.navigationItem.title = @"YJScrollViewLoading";
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btn.frame = CGRectMake(0, 0, 60, 40);
    [btn addTarget:self action:@selector(btnActonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)_setUpMainView{
    
    self.tableView.tableFooterView = [UIView new];
    
    // 配置参数
    //    self.tableView.buttonText = @"再次请求";
    //    self.tableView.buttonNormalColor = [UIColor redColor];
    //    self.tableView.buttonHighlightColor = [UIColor yellowColor];
    //    self.tableView.loadedImageName = @"58x58";
    //    self.tableView.descriptionText = @"破网络，你还是再请求一次吧";
    //    self.tableView.dataVerticalOffset = 200;
    
    // 点击响应
    [self.tableView loadingWithTapBlock:^{
        NSLog(@"重新加载...");
        [self loadingData:NO];
    }];
}

- (void)btnActonClick:(UIButton *)btn{
    if (btn.selected) {
        [self loadingData:YES];
    }else{
        [self loadingData:NO];
    }
    btn.selected = !btn.selected;
}

-(void)loadingData:(BOOL)data{
    if (self.dataSouce.count > 0) {
        [self.dataSouce removeAllObjects];
        [self.tableView reloadData];
    }
    
    // 只需一行代码，我来解放你的代码
    self.tableView.loading = YES;
    
    // 模拟延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (data) {
            for (int i = 0; i < 100; i++) {
                [self.dataSouce addObject:[NSString stringWithFormat:@"终于有数据的了...%d", i]];
            }
        }else {// 无数据时
            self.tableView.loading = NO;
        }
        [self.tableView reloadData];
    });
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSouce.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    cell.textLabel.text = self.dataSouce[indexPath.row];
    return cell;
}

#pragma mark - Lazy
- (NSMutableArray *)dataSouce{
    if (_dataSouce == nil) {
        _dataSouce = [NSMutableArray array];
    }
    return _dataSouce;
}



@end
