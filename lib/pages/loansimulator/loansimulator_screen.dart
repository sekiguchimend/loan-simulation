import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class LoanSimulatorScreen extends HookConsumerWidget {
  const LoanSimulatorScreen({super.key});

  // 統一カラー
  static const Color _primaryColor = Color(0xFF660F15);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = useState('0');
    final previousValue = useState<double?>(null);
    final operation = useState<String?>(null);
    final isNewInput = useState(true);

    // モード管理: false=電卓, true=ローン
    final isLoanMode = useState(false);
    // ローンのステップ: 0: 借入額, 1: 金利, 2: 返済年数, 3: 結果表示
    final loanStep = useState(0);
    final loanAmount = useState<double?>(null);
    final interestRate = useState<double?>(null);
    final loanYears = useState<double?>(null);
    final monthlyPaymentResult = useState<double?>(null);

    // カンマ区切りのフォーマッター
    final numberFormatter = NumberFormat('#,###');
    final decimalFormatter = NumberFormat('#,###.##');

    // 数値をカンマ区切り文字列に変換
    String formatNumber(String value) {
      if (value.isEmpty || value == '0') return value;

      if (value.endsWith('.')) {
        final intPart = value.substring(0, value.length - 1);
        final numValue = double.tryParse(intPart);
        if (numValue != null) {
          return numberFormatter.format(numValue.toInt()) + '.';
        }
        return value;
      }

      final numValue = double.tryParse(value);
      if (numValue == null) return value;

      if (value.contains('.')) {
        return decimalFormatter.format(numValue);
      } else {
        return numberFormatter.format(numValue.toInt());
      }
    }

    String getFormattedDisplay() {
      return formatNumber(display.value);
    }

    void onNumberPressed(String number) {
      // 最大12桁まで制限
      const maxDigits = 12;
      final currentDigits = display.value.replaceAll('.', '').length;

      if (isNewInput.value) {
        display.value = number;
        isNewInput.value = false;
      } else {
        if (display.value == '0') {
          display.value = number;
        } else if (currentDigits < maxDigits) {
          display.value += number;
        }
      }
    }

    void calculate() {
      if (previousValue.value != null && operation.value != null) {
        final current = double.tryParse(display.value);
        if (current != null) {
          double result = 0;
          switch (operation.value!) {
            case '+':
              result = previousValue.value! + current;
              break;
            case '-':
              result = previousValue.value! - current;
              break;
            case '×':
              result = previousValue.value! * current;
              break;
            case '÷':
              result = current != 0 ? previousValue.value! / current : 0;
              break;
          }
          // 結果の桁数を制限
          String resultStr;
          if (result.abs() >= 1e12) {
            resultStr = result.toStringAsExponential(2);
          } else if (result == result.toInt()) {
            resultStr = result.toInt().toString();
          } else {
            resultStr = result.toStringAsFixed(2);
          }
          // 最大12桁に制限
          if (resultStr.length > 15) {
            resultStr = result.toStringAsExponential(2);
          }
          display.value = resultStr;
          previousValue.value = null;
          operation.value = null;
          isNewInput.value = true;
        }
      }
    }

    void onOperationPressed(String op) {
      final currentValue = double.tryParse(display.value);
      if (currentValue != null) {
        if (previousValue.value != null && operation.value != null && !isNewInput.value) {
          calculate();
        }
        previousValue.value = double.tryParse(display.value);
        operation.value = op;
        isNewInput.value = true;
      }
    }

    void calculateLoanPayment() {
      if (loanAmount.value != null && interestRate.value != null && loanYears.value != null) {
        final principal = loanAmount.value!;
        final monthlyRate = interestRate.value! / 100 / 12;
        final totalMonths = loanYears.value! * 12;

        if (principal <= 0 || totalMonths < 1) {
          return;
        }

        double monthlyPayment;
        if (monthlyRate == 0) {
          monthlyPayment = principal / totalMonths;
        } else {
          monthlyPayment = principal *
            (monthlyRate * pow(1 + monthlyRate, totalMonths)) /
            (pow(1 + monthlyRate, totalMonths) - 1);
        }

        if (monthlyPayment.isNaN || monthlyPayment.isInfinite) {
          return;
        }

        monthlyPaymentResult.value = monthlyPayment;
        display.value = monthlyPayment.toStringAsFixed(0);
        loanStep.value = 3;
      }
    }

    void onNextPressed() {
      if (!isLoanMode.value) return;

      if (loanStep.value == 3) {
        // 結果表示後、最初に戻る
        loanStep.value = 0;
        loanAmount.value = null;
        interestRate.value = null;
        loanYears.value = null;
        monthlyPaymentResult.value = null;
        display.value = '0';
        isNewInput.value = true;
        return;
      }

      final currentValue = double.tryParse(display.value);
      if (currentValue == null) return;

      switch (loanStep.value) {
        case 0:
          if (currentValue <= 0) return;
          loanAmount.value = currentValue;
          loanStep.value = 1;
          display.value = '0';
          isNewInput.value = true;
          break;
        case 1:
          if (currentValue < 0) return;
          interestRate.value = currentValue;
          loanStep.value = 2;
          display.value = '0';
          isNewInput.value = true;
          break;
        case 2:
          if (currentValue < 1) return;
          loanYears.value = currentValue;
          calculateLoanPayment();
          break;
      }
    }

    void clear() {
      display.value = '0';
      previousValue.value = null;
      operation.value = null;
      isNewInput.value = true;
      if (isLoanMode.value) {
        loanStep.value = 0;
        loanAmount.value = null;
        interestRate.value = null;
        loanYears.value = null;
        monthlyPaymentResult.value = null;
      }
    }

    void switchToCalculator() {
      isLoanMode.value = false;
      display.value = '0';
      previousValue.value = null;
      operation.value = null;
      isNewInput.value = true;
    }

    void switchToLoan() {
      isLoanMode.value = true;
      loanStep.value = 0;
      loanAmount.value = null;
      interestRate.value = null;
      loanYears.value = null;
      monthlyPaymentResult.value = null;
      display.value = '0';
      isNewInput.value = true;
    }

    String getDisplayLabel() {
      if (!isLoanMode.value) return '';
      switch (loanStep.value) {
        case 0: return '借入額を入力してください';
        case 1: return '金利(%)を入力してください';
        case 2: return '返済年数を入力してください';
        case 3: return '毎月の返済額';
        default: return '';
      }
    }

    String getNextButtonText() {
      if (loanStep.value == 3) return 'OK';
      return '次へ';
    }

    Widget getDisplayText() {
      List<Widget> children = [];

      children.add(
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              getFormattedDisplay(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                fontFamily: 'Roboto Mono',
                letterSpacing: -1,
              ),
            ),
          ),
        ),
      );

      if (!isLoanMode.value && operation.value != null && isNewInput.value) {
        children.add(const SizedBox(width: 8));

        String displayOperator = operation.value!;
        switch (operation.value!) {
          case '+':
            displayOperator = '＋';
            break;
          case '-':
            displayOperator = '－';
            break;
          case '×':
            displayOperator = '×';
            break;
          case '÷':
            displayOperator = '÷';
            break;
        }

        children.add(
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              displayOperator,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: children,
      );
    }

    Widget buildButton({
      required String text,
      required VoidCallback? onPressed,
      Color? backgroundColor,
      Color? textColor,
      IconData? icon,
      bool isOperator = false,
      bool isDisabled = false,
    }) {
      final effectiveOnPressed = isDisabled ? null : onPressed;
      final effectiveColor = isDisabled
          ? Colors.grey[400]
          : (isOperator ? _primaryColor : const Color(0xFF2C2C2C));
      final effectiveBorderColor = isDisabled
          ? Colors.grey[300]!
          : (isOperator ? _primaryColor : const Color(0xFFBBBBBB));

      return Expanded(
        child: Container(
          margin: const EdgeInsets.all(4),
          height: 90,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E5E5),
              foregroundColor: effectiveColor,
              shape: const CircleBorder(),
              elevation: 0,
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: effectiveBorderColor,
                width: isOperator && !isDisabled ? 1.5 : 0.5,
              ),
            ),
            child: Center(
              child: icon != null
                ? Icon(icon, size: 32)
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: (text == '次へ' || text == 'OK') ? 16 : 26,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
        children: [
          // タブヘッダー
          Container(
            margin: const EdgeInsets.fromLTRB(100, 12, 100, 0),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(25),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = (constraints.maxWidth) / 2;
                return Stack(
                  children: [
                    // スライドするインジケーター
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left: isLoanMode.value ? tabWidth : 0,
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    // タブテキスト
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: switchToCalculator,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.transparent,
                              child: Text(
                                '電卓',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isLoanMode.value ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: switchToLoan,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.transparent,
                              child: Text(
                                'ローン',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isLoanMode.value ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          // Display Area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isLoanMode.value) ...[
                    Text(
                      getDisplayLabel(),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                  ],
                  getDisplayText(),
                ],
              ),
            ),
          ),

          // Button Area
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  // Row 1: AC, +/-, %, ÷
                  Expanded(
                    child: Row(
                      children: [
                        buildButton(
                          text: 'AC',
                          onPressed: clear,
                          backgroundColor: const Color(0xFFC0C0C0),
                          textColor: const Color(0xFF2C2C2C),
                        ),
                        buildButton(
                          text: '+/-',
                          onPressed: () {
                            if (display.value != '0') {
                              final value = double.tryParse(display.value);
                              if (value != null) {
                                display.value = (-value).toString();
                              }
                            }
                          },
                          backgroundColor: const Color(0xFFC0C0C0),
                          textColor: const Color(0xFF2C2C2C),
                          isDisabled: isLoanMode.value,
                        ),
                        buildButton(
                          text: '%',
                          onPressed: () {
                            final value = double.tryParse(display.value);
                            if (value != null) {
                              display.value = (value / 100).toString();
                            }
                          },
                          backgroundColor: const Color(0xFFC0C0C0),
                          textColor: const Color(0xFF2C2C2C),
                          isDisabled: isLoanMode.value,
                        ),
                        buildButton(
                          text: '÷',
                          onPressed: () => onOperationPressed('÷'),
                          isOperator: true,
                          isDisabled: isLoanMode.value,
                        ),
                      ],
                    ),
                  ),

                  // Row 2: 7, 8, 9, ×
                  Expanded(
                    child: Row(
                      children: [
                        buildButton(text: '7', onPressed: () => onNumberPressed('7')),
                        buildButton(text: '8', onPressed: () => onNumberPressed('8')),
                        buildButton(text: '9', onPressed: () => onNumberPressed('9')),
                        buildButton(
                          text: '×',
                          onPressed: () => onOperationPressed('×'),
                          isOperator: true,
                          isDisabled: isLoanMode.value,
                        ),
                      ],
                    ),
                  ),

                  // Row 3: 4, 5, 6, -
                  Expanded(
                    child: Row(
                      children: [
                        buildButton(text: '4', onPressed: () => onNumberPressed('4')),
                        buildButton(text: '5', onPressed: () => onNumberPressed('5')),
                        buildButton(text: '6', onPressed: () => onNumberPressed('6')),
                        buildButton(
                          text: '－',
                          onPressed: () => onOperationPressed('-'),
                          isOperator: true,
                          isDisabled: isLoanMode.value,
                        ),
                      ],
                    ),
                  ),

                  // Row 4: 1, 2, 3, +
                  Expanded(
                    child: Row(
                      children: [
                        buildButton(text: '1', onPressed: () => onNumberPressed('1')),
                        buildButton(text: '2', onPressed: () => onNumberPressed('2')),
                        buildButton(text: '3', onPressed: () => onNumberPressed('3')),
                        buildButton(
                          text: '＋',
                          onPressed: () => onOperationPressed('+'),
                          isOperator: true,
                          isDisabled: isLoanMode.value,
                        ),
                      ],
                    ),
                  ),

                  // Row 5: 0, ., 次へ/=, =
                  Expanded(
                    child: Row(
                      children: [
                        buildButton(
                          text: '0',
                          onPressed: () => onNumberPressed('0'),
                        ),
                        buildButton(
                          text: '.',
                          onPressed: () {
                            if (!display.value.contains('.')) {
                              display.value += '.';
                              isNewInput.value = false;
                            }
                          },
                        ),
                        // ローンモード時は「次へ」、電卓モード時は非活性
                        buildButton(
                          text: isLoanMode.value ? getNextButtonText() : '次へ',
                          onPressed: onNextPressed,
                          isOperator: true,
                          isDisabled: !isLoanMode.value,
                        ),
                        buildButton(
                          text: '＝',
                          onPressed: calculate,
                          isOperator: true,
                          isDisabled: isLoanMode.value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
      ),
    );
  }
}
