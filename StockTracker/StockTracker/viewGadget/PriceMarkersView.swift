//
//  PriceMarkersView.swift
//  StockTracker
//
//  Created by Chenning Li on 12/8/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import SwiftUI

struct PriceMarkersView: View {
    
    @ObservedObject var viewController: DetailChartViewController
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        if self.viewController.chartExtremums != nil {
                            Text(self.formattedTextForDouble(value: self.viewController.chartExtremums?.highMax, signed: false) ?? "")
                                .padding([.leading, .trailing], 10)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                            .offset(x: -10, y: -5)
                            
                            Spacer()
                            
                            Text(self.formattedTextForDouble(value: self.viewController.chartExtremums?.lowMin, signed: false) ?? "")
                                .padding([.leading, .trailing], 5)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                            .offset(x: -10, y: 5)
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        if self.viewController.chart?.chart?.result?.first??.meta?.chartPreviousClose != nil {
                            
                            Text(self.formattedTextForDouble(value: self.viewController.chart?.chart?.result?.first??.meta?.chartPreviousClose, signed: false) ?? "")
                                .foregroundColor(Color(.white))
                                .padding([.leading, .trailing], 5)
                                .background(Color(.systemGray2))
                                .cornerRadius(10)
                            .offset(x: 10, y: 0)
                        }
                    }
                    Spacer()
                }
                .offset(x: 0, y: {
                    guard let meta = self.viewController.chart?.chart?.result?.first??.meta, let chartPreviousClose = meta.chartPreviousClose, let minY = self.viewController.chartExtremums?.lowMin, let maxY = self.viewController.chartExtremums?.highMax else { return 0 }
                    let rangeY = minY..<maxY
                    let max = CGFloat(chartPreviousClose) > CGFloat(rangeY.upperBound) ? CGFloat(chartPreviousClose) : CGFloat(rangeY.upperBound)
                    let min = CGFloat(chartPreviousClose) < CGFloat(rangeY.lowerBound) ? CGFloat(chartPreviousClose) : CGFloat(rangeY.lowerBound)
                    if max - min != 0 {
                        return geometry.size.height * (0.5 - (CGFloat(chartPreviousClose) - min) / (max - min))
                    } else {
                        return 0.5
                    }
                    
                }())
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .font(.footnote)
            
        }
        
    }
    
    private func formattedTextForDouble(value : Double?, signed: Bool) -> String? {
        guard let value = value else {return nil}
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = .some(" ")
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        guard let string = formatter.string(for: value.magnitude) else {return nil}
        
        if signed {
            if value == 0.0 {
                return "0.00"
            } else if value > 0.0 {
                return "+" + string
            } else if value < 0.0 {
                return "-" + string
            }
        }
        return string
    }
    
    
}

struct PriceMarkersView_Previews: PreviewProvider {
    static var previews: some View {
        PriceMarkersView(viewController: DetailChartViewController(withJSON: "AAPL"))
    }
}
