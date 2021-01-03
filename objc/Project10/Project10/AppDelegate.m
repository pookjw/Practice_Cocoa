//
//  AppDelegate.m
//  Project10
//
//  Created by Jinwoo Kim on 1/4/21.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    
    NSDictionary<NSString *, id> *defaultSettings = @{
        @"latitude": @"51.507222",
        @"longitude": @"-0.1275",
        @"apiKey": @"",
        @"statusBarOption": @"-1",
        @"units": @"0"
    };
    
    [NSUserDefaults.standardUserDefaults registerDefaults:defaultSettings];
    
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    [nc addObserver:self selector:@selector(loadSettings) name:@"SettingsChanged" object:nil];
    
    self.statusItem.button.title = @"Fetching...";
    self.statusItem.menu = [NSMenu new];
    [self addConfigurationMenuItem];
    
    [self loadSettings];
}

- (void)addConfigurationMenuItem {
    NSMenuItem *separator = [[NSMenuItem alloc] initWithTitle:@"Settings" action:@selector(showSettings:) keyEquivalent:@""];
    [self.statusItem.menu addItem:separator];
}

- (void)showSettings:(NSMenuItem *)sender {
    [self.updateDisplayTimer invalidate];
    NSLog(@"Invalidated updateDisplayTimer");
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = (ViewController *)[storyboard instantiateControllerWithIdentifier:@"ViewController"];
    
    if (vc == nil) return;
    
    NSPopover *popoverView = [NSPopover new];
    popoverView.contentViewController = vc;
    popoverView.behavior = NSPopoverBehaviorTransient;
    [popoverView showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSMaxYEdge];
}

- (void)fetchFeed {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    
    NSString *apiKey = [defaults stringForKey:@"apiKey"];
    if (apiKey == nil) return;
    if (apiKey.length == 0) {
        self.statusItem.button.title = @"No API Key";
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(NSQualityOfServiceUtility, 0), ^{
//        // 1
//        double latitude = [defaults doubleForKey:@"latitude"];
//        double longitude = [defaults doubleForKey:@"longitude"];
//        NSString *dataSource = [NSString stringWithFormat:@"https://api.darksky.net/forecast/%@/%f,%f", apiKey, latitude, longitude];
//
//        if ([defaults integerForKey:@"units"] == 0) {
//            [dataSource stringByAppendingString:@"?units=si"];
//        }
//
//        // 2
//        NSURL *url = [NSURL URLWithString:dataSource];
//        if (url == nil) return;
//        NSString *str = [[NSString alloc] initWithContentsOfURL:url usedEncoding:0 error:nil];
//        if (str == nil) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.statusItem.button.title = @"Bad API Call";
//            });
//            return;
//        }
//        NSData *data = [str dataUsingEncoding:0];
        
        // Due to Dark Sky is end of service, this project used example json file from https://gist.github.com/morozgrafix/d6bace8dc3ae7e3067de7ce8a6c1b8bd
        NSURL *url = [NSBundle.mainBundle URLForResource:@"darksky1" withExtension:@"json"];
        if (url == nil) return;
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:url.path];
        
        // 3
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.feed = dic;
            [self updateDisplay];
            [self refreshSubmenuItems];
        });
    });
}

- (void)loadSettings {
    self.fetchFeedTimer = [NSTimer scheduledTimerWithTimeInterval:60*5 target:self selector:@selector(fetchFeed) userInfo:nil repeats:YES];
    self.fetchFeedTimer.tolerance = 60;
    
    [self fetchFeed];
    
    self.displayMode = [NSUserDefaults.standardUserDefaults integerForKey:@"statusBarOption"];
    [self configureUpdateDisplayTimer];
}

- (void)updateDisplay {
    if (self.feed == nil) return;
    NSString *text = @"Error";
    
    switch (self.displayMode) {
        case 0: {
            // summary text
            NSString *summary = (NSString *)self.feed[@"currently"][@"summary"];
            if (summary == nil) return;
            text = summary;
            break;
        }
        case 1: {
            // Show current temperature
            NSNumber *temparature = (NSNumber *)self.feed[@"currently"][@"temperature"];
            if (temparature == nil) return;
            text = [NSString stringWithFormat:@"%@°", temparature];
            break;
        }
        case 2: {
            // Show chance of rain
            NSNumber *rain = (NSNumber *)self.feed[@"currently"][@"precipProbability"];
            if (rain == nil) return;
            float rainValue = [rain floatValue];
            text = [NSString stringWithFormat:@"Rain: %f%%", rainValue*100];
            break;
        }
        case 3: {
            // Show cloud cover
            NSNumber *cloud = (NSNumber *)self.feed[@"currently"][@"cloudCover"];
            if (cloud == nil) return;
            float cloudValue = [cloud floatValue];
            text = [NSString stringWithFormat:@"Cloud: %f%%", cloudValue*100];
            break;
        }
        default:
            // This should not be reached
            NSLog(@"displayMode Error: %ld", (long)self.displayMode);
            break;
    }
    
    self.statusItem.button.title = text;
}

- (void)changeDisplayMode {
    self.displayMode += 1;
    
    if (self.displayMode > 3) {
        self.displayMode = 0;
    }
    
    [self updateDisplay];
}

- (void)configureUpdateDisplayTimer {
    NSString *statusBarMode = [NSUserDefaults.standardUserDefaults stringForKey:@"statusBarOption"];
    if (statusBarMode == nil) return;
    
    if ([statusBarMode isEqual:@"-1"]) {
        self.displayMode = 0;
        self.updateDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changeDisplayMode) userInfo:nil repeats:YES];
        NSLog(@"Validated updateDisplayTimer");
    } else {
        [self.updateDisplayTimer invalidate];
        NSLog(@"Invalidated updateDisplayTimer");
    }
}

- (void)refreshSubmenuItems {
    if (self.feed == nil) return;
    [self.statusItem.menu removeAllItems];
    
    NSArray *arr = (NSArray *)self.feed[@"hourly"][@"data"];
    NSArray *subarr = [arr subarrayWithRange:NSMakeRange(0, 10)];
    
    for (id forcast in subarr) {
        NSDictionary *forcastDic = (NSDictionary *)forcast;
        NSNumber *forcastTime = (NSNumber *)forcastDic[@"time"];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[forcastTime floatValue]];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.timeStyle = NSDateFormatterShortStyle;
        NSString *formattedDate = [formatter stringFromDate:date];

        NSString *summary = (NSString *)forcastDic[@"summary"];
        NSNumber *temparature = (NSNumber *)forcastDic[@"temperature"];
        NSString *title = [NSString stringWithFormat:@"%@: %@ (%@)", formattedDate, summary, temparature];
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
        [self.statusItem.menu addItem:menuItem];
    }
    
    [self.statusItem.menu addItem:[NSMenuItem separatorItem]];
    [self addConfigurationMenuItem];
}

@end
