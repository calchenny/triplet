//
//  ContentView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_Status") var status = false
    var body: some View {
        ZStack{
            
            if status {
                VStack(spacing: 15){
                    Text("Logged in Successfully")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.black)
                }
            }
            else{
                NavigationStack {
                    Login()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
