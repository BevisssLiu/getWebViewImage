//
//  UIWebViewController.m
//  GrabWebViewImageByJS
//
//  Created by bevis on 01/02/2018.
//  Copyright © 2018 Bevis. All rights reserved.
//

#import "UIWebViewController.h"

@interface UIWebViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation UIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webViewSingleTapGR:)];
    singleTap.delegate = self;
    [self.webview addGestureRecognizer:singleTap];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://mbd.baidu.com/newspage/data/landingsuper?context=%7B%22nid%22%3A%22news_3095037459369908563%22%7D&n_type=0&p_from=1"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
#pragma mark -- grab images from webview by js
- (void)grabWebViewImages:(UIWebView* )webView completion:(void (^ _Nullable)(NSArray * results, NSError * _Nullable error))completion{
    NSString * const getImageJSString =
    @"function grabImages(){\
        var urls = document.getElementsByTagName('img');\
        var urlStr='';\
        for(var i=0;i<urls.length;i++){\
            if(i==0){\
                if(urls[i].alt==''){\
                    urlStr=urls[i].src;\
                }\
            }else{\
                if(urls[i].alt==''){\
                    urlStr+='#'+urls[i].src;\
                }\
            }\
        };\
        return urlStr;\
    };";
    
    NSString *jsFunction=@"grabImages()";
    [webView stringByEvaluatingJavaScriptFromString:getImageJSString];
    NSString * result = [webView stringByEvaluatingJavaScriptFromString:jsFunction];
    if (result && result.length > 0) {
        if([result hasPrefix:@"#"])
        {
            result=[result substringFromIndex:1];
        }
        NSArray * array=[result componentsSeparatedByString:@"#"];
        completion(array, nil);
    }else{
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorZeroByteResource userInfo:nil];
        completion(nil,error);
    }
}

-(void)webViewSingleTapGR:(UITapGestureRecognizer*) sender
{
    /**
     find the index of your selected image which in the image array in order to display it in order.
     */
    CGPoint aPt = [sender locationInView:self.webview];
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", aPt.x, aPt.y];
    NSString * tagName = [self.webview stringByEvaluatingJavaScriptFromString:js];
    if ([tagName isEqualToString:@"img"] || [tagName isEqualToString:@"IMG"]) {
        NSString *srcJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", aPt.x, aPt.y];
        NSString *imageUrl = [self.webview stringByEvaluatingJavaScriptFromString:srcJS];
        [self grabWebViewImages:_webview completion:^(NSArray *results, NSError * _Nullable error) {
            if (results.count > 0) {
                NSLog(@"%@",results);
                NSInteger selectedIndex = [results indexOfObject:imageUrl];
                NSLog(@"selected Image At Index: %ld  URL: %@",selectedIndex, imageUrl);
//                [[[BLImageBrowser alloc] init] showImageWithUrls:reuslts atIndex:selectedIndex fromViewCtroller:self];
            }
        }];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
