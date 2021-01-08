//
//  TimeMarkersView.swift
//  StockTracker
//
//  Created by Chenning Li on 12/8/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import SwiftUI

struct TimeMarkersView: View {
    
    
    @ObservedObject var viewController: DetailChartViewController
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(self.viewController.elementsForTimeSymbol ?? [Int](), id: \.self) { index in
                Text(self.textForIndex(index)).offset(x: self.offcetForIndex(index, size: geometry.size)).font(.caption)
            }
        }
    
    }
    
    private func textForIndex(_ index: Int) -> String {
        guard let timeStamp = viewController.chart?.chart?.result?.first??.timestamp, let timeZone = viewController.chart?.chart?.result?.first??.meta?.timezone, let range = viewController.chart?.chart?.result?.first??.meta?.range else {return ""}
        
        let dateFormatter = DateFormatter()
        let time = Date(timeIntervalSince1970: Double(timeStamp[index]))
        dateFormatter.timeZone = TimeZone(abbreviation: timeZone)
        
        switch range {
        case Period.oneDay.rawValue:
            dateFormatter.dateFormat = "HH"
            return dateFormatter.string(from: time)
        case Period.fiveDays.rawValue:
            dateFormatter.dateFormat = "E"
            return dateFormatter.string(from: time)
        case Period.oneMonth.rawValue:
            dateFormatter.dateFormat = "d MMM"
            return dateFormatter.string(from: time)
        case Period.sixMonth.rawValue:
            dateFormatter.dateFormat = "MMM"
            return dateFormatter.string(from: time)
        case Period.ytd.rawValue:
            dateFormatter.dateFormat = "MMM"
            return dateFormatter.string(from: time)
        case Period.oneYear.rawValue:
            dateFormatter.dateFormat = "MMM"
            return dateFormatter.string(from: time)
        case Period.fiveYear.rawValue:
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter.string(from: time)
        case Period.max.rawValue:
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter.string(from: time)
        default:
            return ""
        }
        
    }
    
    private func offcetForIndex(_ index: Int, size: CGSize) -> CGFloat {
        guard let timeMarkerCount = viewController.timeMarkerCount else {return 0}
        let width = size.width
        let step: CGFloat = width / CGFloat(timeMarkerCount)
        return step * CGFloat(index)
    }
    
}

struct TimeMarkersView_Previews: PreviewProvider {
    static var previews: some View {
        TimeMarkersView(viewController: DetailChartViewController(withJSON: "AAPL"))
    }
}
