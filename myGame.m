#import "myGame.h"

NSString *key_Records = @"Records";
NSString *key_Level = @"level";
NSString *key_Date = @"date";

@implementation myGame

- (myGame*) initWithSize: (CGSize)sz
{
    self = [super init];
    [self newgame];
    state=myGame_state_begin;
    
    NSUserDefaults *sav =[NSUserDefaults standardUserDefaults];
    NSArray *ar = [sav objectForKey:key_Records];
    
    records = [[NSMutableArray alloc] init];
    
    if ([ar isKindOfClass:[NSArray class]])
    {
        for (int i=0; i<[ar count] && i<MAX_RECORDS; i++)
        {
            id ob = [ar objectAtIndex:i];
            if ([ob isKindOfClass:[NSDictionary class]])
            {
                NSNumber *n = [ob valueForKey:key_Level];
                id d = [ob valueForKey:key_Date];
                
                if ([n intValue]>0 && [d isKindOfClass:[NSDate class]])
                    [records addObject:ob];
            }
        }
    }
    
    return self;
}

- (int) countOfRecs
{
    return [records count];
}

- (int) getRecLevelAtIndex:(int)idx
{
    NSDictionary *rec = [records objectAtIndex:idx];
    NSNumber *n = [rec objectForKey:key_Level];
    return [n intValue];
}

- (NSDate*) getRecDateAtIndex:(int)idx
{
    NSDictionary *rec = [records objectAtIndex:idx];
    NSDate *d = [rec objectForKey:key_Date];
    return d;
}

- (void) newgame
{
    int i,j;
    
    sranddev();
    
    state=myGame_state_active;
    
    level=0;
    dropTimeOut=0;
    
    max_val_cube=10;
    max_val_new_cube=9;
    min_val_new_cube=2;
    
    for(i=0; i<MAX_CUBES_X; i++)
        for(j=1; j<MAX_CUBES_Y; j++)
            cubes[i][j]=0;
    
    for(i=0; i<MAX_CUBES_X; i++)
        cubes[i][0]=[self randomcube];
        
    current_cube=[self randomcube];
    
    for(i=1; i<COUNT_OF_NEXT_CUBES; i++)
        next_cube[i]=0;
    
    for(i=1; i<COUNT_OF_NEXT_CUBES; i++)
        next_cube[i]=[self randomcubeOnlyNeg:NO];
    
    [self makecube];
    
    scores=0;
}

- (void) gotomenu
{
    state=myGame_state_begin;
}

- (void) makecube
{
    BOOL AllPositive=YES;
    for(int i=1; i<COUNT_OF_NEXT_CUBES; i++)
        if (next_cube[i]<0)
        {
            AllPositive=NO;
            break;
        }
    
    next_cube[0]=[self randomcubeOnlyNeg:AllPositive];
    
    int current_cube_x_was = current_cube_x;
    while(current_cube_x==current_cube_x_was)
        current_cube_x = arc4random() % MAX_CUBES_X;
    
    current_cube_altitude=MAX_CUBES_Y+CUBE_START_ATL;
    upSpeed=NO;
}

- (void) step
{
    if(state!=myGame_state_active)
        return;
    
    if (dropTimeOut>0)
        dropTimeOut--;
    
    float speed;
    if (upSpeed)
        speed = 0.133f;
    else
        speed = 0.005f + (float)level*0.0008f;
    
    current_cube_altitude-=speed;
    
    int i;
    for(i=0; i<MAX_CUBES_Y; i++)
    {
        if(!cubes[current_cube_x][i])
            break;
    }
    float alt_contact = (float)i + 0.5f;
    
    if (current_cube_altitude<=alt_contact)
    {
        [self contact:i-1];
    }
}

- (void) gameOver
{
    state=myGame_state_gameover;
    
    int idx;
    int recs_count = [records count];
    for (idx=0; idx<recs_count; idx++)
    {
        NSDictionary *rec = [records objectAtIndex:idx];
        int lvl = [[rec valueForKey:@"level"] intValue];
        if (level>lvl)
            break;
    }
    if (idx<MAX_RECORDS && level>0)
    {
        NSDictionary *new_rec = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:level], key_Level, [NSDate date], key_Date, nil];

        [records insertObject:new_rec atIndex:idx];
        if (recs_count>=MAX_RECORDS)
            [records removeLastObject];
    }

    NSUserDefaults *sav =[NSUserDefaults standardUserDefaults];
    [sav setObject:records forKey:key_Records];
    [sav synchronize];
}

- (void) contact: (int)y_index
{
    int cub;
    if (y_index>=0)
    {
        cub = cubes[current_cube_x][y_index] + current_cube;
    }else{
        cub = current_cube;
    }
    
    if(cub>max_val_cube || cub<-max_val_cube)
    {
        if(y_index>=MAX_CUBES_Y-1)
        {
            [self gameOver];
            return;
        }
        
        cubes[current_cube_x][y_index+1]=current_cube;
    }
    else
    {
        if (y_index>=0 && current_cube_altitude>(float)y_index+0.55)
            return;
            
        if(y_index<0) y_index=0;
        int was=cubes[current_cube_x][y_index];
        cubes[current_cube_x][y_index]=cub;
        if(was && !cub)
            [self levelup:was];
    }
    
    current_cube=next_cube[COUNT_OF_NEXT_CUBES-1];
    
    for(int i=COUNT_OF_NEXT_CUBES-1; i>=0; i--)
        next_cube[i+1] = next_cube[i];
    
    [self makecube];
}

- (BOOL) findInNext: (int)val
{
    for(int j=0; j<COUNT_OF_NEXT_CUBES; j++)
    {
        if(next_cube[j]==val)
            return YES;
    }
    return NO;
}

- (int) randomcube
{
    return 2+arc4random() % ((int)round(max_val_new_cube-2.0f));
}

- (int) randomcubeOnlyNeg:(BOOL)OnlyNegative
{
    int val=1;
    for(int i=0; i<40; i++)
    {
        if (OnlyNegative || arc4random() % 100 < 33)
            val = -min_val_new_cube-(arc4random() % ((int)round(max_val_new_cube*0.75f-min_val_new_cube)));
        else
            val = [self randomcube];
        
        if([self findInNext:val]==NO)
            break;
    }
    
    while ([self findInNext:val]==YES || val==0) {
        val--;
    }
    
    return val;
}

- (void) levelup: (int)cub
{
    level++;
    if(cub<=0) cub=-cub;
    scores += (float)level * (upSpeed?2.0f:1.0f + (float)cub*0.2f);
    
    min_val_new_cube+=0.555f;
    max_val_new_cube+=0.666f;

    max_val_cube+=0.8f;
}

- (int) getCubeX: (int)x andY: (int)y
{
    return cubes[x][y];
}

- (int) getCurrentCube
{
    return current_cube;
}

- (void) moveto: (int)x canDrop: (BOOL) can_drop
{
    if(x<MAX_CUBES_X)
    {
        if (current_cube_x==x && can_drop && dropTimeOut>0)
        {
            upSpeed=YES;
        }
        else
        {
            dropTimeOut=40;
            current_cube_x=x;
        }
    }
}

- (int) getNexCube: (int)index
{
    return next_cube[index];
}

- (int) getNextCube: (int)index
{
    return next_cube[index];
}

- (CGPoint) getCurrentCubePos
{
    return CGPointMake(current_cube_x, current_cube_altitude);
}

- (int) getLevel
{
    return level;
}
- (int) getMaxCube
{
    return max_val_cube;
}

- (myGame_states) getState
{
    return state;
}
- (void) setState: (myGame_states)s
{
    state=s;
}

@end
