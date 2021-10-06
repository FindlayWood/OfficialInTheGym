//
//  CircularProgressView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CircularProgressView: UIView {
    
    // MARK: - Properties
    private var backgroundLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    private var textLayer: CATextLayer!
    private var gradientLayer: CAGradientLayer!
    
    var timeRemaining: Int = 0 {
        didSet {
            updateTimeLabel()
        }
    }
    var progress: CGFloat = 0 {
        didSet {
            didProgressUpdated()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let width = rect.width
        let height = rect.height
        
        let lineWidth = (min(width, height) * 0.1)
        
        backgroundLayer = createCircularLayer(strokeColour: UIColor.lightGray.cgColor, fillColour: UIColor.clear.cgColor, lineWidth: lineWidth)
        progressLayer = createCircularLayer(strokeColour: UIColor.lightColour.cgColor, fillColour: UIColor.clear.cgColor, lineWidth: lineWidth)
        textLayer = createTextLayer(textColor: UIColor.lightColour)
        
        progressLayer.strokeEnd = progress
        //timeRemaining = 60
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
        layer.addSublayer(textLayer)
    }
}

private extension CircularProgressView {
    func createCircularLayer(strokeColour: CGColor, fillColour: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = 2 * CGFloat.pi + startAngle
        
        let width = frame.size.width
        let height = frame.size.height
        
        let center = CGPoint(x: width / 2, y: height / 2)
        let radius = (min(width, height) - lineWidth) / 2
        
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = strokeColour
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = fillColour
        shapeLayer.lineCap = .round
        
        return shapeLayer
    }
    
    func createTextLayer(textColor: UIColor) -> CATextLayer {
      
      let width = frame.size.width
      let height = frame.size.height
      
      let fontSize = min(width, height) / 4 - 5
      let offset = min(width, height) * 0.1
      
      let layer = CATextLayer()
      //layer.string = timeRemaining.convertToTime()
      layer.backgroundColor = UIColor.clear.cgColor
      layer.foregroundColor = textColor.cgColor
      //layer.fontSize = fontSize
      layer.font = UIFont(name: "Menlo-Bold", size: fontSize)
      layer.frame = CGRect(x: 0, y: (height - fontSize - offset) / 2, width: width, height: height)
      layer.alignmentMode = .center
      
      return layer
    }
    
    private func didProgressUpdated() {
      progressLayer?.strokeEnd = progress
    }
    
    private func updateTimeLabel() {
        let timeString = timeRemaining.convertToTime()
        textLayer?.string = timeString
    }
}
