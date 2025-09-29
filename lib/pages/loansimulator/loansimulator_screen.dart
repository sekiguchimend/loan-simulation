import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class LoanSimulatorScreen extends HookConsumerWidget {
  const LoanSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = useState('0');
    final previousValue = useState<double?>(null);
    final operation = useState<String?>(null);
    final isNewInput = useState(true);
    final loanStep = useState(-1); // -1: 初期状態, 0: 借入額, 1: 金利, 2: 返済月数, 3: 結果表示
    final loanAmount = useState<double?>(null);
    final interestRate = useState<double?>(null);
    final loanMonths = useState<double?>(null);
    final monthlyPaymentResult = useState<double?>(null);

    // カンマ区切りのフォーマッター
    final numberFormatter = NumberFormat('#,###');
    final decimalFormatter = NumberFormat('#,###.##');

    // 数値をカンマ区切り文字列に変換
    String formatNumber(String value) {
      if (value.isEmpty || value == '0') return value;
      
      // 小数点で終わる場合の処理
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
      
      // 小数点がある場合
      if (value.contains('.')) {
        return decimalFormatter.format(numValue);
      } else {
        return numberFormatter.format(numValue.toInt());
      }
    }

    // 表示用の数値文字列を取得
    String getFormattedDisplay() {
      // 常にフォーマットして表示
      return formatNumber(display.value);
    }

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
      
      // 結果表示中の場合は通常の計算機モードに戻る（ただし計算は継続可能）
      if (loanStep.value == 3) {
        loanStep.value = -1;
        monthlyPaymentResult.value = null;
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
        
        // 結果表示中の場合は通常の計算機モードに戻る
        if (loanStep.value == 3) {
          loanStep.value = -1;
          monthlyPaymentResult.value = null;
        }
      }
    }

    void calculateLoanPayment() {
      if (loanAmount.value != null && interestRate.value != null && loanMonths.value != null) {
        final principal = loanAmount.value!;
        final monthlyRate = interestRate.value! / 100 / 12;
        final totalMonths = loanMonths.value!;
        
        double monthlyPayment;
        if (monthlyRate == 0) {
          // 金利0%の場合
          monthlyPayment = principal / totalMonths;
        } else {
          monthlyPayment = principal * 
            (monthlyRate * pow(1 + monthlyRate, totalMonths)) / 
            (pow(1 + monthlyRate, totalMonths) - 1);
        }
        
        monthlyPaymentResult.value = monthlyPayment;
        display.value = monthlyPayment.toStringAsFixed(0);
        
        // 結果表示状態に移行
        loanStep.value = 3;
      }
    }

    void onLoanButtonPressed() {
      if (loanStep.value == -1) {
        // 初期状態から借入額入力画面へ
        loanStep.value = 0;
        display.value = '0';
        isNewInput.value = true;
        return;
      }

      if (loanStep.value == 3) {
        // 結果表示からリセット
        loanStep.value = -1;
        loanAmount.value = null;
        interestRate.value = null;
        loanMonths.value = null;
        monthlyPaymentResult.value = null;
        display.value = '0';
        isNewInput.value = true;
        return;
      }

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
      if (loanStep.value >= 0 && loanStep.value < 3) {
        display.value = '0';
        isNewInput.value = true;
      } else {
        // 通常の計算機の場合は全てクリア
        display.value = '0';
        previousValue.value = null;
        operation.value = null;
        isNewInput.value = true;
        loanStep.value = -1;
        loanAmount.value = null;
        interestRate.value = null;
        loanMonths.value = null;
        monthlyPaymentResult.value = null;
      }
    }

    String getDisplayLabel() {
      switch (loanStep.value) {
        case 0: return '借入額を入力してください';
        case 1: return '利率(%)を入力してください';
        case 2: return '返済月数を入力してください';
        case 3: return '返済額(月)';
        default: return '';
      }
    }

    String getLoanButtonText() {
      switch (loanStep.value) {
        case -1: return ''; // アイコンのみ
        case 3: return 'OK'; // 結果表示後
        default: return '次へ';
      }
    }

    IconData? getLoanButtonIcon() {
      return loanStep.value == -1 ? Icons.calculate : null;
    }

    Widget getDisplayText() {
      List<Widget> children = [];
      
      // メインの数字（カンマ区切りでフォーマット）
      children.add(
        Text(
          getFormattedDisplay(),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
      
      // 演算子を小さな角丸正方形で表示（新しい入力が始まっていない場合のみ）
      if (operation.value != null && isNewInput.value) {
        children.add(
          const SizedBox(width: 8),
        );
        
        // 全角演算子に変換
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
              color: Theme.of(context).primaryColor,
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
      required VoidCallback onPressed,
      Color? backgroundColor,
      Color? textColor,
      IconData? icon,
      bool isOperator = false,
    }) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.all(4),
          height: 90,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E5E5), 
              foregroundColor: isOperator ? Theme.of(context).primaryColor : const Color(0xFF2C2C2C),
              shape: const CircleBorder(), 
              elevation: 0,
              padding: EdgeInsets.zero,
              side: BorderSide( 
                color: isOperator ? Theme.of(context).primaryColor : const Color(0xFFBBBBBB),
                width: isOperator ? 1.5 : 0.5,
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
                  if (loanStep.value >= 0 && loanStep.value <= 3) ...[
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
                          isOperator: true,
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
                        ),
                      ],
                    ),
                  ),
                  
                  // Row 5: 0, ., ローンボタン, =
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
                          text: getLoanButtonText(),
                          icon: getLoanButtonIcon(),
                          onPressed: onLoanButtonPressed,
                          isOperator: true,
                        ),
                        buildButton(
                          text: '＝',
                          onPressed: calculate,
                          isOperator: true,
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
      ),
    );
  }
}