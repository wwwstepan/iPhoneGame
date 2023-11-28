#import "myViewController.h"
#import "myGame.h"

@implementation myViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation: UIStatusBarAnimationNone];
        
        mainView = [[myMainView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        
        self.view=mainView;
        
        bannerView = [[ADBannerView alloc] init];
        bannerView.delegate = self;
        [mainView setBannerHeight:bannerView.bounds.size.height];
        
        [self.view addSubview:bannerView];
        
        [self layoutAnimated:NO];
    }
    
    return self;
}

- (void)layoutAnimated:(BOOL)animated
{
    CGRect contentFrame = [[UIScreen mainScreen] bounds];
    
    CGRect bannerFrame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y, contentFrame.size.width, bannerView.bounds.size.height);
    
    //CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    UIInterfaceOrientation ori = [self interfaceOrientation];
    
    [mainView setScreenOrientation:ori andSize:contentFrame.size];
    
    if (bannerView.bannerLoaded) {
        float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];

        if(
           (sysVer<8.0f)
           &&
           (
            (ori==UIInterfaceOrientationLandscapeRight) ||
            (ori==UIInterfaceOrientationLandscapeLeft)
            )
           )
        {
            bannerFrame.size.width=contentFrame.size.height;
        }
        else
        {
            bannerFrame.size.width=contentFrame.size.width;
        }
        
    }
    /*    float d = statusBarFrame.size.height;
        contentFrame.origin.y = d;
        contentFrame.size.height -= d;
     */
    
    [UIView animateWithDuration:animated ? 0.2 : 0.0 animations:^{
        //mainView.frame = contentFrame;
        //[mainView layoutIfNeeded];
        bannerView.frame = bannerFrame;
    }];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect contentFrame = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation ori = [self interfaceOrientation];
    
    [mainView setBannerHeight:bannerView.bounds.size.height];
    [mainView setScreenOrientation:ori andSize:contentFrame.size];
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    [mainView setStatusHeight:statusBarFrame.size.height];
}

- (void)startTimer
{
    if (mainTimer == nil) {
        mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer
{
    [mainTimer invalidate];
    mainTimer = nil;
}

- (void)timerTick:(NSTimer *)timer
{
    [mainView live];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutAnimated:NO];
    [self startTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
#endif

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) viewDidLayoutSubviews
{
    [self layoutAnimated:[UIView areAnimationsEnabled]];
}

- (void) bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self layoutAnimated:YES];
}

- (BOOL) bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [self stopTimer];
    return YES;
}

- (void) bannerViewActionDidFinish:(ADBannerView *)banner
{
    [self startTimer];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint p = [touch locationInView: self.view];
        [mainView tapAt:p canDrop:YES];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint p = [touch locationInView: self.view];
        [mainView tapAt:p canDrop:NO];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
    for (UITouch *touch in touches)
    {
        CGPoint p = [touch locationInView: self.view];
        [mainView tapAt:p canDrop:NO];
    }
    */
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

@end
