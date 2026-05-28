import 'dart:io';
import 'package:flutter/material.dart';

class ProfileState {
  // Canlı resim ve isim dinleyicileri (Türkçe karakter içermez)
  static final ValueNotifier<File?> resimNotifier = ValueNotifier<File?>(null);
  static final ValueNotifier<String> isimNotifier = ValueNotifier<String>(
    "Arda",
  );
}
