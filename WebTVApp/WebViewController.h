#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end