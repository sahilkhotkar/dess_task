Getting Started

This is a Flutter project that uses the NASA API to display information about space objects.
1. Architecture Used The app is built using the Model-View architecture:
* Model: Manages the app’s data and logic.
* View: Displays the user interface and handles user interactions.
2. Tools and Features
* Hive: Used to store favourite photos locally for quick access.
* Provider: Used to manage the app's state, especially to track the count of favourite photos.
* SharedPreferences: Used to save responses offline so the app can show data without an internet connection.
3. Challenges and Solutions
* Challenge: Storing favourite photos was tricky because APOD and Mars images had different data formats and keys. Solution: I handled this by writing conditions to manage the differences between the two types of data.
  
Prerequisites

Flutter SDK: Download the Flutter SDK
A code editor or IDE with Flutter support (e.g., Visual Studio Code)
Installation

Clone the repository:
<!-- end list -->

git clone https://github.com/sahilkhotkar/dess_task.git
<!-- end list -->
Navigate to the project directory:
<!-- end list -->
cd dess_task
<!-- end list -->
Install the dependencies:
<!-- end list -->

flutter pub get
<!-- end list -->
Create a file named .env in the root of your project. This file will store your NASA API key.

Add the following line to your .env file, replacing <YOUR_NASA_API_KEY> with your actual NASA API key:

<!-- end list -->


  "NASA_API_KEY": "<YOUR_NASA_API_KEY>"

You can obtain a free NASA API key from NASA Open API.
Running the app
<!-- end list -->
flutter run
Connect your device or start an emulator.

Run the following command to start the development server:

<!-- end list -->





I hope this helps!
