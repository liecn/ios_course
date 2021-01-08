//
//  SettingsView.swift
//  StockTracker
//
//  Created by Chenning Li on 12/8/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import SwiftUI
import Parse
import MapKit

struct SettingsView: View {
    //@State var isDarkMode: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State var username = String((PFUser.current()?.username)!)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    var body: some View {
        HStack {
            NavigationView {
                VStack{
                    Spacer().frame(height:150)
                    Image("dollarHead")
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                        .scaledToFit()
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                        .offset(y: -130)
                        .padding(.bottom, -130)
                    
                    Text(username)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Image("cash")
                        .resizable()
                        .scaledToFit()
                        .padding()
                    .cornerRadius(30)
                    
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            //debugPrint("get")
                            return UserDefaults.standard.integer(forKey: "LastStyle") != UIUserInterfaceStyle.light.rawValue },
                        set: {
                            //debugPrint("set")
                            SceneDelegate.shared?.window!.overrideUserInterfaceStyle = $0 ? .dark : .light
                            UserDefaults.standard.setValue($0 ? UIUserInterfaceStyle.dark.rawValue : UIUserInterfaceStyle.light.rawValue, forKey: "LastStyle")
                    }
                    )) {
                        Text("Dark Mode")
                            .font(.body)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    Button(action: { self.onLogout() }){
                        
                        HStack {Spacer()
                            Text("Log Out")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.white))
                                .padding(.vertical, 5)
                            Spacer()
                        }
                            
                        .background(Color(.black)).cornerRadius(5)
                        
                    }.padding()
                    
                }.navigationBarTitle("Setting", displayMode: NavigationBarItem.TitleDisplayMode.inline)
                    .navigationBarItems(
                        leading: Button(action: {self.presentationMode.wrappedValue.dismiss() }, label: {
                            Text("Cancel")
                        })
                )
                
            }
        }
    }
    private func onLogout() {
        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
