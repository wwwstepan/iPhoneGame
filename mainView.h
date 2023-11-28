#import <UIKit/UIKit.h>
#import "myGame.h"

@interface myMainView : UIView
{
    myGame *gameEngine;
    
    CGSize scrSize;
    CGRect rectNewGame, rectRecs, rectStatus, rectGoToMenu;
    CGPoint pGameOver;
    
    float min_dim, FontSz_1, FontSz_2, FontSz_3, FontSz_GameOver;
    
    int global_counter;
    float bannerHeight;
    float statusHeight;

    float scr_w,scr_h;
    
    UIInterfaceOrientation screenOrientation;
    myGame_states last_state_draw;
    
    NSString *mainFontName;
}

- (void) live;
- (void) setScreenOrientation: (UIInterfaceOrientation) ori andSize: (CGSize) sz;
- (void) tapAt: (CGPoint) p canDrop: (BOOL) can_drop;
-(void) setBannerHeight: (float)h;
-(void) setStatusHeight: (float)h;

@end
