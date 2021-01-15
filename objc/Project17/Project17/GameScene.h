//
//  GameScene.h
//  Project17
//
//  Created by Jinwoo Kim on 1/15/21.
//

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import "Ball.h"

@interface GameScene : SKScene
@property GKShuffledDistribution *nextBall;
@property NSMutableArray<NSMutableArray<Ball *> *> *cols;
@property CGFloat ballSize;
@property double ballsPerColumn;
@property double ballsPerRow;
@property NSMutableSet<Ball *> *currentMatches;
@property SKLabelNode *scoreLabel;
@property (nonatomic) NSInteger score;
@property SKShapeNode *timer;
@property NSTimeInterval gameStartTime;
@end
