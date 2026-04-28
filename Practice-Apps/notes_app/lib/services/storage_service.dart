import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

/// Service for persisting notes using Hive
class StorageService {
  static const String _boxName = 'notes_box';
  static const String _notesKey = 'notes_list';

  late Box _box;

  /// Initialize Hive and open the box
  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Get all saved notes
  List<Note> getNotes() {
    final jsonString = _box.get(_notesKey, defaultValue: '[]') as String;
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Save the entire notes list
  Future<void> saveNotes(List<Note> notes) async {
    final jsonList = notes.map((n) => n.toJson()).toList();
    await _box.put(_notesKey, jsonEncode(jsonList));
  }

  /// Add a single note
  Future<void> addNote(Note note) async {
    final notes = getNotes();
    notes.add(note);
    await saveNotes(notes);
  }

  /// Update a note by ID
  Future<void> updateNote(Note updatedNote) async {
    final notes = getNotes();
    final index = notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      notes[index] = updatedNote;
      await saveNotes(notes);
    }
  }

  /// Delete a note by ID
  Future<void> deleteNote(String id) async {
    final notes = getNotes();
    notes.removeWhere((n) => n.id == id);
    await saveNotes(notes);
  }
}
