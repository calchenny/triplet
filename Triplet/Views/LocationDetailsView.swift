//
//  LocationDetailsView.swift
//  Triplet
//
//  Created by Calvin Chen on 3/2/24.
//

import SwiftUI
import MapKit

struct LocationDetailsView: View {
    @Binding var mapSelection: MapFeature?
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(mapSelection?.title ?? "")
                        .font(.custom("Poppins-Medium", size: 32))

                }
                
                Spacer()
                
                Button {
                    show.toggle()
                    mapSelection = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.darkerGray, Color(.systemGray6))
                }
            }
            HStack(spacing: 24) {
                Button {
                    if let mapSelection {
//                        mapSelection.openInMaps()
                    }
                } label: {
                    Text("Open in Maps")
                        .font(.custom("Poppins-Regular", size: 24))
                        .frame(width: 170, height: 48)
                        .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    LocationDetailsView(mapSelection: .constant(nil), show: .constant(false))
}
