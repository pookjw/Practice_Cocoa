//
//  ViewController.swift
//  Project18
//
//  Created by Jinwoo Kim on 1/15/21.
//

import Cocoa

class ViewController: NSViewController {
    @objc dynamic var temperatureCelsius: Double = 50 {
        didSet {
            updateFahrenheit()
        }
    }
    @objc dynamic var temparatureFahrenheit: Double = 50
    
    @objc dynamic var icon: String {
        switch temperatureCelsius {
        case let temp where temp < 0:
            return "⛄️"
        case 0...10:
            return "❄️"
        case 10...20:
            return "☁️"
        case 20...30:
            return "⛅️"
        case 30...40:
            return "☀️"
        case 40...50:
            return "🔥"
        default:
            return "💀"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numbers: NSArray = [1, 2, 3, 4, 9]
        print(numbers.value(forKeyPath: "@count.self")!)
        print(numbers.value(forKey: "@count"))
        print(numbers.value(forKeyPath: "@max.self")!)
        print(numbers.value(forKeyPath: "@min.self")!)
        print(numbers.value(forKeyPath: "@sum.self")!)
        print(numbers.value(forKeyPath: "@avg.self")!)
        
        // KVO는 Project4 참조
        
        //
        
        updateFahrenheit()
    }
    
    @IBAction func reset(_ sender: Any) {
        temperatureCelsius = 50
    }
    
    override func setNilValueForKey(_ key: String) {
        /*
         storyboard에서 Slider와 Text Field가 temparatureCelsius에 옵지빙하고 있는데, Text Field의 내용을 비워서 nil로 만들 경우, temparatureCelsius는 Optional이 아니기 때문에 런타임 오류가 발생한다.
         
         [<Project18.ViewController 0x600003f74000> setNilValueForKey]: could not set nil as the value for the key temperatureCelsius.
         
         따라서 nil 일 때 처리를 해줘야 한다.
         */
        if key == "temperatureCelsius" {
            temperatureCelsius = 0
        }
    }
    
    func updateFahrenheit() {
        let celsius = Measurement(value: temperatureCelsius, unit: UnitTemperature.celsius)
        temparatureFahrenheit = round(celsius.converted(to: UnitTemperature.fahrenheit).value)
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        // 좌측 하단 Label은 icon을 옵저빙하지만, icon은 최초 실행될 때 한 번만 계산되고 그 이후로는 갱신되지 않는다. 따라서 temperatureCelsius가 바뀔 때, icon도 갱신되도록 해야 한다.
        if key == "icon" {
            return ["temperatureCelsius"]
        } else {
            return []
        }
    }
}

