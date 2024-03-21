## Triplet

### **Project Summary:**

Triplet is an application aimed to minimize disruptions during trips. Our application will allow users to effortlessly create, coordinate, and organize their travel plans.

### **Designing the App:**

[Figma FigJam](https://www.figma.com/file/YD1pgMpGIpVLccyFjbvJRt/Triplet-Flow-Chart?type=whiteboard&node-id=0%3A1&t=WyW6GuQih4Op8yX0-1)

[Figma Wireframe](https://www.figma.com/file/8epjXgVJ385PMJiG4TgJOY/Triplet-Design?type=design&node-id=245%3A6380&mode=design&t=C2eqYvmU2h2ePDjS-1)


### **Build the App**
- Test Account: 650-555-1234 (OTP Code: 123456)
- You may login with your own phone number but there's a quota of 10 logins on Firebase, so it's best to use test account
- There's a quota of 250 runs for the Yelp API as well

### **Basic Overview of Our Code**

Majority of code has been organized by feature in the [Features](https://github.com/calchenny/triplet/tree/main/Triplet/Features) folder
- Login: handles login and verification
- Home: tab view that displays user trips, creating a new trip, and settings page
- Trip: tab view that displays the following tabs and also the map view in every view
    - Active Trip: if the trip has started, then the trip will have an active trip tab
    - Overview: overview tab of the trip with the notes, hotel and food selections
    - Itinerary: itinerary tab of the trip to show trip itinerary in a dijestable format
    - Expenses: expenses tab
