# 💬 Chat Circle - Real-Time Chat App with Firebase

A minimal, elegant real-time chat application built using Flutter and Firebase. Users can register, log in, and chat with others instantly with Firestore-based messaging and seamless authentication.

## ✨ Features
- 🔐 Firebase Authentication (Email & Password)
- 🧑‍🤝‍🧑 Realtime user list (excluding current user)
- 💬 1-to-1 real-time messaging using Firestore
- 📲 Responsive design for mobile
- 🌐 Server-side filtering for user lists
- 🗂 Clean code structure with modular pages
  
## 📂 Project Structure
- ```bash
   lib/
    ├── auth/
    │ ├── login_page.dart       # Login UI & auth logic
    │ ├── register_page.dart    # Register new users
    │ └── main_page.dart        # Redirects to Home or Auth
    ├── screens/
    │ ├── home_page.dart        # Lists all other users to chat
    │ ├── chat_page.dart        # Chat screen between users
    │ └── users.dart            # User model / widget
    ├── main.dart               # Entry point of the app
    └── firebase_options.dart   # Firebase configuration


## 🧪 Firebase Setup

1. Create a project on [Firebase Console](https://console.firebase.google.com/)
2. Enable **Email/Password** authentication
3. Enable **Cloud Firestore** and set rules:
   ```js
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /notes/{document} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.uid;
       }
       match /users/{uid} {
         allow read, write: if request.auth != null && request.auth.uid == uid;
       }
     }
   }

4. Download google-services.json and configure it in your Flutter app using flutterfire configure.
   
## 🛠️ Tech Stack
- Flutter (Frontend UI)
- Firebase Auth (Authentication)
- Cloud Firestore (Real-time database)
- Provider or basic setState for state management
- Material Design 3 for modern UI
## 📸 Screenshots

![All Screens](assets/screens/dashboard.jpg) 

## ✨ How to Run
1. **Clone this repo**
   ```bash
   git clone https://github.com/sahilubale2510/Chat-Circle.git
   cd Chat-Circle
   
2. **Get packages**
   ```bash
   flutter pub get
   
3. **Run the app**
   ```bash
   flutter run

## 📌 Future Improvements
- Push notifications (Firebase Cloud Messaging)
- Group chat support
- User profile customization (avatar, status)
- Media (image/audio) support

## 👨‍💻 Author
**Sahil Ubale**
 A passionate Flutter developer with a love for clean UI and smooth UX.

 ## 📬 Contact

If you like this project or want to collaborate:
- 📧 Email: sahilubale2510@gmail.com
- 💼 LinkdIn: [LinkedIn](https://www.linkedin.com/in/sahilubale2510)
- 🧑‍💻 GitHub: [GitHub](https://www.github.com/sahilubale2510)

   
## 📄 License
This project is licensed under the MIT License.
Feel free to use and modify it for personal or commercial use.
