//
//  Histogram.swift
//  ShinpuruImage
//
//  Created by Simon Gladman on 25/05/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit
import Charts

class Histogram: SLHGroup
{
    let leftGroup = SLVGroup()
    let rightGroup = SLVGroup()
    
    let imageView = UIImageView()
    
    let foo = [String](count: 256, repeatedValue: "")
    var redChartData = [ChartDataEntry](count: 256, repeatedValue: ChartDataEntry())
    var greenChartData = [ChartDataEntry](count: 256, repeatedValue: ChartDataEntry())
    var blueChartData = [ChartDataEntry](count: 256, repeatedValue: ChartDataEntry())
    
    let redSlider = LabelledSlider(title: "White Point Red")
    let greenSlider = LabelledSlider(title: "White Point Green")
    let blueSlider = LabelledSlider(title: "White Point Blue")
    
    let saturationSlider = LabelledSlider(title: "Saturation", minimumValue: 0, maximumValue: 4)
    let brightnessSlider = LabelledSlider(title: "Brightness", minimumValue: -1, maximumValue: 1)
    let contrastSlider = LabelledSlider(title: "Contrast", minimumValue: 0, maximumValue: 2)
    
    let gammaSlider = LabelledSlider(title: "Gamma", minimumValue: 0, maximumValue: 4)
    
    let hueSlider = LabelledSlider(title: "Hue", minimumValue: 0, maximumValue: Float(M_PI * 2))
    let exposureSlider = LabelledSlider(title: "Exposure", minimumValue: 0, maximumValue: 4)
    
    let fastChainHGroup = SLHGroup()
    let fastChainSwitch = UISwitch()
    let fastChainLabel = UILabel()
    
    let chart = LineChartView()
    
    required init()
    {
       super.init()
        
        let left = chart.getAxis(ChartYAxis.AxisDependency.Left)
        left.customAxisMax = 20_000
        left.drawLabelsEnabled = false
        
        let right = chart.getAxis(ChartYAxis.AxisDependency.Right)
        right.customAxisMax = 20_000
        right.drawLabelsEnabled = false
        
        chart.descriptionText = ""
        
        margin = 20
        leftGroup.margin = 10
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        chart.backgroundColor = UIColor.lightGrayColor()
        
        redSlider.value = 1
        greenSlider.value = 1
        blueSlider.value = 1
        
        saturationSlider.value = 2
        contrastSlider.value = 1
        
        gammaSlider.value = 1
        exposureSlider.value = 0.5
        
        redSlider.addTarget(self, action: "updateImage", forControlEvents: UIControlEvents.ValueChanged)
        greenSlider.addTarget(self, action: "updateImage", forControlEvents: UIControlEvents.ValueChanged)
        blueSlider.addTarget(self, action: "updateImage", forControlEvents: UIControlEvents.ValueChanged)
        
        saturationSlider.addTarget(self, action: "updateImage", forControlEvents: UIControlEvents.ValueChanged)
        brightnessSlider.addTarget(self, action: "updateImage", forControlEvents: UIControlEvents.ValueChanged)
        contrastSlider.addTarget(self, action: "updateImage", forControlEvents: UIControlEvents.ValueChanged)
        
        gammaSlider.addTarget(self, action: "updateImage", forControlEvents: UIControlEvents.ValueChanged)
        
        hueSlider.addTarget(self, action: "updateImage", forControlEvents: UIControlEvents.ValueChanged)
        exposureSlider.addTarget(self, action: "updateImage", forControlEvents: UIControlEvents.ValueChanged)
        
        fastChainLabel.text = "Use Fast Chaining"
        fastChainLabel.textAlignment = NSTextAlignment.Right
        fastChainLabel.frame = CGRect(x: 0, y: 0, width: 1, height: fastChainSwitch.intrinsicContentSize().height)
        fastChainHGroup.children = [fastChainLabel, fastChainSwitch]
        fastChainHGroup.explicitSize = fastChainSwitch.intrinsicContentSize().height

        rightGroup.children = [imageView, chart]
        leftGroup.children = [redSlider, greenSlider, blueSlider, saturationSlider, brightnessSlider, contrastSlider, gammaSlider, hueSlider, exposureSlider, fastChainHGroup]
        
        children = [leftGroup, rightGroup]
        
        updateImage()
    }
    
    func updateImage()
    {
        let targetColor = UIColor(red: CGFloat(redSlider.value),
            green: CGFloat(greenSlider.value),
            blue: CGFloat(blueSlider.value),
            alpha: CGFloat(1.0))
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let image: UIImage!
        
        if !fastChainSwitch.on
        {
            image = UIImage(named: "tram.jpg")?
                .SIWhitePointAdjust(color: targetColor)
                .SIColorControls(saturation: saturationSlider.value, brightness: brightnessSlider.value, contrast: contrastSlider.value)
                .SIGammaAdjust(power: gammaSlider.value)
                .SIExposureAdjust(ev: exposureSlider.value)
                .SIHueAdjust(power: hueSlider.value)
        }
        else
        {
            image = SIFastChainableImage(image: UIImage(named: "tram.jpg")!)!
                .SIWhitePointAdjust(color: targetColor)
                .SIColorControls(saturation: saturationSlider.value, brightness: brightnessSlider.value, contrast: contrastSlider.value)
                .SIGammaAdjust(power: gammaSlider.value)
                .SIExposureAdjust(ev: exposureSlider.value)
                .SIHueAdjust(power: hueSlider.value)
                .toUIImage()
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        
        print("duration = \(duration)  fast chain = \(fastChainSwitch.on)")
        
        let histogram = image?.SIHistogramCalculation()
        
        imageView.image = image
        
    for i: Int in 0 ... 255
    {
        redChartData[i] = ( ChartDataEntry(value: Float(histogram!.red[i]), xIndex: i) )
        greenChartData[i] = ( ChartDataEntry(value: Float(histogram!.green[i]), xIndex: i) )
        blueChartData[i] = ( ChartDataEntry(value: Float(histogram!.blue[i]), xIndex: i) )
    }
        
        let redChartDataSet = LineChartDataSet(yVals: redChartData, label: "red")
        let greenChartDataSet = LineChartDataSet(yVals: greenChartData, label: "green")
        let blueChartDataSet = LineChartDataSet(yVals: blueChartData, label: "blue")
        
        redChartDataSet.setColor(UIColor.redColor())
        redChartDataSet.lineWidth = 2
        redChartDataSet.drawCirclesEnabled = false
        
        greenChartDataSet.setColor(UIColor.greenColor())
        greenChartDataSet.lineWidth = 2
        greenChartDataSet.drawCirclesEnabled = false
        
        blueChartDataSet.setColor(UIColor.blueColor())
        blueChartDataSet.lineWidth = 2
        blueChartDataSet.drawCirclesEnabled = false
        
    let lineChartData = LineChartData(xVals: foo, dataSets: [redChartDataSet, greenChartDataSet, blueChartDataSet])
    
    chart.data = lineChartData
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
