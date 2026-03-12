import 'package:hive/hive.dart';

/// App-wide settings stored in Hive.
class AppSettings extends HiveObject {
  bool isDarkMode;
  String activeProfileId;
  String activeGradeScaleId;
  bool isFirstLaunch;

  AppSettings({
    this.isDarkMode = false,
    this.activeProfileId = '',
    this.activeGradeScaleId = 'default',
    this.isFirstLaunch = true,
  });
}

/// Manual Hive TypeAdapter for AppSettings (typeId = 4)
class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    return AppSettings(
      isDarkMode: reader.readBool(),
      activeProfileId: reader.readString(),
      activeGradeScaleId: reader.readString(),
      isFirstLaunch: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer.writeBool(obj.isDarkMode);
    writer.writeString(obj.activeProfileId);
    writer.writeString(obj.activeGradeScaleId);
    writer.writeBool(obj.isFirstLaunch);
  }
}
