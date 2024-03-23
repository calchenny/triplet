## Triplet

### **Project Summary:**

Triplet is an application aimed to minimize disruptions during trips. Our application will allow users to effortlessly create, coordinate, and organize their travel plans.

### **Designing the App:**

[Figma FigJam](https://www.figma.com/file/YD1pgMpGIpVLccyFjbvJRt/Triplet-Flow-Chart?type=whiteboard&node-id=0%3A1&t=WyW6GuQih4Op8yX0-1)

[Figma Wireframe](https://www.figma.com/file/8epjXgVJ385PMJiG4TgJOY/Triplet-Design?type=design&node-id=245%3A6380&mode=design&t=C2eqYvmU2h2ePDjS-1)

### **How to Use the App**
- Use Xcode 15.3 and ensure that the simulator is running on iOS 17.4
- Test Account: 650-555-1234 (OTP Code: 123456)
- You may login with your own phone number but there's a quota of 10 logins on Firebase, so it's best to use test account
- There's a quota of 250 runs for the Yelp API as well
- The location of the user is defaulted on the simulator to Cupertino, CA. This means that if you want to test out the map view thoroughly, please install on your device or set your simulator's current location
- Use a unique bundle identifier, such as: edu.ucdavis.cs.ecs189e.Triplet.Sam
- If there are dependency issues, please run this command in your terminal within the project directory and restart Xcode: `xcodebuild -resolvePackageDependencies` 

### **Basic Overview of Our Code**
Majority of code has been organized by feature in the [Features](https://github.com/calchenny/triplet/tree/main/Triplet/Features) folder
- Login: handles login and verification
- Home: tab view that displays user trips, creating a new trip, and settings page
- Trip: tab view that displays the following tabs and also the map view in every view
    - Active Trip: if the trip has started, then the trip will have an active trip tab
    - Overview: overview tab of the trip with the notes, hotel and food selections
    - Itinerary: itinerary tab of the trip to show trip itinerary in a digestable format
    - Expenses: expense tab for users to keep track of their budget and expenses for the trip
    - Map: view important landmarks, such as police stations, hospitals, and itineraries near the user

#### Packages and APIs
- Yelp API: location suggestions
- MapKit: map view
- PhoneNumberKit: Formating the phone number
- PopupView for pop-up content, like searching, notes, and expenses
- Firebase iOS SDK: Authentication, Firestore Database
- AnimatedTabBar: Fun tab bar that's animated
- ScalingHeaderScrollView: Sticky header which shrinks as you scroll
- TipKit: Popup tips

