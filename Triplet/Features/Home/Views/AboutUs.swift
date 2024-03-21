//
//  AboutUs.swift
//  About us popup in the settings page with a brief overview of who we are
//  Triplet
//
//  Created by Xiaolin Ma on 3/21/24.
//

import SwiftUI

struct AboutUs: View {
    @Binding var showAboutUs: Bool
    
    // Object for the sections
    struct SectionData: Identifiable {
        let id = UUID()
        let title: String
        let description: String
    }
    
    // Defining the about us sections
    let sections = [
        SectionData(title: "Effortless Planning", description: "Say goodbye to travel stress. With Triplet, planning trips is effortless."),
        SectionData(title: "Personalized Experience", description: "Tailored to you. We analyze patterns to minimize disruptions and maximize enjoyment."),
        SectionData(title: "Start Your Adventure", description: "Join us in redefining travel planning. With Triplet, your adventure begins the moment you start planning. Say hello to stress-free journeys and hello to the ease of having a personal travel assistant at your fingertips.")
    ]
    
    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.white)
            VStack(alignment: .leading) {
                ZStack(alignment: .trailing) {
                    HStack {
                        Text("About Us")
                            .font(.custom("Poppins-Bold", size: 30))
                            .foregroundStyle(Color("Dark Teal"))
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    Button {
                        // Close the popup by toggling the binding
                        showAboutUs = false
                    } label: {
                        Circle()
                            .frame(maxWidth: 30)
                            .foregroundStyle(Color("Dark Teal"))
                            .overlay {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                            }
                    }
                    
                }
                .padding([.top, .bottom], 20)
                
                // Iterate through each of the About Us Sections
                ForEach(sections, id: \.title) { section in
                    SectionView(section: section)
                }
                Spacer()
                
                
            }
            .padding([.leading, .trailing], 20)
        }
        .padding()
        .frame(maxHeight: 600)
    }
    
    // Helper view to display the section title and texts
    struct SectionView: View {
        let section: SectionData
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(section.title)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundStyle(.darkTeal)
                Text(section.description)
                    .font(.custom("Poppins-Regular", size: 16))
            }
            .padding(.bottom, 20)
        }
    }
}
