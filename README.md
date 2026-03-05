Here’s a **professional, international‑standard README.md** for your UniRoom Live project. It’s structured for engineers, contributors, and users, with clear sections, badges, and the direct APK download link you provided.

---

# UniRoom Live 📚🏫

[`https://flutter.dev`](https://flutter.dev)  
[`https://firebase.google.com`](https://firebase.google.com)  
[`#license`](#license)

**UniRoom Live** is a production‑grade SaaS mobile application for **university classroom management**. Built with **Flutter** and **Firebase**, it enables students and Class Representatives (CRs) to track room availability, manage schedules, and streamline communication in real time.

---

## 🚀 Features

- 🔑 **Authentication & Role Management**  
  - Students and CRs have distinct dashboards.  
  - CRs require approval before accessing management features.  

- 🏫 **Multi‑Tenant University Support**  
  - Each university has its own departments and rooms.  
  - Students see only their department’s rooms.  
  - CRs see all rooms in their university.  

- 📡 **Real‑Time Room Tracking**  
  - Live status updates: *Available* vs *Running Class*.  
  - CRs can add, edit, update, and delete rooms.  
  - Students view simplified room info when available.  

- 🎨 **Modern UI/UX**  
  - Dark theme with gradient headers.  
  - Animated splash screen.  
  - Responsive dashboards for both roles.  

---

## 📱 Download

👉 [**Download UniRoom Live APK**](https://github.com/TanvirLogic/UniRoom-Live/releases/download/Engineering/uniroom_live.apk)

---

## 🛠️ Tech Stack

| Layer              | Technology |
|--------------------|------------|
| Frontend           | Flutter (Dart) |
| Backend            | Firebase Firestore |
| Authentication     | Firebase Auth |
| State Management   | Provider |
| Architecture       | Clean Architecture, Modular Structure |

---

## 📂 Project Structure

```
lib/
 ├── app/                  # Routing & core setup
 ├── features/
 │    ├── auth/            # Login, signup, auth provider
 │    ├── home/            # Dashboards (Student & CR)
 │    ├── rooms/           # Room entity, provider, CRUD
 │    └── university/      # University & department provider
 └── main.dart             # Entry point
```

---

## ⚙️ Setup & Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/TanvirLogic/UniRoom-Live.git
   cd UniRoom-Live
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).  
   - Enable **Authentication** and **Firestore** in Firebase Console.  

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 👥 Roles & Dashboards

- **Student Dashboard**  
  - View rooms in their department.  
  - See only room number + availability when free.  
  - Full details when a class is running.  

- **CR Dashboard**  
  - Manage all rooms in the university.  
  - Add, edit, delete, and update room status.  
  - Track metadata (`updatedBy`, `updatedAt`).  

---

## 🧪 Testing

- Hot reload supported.  
- Unit tests for providers and models.  
- Integration tests for authentication and Firestore queries.  

---

## 📄 License

This project is licensed under the **MIT License**.  
You are free to use, modify, and distribute with attribution.

---

## 🌍 Contributors

- **Md. Tanvir** – Lead Developer & Architect  
- Open for contributions! Fork the repo, create a branch, and submit a PR.

---

👉 With this README, anyone can **download the APK**, understand the architecture, and contribute professionally.  

Would you like me to also add **screenshots and GIFs** of the dashboards (Student & CR) into the README so it looks more polished for GitHub?
