<p align="center">
  # InTheGym
</p>

This repository contains all the files for the app InTheGym.

InTheGym is an app that allows users to create and share workouts.

<p align="center">
  <img src="https://user-images.githubusercontent.com/39130967/164715709-beb8dfeb-00a2-4740-baef-d94304763e0a.png" width="115"     height="250">
  <img src="https://user-images.githubusercontent.com/39130967/164715673-7826de10-148e-4afa-9902-ce2f6e8f2ec2.png" width="115"     height="250">
  <img src="https://user-images.githubusercontent.com/39130967/164715704-8859e5a5-8313-4832-b9e3-575b88c842f6.png" width="115"     height="250">
  <img src="https://user-images.githubusercontent.com/39130967/164715693-91305407-0215-4bed-950c-772c1f73d0c9.png" width="115"     height="250">
  <img src="https://user-images.githubusercontent.com/39130967/164714582-1c003763-056c-4fe3-b2a2-8f1c36478968.png" width="115"     height="250">
</p>

InTheGym uses Firebase as a backend to store all the workout and exercise data, UIKit to create screens (with a very small amount of SwiftUI),
MVVM (Model-View-ViewModel) design pattern, the coordinator pattern for app navigation and screen reuse and recently makes use of Combine to give
the app a more reactive feel.


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


WORKOUTS

Workouts are created by choosing a list of exercises. For every exercise you must choose the number of sets, the number of reps and then you have the 
option to choose a weight, a time, a distance, a rest time and a note. Instead of choosing a regular exercise you have the option to create a circuit,
an AMRAP or an EMOM. A circuit allows the selection of multiple exercises to be completed in a group (like a superset), an AMRAP (as many rounds as possible)
allows the selection of exercises and a time limit which then allows the user to complete as many rounds as possible of the exercises in the given time limit,
an EMOM (every minute on the minute) also allows a selction of exercises and a time limit which then allows the user to complete given exercises every minute
until the time limit is reached. This allows for huge customisation when creating workouts.


DISCOVER PAGE

InTheGym includes a discover page which allows users to discover new workouts and new users. The discover page features popular workouts and a WOD (Workout of the Day)
which is chosen by us. Users can browse the discover page and save workouts that they might want to complete and view the profiles of other users.


EXERCISE STATS

InTheGym records stats everytime a user completes an exercise. The amount of reps completed, the amount of sets completed, the total amount of weight lifted, 
the max weight lifted for every exercise, the average weight lifted for every exercise and the average RPE of each exercise.

CLIPS

Clips are short videos of exercises. InTheGym allows the user to record up to 30 second video clips of specific exercises. These short videos are then stored in 
the Firebase database. Clips are a very new feature and are still being improved on.


VERTICAL JUMP MEASURING

InTheGym includes a vertical jump measuring feature. This allows the user to record a video in slow motion and then choose the take off frame and the landing frame
from which the height of a jump can be measured. This feature is also a very new feature and is still being improved on.

