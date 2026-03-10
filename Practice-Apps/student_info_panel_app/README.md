# 🎓 Student Info Panel App (Flutter)

A modern **Student Information Management Panel** built with **Flutter** featuring Admin & Student roles, CRUD operations, analytics dashboard, and smooth UI animations.

This project demonstrates clean architecture, reusable widgets, and advanced UI/UX using Flutter.

---

# 📱 Features

### 🔐 Authentication

* Admin and Student login roles
* Form validation
* Demo login credentials

### 👨‍💼 Admin Panel

* Dashboard analytics
* Student management system
* Add / Edit / Delete student records
* Department statistics
* Recent students overview

### 👨‍🎓 Student Panel

* Personal profile view
* Detailed academic information
* Contact and guardian information

### 🔎 Student Management

* Search students by:

  * Name
  * Registration Number
  * Email
* Filter students by:

  * Department
  * Gender
* Sort students by:

  * Name
  * Registration Number
  * CGPA
  * Department

### ✨ UI & Animations

* Animated splash screen
* Staggered dashboard animations
* Hero animations between screens
* Custom page transitions
* Animated statistic cards
* Smooth navigation effects
* Modern dark theme design

---

# 🗂 Project Structure

```
lib/
│
├── main.dart
│
├── models/
│   └── student.dart
│
├── data/
│   └── dummy_data.dart
│
├── utils/
│   ├── app_theme.dart
│   └── page_transitions.dart
│
├── widgets/
│   ├── stat_card.dart
│   ├── student_card.dart
│   └── custom_text_field.dart
│
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── admin_dashboard.dart
    ├── student_dashboard.dart
    ├── add_student_screen.dart
    ├── student_detail_screen.dart
    └── all_students_screen.dart
```

---

# 🔑 Demo Login Credentials

### Admin

```
Email: admin@university.edu
Password: admin123
```

### Student

```
Email: ahmed.khan@university.edu
Password: student123
```

> Any student email from the dummy dataset works with password **student123**

---

# 🧾 Student Information Fields

The system stores complete student data including:

* Name
* Registration Number
* Date of Birth
* Gender
* Blood Group
* Email
* Phone Number
* Address
* Department
* Semester
* CGPA
* Guardian Name
* Guardian Contact

---

# ⚙️ How to Run the Project

### 1️⃣ Clone the repository

```bash
git clone https://github.com/yourusername/student-info-panel-flutter.git
```

### 2️⃣ Navigate to the project

```bash
cd student-info-panel-flutter
```

### 3️⃣ Install dependencies

```bash
flutter pub get
```

### 4️⃣ Run the application

```bash
flutter run
```

---

# 🧪 Code Quality

Project verified using:

```bash
flutter analyze
```

✔ 0 errors
✔ Clean architecture
✔ Reusable widgets

---

# 🛠 Technologies Used

* **Flutter**
* **Dart**
* Material UI
* Custom animations
* State management using local state

---

# 📸 Screenshots

You can add screenshots here later:

```
/screenshots
   splash.png
   login.png
   admin_dashboard.png
   student_dashboard.png
```

Example:

```markdown
![Dashboard](screenshots/admin_dashboard.png)
```

---

# 📚 Learning Objectives

This project demonstrates:

* Flutter project architecture
* Building reusable widgets
* Navigation and routing
* CRUD operations
* UI animations
* Dashboard design

---

# 👨‍💻 Author

**Umair Asghar**

Aspiring **Data Scientist & Flutter Developer**

---

⭐ If you like this project, consider giving it a star!
