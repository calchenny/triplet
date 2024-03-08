## Sprint 4 Planning Meeting Notes - 3/7/2024

### **Project Summary:**

Triplet is an application aimed to minimize disruptions during trips. Our application will allow users to effortlessly create, coordinate, and organize their travel plans.

### **Important Links:**

[Trello Board](https://trello.com/invite/b/OypZmBTq/ATTI206a0bd3b645a7a996c3d7a407be8f3a38BA8E12/triplet)

[Figma FigJam](https://www.figma.com/file/YD1pgMpGIpVLccyFjbvJRt/Triplet-Flow-Chart?type=whiteboard&node-id=0%3A1&t=WyW6GuQih4Op8yX0-1)

[Figma Wireframe](https://www.figma.com/file/8epjXgVJ385PMJiG4TgJOY/Triplet-Design?type=design&node-id=245%3A6380&mode=design&t=C2eqYvmU2h2ePDjS-1)

### **Sprint Meeting Notes:**

**What we did:**
- Merged branches during the sprint meeting
- Updated UI for login, verification, and logo
- Created a Launch screen
- Implemented a map view to display important locations near the user
- Add colors, logo, and font styles to existing views
- Added logic for adding to the Firebase

**What we plan to do:**
- Fully integrate Firebase with the app
- Connect all the screens
- Finish root view and retrieve user data from Firebase

**Issues that we are facing:**
- Many Xcode issues: merge, revert, packages

### **Individual Notes:**

- **[Calvin Chen]:**

  - **Done:**
    - [Link to Commit 1](https://github.com/calchenny/triplet/commit/8969fbfa5626ac6d0e0ce3218fbd779751b34cf5) - Map View with user location
    - [Link to Commit 2](https://github.com/calchenny/triplet/commit/d811bf40a1c50c487a2fb8def08a6a3158dbb3dc) - Location markers for important locations: police, hospitals, bus stops, ATMs, car rental, airport, transport
    - [Link to Commit 3](https://github.com/calchenny/triplet/commit/d811bf40a1c50c487a2fb8def08a6a3158dbb3dc) - Implemented distance between user and marker
    - [Link to Commit 4](https://github.com/calchenny/triplet/commit/22805894ebcf1970527793d93dc1ee22efb049d2) - Changed the login and verification UI

  - **To Do:**
    - Integrate map view into current trip view
    - Integrate MapKit navigation logic

  - **Blockers:**
    - Xcode packages

- **[Xiaolin Ma]:**
  - **Done:**
    - [Link to Commit 1](https://github.com/calchenny/triplet/commit/79d08ee410227e246eeb46f663b81095b153ff48) - Launch screen
    - [Link to Commit 2](https://github.com/calchenny/triplet/commit/79d08ee410227e246eeb46f663b81095b153ff48) - Merge screens
    - Added a Firebase user model to keep track of current user
  - **To Do:**
    - Implement sign-out feature 
    - Root view
  - **Blockers:**
    - Resolving issues with the verification view
- **[Derek Ma]:**
  - **Done:**
    - [Link to Commit 1](https://github.com/calchenny/triplet/commit/c5e1edde359dceaa47e1390d350f09ecf4f3163a) - Backend event listeners
  - **To Do:**
    - Date pickers and location search
    - Need to figure out the popup view
  - **Blockers:**
    - Xcode compile issues
- **[Andy Lam]:**
  - **Done:**
    - [Link to Commit 1](https://github.com/calchenny/triplet/commit/9298aa627840973a68a4273f9620ffb958cf40de) - Imported fonts/colors into itinerary/addNewPlace
    - [Link to Commit 2](https://github.com/calchenny/triplet/commit/9298aa627840973a68a4273f9620ffb958cf40de) - Adding event data to Firebase 
  - **To Do:**
    - Need to convert GeoPoint to String Address
    - Add the trip struct to itinerary viewmodel
  - **Blockers:**
      - Xcode compile issues
- **[Newland Luu]:**
  - **Done:**
    - [Link to Commit 1](https://github.com/calchenny/triplet/commit/3eeaa9e303fd0cb16eb43fea1babe4041eac465a) - Implemented date picker for expenses
    - [Link to Commit 2](https://github.com/calchenny/triplet/commit/3eeaa9e303fd0cb16eb43fea1babe4041eac465a) - Got the Yelp API working for the suggestions and displayed top 3 relevant options
  - **To Do:**
    - Link up expenses to Firebase
    - Refine the views UI
  - **Blockers:**
    - Xcode compile issues

### **Additional Notes:**
- 
