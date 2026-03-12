# 🎓 CGPA Calculator App (Flutter)

A **modern CGPA Calculator** built with **Flutter** that allows students to manage semesters, calculate GPA/CGPA, visualize academic progress with charts, and export results as PDF or images.

The app supports **multiple student profiles**, **custom grade scales**, and **dark/light themes** while storing all data locally using Hive.

---

## ✨ Features

* 📊 **Semester-wise GPA calculation**
* 🎯 **Automatic CGPA calculation**
* 👤 **Multiple student profiles**
* 📈 **GPA progress charts**
* 🌙 **Dark & Light Theme**
* ⚙ **Custom grade scale**
* 📄 **Export results as PDF**
* 🖼 **Export results as image**
* 📱 **Clean and modern UI**

---

## 🛠 Technologies Used

* **Flutter**
* **Dart**
* **Provider** (State Management)
* **Hive** (Local Database)
* **fl_chart** (Charts)
* **PDF & Printing** (Export reports)

---

## 📦 Main Packages

| Package             | Purpose           |
| ------------------- | ----------------- |
| provider            | State management  |
| hive & hive_flutter | Local database    |
| fl_chart            | GPA charts        |
| pdf & printing      | Export PDF        |
| screenshot          | Capture widgets   |
| share_plus          | Share files       |
| path_provider       | File storage      |
| google_fonts        | Modern typography |

---

## 📂 Project Structure

```
lib/
├── main.dart
├── app.dart                        # MaterialApp with theme + routes
├── models/
│   ├── grade.dart                  # Grade enum/class
│   ├── subject.dart                # Subject model (Hive)
│   ├── semester.dart               # Semester model (Hive)
│   ├── student_profile.dart        # Profile model (Hive)
│   ├── grade_scale.dart            # Custom grade scale model
│   └── app_settings.dart           # Settings model (Hive)
├── services/
│   └── database_service.dart       # Hive init + CRUD helpers
├── providers/
│   ├── theme_provider.dart         # Dark/Light mode
│   ├── profile_provider.dart       # Multi-profile management
│   ├── semester_provider.dart      # Semesters + GPA/CGPA calc
│   ├── grade_scale_provider.dart   # Custom grade scales
│   └── settings_provider.dart      # App settings
├── screens/
│   ├── splash_screen.dart          # Animated splash
│   ├── onboarding_screen.dart      # First-launch walkthrough
│   ├── home_screen.dart            # Dashboard with CGPA card + chart
│   ├── semester_detail_screen.dart # Subjects list for a semester
│   ├── profile_screen.dart         # Switch/add/edit profiles
│   ├── settings_screen.dart        # Theme, grade scale, export
│   ├── grade_scale_screen.dart     # Edit custom grade mappings
│   └── chart_screen.dart           # Full-screen GPA chart
├── widgets/
│   ├── cgpa_summary_card.dart      # Animated CGPA display
│   ├── semester_card.dart          # Card for each semester
│   ├── subject_tile.dart           # Row for each subject
│   ├── add_subject_sheet.dart      # Bottom sheet to add/edit subject
│   ├── add_semester_dialog.dart    # Dialog to create semester
│   ├── gpa_chart.dart  
# fl_chart line chart widget
│   ├── gradient_button.dart        # Reusable styled button
│   ├── animated_list_item.dart     # FadeIn + SlideIn wrapper
│   └── empty_state.dart            # "No data" placeholder
└── theme/
    ├── app_theme.dart              # Light + Dark ThemeData
    └── app_colors.dart             # Color constants
```

---

## ⚙️ How to Run the Project

### 1️⃣ Clone the repository

```bash
git clone https://github.com/yourusername/cgpa-calculator-flutter.git
```

### 2️⃣ Open the project

```
cd cgpa-calculator-flutter
```

### 3️⃣ Install dependencies

```
flutter pub get
```

### 4️⃣ Run the app

```
flutter run
```

---

## 📱 App Workflow

1️⃣ Create a **student profile**
2️⃣ Add **semester**
3️⃣ Add **subjects with credit hours and grades**
4️⃣ App automatically calculates **GPA and CGPA**
5️⃣ View **progress charts**
6️⃣ Export results as **PDF or image**

---

## 🎯 Learning Objectives

This project demonstrates:

* Flutter project architecture
* State management using Provider
* Local storage using Hive
* Data modeling
* GPA/CGPA calculation logic
* Charts and data visualization
* Exporting reports

---

## 👨‍💻 Author

**Umair**

Aspiring **Data Scientist & Flutter Developer**

---

⭐ If you like this project, consider giving it a star on GitHub.
