//
//  TTRRecordManager.m
//  SeTct
//
//  Created by kunii on 2014/10/09.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

#import "TTRRecordManager.h"

typedef enum {
    TTRRecordManagerPhaseNone,
    TTRRecordManagerPhaseLogin,
    TTRRecordManagerPhaseLogout,
    TTRRecordManagerPhaseSession,
    TTRRecordManagerPhaseUpdateDevaiceID
} TTRRecordManagerPhase;

@interface TTRRecordManager() {
    /// データ受け取り用。
    NSMutableData*      _data;
    
    /// 通信
    NSURLConnection*    _connection;

    /// ユーザーエージェント　UIWebViewから所得。
    NSString*           _userAgent;
    
    /// セッション
    NSString*           _sessionIdentifier;
    
    /// 状況
    TTRRecordManagerPhase   _phase;
    
    /// セッション確認用タイマー
    NSTimer*            _timer;
}
@end

@implementation TTRRecordManager

/// ユーザーエージェントをUIWebViewから所得。通信時に使用する。
- (id)init {
    self = [super init];
    if (self) {
        UIWebView *webView = [[UIWebView alloc] init];
        _userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        [NSUserDefaults.standardUserDefaults registerDefaults:@{@"UserAgent": _userAgent}];
    }
    return self;
}

/// デバイスIDを戻す。
- (NSString*)identifier {
    NSUUID* identifierUUID = UIDevice.currentDevice.identifierForVendor;
    printf("%s\n", identifierUUID.UUIDString.UTF8String);
    return identifierUUID.UUIDString;
}

/// ウエブ画面用スタートNSURLRequestを戻す。
- (NSURLRequest*)homeURLRequest {
    return [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.tct.k-tecs.co.jp"]];
}

/// NSURLRequest作成。ユーザーエージェントやパラメータをここで設定する。
- (NSURLRequest*)requestWithURLString:(NSString*)URLString postString:(NSString*)postString {
    NSURL *url = [NSURL URLWithString:URLString];
    //  POST用リクエスト用意
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
    assert(request != nil);
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (_sessionIdentifier) {
        // Cookieを作成する
        NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
        properties[NSHTTPCookieName] = @"CAKEPHP";
        properties[NSHTTPCookieValue] = [_sessionIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        properties[NSHTTPCookieDomain] = @"www.tct.k-tecs.co.jp";
        
        // 有効期限を1時間。
        properties[NSHTTPCookieExpires] = [NSDate.date dateByAddingTimeInterval:3600];
        properties[NSHTTPCookiePath] = @"/";
        NSHTTPCookie *cookie = [[ NSHTTPCookie alloc] initWithProperties: properties ];
        NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:@[cookie]];
        [request setAllHTTPHeaderFields:headers];
    }
    [request setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    return request;
}

///  コネクト開始
- (NSURLConnection*)connectionWithURLString:(NSString*)URLString postString:(NSString*)postString {
    _data = [NSMutableData data];
    NSURLRequest* request = [self requestWithURLString:URLString postString:postString];
    return [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

/// ユーザー名、パスワード、デバイスIDを送る。
- (void)login {
    _phase = TTRRecordManagerPhaseLogin;
    _sessionIdentifier = nil;
    NSString* postString = [NSString stringWithFormat:@"data[User][username]=%@", _name];
    postString = [postString stringByAppendingFormat:@"&data[User][password]=%@", _password];
    postString = [postString stringByAppendingFormat:@"&data[User][deviceid]=%@", self.identifier];
    _connection = [self connectionWithURLString:@"https://www.tct.k-tecs.co.jp/users/webapi_login" postString:postString];
}

/// デバイスID更新
- (void)updateDevice {
    _phase = TTRRecordManagerPhaseUpdateDevaiceID;
    NSString* postString = [NSString stringWithFormat:@"data[User][deviceid]=%@", self.identifier];
    _connection = [self connectionWithURLString:@"https://www.tct.k-tecs.co.jp/users/webapi_update_device" postString:postString];
}

- (void)logout {
    _phase = TTRRecordManagerPhaseLogout;
    NSString* postString = [NSString stringWithFormat:@"data[User][deviceid]=%@", self.identifier];
    _connection = [self connectionWithURLString:@"https://www.tct.k-tecs.co.jp/users/webapi_logout" postString:postString];
}

- (void)checkSession {
    printf("checkSession\n");
    NSString* postString = [NSString stringWithFormat:@"data[User][deviceid]=%@", self.identifier];
    _connection = [self connectionWithURLString:@"https://www.tct.k-tecs.co.jp/users/webapi_login_check" postString:postString];
}

#pragma mark - NSURLConnectionデリゲート

///  レスポンス受け取り
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

///  レスポンス受け取り完了
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError* error = nil;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    if (jsonResponse == nil) {
        if (_phase != TTRRecordManagerPhaseLogout) {  //  サーバーバグ対応。現在ログアウトはHTTPページが戻される。
            //  上記以外はエラーとする。
            [_delegate recordManager:self didFailWithError:error];
            return;
        }
    }
    NSLog(@"jsonResponse %@", jsonResponse);

    switch (_phase) {
        case TTRRecordManagerPhaseLogin:
            _sessionIdentifier = jsonResponse[@"session"];  //  OK, NG無関係にセッションは記憶。
            [_delegate recordManager:self didReceiveLoginResponse:jsonResponse];
            break;
        case TTRRecordManagerPhaseLogout:
            [_delegate recordManager:self didReceiveLogoutResponse:jsonResponse];
            break;
        case TTRRecordManagerPhaseSession:
            [_delegate recordManager:self didReceiveSessionResponse:jsonResponse];
            break;
        case TTRRecordManagerPhaseUpdateDevaiceID:
            [_delegate recordManager:self didReceiveUpdateDeviceResponse:jsonResponse];
            break;
        default:
            break;
    }
    _connection = nil;
}

/// 通信エラー
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    if (_connection) {  //  _connectionがnilの場合は故意のキャンセルなので通知しない。
        [_delegate recordManager:self didFailWithError:error];
        _connection = nil;
    }
}

/// レスポンス基礎チェック
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    if ((httpResponse.statusCode / 100) != 2) {
        NSLog(@"HTTP error %zd", (ssize_t) httpResponse.statusCode);
    } else {
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
        // the string, so we can just use -isEqual: on the result.
        NSString * contentTypeHeader = [httpResponse MIMEType];
        if (contentTypeHeader == nil) {
            NSLog(@"No Content-Type!");
        } else {
            ;   //  ("content-Type = %s\n", [contentTypeHeader UTF8String]);
        }
    }
}

/// 認証情報送信
-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] > 0) {
        NSLog(@"challenge proposedCredential");
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        return;
    }
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]
        || [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {
        if ([challenge proposedCredential]) {
            [connection cancel];
            return;
        }
        //  単純なログイン/パスワード型の認証
        NSURLCredential *credential = [NSURLCredential credentialWithUser:_name
                                                                 password:_password
                                                              persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        return;
    }
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // SSL認証時        
        //  OSにおまかせ
        [[challenge sender] performDefaultHandlingForAuthenticationChallenge: challenge];
    }
}

///  セッション開始
- (void)startSession {
    _phase = TTRRecordManagerPhaseSession;
    // ストレージを取得する
    NSHTTPCookieStorage *storage = [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    //  設定。
    [storage setCookieAcceptPolicy: NSHTTPCookieAcceptPolicyAlways];
    
    // Cookieを作成する
    NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
    properties[NSHTTPCookieName] = @"CAKEPHP";
    properties[NSHTTPCookieValue] = [_sessionIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    properties[NSHTTPCookieDomain] = @"www.tct.k-tecs.co.jp";
    
    // 有効期限を1時間。
    properties[NSHTTPCookieExpires] = [NSDate.date dateByAddingTimeInterval:3600];
    properties[NSHTTPCookiePath] = @"/";                                             /* パス設定 */
    
    NSHTTPCookie *cookie = [[ NSHTTPCookie alloc] initWithProperties: properties ];
    [storage setCookie:cookie];

    _timer = [NSTimer scheduledTimerWithTimeInterval:1200.0 target:self selector:@selector(checkSession) userInfo:nil repeats:YES];
}

///  セッション終了
- (void)stopSession {
    if (_connection) {  //  実行中の通信はキャンセル。
        [_connection cancel];
        _connection = nil;
    }
    _phase = TTRRecordManagerPhaseNone;
    [_timer invalidate];
    _timer = nil;
    _sessionIdentifier = nil;
    // ストレージを取得する
    NSHTTPCookieStorage *storage = [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    //  解除。
    NSArray* cookies = [storage cookies];
    for (NSHTTPCookie* cookie in cookies) {
        NSDictionary* prop = [cookie properties];
        if ([prop[NSHTTPCookieDomain] isEqualToString:@"www.tct.k-tecs.co.jp"]) {
            NSMutableDictionary* newPorp = [prop mutableCopy];
            newPorp[NSHTTPCookieExpires] = [NSDate dateWithTimeIntervalSinceNow:-3600];
            NSHTTPCookie *newCookie = [[NSHTTPCookie alloc] initWithProperties:newPorp];
            [storage deleteCookie:cookie];
            [storage setCookie:newCookie];
        }
    }
}
@end
