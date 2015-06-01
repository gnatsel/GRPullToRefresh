//
//  ViewController.m
//  SampleGRPullToRefresh
//
//  Created by Gnatsel Reivilo on 01/06/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+GRPullToRefresh.h"
#import "UIScrollView+GRInfiniteScrolling.h"
#import "GRCustomRefreshView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (strong, nonatomic) GRCustomRefreshView *pullToRefreshView;
@property (strong, nonatomic) GRCustomRefreshView *infiniteScrollingRefreshView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _dataSource = [self generateData];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self configurePullToRefresh];
    [self configureInfiniteScrolling];
}
- (NSMutableArray *)generateData{
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:10];
    for(NSInteger i = 0; i < 10 ; i++){
        [dataArray addObject:@"row : "];
    }
    return dataArray;
}
-(void)resetData{
    if(_pullToRefreshView.isAnimating){
        _pullToRefreshView.shouldEndAnimating = YES;
    }
    _dataSource = [self generateData];
    [_tableView reloadData];
}

-(void)appendData{
    if(_infiniteScrollingRefreshView.isAnimating){
        _infiniteScrollingRefreshView.shouldEndAnimating = YES;
    }
    NSMutableArray *dataArray = [self generateData];
    
    NSMutableArray *indexPathsToInsertArray = [NSMutableArray arrayWithCapacity:dataArray.count];
    for(NSInteger i = 0; i < dataArray.count ; i++){
        [indexPathsToInsertArray addObject:[NSIndexPath indexPathForRow:i+_dataSource.count inSection:0]];
    }
    
    [_dataSource addObjectsFromArray:dataArray];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPathsToInsertArray withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    
}
-(void)configurePullToRefresh{
    if(!_pullToRefreshView){
        _pullToRefreshView = [[GRCustomRefreshView alloc]initWithFrame:CGRectMake(0, 0, 60, 60) ];
        ViewController *weakSelf = self;
        [_tableView addPullToRefreshWithActionHandler:^{
            [weakSelf performSelector:@selector(resetData) withObject:nil afterDelay:2];
        } refreshView:_pullToRefreshView];
    }

}


-(void)configureInfiniteScrolling{
    if(!_infiniteScrollingRefreshView){
        _infiniteScrollingRefreshView = [[GRCustomRefreshView alloc]initWithFrame:CGRectMake(0, 0, 60, 60) ];
        ViewController *weakSelf = self;
        [_tableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf performSelector:@selector(appendData) withObject:nil afterDelay:2];
        } refreshView:_infiniteScrollingRefreshView];
    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@%i",_dataSource[indexPath.row],(int)indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

@end
