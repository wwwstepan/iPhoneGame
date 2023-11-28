#import "mainView.h"

@implementation myMainView

- (void) myInit
{
    gameEngine = [[myGame alloc] initWithSize: scrSize];
    global_counter=0;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        scrSize=frame.size;
        [self myInit];
    }
    
    mainFontName = @"Helvetica";
    
    return self;
}

- (void) setBannerHeight: (float)h
{
    bannerHeight=h;
}

- (void) setStatusHeight: (float)h
{
    statusHeight=h;
}

- (void) setScreenOrientation: (UIInterfaceOrientation) ori andSize: (CGSize) sz
{
    screenOrientation = ori;
    scrSize = sz;
    
    BOOL ori_horiz=NO;
    
    min_dim = scr_w<scr_h ? scr_w : scr_h;
    
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if(
        (sysVer<8.0f)
        &&
        (
            (screenOrientation==UIInterfaceOrientationLandscapeRight) ||
            (screenOrientation==UIInterfaceOrientationLandscapeLeft)
        )
      )
    {
        scr_h = scrSize.width;
        scr_w = scrSize.height;
    }
    else
    {
        scr_w = scrSize.width;
        scr_h = scrSize.height;
    }
    
    float
    stats_w = min_dim*0.42f,
    stats_h = min_dim*0.088f,
    x_stats = scr_w-min_dim*0.49f,
    y_stats = bannerHeight+min_dim*0.017f;
    
    pGameOver = CGPointMake(scr_w/17, scr_h*0.36f);
    
    if (screenOrientation==UIInterfaceOrientationLandscapeRight)
    {
        x_stats = min_dim*0.03f;
        ori_horiz=YES;
    }
    else if (screenOrientation==UIInterfaceOrientationLandscapeLeft)
    {
        ori_horiz=YES;
    }
    else if (screenOrientation==UIInterfaceOrientationPortraitUpsideDown)
    {
        y_stats = scr_h-min_dim*0.2f;
        pGameOver.y = scr_h - min_dim*0.35f;
    }
    else
    {
        pGameOver.y = bannerHeight + min_dim*0.2f;
    }
    
    rectGoToMenu = CGRectMake(x_stats,y_stats,stats_w,stats_h);
    rectStatus = CGRectMake(x_stats,y_stats+stats_h,stats_w,stats_h);
    
    rectNewGame = CGRectMake(scr_w/2-min_dim*0.37f,bannerHeight+min_dim*.09f,min_dim*2.0f*0.37f,min_dim*0.15f);
    rectRecs = CGRectMake(scr_w/2-min_dim*0.42f,bannerHeight+min_dim*0.28f,min_dim*2.0f*0.42f,bannerHeight+min_dim*0.4f);
    
    FontSz_1 = min_dim*0.093f;
    FontSz_2 = min_dim*0.069f;
    FontSz_3 = min_dim*0.054f;
    
    FontSz_GameOver = scr_w * 0.14f;
}

- (void) tapAt: (CGPoint) p canDrop: (BOOL) can_drop
{
    myGame_states state = [gameEngine getState];
    
    if (state==myGame_state_pause)
    {
        [gameEngine setState:myGame_state_active];
    }
    else if (state==myGame_state_begin)
    {
        if (CGRectContainsPoint(rectNewGame,p))
            [gameEngine newgame];
    }
    else
    {
        if (CGRectContainsPoint(rectGoToMenu,p))
        {
            [gameEngine gotomenu];
            return;
        }
        float x;
        if (screenOrientation==UIInterfaceOrientationLandscapeRight)
        {
            x=(scr_h - p.y)/(scr_h-bannerHeight) * MAX_CUBES_X;
        }
        else if (screenOrientation==UIInterfaceOrientationLandscapeLeft)
        {
            x=(p.y-bannerHeight)/(scr_h-bannerHeight) * MAX_CUBES_X;
        }
        else if (screenOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
            x = MAX_CUBES_X - p.x/scr_w * MAX_CUBES_X;
        }
        else
        {
            x=p.x/scr_w * MAX_CUBES_X;
        }
        [gameEngine moveto:x canDrop: can_drop];
    }
}

- (void)live
{
    global_counter++;
    [gameEngine step];
    myGame_states state = [gameEngine getState];
    
    if (state==myGame_state_active || state!=last_state_draw)
        [self setNeedsDisplay];
}

- (void)drawCube:(int)cub at:(CGPoint)p withCubeSize:(float)cubeSize grContex:(CGContextRef)context
{
    UIFont *fnt = [UIFont fontWithName:mainFontName size:17.0f * cubeSize/32.0f];
    
    float sz2=cubeSize/2;
    
    float r1,g1,b1;
    if(cub>0)
    {
        r1=20.0f/255.0f;
        g1=round(120.0f+(cub%14)*10)/255.0f;
        b1=60.0f/255.0f;
    }
    else
    {
        r1=round(120.0f+((-cub)%14)*10)/255.0f;
        g1=20.0f/255.0f;
        b1=60.0f/255.0f;
    }
    
    CGContextSetRGBFillColor(context, r1, g1, b1, 1);
    CGContextFillRect(context, CGRectMake(p.x-sz2, p.y-sz2, cubeSize, cubeSize));
    
    NSString *s = [NSString stringWithFormat:@"%d",cub];
    if(cub>0)
        s=[@"+" stringByAppendingString:s];
    
    p.x-=cubeSize/2-2.0f;
    p.y-=cubeSize/2-2.0f;
    
    [s drawAtPoint:p withAttributes:@{UITextAttributeFont:fnt}];
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGPoint p_cur,p;
    
    myGame_states state = [gameEngine getState];
    last_state_draw = state;
    
    if (state==myGame_state_begin)
    {
        CGContextSetRGBFillColor(context, 0, 200.0f/255.0f, 0, 1);
        CGContextFillRect(context, rectNewGame);
        
        UIFont *fnt1 = [UIFont fontWithName:mainFontName size:FontSz_1];
        UIFont *fnt2 = [UIFont fontWithName:mainFontName size:FontSz_2];
        
        NSString *s1 = @"NEW GAME";
        
        p.x=rectNewGame.origin.x+min_dim*0.111f;
        p.y=rectNewGame.origin.y+min_dim*0.02f;
        [s1 drawAtPoint:p withAttributes:@{UITextAttributeFont:fnt1}];
        
        int cnt_recs = [gameEngine countOfRecs];
        if (cnt_recs>0)
        {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd.MM.yyyy"];
            
            CGContextSetRGBFillColor(context, 150.0f/255.0f, 180.0f/255.0f, 150.0f/255.0f, 1);
            CGContextFillRect(context, rectRecs);
            
            p.x=rectRecs.origin.x+min_dim*0.123f;
            p.y=rectRecs.origin.y+min_dim*0.015f;
            
            float d_y = FontSz_2+min_dim*0.004f;
            
            NSString *s2 = @"Records:";
            [s2 drawAtPoint:p withAttributes:@{UITextAttributeFont:fnt2}];
            
            p.y += d_y*0.4f;
            
            for (int i=0; i<cnt_recs; i++)
            {
                int lev = [gameEngine getRecLevelAtIndex:i];
                NSString *dat_rec = [dateFormatter stringFromDate:[gameEngine getRecDateAtIndex:i]];
                NSString *s3 = [NSString stringWithFormat:@"%@ - %d",dat_rec,lev];
                p.y += d_y;
                [s3 drawAtPoint:p withAttributes:@{UITextAttributeFont:fnt2}];
            }
        }
        
        return;
    }
    
    p = [gameEngine getCurrentCubePos];
    
    int cub;
    float cube_sz,cube_sz_next;
    float start_next_x = 16.0f;
    float sign_dx_next=1.0f;
    float next_cubes_y;
    
    CGContextSetRGBFillColor(context, 222.0f/255.0f, 0, 0, 1);
    
    if (screenOrientation==UIInterfaceOrientationLandscapeRight)
    {
        cube_sz=(scr_h-bannerHeight)/MAX_CUBES_X;
        CGContextFillRect(context, CGRectMake(scr_w-cube_sz*(MAX_CUBES_Y)-1.0f, 0, 1, scr_h));
        p_cur.x=scr_w - cube_sz*p.y;
        p_cur.y=scr_h - p.x * cube_sz - cube_sz/2;
        next_cubes_y = scr_h - cube_sz/3.0f;
    }
    else if (screenOrientation==UIInterfaceOrientationLandscapeLeft)
    {
        cube_sz=(scr_h-bannerHeight)/MAX_CUBES_X;
        start_next_x = scr_w - 16.0f;
        sign_dx_next=-1.0f;
        CGContextFillRect(context, CGRectMake(cube_sz*(MAX_CUBES_Y)+1.0f, 0, 1, scr_h));
        p_cur.x=cube_sz*p.y;
        p_cur.y=bannerHeight + p.x * cube_sz + cube_sz/2;
        next_cubes_y = scr_h - cube_sz/3.0f;
    }
    else if (screenOrientation==UIInterfaceOrientationPortraitUpsideDown)
    {
        cube_sz=scr_w/MAX_CUBES_X;
        CGContextFillRect(context, CGRectMake(0, bannerHeight+cube_sz*(MAX_CUBES_Y), scr_w, 1));
        next_cubes_y = scr_h - cube_sz/3.0f;
        p_cur.x=cube_sz/2+cube_sz*(MAX_CUBES_X-p.x-1);
        p_cur.y=bannerHeight + p.y*cube_sz;
    }
    else
    {
        cube_sz=scr_w/MAX_CUBES_X;
        CGContextFillRect(context, CGRectMake(0, scr_h-cube_sz*(MAX_CUBES_Y)-1.0f, scr_w, 1));
        p_cur.x=cube_sz/2+cube_sz*p.x;
        p_cur.y=scr_h-p.y*cube_sz;
        next_cubes_y = bannerHeight + cube_sz/3.0f;
    }
    
    
    // draw all cubes
    
    for(int i=0; i<MAX_CUBES_X; i++)
        for(int j=0; j<MAX_CUBES_Y; j++)
        {
            cub = [gameEngine getCubeX:i andY:j];
            if(cub)
            {
                if (screenOrientation==UIInterfaceOrientationLandscapeRight)
                {
                    p.y=scr_h - cube_sz/2 - cube_sz*i;
                    p.x=scr_w - cube_sz/2 - cube_sz*j;
                }
                else if (screenOrientation==UIInterfaceOrientationLandscapeLeft)
                {
                    p.y=bannerHeight + cube_sz/2 + cube_sz*i;
                    p.x=cube_sz/2 + cube_sz*j;
                }
                else if (screenOrientation==UIInterfaceOrientationPortraitUpsideDown)
                {
                    p.x=cube_sz/2 + cube_sz*(MAX_CUBES_X-i-1);
                    p.y=bannerHeight + cube_sz/2 + cube_sz*j;
                }
                else
                {
                    p.x=cube_sz/2 + cube_sz*i;
                    p.y=scr_h - cube_sz/2-cube_sz*j;
                }
                
                [self drawCube:cub at:p withCubeSize:cube_sz grContex:context];
            }
        }
    
    p.y=next_cubes_y;
    float size_next=cube_sz/4.0f;
    float size_next_d=cube_sz/16.0f;
    
    
    // draw next cubes
    
    for(int i=0; i<COUNT_OF_NEXT_CUBES; i++)
    {
        cub = [gameEngine getNexCube:i];
        p.x = start_next_x;
        cube_sz_next=size_next;
        start_next_x += sign_dx_next*(size_next+cube_sz_next/5.0f);
        size_next+=size_next_d;
        
        [self drawCube:cub at:p withCubeSize:cube_sz_next grContex:context];
    }
    
    
    // draw buttons
    
    int lvl = [gameEngine getLevel];
    int max_c = [gameEngine getMaxCube];
    
    //CGContextSetRGBFillColor(context, 0, 0.67f, 0, 1);
    //CGContextFillRect(context, rectStatus);
    UIColor *clr_stat = [[UIColor alloc] initWithRed:0.07 green:0.07 blue:1 alpha:1];
    UIFont *fnt = [UIFont fontWithName:mainFontName size:FontSz_3];
    NSString *s = [NSString stringWithFormat:@"Level %d  Max %d",lvl,max_c];
    p.x=rectStatus.origin.x;
    p.y=rectStatus.origin.y+min_dim*0.007;
    [s drawAtPoint:p withAttributes:@{UITextAttributeFont:fnt, UITextAttributeTextColor:clr_stat}];
    
    CGContextSetRGBFillColor(context, 0.5f, 0.677f, 0.96f, 1);
    CGContextFillRect(context, rectGoToMenu);
    //UIFont *fnt1 = [UIFont fontWithName:mainFontName size:FontSz_3];
    NSString *s1 = @"GO TO MENU";
    
    p.x=rectGoToMenu.origin.x+min_dim*0.043;
    p.y=rectGoToMenu.origin.y+min_dim*0.014;
    [s1 drawAtPoint:p withAttributes:@{UITextAttributeFont:fnt}];
    
    
    // draw falling cube
    
    cub = [gameEngine getCurrentCube];
    [self drawCube:cub at:p_cur withCubeSize:cube_sz grContex:context];
    
    
    // print "game over"
    
    if (state==myGame_state_gameover)
    {
        UIColor *clr_red = [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:1];
        //UIColor *clr_shdw = [[UIColor alloc] initWithRed:0 green:0 blue:0.2f alpha:1];
        //UIOffset shdw = { 0.2f, 0.2f };
        //NSValue *o_shdw = [NSValue value:&shdw withObjCType:@encode(UIOffset)];
        NSString *s2 = @"GAME OVER";
        p.x=pGameOver.x;
        p.y=pGameOver.y;
        UIFont *fnt2 = [UIFont fontWithName:mainFontName size:FontSz_GameOver];
        [s2 drawAtPoint:p withAttributes:
         @{UITextAttributeFont:fnt2, UITextAttributeTextColor:clr_red
           //, UITextAttributeTextShadowColor:clr_shdw, UITextAttributeTextShadowOffset:o_shdw
           }];
    }
}

@end
