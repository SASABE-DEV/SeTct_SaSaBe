//
//  TTRLoginViewController.h
//  SeTct
//
//  Created by kunii on 2014/10/09.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTRRecordManager;
@class TTRLoginViewController;

@protocol TTRLoginViewControllerDelegate <NSObject>
- (void)didDismissLoginViewController:(TTRLoginViewController*)controller;
@end

@interface TTRLoginViewController : UIViewController
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* password;
@property (weak, nonatomic) id<TTRLoginViewControllerDelegate> delegate;
@end
