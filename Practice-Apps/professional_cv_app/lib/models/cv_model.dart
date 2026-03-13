// CV data model — all fields the user fills in.

/// A single education entry.
class EducationEntry {
  String degree;
  String institution;
  String year;

  EducationEntry({this.degree = '', this.institution = '', this.year = ''});
}

/// A single work experience entry.
class ExperienceEntry {
  String role;
  String company;
  String duration;
  String description;

  ExperienceEntry({
    this.role = '',
    this.company = '',
    this.duration = '',
    this.description = '',
  });
}

/// A single hobby entry.
class HobbyEntry {
  String name;
  String description;

  HobbyEntry({this.name = '', this.description = ''});
}

/// The complete CV data model.
class CvModel {
  // ─── Shared ───
  String name;
  String email;
  String phone;

  // ─── Professional ───
  List<EducationEntry> education;
  List<String> skills;
  List<ExperienceEntry> experience;

  // ─── Hobby ───
  List<HobbyEntry> hobbies;
  List<String> interests;
  List<String> personalSkills;

  CvModel({
    this.name = '',
    this.email = '',
    this.phone = '',
    List<EducationEntry>? education,
    List<String>? skills,
    List<ExperienceEntry>? experience,
    List<HobbyEntry>? hobbies,
    List<String>? interests,
    List<String>? personalSkills,
  })  : education = education ?? [EducationEntry()],
        skills = skills ?? [''],
        experience = experience ?? [ExperienceEntry()],
        hobbies = hobbies ?? [HobbyEntry()],
        interests = interests ?? [''],
        personalSkills = personalSkills ?? [''];
}
