#import "WebViewController.h"

@interface WebViewController ()
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWebView];
}

- (void)setupWebView {
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    self.webView.backgroundColor = [UIColor blackColor];
    self.webView.opaque = YES;
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.scrollEnabled = YES;
    
    NSURL *url = [NSURL URLWithString:@"https://tvos-emulator.j3ly.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectJavaScriptBridge];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WebView load error: %@", error);
}

#pragma mark - JavaScript Bridge

- (void)injectJavaScriptBridge {
    NSString *js = @"if(!window._atvRemoteCb){window._atvRemoteCb=null}window.appleTVRemote={onButton:function(cb){window._atvRemoteCb=cb}};";
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - Remote Input Handling

- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIEvent *)event {
    for (UIPress *press in presses) {
        NSString *btn = [self buttonNameForPressType:press.type];
        if (btn) {
            [self sendToJS:btn];
        }
    }
    [super pressesBegan:presses withEvent:event];
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIEvent *)event {
    for (UIPress *press in presses) {
        if (press.type == UIPressTypeMenu) {
            exit(0);
        }
        
        NSString *btn = [self buttonNameForPressType:press.type];
        if (btn) {
            NSString *upBtn = [btn stringByAppendingString:@"_up"];
            [self sendToJS:upBtn];
        }
    }
    [super pressesEnded:presses withEvent:event];
}

- (NSString *)buttonNameForPressType:(UIPressType)type {
    switch (type) {
        case UIPressTypeUpArrow:
            return @"up";
        case UIPressTypeDownArrow:
            return @"down";
        case UIPressTypeLeftArrow:
            return @"left";
        case UIPressTypeRightArrow:
            return @"right";
        case UIPressTypeSelect:
            return @"select";
        case UIPressTypeMenu:
            return @"menu";
        case UIPressTypePlayPause:
            return @"playpause";
        default:
            return nil;
    }
}

- (void)sendToJS:(NSString *)btn {
    NSString *js = [NSString stringWithFormat:@"if(window._atvRemoteCb)window._atvRemoteCb('%@')", btn];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

@end