//
//  ListView.swift
//  StockTracker
//
//  Created by Chenning Li on 11/30/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import SwiftUI

struct ListView: View {
    
    var list: SymbolList
    
    @ObservedObject var mainViewController: MainViewController
    @Binding var detailIsActive: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Spacer().frame(width: 15)
                Button(action: {
                    if let index = self.mainViewController.symbolLists.firstIndex(where: { $0.id == self.list.id}) { 
                        withAnimation(.linear(duration: 0.3)) {
                            self.mainViewController.symbolLists[index].isActive.toggle()
                            
                            if self.mainViewController.symbolLists[index].isActive {
                                for symbol in self.mainViewController.symbolLists[index].symbolsArray {
                                    self.mainViewController.modelWithId(symbol).mode = self.mainViewController.connectionCheck ? .active : .waiting
                                }
                            } else {
                                for symbol in self.mainViewController.symbolLists[index].symbolsArray {
                                    self.mainViewController.modelWithId(symbol).mode = .hidden
                                }
                            }
                        }
                    }
                }) {
                    
                    HStack {
                        Text(list.name)
                            .font(.body)
                            .fontWeight(.heavy)
                            .foregroundColor( self.list.isActive ? Color(.systemGray) : Color(.black))
                            .padding(3)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if !self.list.isActive {
                            Text("\(list.symbolsArray.count) \(list.symbolsArray.count == 1 ? "item" : "items")")
                                .font(.footnote)
                                .foregroundColor(Color(.systemGray))
                                .padding(.trailing, 10)
                        } else {
                            if list.symbolsArray.count == 0 {
                                Text("Empty")
                                    .font(.footnote)
                                    .foregroundColor(Color(.systemGray4))
                                    .padding(.trailing, 10)
                            }
                        }
                        
                        Image(systemName: self.list.isActive ? "chevron.up": "chevron.down").foregroundColor(Color(.systemGray2))
                            .padding()
                    }
                    
                }
                
            }
            
            if self.list.isActive == true {
                
                VStack(alignment: .center, spacing: 0) {
                    
                    if list.symbolsArray.count != 0 {
                        Divider()
                    }
                    
                    ForEach(list.symbolsArray, id: \.self) { symbol  in
                        
                        Button(action: {
                            
                            self.detailIsActive = true
                            let detailController = DetailChartViewController(withSymbol: symbol, connectionCheck: self.mainViewController.connectionCheck)
                            detailController.statistics = self.mainViewController.modelWithId(symbol).statistics
                            self.mainViewController.detailViewController = detailController
                        })
                        {
                            VStack {
                                ChartView(viewController: self.mainViewController.modelWithId(symbol))
                                    .foregroundColor(.primary)
                                    .padding([.leading, .trailing], 5)
                                    .frame(height: 70)
                                
                                Divider()
                                    .padding(.horizontal)
                            }
                            
                        } // Button
                    }
                    .id(UUID())
                    
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding([.leading, .trailing, .bottom], 10)
        
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(list: SymbolList(name: "EQUITY", symbolsArray: ["AAPL"], isActive: true), mainViewController: MainViewController(from: "AAPL"), detailIsActive: .constant(true))
    }
}
