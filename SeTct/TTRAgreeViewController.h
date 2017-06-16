//
//  TTRAgreeViewController.h
//  SeTct
//
//  Created by kunii on 2014/10/10.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTRAgreeViewController;

@protocol TTRAgreeViewControllerDelegate <NSObject>
- (void)agreeViewController:(TTRAgreeViewController*)contoller didDismissWithAgree:(BOOL)agree;
@end

@interface TTRAgreeViewController : UIViewController
@property (weak, nonatomic) id<TTRAgreeViewControllerDelegate> delegate;
@end
