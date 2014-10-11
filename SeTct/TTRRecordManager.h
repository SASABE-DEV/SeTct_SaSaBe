//
//  TTRRecordManager.h
//  SeTct
//
//  Created by kunii on 2014/10/09.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTRRecordManager;
@protocol TTRRecordManagerDelegate <NSObject>
///  ログインの返答。
- (void)recordManager:(TTRRecordManager*)recordManager didReceiveLoginResponse:(NSDictionary*)responce;

///  ログアウトの返答。
- (void)recordManager:(TTRRecordManager*)recordManager didReceiveLogoutResponse:(NSDictionary*)responce;

///  デバイス更新の返答。
- (void)recordManager:(TTRRecordManager*)recordManager didReceiveUpdateDeviceResponse:(NSDictionary*)responce;

///  セッションチェックの返答。
- (void)recordManager:(TTRRecordManager*)recordManager didReceiveSessionResponse:(NSDictionary*)responce;

///  通信エラー
- (void)recordManager:(TTRRecordManager*)recordManager didFailWithError:(NSError*)error;
@end

@interface TTRRecordManager : NSObject
/// ログイン
- (void)login;

/// ログアウト
- (void)logout;

/// デバイス更新
- (void)updateDevice;

/// セッション開始。20分ごとにセッションチェック。
- (void)startSession;

/// セッション停止。
- (void)stopSession;

/// ウエブ画面のスタート
- (NSURLRequest*)homeURLRequest;

/// デバイスID
- (NSString*)identifier;

/// ユーザーID
@property (strong, nonatomic) NSString* name;

/// パスワード
@property (strong, nonatomic) NSString* password;

/// デリゲート
@property (weak, nonatomic) id<TTRRecordManagerDelegate> delegate;
@end
