import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart'
    as legacy_picker;

export 'package:flutter_datetime_picker/flutter_datetime_picker.dart'
    show BasePickerModel, LocaleType;

/// Crea el mismo tema original de flutter_datetime_picker sin entrar en
/// conflicto con DatePickerTheme de Flutter Material.
legacy_picker.DatePickerTheme LegacyDatePickerTheme() =>
    legacy_picker.DatePickerTheme();

typedef DateChangedCallback = void Function(DateTime time);
typedef DateCancelledCallback = void Function();

class OverrideDatePicker {
  static Future<DateTime?> showDatePicker(
    BuildContext context, {
    bool showTitleActions = true,
    DateTime? minTime,
    DateTime? maxTime,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    dynamic locale = legacy_picker.LocaleType.en,
    DateTime? currentTime,
    legacy_picker.DatePickerTheme? theme,
  }) {
    return legacy_picker.DatePicker.showDatePicker(
      context,
      showTitleActions: showTitleActions,
      minTime: minTime,
      maxTime: maxTime,
      onChanged: onChanged,
      onConfirm: onConfirm,
      onCancel: onCancel,
      locale: locale as legacy_picker.LocaleType,
      currentTime: currentTime,
      theme: theme,
    );
  }

  static Future<DateTime?> showTimePicker(
    BuildContext context, {
    bool showTitleActions = true,
    bool showSecondsColumn = true,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    dynamic locale = legacy_picker.LocaleType.en,
    DateTime? currentTime,
    legacy_picker.DatePickerTheme? theme,
  }) {
    return legacy_picker.DatePicker.showTimePicker(
      context,
      showTitleActions: showTitleActions,
      showSecondsColumn: showSecondsColumn,
      onChanged: onChanged,
      onConfirm: onConfirm,
      onCancel: onCancel,
      locale: locale as legacy_picker.LocaleType,
      currentTime: currentTime,
      theme: theme,
    );
  }

  static Future<DateTime?> showTime12hPicker(
    BuildContext context, {
    bool showTitleActions = true,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    dynamic locale = legacy_picker.LocaleType.en,
    DateTime? currentTime,
    legacy_picker.DatePickerTheme? theme,
  }) {
    return legacy_picker.DatePicker.showTime12hPicker(
      context,
      showTitleActions: showTitleActions,
      onChanged: onChanged,
      onConfirm: onConfirm,
      onCancel: onCancel,
      locale: locale as legacy_picker.LocaleType,
      currentTime: currentTime,
      theme: theme,
    );
  }

  static Future<DateTime?> showDateTimePicker(
    BuildContext context, {
    bool showTitleActions = true,
    DateTime? minTime,
    DateTime? maxTime,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    dynamic locale = legacy_picker.LocaleType.en,
    DateTime? currentTime,
    legacy_picker.DatePickerTheme? theme,
  }) {
    return legacy_picker.DatePicker.showDateTimePicker(
      context,
      showTitleActions: showTitleActions,
      minTime: minTime,
      maxTime: maxTime,
      onChanged: onChanged,
      onConfirm: onConfirm,
      onCancel: onCancel,
      locale: locale as legacy_picker.LocaleType,
      currentTime: currentTime,
      theme: theme,
    );
  }

  static Future<DateTime?> showPicker(
    BuildContext context, {
    bool showTitleActions = true,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    dynamic locale = legacy_picker.LocaleType.en,
    legacy_picker.BasePickerModel? pickerModel,
    legacy_picker.DatePickerTheme? theme,
  }) {
    return legacy_picker.DatePicker.showPicker(
      context,
      showTitleActions: showTitleActions,
      onChanged: onChanged,
      onConfirm: onConfirm,
      onCancel: onCancel,
      locale: locale as legacy_picker.LocaleType,
      pickerModel: pickerModel,
      theme: theme,
    );
  }
}
