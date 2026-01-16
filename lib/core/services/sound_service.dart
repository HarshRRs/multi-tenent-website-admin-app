import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:rockster/core/utils/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundSource {
  system,
  custom,
  off,
}

class SoundService {
  static const String _prefKeySource = 'notification_sound_source';
  static const String _prefKeyPath = 'notification_sound_path';
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLooping = false;
  
  Future<void> playOrderSound({bool loop = false}) async {
    _isLooping = loop;
    final prefs = await SharedPreferences.getInstance();
    final sourceIndex = prefs.getInt(_prefKeySource) ?? SoundSource.system.index;
    final source = SoundSource.values[sourceIndex];
    
    switch (source) {
      case SoundSource.system:
        if (loop) {
          FlutterRingtonePlayer().play(
            android: AndroidSounds.ringtone,
            ios: IosSounds.glass,
            looping: true,
            volume: 1.0,
          );
        } else {
          FlutterRingtonePlayer().playNotification();
        }
        break;
      case SoundSource.custom:
        final path = prefs.getString(_prefKeyPath);
        if (path != null && File(path).existsSync()) {
          await _audioPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
          await _audioPlayer.play(DeviceFileSource(path));
        } else {
          if (loop) {
            FlutterRingtonePlayer().play(
              android: AndroidSounds.ringtone,
              ios: IosSounds.glass,
              looping: true,
            );
          } else {
            FlutterRingtonePlayer().playNotification();
          }
        }
        break;
      case SoundSource.off:
        break;
    }
  }

  Future<void> stopOrderSound() async {
    _isLooping = false;
    await _audioPlayer.stop();
    FlutterRingtonePlayer().stop();
  }

  Future<SoundSource> getSoundSource() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_prefKeySource) ?? SoundSource.system.index;
    return SoundSource.values[index];
  }
  
  Future<String?> getCustomSoundPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeyPath);
  }

  Future<void> setSoundSource(SoundSource source) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeySource, source.index);
  }

  Future<void> pickCustomSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyPath, result.files.single.path!);
      await prefs.setInt(_prefKeySource, SoundSource.custom.index);
    }
  }

  Future<void> testSound() async {
    await playOrderSound();
  }
}
