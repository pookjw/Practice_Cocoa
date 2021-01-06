//
//  GameScene.m
//  Project11
//
//  Created by Jinwoo Kim on 1/6/21.
//

#import "GameScene.h"

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    self.bubbleTextures = @[
        [SKTexture textureWithImageNamed:@"bubbleBlue"],
        [SKTexture textureWithImageNamed:@"bubbleCyan"],
        [SKTexture textureWithImageNamed:@"bubbleGray"],
        [SKTexture textureWithImageNamed:@"bubbleGreen"],
        [SKTexture textureWithImageNamed:@"bubbleOrange"],
        [SKTexture textureWithImageNamed:@"bubblePink"],
        [SKTexture textureWithImageNamed:@"bubblePurple"],
        [SKTexture textureWithImageNamed:@"bubbleRed"]
    ];
    
    self.currentBubbleTexture = 0;
    self.maximumNumber = 1;
    self.bubbles = [@[] mutableCopy];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    for (NSUInteger i = 0; i < 8; i++) {
        [self createBubble];
    }
    
    self.bubbleTimer = [NSTimer
                        scheduledTimerWithTimeInterval:5
                        target:self
                        selector:@selector(createBubble)
                        userInfo:nil
                        repeats:YES];
}

- (void)createBubble {
    // 1: create a new sprite node from our current texture
    SKSpriteNode *bubble = [SKSpriteNode spriteNodeWithTexture:self.bubbleTextures[self.currentBubbleTexture]];
    
    // 2: give it the stringfied version of our current number
    bubble.name = [NSString stringWithFormat:@"%lu", self.maximumNumber];
    
    // 3: give it a Z-position of 1, so it draws above any background
    bubble.zPosition = 1;
    
    // 4: create a label node with the current number, in nice, bright text
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    label.text = bubble.name;
    label.color = NSColor.whiteColor;
    label.fontSize = 64;
    
    // 5: make the label center itself vertically and draw above the bubble
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    label.zPosition = 2;
    
    // 6: add the label to the bubble, then the bubble to the game scene
    [bubble addChild:label];
    [self addChild:bubble];
    
    // 7: add the new bubble to our array for later use
    [self.bubbles addObject:bubble];
    
    // 8: make it apeear somewhere inside our game scene
    NSUInteger xPos = arc4random_uniform(800);
    NSUInteger yPos = arc4random_uniform(600);
    bubble.position = CGPointMake(xPos, yPos);
    
    float scale = (float)rand()/RAND_MAX;
    [bubble setScale:MAX(0.7, scale)];
    
    // fade effect when appears
    bubble.alpha = 0;
    [bubble runAction:[SKAction fadeInWithDuration:0.5]];
    
    [self configurePhysicsFor:bubble];
    [self nextBubble];
}

- (void)nextBubble {
    // move on to the next bubble texture
    self.currentBubbleTexture += 1;
    
    // if we've used all the bubble textures start at the beginning
    if (self.currentBubbleTexture == self.bubbleTextures.count) {
        self.currentBubbleTexture = 0;
    }
    
    // add a random numbr between 1 and 3 to `maximumNumber`
    self.maximumNumber += arc4random_uniform(3) + 1;
    
    // fix the mystery problem
    NSUInteger lastDigitOfMaximumNumber = self.maximumNumber;
    while (lastDigitOfMaximumNumber >= 10) {
        lastDigitOfMaximumNumber %= 10;
    }
    
    if (lastDigitOfMaximumNumber == 6) self.maximumNumber += 1;
    if (lastDigitOfMaximumNumber == 9) self.maximumNumber += 1;
}

- (void)configurePhysicsFor:(SKSpriteNode *)bubble {
    bubble.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bubble.size.width/2];
    bubble.physicsBody.linearDamping = 0;
    bubble.physicsBody.angularDamping = 0;
    bubble.physicsBody.restitution = 1;
    bubble.physicsBody.friction = 0;
    
    CGFloat motionX = (CGFloat)(int)(arc4random_uniform(401) - 200) + (float)rand()/RAND_MAX;
    CGFloat motionY = (CGFloat)(int)(arc4random_uniform(401) - 200) + (float)rand()/RAND_MAX;

    bubble.physicsBody.velocity = CGVectorMake(motionX, motionY);
    bubble.physicsBody.angularVelocity = (float)rand()/RAND_MAX;
}

- (void)mouseDown:(NSEvent *)event {
    // find where we clicked in SpriteKit
    CGPoint location = [event locationInNode:self];
    
    // filter out nodes that don't have a name
    NSArray<SKNode *> *clickedNodes = [[self nodesAtPoint:location] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name != nil"]];
    
    // make sure at least one clicked node remains
    if (clickedNodes.count == 0) return;
    
    // find the lowest-numbered bubble on the screen
    SKSpriteNode *lowestBubble = self.bubbles[0];
    for (SKSpriteNode *bubble in self.bubbles) {
        if ([bubble.name integerValue] <= [lowestBubble.name integerValue]) {
            lowestBubble = bubble;
        }
    }
    NSString *bestNumber = lowestBubble.name;
    if (bestNumber == nil) return;
    
    // go through all nodes the user clicked to see if any of them is the best number
    for (SKNode *node in clickedNodes) {
        if ([node.name isEqual:bestNumber]) {
            // they were correct = pop the bubble!
            [self pop:(SKSpriteNode *)node];
            
            // exit the method so don't create new bubbles
            return;
        }
    }
    
    // if we're still here it means they were incorrect; create two penalty bubbles
    [self createBubble];
    [self createBubble];
}

- (void)pop:(SKSpriteNode *)node {
    [self.bubbles removeObject:node];
    
    node.physicsBody = nil;
    node.name = nil;
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.3];
    SKAction *scaleUp = [SKAction scaleBy:1.5 duration:0.5];
    scaleUp.timingMode = SKActionTimingEaseOut;
    SKAction *group = [SKAction group:@[fadeOut, scaleUp]];
    
    SKAction *sequence = [SKAction sequence:@[group, [SKAction removeFromParent]]];
    [node runAction:sequence];
    
    [self runAction:[SKAction playSoundFileNamed:@"pop.wav" waitForCompletion:NO]];
    
    if (self.bubbles.count == 0) [self.bubbleTimer invalidate];
}

@end
