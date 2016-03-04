//
//  ZJCalendar.m
//  T
//
//  Created by Jion on 15/11/5.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "ZJCalendar.h"
#import "NSDate+ZJSetCalendar.h"
#import "ZJCalendarRange.h"
#import "ZJButton.h"

@interface ZJCalendar ()<UIScrollViewDelegate>
{
    //星期
    UIView *_headView;
    //日历的展示
    UIView *_bodyViewL;
    UIView *_bodyViewM;
    UIView *_bodyViewR;
    //滑动功能的支持
    UIScrollView *_scrollView;
    NSDate       *_today;
    
    //用来显示日期
    UILabel *showDate;
    
}

@property (nonatomic,strong)NSDate  *currentDate;
//日期对象
@property (nonatomic,strong)NSMutableArray *markArray;
//长按开始和结束日期
@property (nonatomic, copy) NSDateComponents *draggingEndDay;
@property (nonatomic, copy) NSDateComponents *draggingStartDay;


@end

@implementation ZJCalendar

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    _markArray = [NSMutableArray array];
    [self reloadViews];
   
}

/*--------------------简单的日历写法-----------------------------------*/
- (void)reloadViews{
    _currentDate = [NSDate date];
    _today = [NSDate date];
    
    self.title = [NSString stringWithFormat:@"%d年%d月",[_today getYear],[_today getMonth]];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.width/7*6)];
    _scrollView.backgroundColor = [UIColor orangeColor];
    _scrollView.contentSize = CGSizeMake(3*self.view.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0);
    _scrollView.pagingEnabled=YES;
    _scrollView.delegate=self;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_scrollView];
    
    
    _bodyViewL = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
    [_scrollView addSubview:_bodyViewL];
    _bodyViewM = [[UIView alloc]initWithFrame:CGRectMake(_scrollView.frame.size.width,0,  _scrollView.frame.size.width, _scrollView.frame.size.height)];
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureAction:)];
    longGesture.minimumPressDuration = 1.0;
    [_bodyViewM addGestureRecognizer:longGesture];
    [_scrollView addSubview:_bodyViewM];
    _bodyViewR = [[UIView alloc]initWithFrame:CGRectMake(_scrollView.frame.size.width*2, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
    [_scrollView addSubview:_bodyViewR];
    
    //展示星期
    _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    _headView.backgroundColor = [UIColor redColor];
    NSArray * weekArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for (int i=0; i<7; i++) {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/7*i, 0, self.view.frame.size.width/7, 30)];
        if (i!=0&&i!=6) {
            label.backgroundColor = [UIColor redColor];
        }else{
            label.backgroundColor = [UIColor purpleColor];
        }
        label.text=weekArray[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.borderColor = [[UIColor grayColor]CGColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.textColor = [UIColor whiteColor];
        label.layer.borderWidth = 1;
        [_headView addSubview:label];
    }
    [self.view addSubview:_headView];
    
    [self creatViewWithData:[_currentDate getPreviousframDate:_currentDate] onView:_bodyViewL];
    [self creatViewWithData:[_currentDate getNextMonthframDate:_currentDate] onView:_bodyViewR];
    [self creatViewWithData:_currentDate onView:_bodyViewM];
    
    //label只是为了显示，这种写法是不好的
    showDate = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, CGRectGetMaxY(_scrollView.frame), 200, 30)];
    showDate.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:showDate];
}

//核心方法
- (void)creatViewWithData:(id)data onView:(UIView *)bodyView
{
    NSDate *currentDate = (NSDate*)data;
    //获取当前月有多少天
    int monthNum = (int)[currentDate numberOfDaysInCurrentMonth];
    //获取第一天的日期
    NSDate *fistDate = [currentDate firstDayOfCurrentMonth];
    //确定这一天是周几
    int weekday = (int)[fistDate weeklyOrdinality];
    weekday=weekday-1;
    //确定创建多少行
    int weekRow=0;
    int tmp=monthNum;
//    if (weekday != 7) {
//        weekRow++;
//        tmp = monthNum - (7-weekday);
//    }
    tmp+=weekday;
    weekRow += tmp/7;
    weekRow += (tmp%7)?1:0;
    
    //先移除View上的表格，再创建表格
    NSArray *array = [bodyView subviews];
    for (UIView *view in  array) {
        [view removeFromSuperview];
    }
    
     int nextDate = 1;
    //行
    for (int i = 0; i< weekRow; i++) {
        //列
        for (int j=0; j<7; j++) {
            //先进行上个月余天的创建
            ZJButton * btn;
            if (weekday != 0 && (i*7+j)<weekday) {
                //获取上个月有多少天
                NSDate * preDate = [currentDate getPreviousframDate:currentDate];
                int preDays = (int)[preDate numberOfDaysInCurrentMonth];
                NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitCalendar fromDate:preDate];
                
                btn =[[ZJButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/7*j, self.view.frame.size.width/7*i, self.view.frame.size.width/7, self.view.frame.size.width/7)];
                dateComponents.day = preDays-weekday+j+1;
                dateComponents.weekday = j;
                
                btn.dateComponents = dateComponents;
                [btn setTitle:[NSString stringWithFormat:@"%ld",(long)dateComponents.day] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [bodyView addSubview:btn];
            }
            
            else if ( i*7+j+1-(weekday==0?0:weekday)<=monthNum){
                NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitCalendar fromDate:currentDate];
                
                
                btn =[[ZJButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/7*j, self.view.frame.size.width/7*i, self.view.frame.size.width/7, self.view.frame.size.width/7)];
                
                dateComponents.day = i*7+j+1-(weekday==7?0:weekday);
                dateComponents.weekday = j;
                btn.dateComponents = dateComponents;
                [btn setTitle:[NSString stringWithFormat:@"%ld",dateComponents.day] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [bodyView addSubview:btn];
            }
            //下个月余天的创建
            else
            {
                NSDate * preDate = [currentDate getNextMonthframDate:currentDate];
                NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitCalendar fromDate:preDate];
                
                btn =[[ZJButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/7*j, self.view.frame.size.width/7*i, self.view.frame.size.width/7, self.view.frame.size.width/7)];
                dateComponents.day = nextDate++;
                dateComponents.weekday = j;
                btn.dateComponents = dateComponents;
                [btn setTitle:[NSString stringWithFormat:@"%ld",btn.dateComponents.day] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [bodyView addSubview:btn];
            }
            //将今天的日期标出
            if ([currentDate getYear]==[_today getYear]&&[currentDate getMonth]==[_today getMonth]&&[btn.titleLabel.text intValue]==[_today getDay]&&!CGColorEqualToColor([btn.titleLabel.textColor CGColor], [[UIColor grayColor] CGColor])) {
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
            if (!CGColorEqualToColor([btn.titleLabel.textColor CGColor], [[UIColor grayColor] CGColor]))
            {
                //添加点击事件
                [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            }
            
           
            [UIView animateWithDuration:0.3 animations:^{
                _scrollView.frame = CGRectMake(0, 30, self.view.bounds.size.width,weekRow * self.view.bounds.size.width/7);
                _scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0);
                showDate.frame = CGRectMake(self.view.frame.size.width/2 - 100, CGRectGetMaxY(_scrollView.frame), 200, 30);
            }];
            
            //是否有节点标记
            [self loadMarkDate:btn];
            
        }
    }
    
}

- (void)loadMarkDate:(ZJButton*)sender
{
    for (NSDictionary *markDic in _markArray) {
        
        NSDateComponents *startDay = [markDic valueForKey:@"startDay"];
        NSDateComponents *endDay = [markDic valueForKey:@"endDay"];
        UIColor *bgColor = [markDic valueForKey:@"color"];
        if (startDay == nil ||endDay== nil) return;
        ZJCalendarRange *range = [[ZJCalendarRange alloc] initWithStartDay:startDay endDay:endDay];
        if ([range containsDay:sender.dateComponents]) {
            sender.backgroundColor = bgColor;
        }
    }
}

#pragma mark--UIScrollViewDelegate
//方法重构
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x==0) {
        //向前翻页了
        _currentDate = [_currentDate getPreviousframDate:_currentDate];
        _scrollView.contentOffset=CGPointMake(scrollView.frame.size.width, 0);
        
        
        [self creatViewWithData:[_currentDate getPreviousframDate:_currentDate] onView:_bodyViewL];
        [self creatViewWithData:[_currentDate getNextMonthframDate:_currentDate] onView:_bodyViewR];
        [self creatViewWithData:_currentDate onView:_bodyViewM];
        
    }else if (scrollView.contentOffset.x==scrollView.frame.size.width){
        
    }else if (scrollView.contentOffset.x==scrollView.frame.size.width*2){
        _currentDate = [_currentDate getNextMonthframDate:_currentDate];
        _scrollView.contentOffset=CGPointMake(scrollView.frame.size.width, 0);
        
        
        [self creatViewWithData:[_currentDate getPreviousframDate:_currentDate] onView:_bodyViewL];
        [self creatViewWithData:[_currentDate getNextMonthframDate:_currentDate] onView:_bodyViewR];
        [self creatViewWithData:_currentDate onView:_bodyViewM];
    }
    self.title = [NSString stringWithFormat:@"%d年%d月",[_currentDate getYear],[_currentDate getMonth]];
    
    
//    scrollView.userInteractionEnabled=YES;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    scrollView.userInteractionEnabled=NO;
}

#pragma mark--Action
//点击事件
-(void)clickBtn:(ZJButton *)btn
{
    NSLog(@"%ld年%ld月%ld日 周%@",btn.dateComponents.year,btn.dateComponents.month,btn.dateComponents.day,(long)btn.dateComponents.weekday==0?@"日":[NSString stringWithFormat:@"%ld",(long)btn.dateComponents.weekday]);
    
    for (UIView *bn in btn.superview.subviews) {
        if ([bn isKindOfClass:[ZJButton class]]) {
            bn.backgroundColor = [UIColor clearColor];
        }
    }
    btn.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //label只是为了显示
    showDate.text = [NSString stringWithFormat:@"%ld年%ld月%ld日 周%@",btn.dateComponents.year,btn.dateComponents.month,btn.dateComponents.day,(long)btn.dateComponents.weekday==0?@"日":[NSString stringWithFormat:@"%ld",(long)btn.dateComponents.weekday]];
    
    
}
//长按事件
- (void)longGestureAction:(UILongPressGestureRecognizer*)longGesture
{
    NSLog(@"长按");
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        _draggingStartDay = nil;
        _draggingEndDay = nil;
    }
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    //动画时间
    animation.duration = 0.5;
    animation.type = @"rippleEffect";
    [longGesture.view.layer addAnimation:animation forKey:@"animation"];

   UIView *selectionView = [longGesture.view hitTest:[longGesture locationInView:longGesture.view] withEvent:nil];
    
    while (selectionView != longGesture.view) {
        if ([selectionView isKindOfClass:[ZJButton class]]) {
            ZJButton *bt = (ZJButton*)selectionView;
            if (self.draggingStartDay==nil) {
                self.draggingStartDay = bt.dateComponents;
            }
            if (self.draggingEndDay == nil||[self.draggingStartDay.date compare:bt.dateComponents.date] != NSOrderedDescending) {
                self.draggingEndDay = bt.dateComponents;
            }
            
            NSLog(@"===%@==%ld",bt.titleLabel.text,self.draggingEndDay.day);
            
        }
        selectionView = selectionView.superview;
    }
    for (UIView *view in longGesture.view.subviews) {
        view.backgroundColor = [UIColor clearColor];
        if ([view isKindOfClass:[ZJButton class]]) {
            ZJButton *bt = (ZJButton*)view;
            ZJCalendarRange *range = [[ZJCalendarRange alloc] initWithStartDay:self.draggingStartDay endDay:self.draggingEndDay];
            if ([range containsDay:bt.dateComponents]) {
                bt.backgroundColor = [UIColor grayColor];
            }
        }
    }
    //记录开始和结束的时间点
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        [_markArray addObject:@{@"startDay":self.draggingStartDay,@"endDay":self.draggingEndDay,@"color":[UIColor grayColor]}];
    }
}


//异或加密算法
-(NSString*)encodeString:(NSString*)data :(NSString*)key{
    
    data =  [data stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *result=[NSString string];
    
    //      char Sdata[8];
    for(int i=0; i < [data length]; i++){
        
        
        //        NSLog(@"key == %c",[key characterAtIndex:i]);
        char chData=[data characterAtIndex:i]^[key characterAtIndex:i];
        //        NSLog(@"data == %d",chData);
        if(chData)
            result=[NSString stringWithFormat:@"%@%@",result,[NSString stringWithFormat:@"%c",chData]];
        else
        {
            result=[NSString stringWithFormat:@"%@%@",result,@"\0"];
            
        }
        
        //        Sdata[i] = chData;
    }
    //    result = [NSString stringWithCString:Sdata encoding:NSUTF8StringEncoding];
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
