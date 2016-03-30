//
//  ViewController.m
//  zuoyetwo
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 m14a.cn. All rights reserved.
//

#import "ViewController.h"
#import "XMGStatus.h"
#import "XMGStatusCell.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface ViewController ()

/** 微博数组*/
@property (nonatomic, strong) NSMutableArray *statuses;
/** 页数*/
@property (nonatomic, assign) NSInteger page;

@end

@implementation ViewController

#pragma mark - 懒加载
- (NSMutableArray *)statuses
{
    if (_statuses == nil) {
        _statuses = [NSMutableArray array];
    }
    return _statuses;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setupRowHeight];
    
    // 集成下拉刷新控件
    [self setupDownRefresh];
    
    // 集成上拉刷新控件
    [self setupUpRefresh];
}

- (void)setupRowHeight
{
    // iOS8之后才拥有的技术
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
}

#pragma mark - 集成下拉刷新控件
- (void)setupDownRefresh
{
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        [weakSelf loadNewData];
    }];
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 集成上拉刷新控件
- (void)setupUpRefresh
{
    // 进入刷新状态后会自动调用这个block
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    self.tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
}

- (void)loadNewData
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //设置响应格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //修改数据的解析方式
    //3种解析方式:JSON & XML &http(不做任何处理)
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //创建字典,转载参数
    NSDictionary *dictM =@{
                           @"page":@1
                           };
    // 赋值
    self.page = 1;
    
    // 3.发送请求
    [manager POST:@"http://api.liyaogang.com/weibo/status.php" parameters:dictM success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // 字典数组转模型数组
        self.statuses = [XMGStatus mj_objectArrayWithKeyValuesArray:responseObject];
        
        if (self.statuses.count == 0) { // 返回数据为空
            // 结束刷新
            [self.tableView.mj_header endRefreshing];
            return ;
        }
        
        // 刷新表格
        [self.tableView reloadData];
        // 结束刷新
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"失败--%@",error);
        
    }];
}

- (void)loadMoreData
{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //设置响应格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //修改数据的解析方式
    //3种解析方式:JSON & XML &http(不做任何处理)
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    // 赋值
    self.page++;
    NSNumber *page = [[NSNumber alloc] initWithInteger:self.page];;
    
    //创建字典,转载参数
    NSDictionary *dictM =@{
                           @"page":page
                           };
    // 3.发送请求
    [manager POST:@"http://api.liyaogang.com/weibo/status.php" parameters:dictM success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // 字典数组转模型数组
        NSArray *newStatuses = [XMGStatus mj_objectArrayWithKeyValuesArray:responseObject];
        
        if (newStatuses.count == 0) { // 下拉没有更多数据了
            // 0.设置黑色的遮罩
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD showErrorWithStatus:@"没有更多数据了"];
        }
        
        // 来到这,说明有数据,将更多的微博数据，添加到总数组的最后面
        [self.statuses addObjectsFromArray:newStatuses];
        
        // 刷新表格
        [self.tableView reloadData];
        // 结束刷新
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"失败--%@",error);
        
    }];
}


#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statuses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 去缓存池里面找，如果没有找到，去storyboard里面找
    static NSString *ID = @"status";
    XMGStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];

    // 传递模型数据
    cell.status = self.statuses[indexPath.row];
    
    return cell;
}


@end
