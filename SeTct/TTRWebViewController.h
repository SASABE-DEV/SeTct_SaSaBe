//
//  TTRWebViewController.h
//  SeTct
//
//  Created by kunii on 2014/10/10.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTRWebViewController;

@protocol TTRWebViewControllerDelegate <NSObject>
- (void)webViewController:(TTRWebViewController*)controller withAction:(NSString*)action;
@end

@interface TTRWebViewController : UIViewController
@property (strong, nonatomic) NSURLRequest* URLRequest;
@property (weak, nonatomic) id<TTRWebViewControllerDelegate> delegate;
@end
