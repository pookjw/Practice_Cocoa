//
//  ViewController.m
//  Project18
//
//  Created by Jinwoo Kim on 1/16/21.
//

#import "ViewController.h"

@implementation ViewController

- (void)setTemperatureCelsius:(double)temperatureCelsius {
    _temperatureCelsius = temperatureCelsius;
    [self updateFahrenheit];
}

- (NSString *)icon {
    double temp = self.temperatureCelsius;
    if (temp < 0) return @"⛄️";
    else if ((temp >= 0) && (temp <= 10)) return @"❄️";
    else if ((temp >= 10) && (temp <= 20)) return @"☁️";
    else if ((temp >= 20) && (temp <= 30)) return @"⛅️";
    else if ((temp >= 30) && (temp <= 40)) return @"☀️";
    else if ((temp >= 40) && (temp <= 50)) return @"🔥";
    return @"💀";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *numbers = @[@1, @2, @3, @4, @9];
    NSLog(@"%@", [numbers valueForKeyPath:@"@count.self"]);
    NSLog(@"%@", [numbers valueForKey:@"@count"]);
    NSLog(@"%@", [numbers valueForKeyPath:@"@max.self"]);
    NSLog(@"%@", [numbers valueForKeyPath:@"@min.self"]);
    
    // KVO는 Project4 참조
    
    //
}

- (void)setup {
    self.temperatureCelsius = 50;
    self.temparatureFahrenheit = 50;
}

- (void)updateFahrenheit {
    NSUnitTemperature *celsiusUnit = [NSUnitTemperature celsius];
    NSUnitTemperature *fahrenheitUnit = [NSUnitTemperature fahrenheit];
    
    NSMeasurement *celsius = [[NSMeasurement alloc] initWithDoubleValue:self.temperatureCelsius unit:celsiusUnit];
    self.temparatureFahrenheit = round([[celsius measurementByConvertingToUnit:fahrenheitUnit] doubleValue]);
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    // 좌측 하단 Label은 icon을 옵저빙하지만, icon은 최초 실행될 때 한 번만 계산되고 그 이후로는 갱신되지 않는다. 따라서 temperatureCelsius가 바뀔 때, icon도 갱신되도록 해야 한다.
    if ([key isEqual:@"icon"]) {
        return [NSSet setWithArray:@[@"temperatureCelsius"]];
    } else {
        return [NSSet setWithArray:@[]];
    }
}

- (void)setNilValueForKey:(NSString *)key {
    /*
     storyboard에서 Slider와 Text Field가 temparatureCelsius에 옵지빙하고 있는데, Text Field의 내용을 비워서 nil로 만들 경우, temparatureCelsius는 Optional이 아니기 때문에 런타임 오류가 발생한다.
     
     [<Project18.ViewController 0x600003f74000> setNilValueForKey]: could not set nil as the value for the key temperatureCelsius.
     
     따라서 nil 일 때 처리를 해줘야 한다.
     */
    if ([key isEqual:@"temperatureCelsius"]) self.temperatureCelsius = 0;
}

- (IBAction)reset:(id)sender {
    self.temperatureCelsius = 50;
}


@end
