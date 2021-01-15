//
//  GameScene.m
//  Project17
//
//  Created by Jinwoo Kim on 1/15/21.
//

#import "GameScene.h"

@implementation GameScene

- (void)setup {
    self.nextBall = [GKShuffledDistribution distributionWithLowestValue:0 highestValue:3];
    self.cols = [@[] mutableCopy];
    self.ballSize = 50;
    self.ballsPerColumn = 10;
    self.ballsPerRow = 14;
    self.currentMatches = [NSMutableSet setWithArray:@[]];
    self.score = 0;
    self.gameStartTime = 0;
}

- (void)setScore:(NSInteger)score {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    // 135618을 135,618을 이렇게 표시해주기 위해 NSNumberFormatter를 사용한다.
    NSString *formattedScore = [formatter stringFromNumber:[NSNumber numberWithInteger:score]];
    
    if (formattedScore) {
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %@", formattedScore];
    }
    
    _score = score;
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    [self setup];
    
    // loop over as many columns as we need
    for (NSInteger x = 0; x < self.ballsPerRow; x++) {
        // create a new column to store these balls
        NSMutableArray<Ball *> *col = [@[] mutableCopy];
        
        for (NSInteger y = 0; y <self.ballsPerColumn; y++) {
            // add to this column ad many balls we need
            Ball *ball = [self createBallRow:y col:x];
            [col addObject:ball];
        }
        
        // add this column to the array of columns
        [self.cols addObject:col];
    }
    
    self.scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"HelveticaNeue"];
    self.scoreLabel.text = @"Score: 0";
    self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    self.scoreLabel.position = CGPointMake(55, CGRectGetMaxY(self.frame) - 55);
    [self addChild:self.scoreLabel];
    
    self.timer = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, 200, 40)];
    self.timer.fillColor = NSColor.greenColor;
    self.timer.strokeColor = NSColor.clearColor;
    self.timer.position = CGPointMake(545, 539);
    [self addChild:self.timer];
}

- (CGPoint)positionFor:(Ball *)ball {
    CGFloat x = 72 + (self.ballSize * (CGFloat)ball.col);
    CGFloat y = 50 + (self.ballSize * (CGFloat)ball.row);
    return CGPointMake(x, y);
}

- (Ball *)createBallRow:(NSInteger)row col:(NSInteger)col {
    return [self createBallRow:row col:col startOfScreen:NO];
}

- (Ball *)createBallRow:(NSInteger)row col:(NSInteger)col startOfScreen:(BOOL)startOfScreen {
    // pick a random ball image
    NSArray<NSString *> *ballImages = @[@"ballBlue", @"ballGreen", @"ballPurple", @"ballRed"];
    NSString *ballImage = ballImages[[self.nextBall nextInt]];
    
    // create a new ball, and set its row and column
    Ball *ball = [Ball spriteNodeWithImageNamed:ballImage];
    ball.row = row;
    ball.col = col;
    
    if (startOfScreen) {
        // animate the ball in
        CGPoint finalPosition = [self positionFor:ball];
        ball.position = CGPointMake(finalPosition.x, finalPosition.y + 600);
        
        SKAction *action = [SKAction moveTo:finalPosition duration:0.4];
        __weak typeof(self) weakSelf;
        [ball runAction:action completion:^{
            [self setUserInteractionEnabled:YES];
        }];
    } else {
        // place the ball in its final position
        ball.position = [self positionFor:ball];
    }
    
    // name the ball with its image name
    ball.name = ballImage;
    [self addChild:ball];
    
    // send the ball back to our caller
    return ball;
}

- (Ball *)ballAt:(CGPoint)point {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [Ball class]];
    NSArray<Ball *> *balls = (NSArray<Ball *> *)[[self nodesAtPoint:point] filteredArrayUsingPredicate:predicate];
    return [balls firstObject];
}

- (void)matchBall:(Ball *)originalBall {
    NSMutableArray<Ball *> *checkBalls = [@[] mutableCopy];
    
    // mark that we've matched the current ball
    [self.currentMatches addObject:originalBall];
    
    // a temporary variable to make this code easier to read
    CGPoint pos = originalBall.position;
    
    // attempt to find the balls above, below, to the left, and to the right of our starting ball
    Ball *bottomBall = [self ballAt:CGPointMake(pos.x, pos.y - self.ballSize)];
    if (bottomBall) [checkBalls addObject:bottomBall];
    
    Ball *topBall = [self ballAt:CGPointMake(pos.x, pos.y + self.ballSize)];
    if (topBall) [checkBalls addObject:topBall];
    
    Ball *leftBall = [self ballAt:CGPointMake(pos.x - self.ballSize, pos.y)];
    if (leftBall) [checkBalls addObject:leftBall];
    
    Ball *rightBall = [self ballAt:CGPointMake(pos.x + self.ballSize, pos.y)];
    if (rightBall) [checkBalls addObject:rightBall];
    
    // loop over all the non-nil balls
    for (Ball *check in checkBalls) {\
        // if we checked this ball already, ignore it
        if ([self.currentMatches containsObject:check]) continue;
        
        // if this ball is named the samed as our original...
        if ([check.name isEqual:originalBall.name]) {
            // ...match other balls from there
            [self matchBall:check];
        }
    }
}

- (void)destoryBall:(Ball *)ball {
    [self.cols[ball.col] removeObjectAtIndex:ball.row];
    [ball removeFromParent];
    
    //
    
    SKEmitterNode *particles = [SKEmitterNode nodeWithFileNamed:@"Fire"];
    if (particles) {
        particles.position = ball.position;
        [self addChild:particles];
        
        SKAction *wait = [SKAction waitForDuration:particles.particleLifetime];
        SKAction *sequence = [SKAction sequence:@[wait, [SKAction removeFromParent]]];
        [particles runAction:sequence];
    }
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    
    // figure out where we were clicked
    CGPoint location = [event locationInNode:self];
    
    // if there isn't a ball there bail out
    Ball *clickedBall = [self ballAt:location];
    if (clickedBall == nil) return;
    
    // clear the `currentMathces` set so we can re-fill it
    [self setUserInteractionEnabled:NO];
    [self.currentMatches removeAllObjects];
    
    // match the clicked ball, then recursively match all others around it
    [self matchBall:clickedBall];
    
    // make sure we remove higher-up balls first
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:NO];
    NSArray<Ball *> *sortedMatches = [self.currentMatches sortedArrayUsingDescriptors:@[descriptor]];
    
    // remove all matched balls
    for (Ball *match in sortedMatches) {
        [self destoryBall:match];
    }
    
    // move down any balls that need it
    [self.cols enumerateObjectsUsingBlock:^(NSMutableArray<Ball *> *col, NSUInteger columnIndex, BOOL * _Nonnull stop1){
        [col enumerateObjectsUsingBlock:^(Ball *ball, NSUInteger rowIndex, BOOL * _Nonnull stop2){
            // update this ball's row
            ball.row = rowIndex;
            
            // recalculate its position then remove it
            SKAction *action = [SKAction moveTo:[self positionFor:ball] duration:0.1];
            [ball runAction:action];
        }];
        
        // add new balls
        // loop until this column is full
        while (self.cols[columnIndex].count < self.ballsPerColumn) {
            // create a new ball off screen
            Ball *ball = [self createBallRow:self.cols[columnIndex].count col:columnIndex startOfScreen:YES];

            // append it to this column
            [self.cols[columnIndex] addObject:ball];
        }
    }];
    
    //
    
    NSInteger newScore = self.currentMatches.count;
    
    if (newScore == 1) {
        // bad move - take away points!
        self.score -= 1000;
    } else if (newScore == 2) {
        // meh move; do nothing
    } else {
        // good move - add points depending how many balls they matched
        double scoreToAdd = pow(2, MIN(newScore, 16));
        self.score += (NSInteger)scoreToAdd;
    }
}

- (void)update:(NSTimeInterval)currentTime {
    [super update:currentTime];
    
    if (self.gameStartTime == 0) {
        self.gameStartTime = currentTime;
    }
    
    NSTimeInterval elapsed = currentTime - self.gameStartTime;
    NSTimeInterval remaining = 100 - elapsed;
    self.timer.xScale = (CGFloat)MAX((CGFloat)0, ((CGFloat)remaining / (CGFloat)100));
}
@end
