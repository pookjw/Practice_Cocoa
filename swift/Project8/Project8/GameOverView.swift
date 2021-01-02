//
//  GameOverView.swift
//  Project8
//
//  Created by Jinwoo Kim on 1/2/21.
//

import Cocoa

class GameOverView: NSView {
    
    override func mouseUp(with event: NSEvent) {
        print(#function)
    }

    override func mouseDown(with event: NSEvent) {
        print(#function)
        // don't let mouse clicks bleed through
    }
    
    func startEmitting() {
        wantsLayer = true
        
        let title = NSTextField(labelWithString: "Game Over")
        title.font = NSFont.systemFont(ofSize: 96, weight: .heavy)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = NSColor.white
        title.wantsLayer = true
        addSubview(title)
        
        title.layer?.shadowOffset = .zero
        title.layer?.shadowOpacity = 1
        title.layer?.shadowRadius = 3
        
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        
        createEmitter()
    }

    func createEmitterCell(color: NSColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 3
        cell.lifetime = 7
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        
        let image = NSImage(named: "particle_confetti")
        
        if let img = image?.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            cell.contents = img
        }
        
        return cell
    }
    
    func createEmitter() {
        let particleEmitter = CAEmitterLayer()
        particleEmitter.emitterPosition = CGPoint(x: frame.midX, y: frame.maxY)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: frame.size.width / 100, height: 1)
        particleEmitter.beginTime = CACurrentMediaTime()
        
        let red = createEmitterCell(color: NSColor(red: 1, green: 0.2, blue: 0.2, alpha: 1))
        let green = createEmitterCell(color: NSColor(red: 0.3, green: 1, blue: 0.3, alpha: 1))
        let blue = createEmitterCell(color: NSColor(red: 0.2, green: 0.2, blue: 1, alpha: 1))
        let yellow = createEmitterCell(color: NSColor(red: 1, green: 1, blue: 0.3, alpha: 1))
        let cyan = createEmitterCell(color: NSColor(red: 0.3, green: 1, blue: 1, alpha: 1))
        let magenta = createEmitterCell(color: NSColor(red: 1, green: 0.3, blue: 1, alpha: 1))
        let white = createEmitterCell(color: NSColor(red: 1, green: 1, blue: 1, alpha: 1))
        
        particleEmitter.emitterCells = [red, green, blue, yellow, cyan, magenta, white]
        
        layer?.addSublayer(particleEmitter)
    }
    
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
    }
}
