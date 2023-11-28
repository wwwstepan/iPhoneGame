#import <Foundation/Foundation.h>

#define MAX_CUBES_X 5
#define MAX_CUBES_Y 4
#define MAX_RECORDS 5
#define CUBE_START_ATL 2
#define COUNT_OF_NEXT_CUBES 4

typedef enum {
    myGame_state_begin,
    myGame_state_active,
    myGame_state_gameover,
    myGame_state_pause
} myGame_states;

@interface myGame : NSObject
{
    myGame_states state;
    int cubes[MAX_CUBES_X][MAX_CUBES_Y];
    int next_cube[COUNT_OF_NEXT_CUBES];
    int current_cube;
    float current_cube_altitude;
    int current_cube_x;
    int level;
    float max_val_cube;
    float max_val_new_cube, min_val_new_cube;
    double scores;
    int dropTimeOut;
    BOOL upSpeed;
    NSMutableArray *records;
}

- (myGame*) initWithSize: (CGSize)sz;
- (void) step;
- (void) contact: (int)y_index;
- (int) randomcube;
- (int) randomcubeOnlyNeg:(BOOL)OnlyNegative;
- (BOOL) findInNext: (int)val;
- (void) newgame;
- (void) gotomenu;
- (void) makecube;
- (void) levelup: (int)cub;
- (int) getCubeX: (int)x andY: (int)y;
- (void) moveto: (int)x canDrop: (BOOL) can_drop;
- (int) getCurrentCube;
- (int) getNexCube: (int)index;
- (CGPoint) getCurrentCubePos;
- (int) getLevel;
- (int) getMaxCube;
- (myGame_states) getState;
- (void) setState: (myGame_states)s;
- (int) countOfRecs;
- (int) getRecLevelAtIndex:(int)idx;
- (NSDate*) getRecDateAtIndex:(int)idx;

@end
