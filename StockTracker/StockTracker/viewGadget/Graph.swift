//
//  Graph.swift
//  StockTracker
//
//  Created by Chenning Li on 12/9/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation
import SwiftUI


class Graph: UIView  {
    
    @ObservedObject var viewController: DetailChartViewController
    
    var lineWidth: CGFloat = 2
    
    init(chartViewController: ObservedObject<DetailChartViewController>) {
        _viewController = chartViewController
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
            
            if let timeStamp = viewController.chart?.chart?.result?.first??.timestamp,
                let meta = viewController.chart?.chart?.result?.first??.meta,
                let quote = viewController.chart?.chart?.result?.first??.indicators?.quote?.first,
                let timeMarkerCount = viewController.timeMarkerCount,
                let chartPreviousClose = meta.chartPreviousClose
            {
                if timeStamp.count > 0 {
                    let size = rect.size
                    
                    let stepX = size.width / CGFloat(timeMarkerCount)
                    
                    let clippingPath = UIBezierPath()
                    
                    let context = UIGraphicsGetCurrentContext()!
                    
                    context.beginPath()
                    
                    context.move(to: CGPoint(
                        x: 0,
                        y: coordinateY(price: chartPreviousClose, size: size)))
                    
                    context.addLine(to: CGPoint(
                        x: 0,
                        y: coordinateY(price: (quote?.open?[0] ?? chartPreviousClose), size: size)))
                    
                    context.setStrokeColor(((quote?.close?[0] ?? chartPreviousClose) - chartPreviousClose).sign == .plus ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor)

                    for index in 1..<timeStamp.count {
                        
                        //if let close = quote.close, let _ = close[index] {
                        if (self.viewController.priceForIndex(index) - chartPreviousClose).sign == (self.viewController.priceForIndex(index - 1) - chartPreviousClose).sign {
                                
                                context.setStrokeColor((self.viewController.priceForIndex(index) - chartPreviousClose).sign == .plus ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor)
                            
                                context.addLine(to: CGPoint(
                                    x: CGFloat(index) * stepX,
                                    y: coordinateY(price: self.viewController.priceForIndex(index), size: size)))
                            } else {
                                
                                context.addLine(to: CGPoint(
                                    x: betweenCoordinateX(index: index, deltaX: stepX),
                                    y: coordinateY(price: chartPreviousClose, size: size)))
                                
                                clippingPath.append(UIBezierPath(cgPath: context.path!))
                                
                                context.strokePath()
                                
                                context.beginPath()
                                context.move(to: CGPoint(
                                    x: betweenCoordinateX(index: index, deltaX: stepX),
                                    y: coordinateY(price: chartPreviousClose, size: size)))
                            }
                    }
                    
                    clippingPath.append(UIBezierPath(cgPath: context.path!))
                    
                    clippingPath.addLine(to: CGPoint(
                        x: clippingPath.bounds.origin.x + clippingPath.bounds.size.width,
                        y: coordinateY(price: chartPreviousClose, size: size)))
                    
                    context.strokePath()
                    
                    clippingPath.addClip()
                    gradientFill(context: context, size: size)
                    
                    context.move(to: CGPoint(
                        x: 0,
                        y: coordinateY(price: chartPreviousClose, size: size)))
                    
                    context.addLine(to: CGPoint(
                        x: 0,
                        y: coordinateY(price: quote?.close?[0] ?? chartPreviousClose, size: size)))
                    
                    context.setStrokeColor(UIColor.systemBackground.withAlphaComponent(0.5).cgColor)
                    context.strokePath()
                    
                    context.resetClip()
                    
                    context.move(to: CGPoint(
                        x: 0,
                        y: coordinateY(price: chartPreviousClose, size: size)))
                    context.addLine(to: CGPoint(
                        x: size.width,
                        y: coordinateY(price: chartPreviousClose, size: size)))
                    context.setLineDash(phase: 0.0, lengths: [2.0, 2.0])
                    context.setStrokeColor(UIColor.systemGray.cgColor)
                    
                    //context.setStrokeColor((meta.regularMarketPrice ?? 0) > chartPreviousClose ? UIColor.systemGreen.cgColor : UIColor.systemRed.withAlphaComponent(0.7).cgColor)
                    context.setLineWidth(1)

                    context.strokePath()
                    
                    
                    
                    if let regularMarketPrice = self.viewController.statistics?.optionChain?.result?.first?.quote?.regularMarketPrice {
                        
                        context.setFillColor((regularMarketPrice - chartPreviousClose).sign == .plus ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor)
                        
                        context.move(to: CGPoint(x: CGFloat(timeStamp.count) * stepX, y: coordinateY(price: regularMarketPrice, size: size)))
                        
                        context.addEllipse(in: CGRect(x: CGFloat(timeStamp.count) * stepX - 1.5, y: coordinateY(price: regularMarketPrice, size: size) - 1.5, width: 3, height: 3))
                        context.fillPath()
                    }
                    
                    
                }
            }
        }
        
        private func betweenCoordinateX(index: Int, deltaX: CGFloat) -> CGFloat {
            
            guard let quote = viewController.chart?.chart?.result?.first??.indicators?.quote?.first,
                let meta = viewController.chart?.chart?.result?.first??.meta, let chartPreviousClose = meta.chartPreviousClose else { return 0 }
            let previousPrice = (index == 1 ? (quote?.close?[0] ?? chartPreviousClose) : (self.viewController.priceForIndex(index - 1)))
            let deltaY = CGFloat(self.viewController.priceForIndex(index) - previousPrice)
            let differential = deltaX / deltaY
            let coordinateX = deltaX * CGFloat(index - 1) + CGFloat(self.viewController.priceForIndex(index) - chartPreviousClose) * differential
            return coordinateX
        }
        
        private func coordinateY(price: Double, size: CGSize) -> CGFloat {
    
            guard let meta = viewController.chart?.chart?.result?.first??.meta, let chartPreviousClose = meta.chartPreviousClose,  let extremums = viewController.chartExtremums else { return 0 }
            
            let rangeY = extremums.lowMin..<extremums.highMax
            
            let maxY = CGFloat(chartPreviousClose) > CGFloat(rangeY.upperBound) ? CGFloat(chartPreviousClose) : CGFloat(rangeY.upperBound)
            let minY = CGFloat(chartPreviousClose) < CGFloat(rangeY.lowerBound) ? CGFloat(chartPreviousClose) : CGFloat(rangeY.lowerBound)
            
            
            if maxY - minY != 0 {
                return size.height * (1 - (CGFloat(price) - minY) / (maxY - minY))
            } else {
                return size.height * 0.5
            }
            
        }
        
        private func gradientFill(context: CGContext, size: CGSize) {
            
            guard let meta = viewController.chart?.chart?.result?.first??.meta, let chartPreviousClose = meta.chartPreviousClose, let extremums = viewController.chartExtremums else {return}
            let rangeY = extremums.lowMin..<extremums.highMax
                
            let colors = [UIColor.systemGreen.withAlphaComponent(0.1).cgColor, UIColor.systemBackground.withAlphaComponent(1.0).cgColor, UIColor.systemRed.withAlphaComponent(0.1).cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var positionForWhiteColor = CGFloat((rangeY.upperBound - chartPreviousClose) / rangeY.distance)
            if positionForWhiteColor > 1.0 {
                positionForWhiteColor = 1.0
            } else if positionForWhiteColor < 0.0 {
                positionForWhiteColor = 0.0
            }
            let colorLocations: [CGFloat] = [0.0, positionForWhiteColor, 1.0]
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
            
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: [])
        }
}

struct GraphViewUI: UIViewRepresentable  {
    @ObservedObject var viewController: DetailChartViewController
 
    func makeUIView(context: UIViewRepresentableContext<GraphViewUI>) -> UIView {
        let graphView = GraphView(chartViewController: _viewController)
        graphView.backgroundColor = .clear
        return graphView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GraphViewUI>) {
        uiView.setNeedsDisplay()
    }
}



struct GraphViewUI_Previews: PreviewProvider {
    static var previews: some View {
        GraphViewUI(viewController: DetailChartViewController(withJSON: "AAPL"))
    }
}
