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
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 70, 30);
    btn.backgroundColor = [UIColor orangeColor];
    [btn.layer setCornerRadius:5.0f];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [btn setTitle:@"无数据" forState:UIControlStateNormal];
    [btn setTitle:@"有数据" forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(btnActonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)_setUpMainView{
    
    self.tableView.tableFooterView = [UIView new];
    [self loadingData:NO];
    
//    // 配置参数
//        self.tableView.buttonText = @"再次请求";
//        self.tableView.buttonNormalColor = [UIColor redColor];
//        self.tableView.buttonHighlightColor = [UIColor yellowColor];
//        self.tableView.loadedImageName = @"noDataDefault.png";
//        self.tableView.descriptionText = @"你可以尝试再次请求";
//        self.tableView.dataVerticalOffset = 100;
    
    // 点击响应
    [self.tableView loadingWithTapBlock:^{
        NSLog(@"重新加载...");
        [self loadingData:NO];
    }];
}

- (void)btnActonClick:(UIButton *)btn{
    btn.selected = !btn.selected;

    if (btn.selected) {
        [self loadingData:YES];
        btn.backgroundColor = [UIColor redColor];
    }else{
        btn.backgroundColor = [UIColor orangeColor];
        [self loadingData:NO];
    }
}

-(void)loadingData:(BOOL)data{
    if (self.dataSouce.count > 0) {
        [self.dataSouce removeAllObjects];
        [self.tableView reloadData];
    }
    
    self.tableView.installYJLoading = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (data) {
            for (int i = 0; i < 100; i++) {
                [self.dataSouce addObject:[NSString stringWithFormat:@"终于有数据的了...%d", i]];
            }
        }
        
        NSInteger items = 0;
        UITableView * tableView = (UITableView *)self.tableView;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }

        if (items == 0) {
            self.tableView.installYJLoading = NO;
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
