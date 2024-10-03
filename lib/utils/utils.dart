import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../model/enum.dart';

Color parseColor(String colorString) {
  final colorValue = int.parse(colorString.split('(0x')[1].split(')')[0], radix: 16);
  return Color(colorValue);
}

IconData parseIcon(String iconString) {
  try {
    // Trích xuất giá trị mã Unicode từ chuỗi và chuyển đổi thành IconData
    final iconValue = int.parse(
      iconString.split('U+').last.split(')').first,
      radix: 16,
    );
    return IconData(iconValue, fontFamily: 'FontAwesomeSolid', fontPackage: 'font_awesome_flutter',);
  } catch (e) {
    print('Error parsing icon data: $e');
    return Icons.error;
  }
}

String formatAmount(double amount) {
  final formatter = NumberFormat('#,###', 'vi_VN');

  if (amount < 0) {
    return '- ${formatter.format(amount.abs())}';
  } else if (amount >= 1000000000) {
    return '${formatter.format((amount / 1))}';
  } else if (amount >= 1000000) {
    return '${formatter.format((amount / 1))}';
  } else if (amount >= 1000) {
    return '${formatter.format(amount.round())}';
  } else {
    return amount.toStringAsFixed(0);
  }
}

String formatAmount_2(double amount) {
  final formatter = NumberFormat('#,###.##', 'vi_VN');

  if (amount >= 1000000000) {
    return '${formatter.format((amount / 1000000000))} T';
  } else if (amount >= 1000000) {
    return '${formatter.format((amount / 1000000))} Tr';
  } else if (amount >= 1000) {
    return '${formatter.format(amount.round())}';
  } else {
    return amount.toStringAsFixed(0);
  }
}

void formatAmount_3(TextEditingController amountController) {
  final text = amountController.text;
  if (text.isEmpty) return;
  final cleanedText = text.replaceAll(RegExp(r'[^0-9]'), '');
  final number = int.parse(cleanedText);
  final formatted = NumberFormat('#,###', 'vi_VN').format(number);

  amountController.value = TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(offset: formatted.length),
  );
}

String chartTotalAmountFormat(double totalAmount) {
  final formatter = NumberFormat('#,###', 'vi_VN');

  if (totalAmount >= 1000000000) {
    return '${formatter.format((totalAmount / 1))} ₫';
  } else if (totalAmount >= 1000000) {
    return '${formatter.format((totalAmount / 1))} ₫';
  } else if (totalAmount >= 1000) {
    return '${formatter.format(totalAmount.round())} ₫';
  } else {
    return '${totalAmount.toStringAsFixed(0)} ₫';
  }
}

DateTime parseDateKey(String dateKey, String selectedTimeframe) {
  switch (selectedTimeframe) {
    case 'day':
      final parts = dateKey.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } else {
        throw FormatException('Invalid date format in dateKey: $dateKey');
      }
    case 'custom':
      final customPattern = RegExp(r'(\d{1,2}/\d{1,2}/\d{4}) - (\d{1,2}/\d{1,2}/\d{4})');
      final customMatch = customPattern.firstMatch(dateKey);
      if (customMatch != null) {
        final startDateParts = customMatch.group(1)!.split('/');
        return DateTime(int.parse(startDateParts[2]), int.parse(startDateParts[1]), int.parse(startDateParts[0]));
      } else {
        throw FormatException('Invalid custom format in dateKey: $dateKey');
      }
    case 'week':
      final weekPattern = RegExp(r'(\d{1,2}/\d{1,2}/\d{4}) - (\d{1,2}/\d{1,2}/\d{4})');
      final match = weekPattern.firstMatch(dateKey);
      if (match != null) {
        final startDateParts = match.group(1)!.split('/');
        return DateTime(int.parse(startDateParts[2]), int.parse(startDateParts[1]), int.parse(startDateParts[0]));
      } else {
        throw FormatException('Invalid week format in dateKey: $dateKey');
      }
    case 'month':
      final parts = dateKey.split('/');
      if (parts.length == 2) {
        final month = int.parse(parts[0]);
        final year = int.parse(parts[1]);
        return DateTime(year, month);
      } else {
        throw FormatException('Invalid month format in dateKey: $dateKey');
      }

    case 'year':
      final yearPattern = RegExp(r'(\d{4})');
      final match = yearPattern.firstMatch(dateKey);
      if (match != null) {
        final year = int.parse(match.group(1)!);
        return DateTime(year);
      } else {
        throw FormatException('Invalid year format in dateKey: $dateKey');
      }
    default:
      throw FormatException('Unknown timeframe: $selectedTimeframe');
  }
}

String formatDate_2(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatDate(DateTime date) {
  final daysOfWeek = [
    tr('sunday'),
    tr('monday'),
    tr('tuesday'),
    tr('wednesday'),
    tr('thursday'),
    tr('friday'),
    tr('saturday')
  ];
  final dayOfWeek = daysOfWeek[date.weekday % 7]; // % 7 để điều chỉnh Chủ Nhật về index 0
  return "$dayOfWeek - ${date.day}/${date.month}/${date.year}";
}

String formatHour(TimeOfDay time) {
  return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
}

String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return tr('morning');
  } else if (hour < 19) {
    return tr('afternoon');
  } else {
    return tr('evening');
  }
}

String getRepeatString(Repeat repeatBudget) {
  switch (repeatBudget) {
    case Repeat.Daily:
      return tr('repeat_daily');
    case Repeat.Weekly:
      return tr('repeat_weekly');
    case Repeat.Monthly:
      return tr('repeat_monthly');
    case Repeat.Quarterly:
      return tr('repeat_quarterly');
    case Repeat.Yearly:
      return tr('repeat_yearly');
    default:
      return '';
  }
}

bool isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
