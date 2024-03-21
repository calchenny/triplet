//
//  TripView.swift
//  Triplet
//
//  Created by Derek Ma on 3/13/24.
//

import SwiftUI
import MapKit
import AnimatedTabBar
import ScalingHeaderScrollView
import PopupView
import TipKit

struct MapTip: Tip {
    var title: Text {
        Text("Explore to the Map!")
    }
    
    var message: Text? {
        Text("Tap on the map to expand it, allowing you to find and engage with nearby landmarks or your itineraries.")
    }
    
    var image: Image? {
        Image(systemName: "map")
    }
}

struct TripView: View {
    var tripId: String
    var isActive: Bool
    @StateObject var tripViewModel: TripViewModel = TripViewModel()
    @State var selectedIndex: Int = 0
    @State var showMapView: Bool = false
    @Environment(\.dismiss) var dismiss

    func wiggleButtonAt(_ index: Int, name: String) -> some View {
        WiggleButton(image: Image(systemName: name), maskImage: Image(systemName: "\(name).fill"), isSelected: index == selectedIndex)
            .scaleEffect(1.2)
    }
    
    func getViews(isActive: Bool) -> [some View] {
        let active = ["star", "text.book.closed", "list.clipboard", "dollarsign.square"]
        let inActive = ["text.book.closed", "list.clipboard", "dollarsign.square"]
        
        return isActive ? (0..<active.count).map { wiggleButtonAt($0, name: active[$0]) } 
        : (0..<inActive.count).map { wiggleButtonAt($0, name: inActive[$0]) }
    }
    
    var body: some View {
        ScalingHeaderScrollView {
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .bottom) {
                    Map(position: Binding(
                        get: {
                            guard let cameraPosition = tripViewModel.cameraPosition else {
                                let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                                let region = MKCoordinateRegion(center: center, span: span)
                                
                                return MapCameraPosition.region(region)
                            }
                            return cameraPosition
                        },
                        set: { tripViewModel.cameraPosition = $0 }
                    ), interactionModes: [])
                    .onTapGesture {
                            showMapView = true
                    }
                    .popoverTip(MapTip(), arrowEdge: .top)
                    RoundedRectangle(cornerRadius: 15)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: 100)
                        .foregroundStyle(Color("Even Lighter Blue"))
                        .overlay(
                            VStack {
                                if let trip = tripViewModel.trip {
                                    Text(trip.name)
                                        .font(.custom("Poppins-Bold", size: 30))
                                        .foregroundStyle(Color("Dark Teal"))
                                    Text("\(trip.city), \(trip.state) | \(getDateString(date: trip.start)) - \(getDateString(date: trip.end))")
                                        .font(.custom("Poppins-Medium", size: 20))
                                        .foregroundStyle(Color("Dark Teal"))
                                }
                            }
                        )
                        .padding(.bottom, 30)
                        .scaleEffect(x: getHeaderWidthScale(collapseProgress: tripViewModel.headerCollapseProgress, screenWidth: UIScreen.main.bounds.width),
                                     y: getHeaderHeightScale(collapseProgress: tripViewModel.headerCollapseProgress))
                }
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "house")
                            .font(.title2)
                            .padding()
                            .background(Color("Dark Teal"))
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }
                    .padding(.top, 60)
                    .padding(.leading)
                    .tint(.primary)
                    Spacer()
                    Button {
                        tripViewModel.deleteTrip()
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                            .font(.title2)
                            .padding()
                            .background(.evenLighterBlue)
                            .foregroundStyle(.red)
                            .clipShape(Circle())
                    }
                    .padding(.top, 60)
                    .padding(.trailing)
                    .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity)
        } content: {
            VStack {
                    switch selectedIndex {
                    case 0:
                        if isActive {
                            ActiveTripView(tripId: tripId)
                        } else {
                            OverviewView(tripId: tripId)
                        }
                    case 1:
                        if isActive {
                            OverviewView(tripId: tripId)
                        } else {
                            ItineraryView(tripId: tripId)
                        }
                    case 2:
                        if isActive {
                            ItineraryView(tripId: tripId)
                        } else {
                            ExpensesView(tripId: tripId)
                        }
                    default:
                        ExpensesView(tripId: tripId)
                    }
            }
        }
        .height(min: tripViewModel.headerMinHeight, max: tripViewModel.headerMaxHeight)
        .allowsHeaderCollapse()
        .collapseProgress($tripViewModel.headerCollapseProgress)
        .setHeaderSnapMode(.immediately)
        .ignoresSafeArea(edges: .top)
        .popup(isPresented: $showMapView) {
            MapView(showMapView: $showMapView)
                .environmentObject(tripViewModel)
                .navigationBarBackButtonHidden(true)
        } customize: { popup in
            popup
                .appearFrom(.top)
                .type(.default)
                .position(.center)
                .animation(.easeIn)
                .closeOnTap(false)
                .closeOnTapOutside(false)
                .dragToDismiss(false)
                .isOpaque(true)
                .backgroundColor(.white)
        }
        .environmentObject(tripViewModel)
        .onAppear {
            tripViewModel.subscribe(tripId: tripId)
        }
        .onDisappear {
            tripViewModel.unsubscribe()
        }
        AnimatedTabBar(selectedIndex: $selectedIndex, views: getViews(isActive: isActive))
            .cornerRadius(16)
            .selectedColor(.darkTeal)
            .unselectedColor(.darkTeal.opacity(0.6))
            .ballColor(.darkTeal)
            .verticalPadding(15)
            .ballTrajectory(.teleport)
    }
}
