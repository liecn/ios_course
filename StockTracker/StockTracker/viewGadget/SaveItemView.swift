//
//  SaveItemView.swift
//  StockTracker
//
//  Created by Chenning Li on 12/8/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import SwiftUI
import Combine

struct SaveItemView: View {
    
    @EnvironmentObject var mainViewController: MainViewController
    
    @ObservedObject var viewController: DetailChartViewController
    
    @Binding var storeSymbolToListMode: Bool
    
    //@State var createNewListMode: Bool = false
    
    @State var textForListName: String = "List"
    @State var keyboardYOffset: CGFloat = 0
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 30) {
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    Text("Create List:")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemGray))
                    
                    Spacer().frame(height: 30)
                    HStack(alignment: .center, spacing: 0) {
                        TextField("Enter Text", text: self.$textForListName, onEditingChanged: { boolValue in}) {}
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            //.background(Color(.secondarySystemFill))
                            .frame(width: 200)
                        
                        Spacer()
                        
                        Button(action: {
                            
                            guard let symbol = self.viewController.symbol else {return}
                            
                            var index: Int = 0
                            
                            if let i = self.mainViewController.symbolLists.firstIndex(where: { $0.name == self.textForListName}) {
                                index = i
                                self.mainViewController.symbolLists[index].symbolsArray.append(symbol)
                            } else {
                                self.mainViewController.symbolLists.insert(SymbolList(name: self.textForListName, symbolsArray: [symbol], isActive: true), at: index)
                            }
                            
                            self.mainViewController.addNewModelWithSymbol(symbol, from: self.viewController, toListWithIndex: index)
                            
                            self.storeSymbolToListMode.toggle()
                            
                        }) {
                            Text("Save")
                        }
                        
                    }
                    
                }
                
                Spacer().frame(height: 30)
                
                if mainViewController.symbolLists.count > 0 {
                    Text("Save item into List:")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemGray))
                    
                    ForEach(self.mainViewController.symbolLists, id: \.id) { list in
                        
                        Button(action: {
                            
                            guard let symbol = self.viewController.symbol else {return}
                            
                            guard let index = self.mainViewController.symbolLists.firstIndex(where: { $0.id == list.id}) else {return}
                            
                            self.mainViewController.symbolLists[index].symbolsArray.append(symbol)
                            
                            self.mainViewController.addNewModelWithSymbol(symbol, from: self.viewController, toListWithIndex: index)
                            
                            self.storeSymbolToListMode.toggle()
                            
                        }) {
                            Text(list.name)
                                .font(.body)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                Spacer()
                    .frame(height: 30)
            }
            .padding([.leading, .trailing], 30)
        }//.onKeyboard($keyboardYOffset)
    }
}
