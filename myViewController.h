#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "mainView.h"

@interface myViewController : UIViewController <ADBannerViewDelegate>
{
    ADBannerView *bannerView;
    NSTimer *mainTimer;
    myMainView *mainView;
}

@end
