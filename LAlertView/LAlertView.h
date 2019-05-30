//
//  LAlertView.h
//  LAlertView
//
//  Created by limengzhu on 2019/5/24.
//  Copyright © 2019 limengzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, LAlertViewStyle) {
    LAlertViewStyleDefault = 0,
    LAlertViewStyleSecureTextInput,
    LAlertViewStylePlainTextInput,
    LAlertViewStyleLoginAndPasswordInput
};
@class LAlertView;
@protocol LAlertViewDelegate <NSObject>

/**
 点击按钮触发代理
 
 @param alertView   告警框
 @param buttonIndex 按钮下标索引(从0开始)
 */
- (void)cuscomsAlertView:(LAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
@interface LAlertView : UIView

/**
 初始化弹窗
 
 @param title 标题
 @param message 提示信息
 @param style 弹窗风格
 @param delegate 委托对象
 @param cancelButtonTitle 取消按钮
 @param otherButtonTitles 可变动按钮
 @return SLAlertView对象
 */
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                        style:(LAlertViewStyle)style
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
/**
 显示弹窗
 */
- (void)show;

// hides alert sheet or popup. use this method when you need to explicitly dismiss the alert.
// it does not need to be called if the user presses on a button
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

// Retrieve a text field at an index
// The field at index 0 will be the first text field (the single field or the login field), the field at index 1 will be the password field. */
//- (nullable UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

@end

NS_ASSUME_NONNULL_END
