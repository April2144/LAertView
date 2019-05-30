//
//  LAlertView.m
//  LAlertView
//
//  Created by limengzhu on 2019/5/24.
//  Copyright © 2019 limengzhu. All rights reserved.
//

#import "LAlertView.h"
static CGFloat const LAlertViewTitleFont = 18.f;
static CGFloat const LAlertViewMessageFont = 14.f;
static CGFloat const LAlertViewTopMargin = 10.f;
static CGFloat const LAlertViewBottomMargin = 20.f;
static CGFloat const LAlertViewItemSpaceMargin = 10.f;

@protocol LListViewCellDelegate <NSObject>

- (void)didbuttonClick:(NSInteger)index;

@end
@interface LListViewCell : UITableViewCell
@property (nonatomic,strong)NSArray *itemArr;
@property (nonatomic,strong)UIView *horizontalSeparatorLine;
@property (nonatomic,weak)id<LListViewCellDelegate>delegate;
@end
@implementation LListViewCell
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self){
        [self initializer];
    }

    return self;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initializer];
    }
    return self;
}

- (void)initializer{
    _horizontalSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.0)];
    _horizontalSeparatorLine.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
    [self addSubview:_horizontalSeparatorLine];
}

-(void)setItemArr:(NSArray *)itemArr{
    if (itemArr.count == 1) {
        self.horizontalSeparatorLine.hidden = YES;
        UIButton *listbutton = [UIButton buttonWithType:UIButtonTypeSystem];
        listbutton.tag = 100 ;
        listbutton.frame = CGRectMake(20, 0, CGRectGetWidth(self.frame) - 40, CGRectGetHeight(self.frame)-1);
        [listbutton setTitle:[itemArr objectAtIndex:0] forState:UIControlStateNormal];
        listbutton.backgroundColor = [UIColor clearColor];
        [listbutton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        listbutton.titleLabel.font = [UIFont systemFontOfSize:LAlertViewMessageFont];
        listbutton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [listbutton addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:listbutton];
    }else if(itemArr.count == 2){
        self.horizontalSeparatorLine.hidden = NO;
        for (int i =0; i<itemArr.count;i++ ) {
            UIButton *listbutton = [UIButton buttonWithType:UIButtonTypeSystem];
            listbutton.tag = 100 + i ;
            listbutton.frame = CGRectMake((CGRectGetWidth(self.frame) - 1)/2.0 * i
                                          , 1, (CGRectGetWidth(self.frame) - 1)/2.0, CGRectGetHeight(self.frame)-1);
            [listbutton setTitle:[itemArr objectAtIndex:i] forState:UIControlStateNormal];
            listbutton.backgroundColor = [UIColor clearColor];
            [listbutton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            listbutton.titleLabel.font = [UIFont systemFontOfSize:LAlertViewMessageFont];
            listbutton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [listbutton addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:listbutton];
            
            if (i == 0) {
                UIView *verticalSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(listbutton.frame),1,1, CGRectGetHeight(self.frame)-1)];
                verticalSeparatorLine.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
                [self addSubview:verticalSeparatorLine];
            }
        }
    }
}

-(void)buttonTap:(UIButton*)sender{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didbuttonClick:)]) {
        [self.delegate didbuttonClick:(sender.tag - 100)];
    }
}

@end

@interface LAlertView ()<UITableViewDelegate,UITableViewDataSource,LListViewCellDelegate>{
    CGFloat flyoutViewWidth;
    CGFloat flyoutViewHeight;
    UIWindow *_alertWindow;
}
@property (nonatomic, weak) UIView      *alphaBackgroundView;
@property (nonatomic, weak) UIView      *flyoutView;//弹出视图
@property (nonatomic, weak) UILabel     *titleLabel;
@property (nonatomic, weak) UILabel     *messageLabel;
@property (nonatomic, weak) UITableView *listView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic, weak) id<LAlertViewDelegate>delegate;
@property (nonatomic, assign) LAlertViewStyle alertViewStyle;

@end
@implementation LAlertView
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                        style:(LAlertViewStyle)style
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION{
    if(self = [super init]){
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.4f];
        _alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _alertWindow.backgroundColor = [UIColor clearColor];
        _alertWindow.windowLevel = UIWindowLevelAlert;
        _alertWindow.hidden = YES;
        
        self.frame = _alertWindow.frame;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIViewController *controller = [[UIViewController alloc] init];
        controller.view.backgroundColor = [UIColor yellowColor];
        _alertWindow.rootViewController = controller;
        flyoutViewWidth = 270;
        flyoutViewHeight = 0.0f;
        self.titleLabel.text = title;
        self.messageLabel.text = message;
        self.alertViewStyle = style;
        self.delegate = delegate;
        self.buttonTitles = @[].mutableCopy;
        if (cancelButtonTitle) {
            [self.buttonTitles addObject:cancelButtonTitle];
        }
        if (otherButtonTitles) {
            [self.buttonTitles addObject:otherButtonTitles];
        }
        va_list argList;
        va_start(argList, otherButtonTitles);
        NSString *buttonTitleString;
        while ((buttonTitleString = va_arg(argList, NSString *))) {
            [self.buttonTitles addObject:buttonTitleString];
        }
        va_end(argList);
        [self.listView reloadData];
    }
    return self;
}
- (void)show{
    UIViewController *rootController = (UIViewController *)_alertWindow.rootViewController;
    rootController.view = self;
    _alertWindow.hidden = NO;
    [_alertWindow makeKeyAndVisible];
}
- (void)close{
    _alertWindow.hidden = YES;
    [_alertWindow resignKeyWindow];
    [self removeFromSuperview];
}
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated{
    
}
- (void)dealloc {
    self.delegate = nil;
}
#pragma mark - LListViewCellDelegate
-(void)didbuttonClick:(NSInteger)index{
    if ([self.delegate respondsToSelector:@selector(cuscomsAlertView:clickedButtonAtIndex:)]) {
        [self.delegate cuscomsAlertView:self clickedButtonAtIndex:index];
    }
    [self close];
}
#pragma mark - Event response
- (void)buttonTap:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(cuscomsAlertView:clickedButtonAtIndex:)]) {
        [self.delegate cuscomsAlertView:self clickedButtonAtIndex:button.tag];
    }
    [self close];
}
#pragma mark - Private method
#pragma mark - LayoutSubviews
#pragma mark 布局标题
- (CGFloat)layoutTitleLabel {
    if (!self.titleLabel.text || [self.titleLabel.text isEqualToString:@""]) {
        return 0;
    }
    CGSize size = [self getStringSizeWithString:self.titleLabel.text FontSize:LAlertViewTitleFont maxWidth:flyoutViewWidth maxHeight:MAXFLOAT];
    NSDictionary *titleViews  = NSDictionaryOfVariableBindings(_titleLabel);
    NSArray *HTitleContrains = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_titleLabel]-20-|" options:0 metrics:nil views:titleViews];
    NSArray *VTitleContrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-LAlertViewTopMargin-[_titleLabel(height)]-|" options:0 metrics:@{@"height":@(size.height),@"LAlertViewTopMargin":@(LAlertViewTopMargin)} views:titleViews];
    [_flyoutView addConstraints:HTitleContrains];
    [_flyoutView addConstraints:VTitleContrains];
    flyoutViewHeight += size.height + LAlertViewTopMargin + LAlertViewItemSpaceMargin;
    return size.height + LAlertViewTopMargin + LAlertViewItemSpaceMargin;
}

#pragma mark 布局消息
- (CGFloat)layoutMessageLabel {
    if (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""]) {
        return 0;
    }
    CGSize size = [self getStringSizeWithString:self.messageLabel.text FontSize:LAlertViewMessageFont maxWidth:flyoutViewWidth maxHeight:MAXFLOAT];
    NSDictionary *messageViews  = NSDictionaryOfVariableBindings(_messageLabel);
    NSArray *HMessageContrains = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_messageLabel]-20-|" options:0 metrics:nil views:messageViews];
    NSArray *VMessageContrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-flyoutViewHeight-[_messageLabel(height)]-|" options:0 metrics:@{@"height":@(size.height),@"flyoutViewHeight":@(flyoutViewHeight)} views:messageViews];
    [_flyoutView addConstraints:HMessageContrains];
    [_flyoutView addConstraints:VMessageContrains];
    flyoutViewHeight += size.height + LAlertViewBottomMargin;
    return size.height + LAlertViewBottomMargin;
}
#pragma mark 布局按钮
- (CGFloat)layoutButtons {
    if (0 == self.buttonTitles.count || ((!self.titleLabel.text || [self.titleLabel.text isEqualToString:@""])
                                         && (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""]))) {
        return 0;
    }
    CGFloat listViewHeight = [self rowHeight]*(self.buttonTitles.count > 2? self.buttonTitles.count:1);
    NSDictionary *listViews  = NSDictionaryOfVariableBindings(_listView);
    NSArray *HListContrains = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_listView]-|" options:0 metrics:nil views:listViews];
    NSArray *VListContrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-flyoutViewHeight-[_listView(listViewHeight)]" options:0 metrics:@{@"flyoutViewHeight":@(flyoutViewHeight),@"listViewHeight":@(listViewHeight)} views:listViews];
    [_flyoutView addConstraints:HListContrains];
    [_flyoutView addConstraints:VListContrains];
    flyoutViewHeight += listViewHeight;
    return listViewHeight;
}
#pragma mark 布局主窗口
-(void)layoutSubviews{
    //主窗口
    CGFloat titleHeight = [self layoutTitleLabel];
    CGFloat messageHeight = [self layoutMessageLabel];
    CGFloat listViewHeight=  [self layoutButtons];
    flyoutViewHeight = MIN(flyoutViewHeight, CGRectGetHeight(self.frame) - 40);
    if (listViewHeight > (flyoutViewHeight - titleHeight - messageHeight)) {
        _listView.bounces = YES;
    }
    
    NSDictionary *flyoutViews  = NSDictionaryOfVariableBindings(_flyoutView);
    NSArray *HContrains = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_flyoutView(flyoutViewWidth)]" options:0 metrics:@{@"flyoutViewWidth":@(flyoutViewWidth)} views:flyoutViews];
    NSArray *VContrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_flyoutView(flyoutViewHeight)]" options:0 metrics:@{@"flyoutViewHeight":@(flyoutViewHeight)} views:flyoutViews];
    NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:_flyoutView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:_flyoutView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraints:HContrains];
    [self addConstraints:VContrains];
    [self addConstraint:xConstraint];
    [self addConstraint:yConstraint];
}
#pragma mark - 获取字符串大小
- (CGSize)getStringSizeWithString:(NSString *)string FontSize:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGRect rect = [string boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:dict
                                       context:nil
                   ];
    return rect.size;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.buttonTitles.count <= 2) {
        return 1;
    }
    return self.buttonTitles.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LListViewCell" forIndexPath:indexPath];
    if (self.buttonTitles.count > 2) {
        if (indexPath.row == 0) {
            cell.horizontalSeparatorLine.hidden = YES;
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = self.buttonTitles[indexPath.row];
    }else{
        cell.delegate = self;
        cell.itemArr = self.buttonTitles;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self rowHeight];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(cuscomsAlertView:clickedButtonAtIndex:)]) {
        [self.delegate cuscomsAlertView:self clickedButtonAtIndex:indexPath.row];
    }
    [self close];
}
#pragma mark - Getter

- (UIView *)flyoutView {
    if (!_flyoutView) {
        UIView *view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor whiteColor];
        view.clipsToBounds = YES;
        view.layer.cornerRadius = 12.f;
        [self addSubview:view];
        _flyoutView = view;
    }
    return _flyoutView;
}
-(UITableView *)listView{
    if (!_listView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.bounces = NO;
        [tableView registerClass:[LListViewCell class] forCellReuseIdentifier:@"LListViewCell"];
        [self.flyoutView addSubview:tableView];
        _listView = tableView;
    }
    return _listView;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:LAlertViewTitleFont];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [self.flyoutView addSubview:label];
        _titleLabel = label;
    }
    return _titleLabel;
}
- (UILabel *)messageLabel {
    if (!_messageLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:LAlertViewMessageFont];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithWhite:0.4f alpha:1.f];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [self.flyoutView addSubview:label];
        _messageLabel = label;
    }
    return _messageLabel;
}
- (CGFloat)rowHeight{
    return 45;
}


@end
