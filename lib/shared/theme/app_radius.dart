import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double smValue = 8;
  static const double mdValue = 12;
  static const double lgValue = 16;
  static const double xlValue = 24;

  static const BorderRadius sm = BorderRadius.all(Radius.circular(smValue));

  static const BorderRadius md = BorderRadius.all(Radius.circular(mdValue));

  static const BorderRadius lg = BorderRadius.all(Radius.circular(lgValue));

  static const BorderRadius xl = BorderRadius.all(Radius.circular(xlValue));
}
