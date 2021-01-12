//
//  GameScene.m
//  Project14
//
//  Created by Jinwoo Kim on 1/12/21.
//

#import "GameScene.h"

@implementation GameScene

- (void)dealloc {
    NSLog(@"dealloc");
//    [super dealloc];
}

- (void)setup {
    self.bulletsTextures = @[
        [SKTexture textureWithImageNamed:@"shots0"],
        [SKTexture textureWithImageNamed:@"shots1"],
        [SKTexture textureWithImageNamed:@"shots2"],
        [SKTexture textureWithImageNamed:@"shots3"]
    ];
    
    self.bulletsInClip = 3;
    self.targetSpeed = 4.0;
    self.targetDelay = 0.8;
    self.targetsCreated = 0;
    self.isGameOver = NO;
}

- (NSUInteger)bulletsInClip {
    self.bulletsSprite.texture = self.bulletsTextures[_bulletsInClip];
    return _bulletsInClip;
}

- (NSInteger)score {
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)_score];
    return _score;
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    
    [self setup];
    [self createBackground];
    [self createWater];
    [self createOverlay];
    [self levelUp];
}

- (void)createBackground {
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"wood-background"];
    background.position = CGPointMake(400, 300);
    background.blendMode = SKBlendModeReplace;
    [self addChild:background];
    
    SKSpriteNode *grass = [SKSpriteNode spriteNodeWithImageNamed:@"grass-trees"];
    grass.position = CGPointMake(400, 300);
    [self addChild:grass];
    grass.zPosition = 100;
}

- (void)createWater {
    void(^animate)(SKNode *, CGFloat, NSTimeInterval) = ^(SKNode *node, CGFloat distance, NSTimeInterval duration){
        SKAction *movementUp = [SKAction moveByX:0 y:distance duration:duration];
        SKAction *movementDown = [movementUp reversedAction];
        SKAction *sequence = [SKAction sequence:@[movementUp, movementDown]];
        SKAction *repeatForever = [SKAction repeatActionForever:sequence];
        [node runAction:repeatForever];
    };
    
    SKSpriteNode *waterBackground = [SKSpriteNode spriteNodeWithImageNamed:@"water-bg"];
    waterBackground.position = CGPointMake(400, 180);
    waterBackground.zPosition = 200;
    [self addChild:waterBackground];
    
    SKSpriteNode *waterForeground = [SKSpriteNode spriteNodeWithImageNamed:@"water-fg"];
    waterForeground.position = CGPointMake(400, 120);
    waterForeground.zPosition = 300;
    [self addChild:waterForeground];
    
    animate(waterBackground, 8, 1.3);
    animate(waterForeground, 12, 1);
}

- (void)createOverlay {
    SKSpriteNode *curtains = [SKSpriteNode spriteNodeWithImageNamed:@"curtains"];
    curtains.position = CGPointMake(400, 300);
    curtains.zPosition = 400;
    [self addChild:curtains];
    
    self.bulletsSprite = [SKSpriteNode spriteNodeWithImageNamed:@"shots3"];
    self.bulletsSprite.position = CGPointMake(170, 60);
    self.bulletsSprite.zPosition = 500;
    [self addChild:self.bulletsSprite];
    
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    // SKSpriteNode는 anchorPoint를 중심을 잡지만, SKLabelNode는 alignment로 잡는다.
    self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    
    self.scoreLabel.position = CGPointMake(680, 50);
    self.scoreLabel.zPosition = 500;
    self.scoreLabel.text = @"Score: 0";
    [self addChild:self.scoreLabel];
}

- (void)createTarget {
    // create and initialize our custon node
    Target *target = [Target new];
    [target setup];
    
    // decide where we want to place it in the game scene
    NSInteger level = arc4random_uniform(3);
    
    // default to targets moving left to right
    BOOL movingRight = YES;
    
    switch (level) {
        case 0:
            // in front of the grass
            target.zPosition = 150;
            target.position = CGPointMake(target.position.x, 280);
            [target setScale:0.7];
            break;
        case 1:
            // in front of the water background
            target.zPosition = 250;
            target.position = CGPointMake(target.position.x, 190);
            [target setScale:0.85];
            movingRight = NO;
            break;
        default:
            // in front of the water foreground
            target.zPosition = 350;
            target.position = CGPointMake(target.position.x, 100);
            break;
    }
    
    // new position the target at the left or right edge, moving it to the opposite edge.
    SKAction *move;
    
    if (movingRight) {
        target.position = CGPointMake(0, target.position.y);
        move = [SKAction moveToX:800 duration:self.targetSpeed];
    } else {
        target.position = CGPointMake(800, target.position.y);
        // flip the target horizontally so it faces the direction of travel
        target.xScale = -target.xScale;
        move = [SKAction moveToX:0 duration:self.targetSpeed];
    }
    
    // create a sequence that moves the target acorss the screen then removes from the screen afterwards
    SKAction *sequence = [SKAction sequence:@[move, [SKAction removeFromParent]]];
    
    // start the target moving, then add it to our game scene
    [target runAction:sequence];
    [self addChild:target];
    
    [self levelUp];
}

- (void)levelUp {
    // make the game slightly harder
    self.targetSpeed *= 0.99;
    self.targetDelay *= 0.99;
    
    // update our target counter
    self.targetsCreated += 1;
    
    if (self.targetsCreated < 100) {
        // schedule another target to be created after `targetDelay` seconds have passed
        
        __weak typeof(self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.targetDelay * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{ // async
            [weakSelf createTarget];
        });
    } else {
        __weak typeof(self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [weakSelf gameOver];
        });
    }
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    
    if (self.isGameOver) {
        SKScene *newGame = [SKScene nodeWithFileNamed:@"GameScene"];
        
        if (newGame) {
            SKTransition *transition = [SKTransition doorwayWithDuration:1];
            [self.view presentScene:newGame transition:transition];
            // 기존 Scene은 removeFromParent되고 dealloc 된다.
        }
    } else {
        if (self.bulletsInClip > 0) {
            [self runAction:[SKAction playSoundFileNamed:@"shot.wav" waitForCompletion:NO]];
            self.bulletsInClip -= 1;
            
            CGPoint location = [event locationInNode:self];
            [self shotAt:location];
        } else {
            [self runAction:[SKAction playSoundFileNamed:@"empty.wav" waitForCompletion:NO]];
        }
    }
}

- (void)shotAt:(CGPoint)location {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"target"];
    NSArray<SKNode *> * _Nonnull hitNodes = [[self nodesAtPoint:location] filteredArrayUsingPredicate:predicate];
    
    SKNode *hitNode = [hitNodes firstObject];
    if (hitNode == nil) return;
    Target *parentNode = (Target *)hitNode.parent;
    if (parentNode == nil) return;
    
    [parentNode hit];
    self.score += 3;
}

- (void)keyDown:(NSEvent *)event {
    [super keyDown:event];
    
    if ([[event charactersIgnoringModifiers] isEqual:@" "]) {
        [self runAction:[SKAction playSoundFileNamed:@"reload.wav" waitForCompletion:NO]];
        self.bulletsInClip = 3;
        self.score -= 1;
    }
}

- (void)gameOver {
    self.isGameOver = YES;
    
    SKSpriteNode *gameOverTitle = [SKSpriteNode spriteNodeWithImageNamed:@"game-over"];
    gameOverTitle.position = CGPointMake(400, 300);
    [gameOverTitle setScale:2];
    gameOverTitle.alpha = 0;
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.3];
    SKAction *scaleDown = [SKAction scaleTo:1 duration:0.3];
    SKAction *group = [SKAction group:@[fadeIn, scaleDown]];
    
    [gameOverTitle runAction:group];
    gameOverTitle.zPosition = 900;
    [self addChild:gameOverTitle];
}

@end
