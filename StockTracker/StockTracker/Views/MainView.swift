//
//  Main.swift
//  StockTracker
//
//  Created by Chenning Li on 11/29/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct MainView: View {
    
    @State private var searchText : String = ""
    
    @ObservedObject var mainViewController: MainViewController
    
    @State var isSearchMode: Bool = false
    @State var isEditMode: Bool = false
    
    @State var isSettingsMode: Bool = false
    
    @State var rssIsActive: Bool = false
    
    @State var detailIsActive: Bool = false
    
    @State var showTrendDetailsView: Bool = false
    
    @State var infoState: Int = 0
    
    @State var trendSymbol: String = ""
    
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    var body: some View {
        HStack {
            NavigationView {
                VStack(alignment: .center, spacing: 0){
                    
                    // connection check view
                    if !self.mainViewController.connectionCheck {
                        HStack {
                            Spacer()
                            Text("Internet is not available")
                                .font(.headline)
                                .foregroundColor(Color(.systemYellow))
                            Spacer()
                        }
                        .background(Color(.systemRed))
                        .padding([.horizontal], 40)
                        .cornerRadius(10)
                    }
                    //MARK: SELECTION BUTTON
                    ScrollView(.horizontal,showsIndicators: false) {
                        HStack(spacing: 0) {
                            Button(action: { self.infoState = 0 }, label: {
                                
                                HStack {
                                    Text("Watchlist").fontWeight(.bold)
                                        .frame(width: 100, height: 30)
                                        .foregroundColor(Color(.white))
                                }
                                
                            }).background(Image("color2").resizable().cornerRadius(5))
                            
                            Spacer()
                            
                            Button(action: {  self.infoState = 1; self.mainViewController.rssSubject.send()
                            }, label: {
                                
                                HStack {
                                    Text("News").fontWeight(.bold)
                                        .frame(width: 70, height: 30)
                                        .foregroundColor(Color(.white))
                                }
                                
                            }).background(Image("color3").resizable().cornerRadius(5))
                            
                            Spacer()
                            
                            Button(action: {  self.infoState = 2 }, label: {
                                
                                HStack {
                                    Text("Trend").fontWeight(.bold)
                                        .frame(width: 70, height: 30)
                                        .foregroundColor(Color(.white))
                                }
                                
                            }).background(Image("color1").resizable().cornerRadius(5))
                            
                            Spacer()
                            
                            Button(action: {
                                self.infoState = 3
                            }, label: {
                                
                                HStack {
                                    Text("Signal").fontWeight(.bold)
                                        .frame(width: 70, height: 30)
                                        .foregroundColor(Color(.white))
                                }
                                
                            })
                                .background(Image("color4").resizable().cornerRadius(5))
                            
                            Spacer()
                            
                            Button(action: {  self.infoState = 4 }, label: {
                                
                                HStack {
                                    Text("More!").fontWeight(.bold)
                                        .frame(width: 80, height: 30)
                                        .foregroundColor(Color(.white))
                                }
                                
                            }).background(Image("color5").resizable().cornerRadius(5))
                            
                            
                        }
                        .padding()
                    }
                    
                    //MARK: VIEW PART
                    ScrollView(.vertical, showsIndicators: true, content: {
                        //MARK: WATCH LISTS
                        if self.infoState == 0 {
                            HStack(spacing: 0) {
                                Button(action: { self.isSearchMode.toggle() }, label: {
                                    
                                    HStack {
                                        Spacer()
                                        Image(systemName: "magnifyingglass").foregroundColor(Color(.systemGray))
                                        Text("Lookup")
                                            .frame(width: 70, height: 30, alignment: .leading)
                                            .foregroundColor(Color(.systemGray))
                                        Spacer()
                                    }
                                    .background(Color(.systemGray5)).cornerRadius(5)
                                    
                                })
                                    .sheet(isPresented: $isSearchMode, content: {
                                        SearchFieldView(mainViewController: self.mainViewController, detailIsActive: self.$detailIsActive, isSearchMode: self.$isSearchMode)
                                            .onAppear {}
                                            .onDisappear {}
                                    })
                                
                                Spacer().frame(width: 100)
                                
                                Button(action: {
                                    self.isEditMode = true
                                }) {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "pencil").foregroundColor(Color(.systemGray))
                                        Text("Edit Lists")
                                            .frame(width: 70, height: 30, alignment: .leading)
                                            .foregroundColor(Color(.systemGray))
                                        Spacer()
                                    }
                                }
                                .background(Color(.systemGray5))
                                .cornerRadius(5)
                                .sheet(isPresented: $isEditMode, content: {
                                    EditView(mainViewController: self.mainViewController)
                                        .background(Color(UIColor.systemGray5.withAlphaComponent(0.5)))
                                        .onAppear {}
                                        .onDisappear { self.isEditMode = false }
                                })
                            }
                            .padding()
                            
                            ZStack {
                                NavigationLink("DETAIL", destination: {
                                    VStack{
                                        if self.detailIsActive == true {
                                            if self.mainViewController.detailViewController != nil {
                                                DetailChartView(viewController: self.mainViewController.detailViewController ?? DetailChartViewController(withSymbol: nil, connectionCheck: self.mainViewController.connectionCheck))
                                                    .onAppear {
                                                        if self.mainViewController.connectionCheck {
                                                            self.mainViewController.chartViewControllers.forEach{
                                                                if $0.mode != .hidden {
                                                                    $0.mode = .waiting
                                                                }
                                                            }
                                                        }
                                                }.onDisappear {
                                                    self.mainViewController.detailViewController?.cancelSubscriptions()
                                                    self.mainViewController.detailViewController = nil
                                                    self.detailIsActive = false
                                                    
                                                    if self.mainViewController.connectionCheck {
                                                        self.mainViewController.chartViewControllers.forEach{
                                                            if $0.mode != .hidden {
                                                                $0.mode = .active
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                EmptyView()
                                            }
                                        } else {
                                            EmptyView()
                                        }
                                    }
                                }(), isActive: self.$detailIsActive) // NavigationLink
                                    .opacity(0)
                                
                                VStack(spacing: 10) {
                                    
                                    ForEach(mainViewController.symbolLists, id: \.id) { list in
                                        ListView(list: list, mainViewController: self.mainViewController, detailIsActive: self.$detailIsActive)
                                    }
                                    .id(UUID())
                                }
                            }.padding([.top], -10)
                            
                            
                            Spacer()
                                .frame(height: 30)
                        }
                            
                            //MARK: - RSS BUTTON
                        else if self.infoState == 1 {
                            ZStack {
                                NavigationLink("RSS", destination: {
                                    VStack{
                                        if self.rssIsActive == true {
                                            if mainViewController.currentRssUrl != nil {
                                                RSSLinkView(url: mainViewController.currentRssUrl!)
                                                    .onAppear {
                                                        self.mainViewController.chartViewControllers.forEach{
                                                            if $0.mode != .hidden {
                                                                $0.mode = .waiting
                                                            }
                                                        }}
                                                    .onDisappear {
                                                        self.rssIsActive = false
                                                        self.mainViewController.currentRssUrl = nil
                                                        self.mainViewController.chartViewControllers.forEach{
                                                            if $0.mode != .hidden {
                                                                $0.mode = .active
                                                            }
                                                        }
                                                }
                                            } else {
                                                EmptyView()
                                            }
                                            
                                        } else {
                                            EmptyView()
                                        }
                                    }
                                }(), isActive: self.$rssIsActive) // NavigationLink
                                    .opacity(0)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(mainViewController.rss, id: \.id) {  item in
                                        Button(action: {
                                            self.rssIsActive = true
                                            self.mainViewController.currentRssUrl = URL(string: item.link)
                                        }) {
                                            VStack {
                                                RSSView(item: item)
                                            }
                                        }
                                    }
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                }
                            }
                        }
                        else if self.infoState == 2 {
                            NavigationLink("TRENDDETAIL", destination: {
                                VStack{
                                    if self.showTrendDetailsView {
                                        if self.mainViewController.detailViewController == nil {
                                            DetailChartView(viewController: self.mainViewController.detailViewController ?? DetailChartViewController(withSymbol: self.trendSymbol, connectionCheck: self.mainViewController.connectionCheck)).environmentObject(self.mainViewController).onAppear(perform: {
                                            })
                                                .onDisappear(
                                                    perform: {
                                                        self.showTrendDetailsView=false
                                                        self.mainViewController.detailViewController?.cancelSubscriptions()
                                                        self.mainViewController.detailViewController = nil
                                                }
                                            )}
                                        else{
                                            EmptyView()
                                        }
                                    }
                                    else{
                                        EmptyView()
                                    }
                                }
                            }(), isActive: self.$showTrendDetailsView) // NavigationLink
                                .opacity(0)
                            
                            VStack(spacing: 20) {
                                Spacer().frame(height:10)
                                HStack() {
                                    Button(action: {
                                        self.showTrendDetailsView=true
                                        self.trendSymbol="AAPL"
                                    }){
                                        Text("AAPL").fontWeight(.bold)
                                            .foregroundColor(Color(.white))
                                    }
                                    .background(Image("trend1").resizable().frame(width: screenWidth/4+20, height: 170).cornerRadius(30)).padding(50)
                                    Spacer()
                                    Button(action: {
                                        self.showTrendDetailsView=true
                                        self.trendSymbol="MCD"
                                    }){
                                        Text("MCD").fontWeight(.bold)
                                            .foregroundColor(Color(.white))
                                    }
                                    .background(Image("trend2").resizable().frame(width: screenWidth*3/4-70, height: 170,alignment: .trailing).cornerRadius(30)).padding(50)
                                    Spacer()
                                }
                                Spacer().frame(height:50)
                                HStack(spacing: 30) {
                                    Spacer()
                                    Button(action: {
                                        self.showTrendDetailsView=true
                                        self.trendSymbol="TWTR"
                                    }){
                                        Text("TWTR").fontWeight(.bold)
                                            .foregroundColor(Color(.white))
                                    }
                                    .background(Image("trend3").resizable().frame(width: screenWidth*2/3-40, height: 260,alignment: .leading).cornerRadius(30)).padding(50)
                                    
                                    Spacer().frame(width: 30)
                                    
                                    VStack {
                                        Button(action: {self.showTrendDetailsView=true
                                            self.trendSymbol="NKE"
                                        }){
                                            Text("NKE").fontWeight(.bold)
                                                .foregroundColor(Color(.white))}
                                            .background(Image("trend4").resizable().frame(width: screenWidth/3-10, height: 120,alignment: .top).cornerRadius(30))
                                        
                                        Spacer().frame(height: 120)
                                        Button(action: { self.showTrendDetailsView=true
                                            self.trendSymbol="PYPL"
                                        }){
                                            Text("PYPL").fontWeight(.bold)
                                                .foregroundColor(Color(.white))
                                        }
                                        .background(Image("trend5").resizable().frame(width: screenWidth/3-10, height: 120,alignment: .bottom).cornerRadius(30))
                                    }
                                    Spacer()
                                }
                                
                                Spacer().frame(height:100)
                                ZStack() {
                                    Button(action: {
                                        self.showTrendDetailsView=true
                                        self.trendSymbol="LYFT"
                                    }){
                                        Text("LYFT").fontWeight(.bold)
                                            .foregroundColor(Color(.white))
                                            .frame(alignment: .center)
                                    }
                                }
                                .background(Image("trend6").resizable().frame(width: screenWidth-25, height: 170,alignment: .leading).cornerRadius(40))
                            }.frame(width:screenWidth).padding(10)
                        }
                        else if self.infoState == 3 {
                            VStack{
                                Image("signal")
                                    .resizable()
                                    .scaledToFill()
                            }
                            
                        }
                    }) // ScrollView
                        .onAppear(perform: { })
                        .onDisappear(perform: {
                            self.isSearchMode = false
                        })
                        .background(Color(UIColor.systemGray5.withAlphaComponent(0.5)))
                        .navigationBarTitle("", displayMode: NavigationBarItem.TitleDisplayMode.inline)
                        .navigationBarItems(
                            leading: Button(action: {
                                NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
                            }, label: {
                                Text("< Logout")
                            }),
                            trailing: Button(action: { self.isSettingsMode = true }, label: {
                                Image(systemName: "person").foregroundColor(Color(.systemBlue))
                            })
                                .padding()
                                .sheet(isPresented: self.$isSettingsMode, content: {
                                    SettingsView()
                                })
                    )
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(mainViewController: MainViewController(from: "AAPL"))
    }
}

