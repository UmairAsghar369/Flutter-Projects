import 'package:flutter/material.dart';
import '../models/cv_model.dart';

/// State management via ChangeNotifier — holds all CV form data
/// and which view (Professional / Hobby) is currently active.
class CvProvider extends ChangeNotifier {
  CvModel _cv = CvModel();

  /// true = Professional view, false = Hobby view.
  bool isProfessional = true;

  CvModel get cv => _cv;

  /// Convenience accessor — reads the nearest CvProvider from the widget tree.
  static CvProvider of(BuildContext context) {
    return context
        .findAncestorStateOfType<_CvProviderScopeState>()!
        .provider;
  }

  // ─── View toggle ───
  void toggleView(bool professional) {
    isProfessional = professional;
    notifyListeners();
  }

  // ─── Basic info ───
  void updateName(String v) {
    _cv.name = v;
    notifyListeners();
  }

  void updateEmail(String v) {
    _cv.email = v;
    notifyListeners();
  }

  void updatePhone(String v) {
    _cv.phone = v;
    notifyListeners();
  }

  // ─── Education ───
  void addEducation() {
    _cv.education.add(EducationEntry());
    notifyListeners();
  }

  void removeEducation(int i) {
    if (_cv.education.length > 1) {
      _cv.education.removeAt(i);
      notifyListeners();
    }
  }

  void updateEducation(int i,
      {String? degree, String? institution, String? year}) {
    if (degree != null) _cv.education[i].degree = degree;
    if (institution != null) _cv.education[i].institution = institution;
    if (year != null) _cv.education[i].year = year;
    notifyListeners();
  }

  // ─── Skills ───
  void addSkill() {
    _cv.skills.add('');
    notifyListeners();
  }

  void removeSkill(int i) {
    if (_cv.skills.length > 1) {
      _cv.skills.removeAt(i);
      notifyListeners();
    }
  }

  void updateSkill(int i, String v) {
    _cv.skills[i] = v;
    notifyListeners();
  }

  // ─── Experience ───
  void addExperience() {
    _cv.experience.add(ExperienceEntry());
    notifyListeners();
  }

  void removeExperience(int i) {
    if (_cv.experience.length > 1) {
      _cv.experience.removeAt(i);
      notifyListeners();
    }
  }

  void updateExperience(int i,
      {String? role,
      String? company,
      String? duration,
      String? description}) {
    if (role != null) _cv.experience[i].role = role;
    if (company != null) _cv.experience[i].company = company;
    if (duration != null) _cv.experience[i].duration = duration;
    if (description != null) _cv.experience[i].description = description;
    notifyListeners();
  }

  // ─── Hobbies ───
  void addHobby() {
    _cv.hobbies.add(HobbyEntry());
    notifyListeners();
  }

  void removeHobby(int i) {
    if (_cv.hobbies.length > 1) {
      _cv.hobbies.removeAt(i);
      notifyListeners();
    }
  }

  void updateHobby(int i, {String? name, String? description}) {
    if (name != null) _cv.hobbies[i].name = name;
    if (description != null) _cv.hobbies[i].description = description;
    notifyListeners();
  }

  // ─── Interests ───
  void addInterest() {
    _cv.interests.add('');
    notifyListeners();
  }

  void removeInterest(int i) {
    if (_cv.interests.length > 1) {
      _cv.interests.removeAt(i);
      notifyListeners();
    }
  }

  void updateInterest(int i, String v) {
    _cv.interests[i] = v;
    notifyListeners();
  }

  // ─── Personal Skills ───
  void addPersonalSkill() {
    _cv.personalSkills.add('');
    notifyListeners();
  }

  void removePersonalSkill(int i) {
    if (_cv.personalSkills.length > 1) {
      _cv.personalSkills.removeAt(i);
      notifyListeners();
    }
  }

  void updatePersonalSkill(int i, String v) {
    _cv.personalSkills[i] = v;
    notifyListeners();
  }

  /// Reset all data to empty.
  void reset() {
    _cv = CvModel();
    isProfessional = true;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CvProviderScope — InheritedWidget-style wrapper that exposes CvProvider
// down the tree via CvProvider.of(context).
// ─────────────────────────────────────────────────────────────────────────────

class CvProviderScope extends StatefulWidget {
  final Widget child;
  const CvProviderScope({super.key, required this.child});

  @override
  State<CvProviderScope> createState() => _CvProviderScopeState();
}

class _CvProviderScopeState extends State<CvProviderScope> {
  final CvProvider provider = CvProvider();

  @override
  void dispose() {
    provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
