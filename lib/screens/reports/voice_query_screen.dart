// lib/screens/reports/voice_query_screen.dart
// Voice-based financial search and queries using speech recognition

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/expense_provider.dart';
import '../../providers/investment_provider.dart';
import '../../utils/formatters.dart';

class VoiceQueryScreen extends StatefulWidget {
  const VoiceQueryScreen({super.key});

  @override
  State<VoiceQueryScreen> createState() => _VoiceQueryScreenState();
}

class _VoiceQueryScreenState extends State<VoiceQueryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late stt.SpeechToText _speechToText;
  final _queryController = TextEditingController();

  bool _isListening = false;
  String _lastWords = '';
  List<Map<String, dynamic>> _queryResults = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      await _speechToText.initialize();
    } catch (e) {
      print('Error initializing speech: $e');
    }
  }

  void _startListening() async {
    if (!_isListening) {
      _animController.repeat(reverse: true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
            _queryController.text = _lastWords;
          });
        },
      );
      setState(() => _isListening = true);
    }
  }

  void _stopListening() async {
    _speechToText.stop();
    _animController.stop();
    setState(() => _isListening = false);
    if (_lastWords.isNotEmpty) {
      await _processQuery(_lastWords);
    }
  }

  Future<void> _processQuery(String query) async {
    setState(() => _isProcessing = true);

    try {
      final lowercaseQuery = query.toLowerCase();
      final results = <Map<String, dynamic>>[];

      // Mock query processing
      await Future.delayed(const Duration(milliseconds: 500));

      if (lowercaseQuery.contains('expense') ||
          lowercaseQuery.contains('spent')) {
        final expenseProvider = context.read<ExpenseProvider>();
        final total =
            expenseProvider.expenses.fold(0.0, (sum, e) => sum + e.amount);
        results.add({
          'type': 'summary',
          'title': 'Total Spent',
          'value': Formatters.formatCurrency(total),
          'icon': Icons.trending_up,
          'color': Colors.red,
        });
      } else if (lowercaseQuery.contains('investment') ||
          lowercaseQuery.contains('portfolio')) {
        final investmentProvider = context.read<InvestmentProvider>();
        results.add({
          'type': 'summary',
          'title': 'Portfolio Value',
          'value': Formatters.formatCurrency(investmentProvider.portfolioValue),
          'icon': Icons.trending_up,
          'color': Colors.green,
        });
      } else if (lowercaseQuery.contains('budget')) {
        results.add({
          'type': 'info',
          'title': 'Budget Information',
          'message': 'Your current month budget limit is ₹50,000',
        });
      } else if (lowercaseQuery.contains('save') ||
          lowercaseQuery.contains('savings')) {
        results.add({
          'type': 'suggestion',
          'title': 'Savings Tip',
          'message':
              'Consider reducing discretionary spending by 10% this month',
        });
      } else {
        results.add({
          'type': 'error',
          'title': 'No results found',
          'message': 'Try asking about expenses, investments, or budget',
        });
      }

      setState(() => _queryResults = results);
    } catch (e) {
      setState(() {
        _queryResults = [
          {
            'type': 'error',
            'title': 'Error',
            'message': 'Failed to process query: $e',
          }
        ];
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Voice Query'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Microphone Button
            Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.2).animate(
                  CurvedAnimation(
                      parent: _animController, curve: Curves.easeInOut),
                ),
                child: GestureDetector(
                  onTapDown: (_) => _startListening(),
                  onTapUp: (_) => _stopListening(),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isListening
                          ? LinearGradient(
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade600
                              ],
                            )
                          : AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? Colors.red
                                  : AppTheme.primaryColor)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _isListening ? 'Listening...' : 'Press to speak',
                style: TextStyle(
                  fontSize: 14,
                  color: _isListening ? Colors.red : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Query Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Or type your query',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _queryController,
                    onSubmitted: (value) => _processQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Ask about expenses, investments, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Results
            if (_queryResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Results',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(_queryResults.map((result) {
                    if (result['type'] == 'summary') {
                      return _buildSummaryResult(result);
                    } else if (result['type'] == 'suggestion') {
                      return _buildSuggestionResult(result);
                    } else {
                      return _buildMessageResult(result);
                    }
                  }).toList()),
                ],
              ),

            // Quick Suggestions
            if (_queryResults.isEmpty) ...[
              const Text(
                'Quick Suggestions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickSuggestion('How much did I spend this month?'),
              const SizedBox(height: 8),
              _buildQuickSuggestion('What is my portfolio value?'),
              const SizedBox(height: 8),
              _buildQuickSuggestion('Show my budget status'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryResult(Map<String, dynamic> result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (result['color'] as Color).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (result['color'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                result['icon'],
                color: result['color'],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['title'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  result['value'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionResult(Map<String, dynamic> result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                result['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result['message'],
            style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageResult(Map<String, dynamic> result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result['title'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result['message'],
            style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestion(String suggestion) {
    return GestureDetector(
      onTap: () => _processQuery(suggestion),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.mic_outlined, color: AppTheme.primaryColor, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    _animController.dispose();
    _speechToText.stop();
    super.dispose();
  }
}
