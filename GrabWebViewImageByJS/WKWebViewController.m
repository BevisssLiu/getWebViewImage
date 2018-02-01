//
//  WKWebViewController.m
//  GrabWebViewImageByJS
//
//  Created by bevis on 01/02/2018.
//  Copyright © 2018 Bevis. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>

@interface WKWebViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) WKWebView     *webView;
@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:self.webView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webViewSingleTapGR:)];
    singleTap.delegate = self;
    [self.webView addGestureRecognizer:singleTap];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://mbd.baidu.com/newspage/data/landingsuper?context=%7B%22nid%22%3A%22news_3095037459369908563%22%7D&n_type=0&p_from=1"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- grab images from webview by js
- (void)grabWebViewImagesByJS:(WKWebView *)webView completion:(void (^ _Nullable)(NSArray * reuslts, NSError * _Nullable error))completion{
    NSString * const getImageJSString =
    @"function grabImages(){\
        var images = document.getElementsByTagName('img');\
        var urls=[];\
        for(var i=0;i<images.length;i++) {\
            urls[i] = images[i].src\
        }\
        return urls;\
        }";
    
    
    [webView evaluateJavaScript:getImageJSString completionHandler:^(id Result, NSError * error) {
        if (error) {
            completion(nil,error);
            return ;
        }
        
        NSString *jsFunction=@"grabImages()";
        [webView evaluateJavaScript:jsFunction completionHandler:^(id Result, NSError * error) {
            if (error) {
                completion(nil,error);
            }else{
                if ([Result isKindOfClass:[NSArray class]]) {
                    completion(Result, nil);
                }else{
                    completion(nil,[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorZeroByteResource userInfo:nil]);
                    NSLog(@"images urls are not formated!");
                }
            }
            //            NSLog(@"array====%@",array);
        }];
    }];
}

-(void)webViewSingleTapGR :(UITapGestureRecognizer*) sender
{
    CGPoint aPt = [sender locationInView:self.webView];
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", aPt.x, aPt.y];
    [self.webView evaluateJavaScript:js completionHandler:^(NSString * tagName, NSError * _Nullable error) {
        if ([tagName isEqualToString:@"img"] || [tagName isEqualToString:@"IMG"] || [tagName isEqualToString:@"IFRAME"]) {
            NSString *srcJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", aPt.x, aPt.y];
            [self.webView evaluateJavaScript:srcJS completionHandler:^(NSString * _Nullable imageUrl , NSError * _Nullable error) {
                [self grabWebViewImagesByJS:self.webView completion:^(NSArray *results, NSError * _Nullable error) {
                    if (results.count > 0) {
                        NSLog(@"%@",results);
                        NSInteger selectedIndex = [results indexOfObject:imageUrl];
                        NSLog(@"selected Image At Index: %ld  URL: %@",(long)selectedIndex, imageUrl);
//                        [[[BLImageBrowser alloc] init] showImageWithUrls:reuslts atIndex:selectedIndex fromViewCtroller:self];
                    }
                }];
            }];
        }
    }];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
