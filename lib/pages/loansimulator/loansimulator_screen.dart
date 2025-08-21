import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math';

class LoanSimulatorScreen extends HookConsumerWidget {
  const LoanSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = useState('0');
    final previousValue = useState<double?>(null);
    final operation = useState<String?>(null);
    final isNewInput = useState(true);
    final loanStep = useState(0); // 0: 借入額, 1: 金利, 2: 返済月数
    final loanAmount = useState<double?>(null);
    final interestRate = useState<double?>(null);
    final loanMonths = useState<double?>(null);

    void onNumberPressed(String number) {
      if (isNewInput.value) {
        display.value = number;
        isNewInput.value = false;
      } else {
        if (display.value == '0') {
          display.value = number;
        } else {
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
          display.value = result == result.toInt() ? result.toInt().toString() : result.toStringAsFixed(2);
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
      if (loanAmount.value != null && interestRate.value != null && loanMonths.value != null) {
        final principal = loanAmount.value!;
        final monthlyRate = interestRate.value! / 100 / 12;
        final totalMonths = loanMonths.value!;
        
        if (monthlyRate == 0) {
          // 金利0%の場合
          final monthlyPayment = principal / totalMonths;
          display.value = '月額: ${monthlyPayment.toStringAsFixed(0)}円';
        } else {
          final monthlyPayment = principal * 
            (monthlyRate * pow(1 + monthlyRate, totalMonths)) / 
            (pow(1 + monthlyRate, totalMonths) - 1);
          display.value = '月額: ${monthlyPayment.toStringAsFixed(0)}円';
        }
        
        // 結果表示後は最初に戻る
        loanStep.value = 0;
        loanAmount.value = null;
        interestRate.value = null;
        loanMonths.value = null;
      }
    }

    void onLoanNext() {
      final currentValue = double.tryParse(display.value);
      if (currentValue == null) return;

      switch (loanStep.value) {
        case 0:
          loanAmount.value = currentValue;
          loanStep.value = 1;
          display.value = '0';
          isNewInput.value = true;
          break;
        case 1:
          interestRate.value = currentValue;
          loanStep.value = 2;
          display.value = '0';
          isNewInput.value = true;
          break;
        case 2:
          loanMonths.value = currentValue;
          calculateLoanPayment();
          break;
      }
    }

    void clear() {
      // ローンシミュレーション中の場合は現在のステップのみクリア
      if (loanStep.value > 0) {
        display.value = '0';
        isNewInput.value = true;
      } else {
        // 通常の計算機の場合は全てクリア
        display.value = '0';
        previousValue.value = null;
        operation.value = null;
        isNewInput.value = true;
        loanAmount.value = null;
        interestRate.value = null;
        loanMonths.value = null;
      }
    }

    String getDisplayLabel() {
      switch (loanStep.value) {
        case 0: return '';
        case 1: return '借入額: ${loanAmount.value?.toInt()}万円 → 金利(%)を入力';
        case 2: return '金利: ${interestRate.value}% → 返済月数を入力';
        default: return '';
      }
    }

    String getDisplayText() {
      String baseText = display.value;
      
      // 現在の演算子を表示
      if (operation.value != null && !isNewInput.value) {
        baseText += ' ${operation.value!}';
      } else if (operation.value != null && isNewInput.value) {
        baseText = '${previousValue.value} ${operation.value!}';
      }
      
      return baseText;
    }

    Widget buildButton({
      required String text,
      required VoidCallback onPressed,
      Color? backgroundColor,
      Color? textColor,
    }) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.all(1.5),
          height: 65,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? const Color(0xFFE5E5E5), 
              foregroundColor: textColor ?? const Color(0xFF2C2C2C),
              shape: const CircleBorder(), 
              elevation: 0,
              padding: EdgeInsets.zero,
              side: const BorderSide( 
                color: Color(0xFFBBBBBB),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: text.length > 2 ? 14 : 22,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('電卓・ローンシミュレーター'),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                  if (loanStep.value > 0) ...[
                    Text(
                      getDisplayLabel(),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    getDisplayText(),
                    style: TextStyle(
                      fontSize: display.value.contains('月額') ? 24 : 48,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          
          // Button Area
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
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
                            if (display.value != '0' && !display.value.contains('月額')) {
                              final value = double.tryParse(display.value);
                              if (value != null) {
                                display.value = (-value).toString();
                              }
                            }
                          },
                          backgroundColor: const Color(0xFFC0C0C0),
                          textColor: const Color(0xFF2C2C2C),
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
                        ),
                        buildButton(
                          text: '÷',
                          onPressed: () => onOperationPressed('÷'),
                          backgroundColor: const Color(0xFFB85450),
                          textColor: Colors.white,
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
                          backgroundColor: const Color(0xFFB85450),
                          textColor: Colors.white,
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
                          text: '-',
                          onPressed: () => onOperationPressed('-'),
                          backgroundColor: const Color(0xFFB85450),
                          textColor: Colors.white,
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
                          text: '+',
                          onPressed: () => onOperationPressed('+'),
                          backgroundColor: const Color(0xFFB85450),
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  
                  // Row 5: 0, ., 次へ, =
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
                        buildButton(
                          text: '次へ',
                          onPressed: onLoanNext,
                          backgroundColor: const Color(0xFFB85450),
                          textColor: Colors.white,
                        ),
                        buildButton(
                          text: '=',
                          onPressed: calculate,
                          backgroundColor: const Color(0xFFB85450),
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}