<h1 align="center">
  InTheGym
</h1>

<p align="center">
  <img src="https://user-images.githubusercontent.com/39130967/173814303-592372bb-a608-4618-956f-00ec51c06a34.PNG" width="115"     height="115">
</p>



<p align="center">
  <img src="https://user-images.githubusercontent.com/39130967/169828661-bebd907e-f9f9-4ea0-a35c-cca0d64fad0b.PNG" width="159"     height="300">
  <img src="https://user-images.githubusercontent.com/39130967/169829503-f3bb22fa-7148-4818-9fb6-82e9189b8261.PNG" width="159"     height="300">
  <img src="https://user-images.githubusercontent.com/39130967/177224531-423ee1a7-11dc-4047-aa34-80709b1a8924.PNG" width="159"     height="300">
  <img src="https://user-images.githubusercontent.com/39130967/177224580-a2de6114-da92-4d26-a67b-0ffa64faf099.PNG" width="159"     height="300">
  <img src="https://user-images.githubusercontent.com/39130967/177224587-89172d87-84be-4338-a1a3-fe5fdb12867a.PNG" width="159"     height="300">
</p>

InTheGym is an app that allows users to create and share workouts.

<h2>
  Development
</h2>

- Swift
- UIKit
- Small use of SwiftUI (Hosting controller for swiftUI integration)
- Combine
- MVVM
- Coordinator pattern for navigation

InTheGym uses Firebase as a backend to store all the workout and exercise data, UIKit to create screens (with a very small amount of SwiftUI),
MVVM (Model-View-ViewModel) design pattern, the coordinator pattern for app navigation and screen reuse and recently makes use of Combine to give
the app a more reactive feel.

<h2>
  Features
</h2>

SIGN UP

A user may sign up as either a player or a coach. The different user types are similar with a few important differences. Both types can
  - create workouts
  - share workouts
  
A coach user can, 
  - send requests to player users to become their 'coach'
  - assign workouts to players that have accepted their coach request
  - view workouts and workload data of players that have accepted their coach request
  - create groups
  
A player user can,
  - complete workouts
  - complete live workouts
  - monitor workload data
  - monitor exercise stats

<h2>
  WORKOUTS
</h2>
Workouts are created by choosing a list of exercises. For every exercise you must choose the number of sets, the number of reps and then you have the 
option to choose a weight, a time, a distance, a rest time and a note. Instead of choosing a regular exercise you have the option to create a circuit,
an AMRAP or an EMOM. A circuit allows the selection of multiple exercises to be completed in a group (like a superset), an AMRAP (as many rounds as possible)
allows the selection of exercises and a time limit which then allows the user to complete as many rounds as possible of the exercises in the given time limit,
an EMOM (every minute on the minute) also allows a selction of exercises and a time limit which then allows the user to complete given exercises every minute
until the time limit is reached. This allows for huge customisation when creating workouts.

EXERCISE STATS

InTheGym records stats everytime a user completes an exercise. The amount of reps completed, the amount of sets completed, the total amount of weight lifted, 
the max weight lifted for every exercise, the average weight lifted for every exercise and the average RPE of each exercise.

<h2>
  Premium Features
</h2>
  
  - Clips - Record up to 16 second video clips
  - Vertical Jump Height Measure
  - Programs

<h2>
  Performance Monitor
</h2>
With a premium account a user may gain access to the Performance Monitor. Here the user will be able to see all kinds of data relating to their performance including their Acute workload, Chronic workload, ACWR (Acute Chronic Workload Ratio) and more. 

<h1>
  Stack
</h1>

[<img src="https://user-images.githubusercontent.com/39130967/164758730-543f0199-01ad-4156-b726-ca67d1db9a78.png" width="50"/>](https://developer.apple.com/swift)
[<img src="https://user-images.githubusercontent.com/39130967/164758836-70854f98-2973-4e45-9945-f282b2e504ab.png" width="50"/>](https://developer.apple.com/documentation/uikit)
[<img src="https://user-images.githubusercontent.com/39130967/164758868-fe995259-307e-41c6-8a2d-55a525209a93.png" width="50"/>](https://firebase.google.com)
[<img src="https://user-images.githubusercontent.com/39130967/164760955-5761127b-9ec6-46ca-b338-4e692032b54e.png" width="50"/>](https://developer.apple.com/swiftui)

