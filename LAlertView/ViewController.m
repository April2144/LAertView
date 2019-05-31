//
//  ViewController.m
//  LAlertView
//
//  Created by limengzhu on 2019/5/24.
//  Copyright © 2019 limengzhu. All rights reserved.
//

#import "ViewController.h"
#import "LAlertView.h"

@interface ViewController ()<UIAlertViewDelegate,LAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (IBAction)customAlertView:(id)sender {

//    @"button1",@"button3",@"button2",@"button4",@"button5",@"button6",@"button7",@"button8",@"button9",@"button10",@"button11",@"button12",@"button14",@"button15",@"button16",@"button17",@"button18",@"button19",@"button20",@"button21",@"button23",
    LAlertView *alertView = [[LAlertView alloc] initWithTitle:@"提示" message:@"自定义alertview" style:LAlertViewStyleDefault delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",@"button1",@"button3",@"button2",@"button4",@"button5",@"button6",@"button7",@"button8",@"button9",@"button10",@"button11",@"button12",@"button14",@"button15",@"button16",@"button17",@"button18",@"button19",@"button20",@"button21",@"button23",nil];
    [alertView show];
}
- (IBAction)systemAlertView:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"系统alertview" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",@"button1",@"button3",@"button2", @"button4",@"button5",@"button6",@"button7",@"button8",@"button9",@"button10",@"button11",@"button12",@"button14",@"button15",@"button16",@"button17",@"button18",@"button19",@"button20",@"button21",@"button23",nil];
    [alertView show];
}

#pragma mark --UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"系统alertview");
}
#pragma mark --LAlertViewDelegate
-(void)cuscomsAlertView:(LAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"自定义alertview");
}
@end
