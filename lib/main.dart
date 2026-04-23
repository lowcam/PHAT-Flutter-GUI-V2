import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:convert/convert.dart';
import 'constants.dart';
import 'logic/hashing_logic.dart';
import 'widgets/custom_cards.dart';
import 'widgets/app_logo.dart';
import 'widgets/info_drawer.dart';

void main() => runApp(const PhatApp());

class PhatApp extends StatelessWidget {
  const PhatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
          primary: AppConstants.primaryAccent,
          surface: AppConstants.cardColor,
        ),
        scaffoldBackgroundColor: AppConstants.scaffoldBgColor,
        fontFamily: 'sans-serif',
        // Update to newer opacity API if needed, but keeping for now
      ),
      home: const PHATHome(),
    );
  }
}

enum RestrictDigit { yes, no }

class PHATHome extends StatefulWidget {
  const PHATHome({super.key});

  @override
  State<PHATHome> createState() => _PHATHomeState();
}

class _PHATHomeState extends State<PHATHome> {
  final _inputController = TextEditingController();
  final _saltController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Timer? _clipboardTimer;
  String inputText = '';
  String saltText = '';
  String? algorithm = AppConstants.algorithmOptions[0];
  String? numSystem = AppConstants.systemOptions[0];
  RestrictDigit? _character = RestrictDigit.no;
  double _valueRestrictDigit = 128;
  String outText = 'Output will appear here';
  bool _isCalculating = false;
  bool _isInputVisible = false;
  bool _isSaltVisible = false;
  bool _isOutputVisible = false;

  // Advanced Settings
  int argon2Iterations = AppConstants.argon2Iterations;
  int argon2Memory = AppConstants.argon2Memory;
  int argon2Parallelism = AppConstants.argon2Parallelism;
  int pbkdf2Iterations = AppConstants.pbkdf2Iterations;

  bool get _requiresSalt {
    return algorithm == 'Argon2id' || algorithm == 'PBKDF2';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _saltController.dispose();
    _clipboardTimer?.cancel();
    super.dispose();
  }

  void _startAutoClearTimer() {
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer(const Duration(seconds: 30), () {
      if (!kIsWeb) {
        Clipboard.setData(const ClipboardData(text: ''));
      }
      if (mounted) {
        setState(() => outText = 'Output will appear here');
        _showSnackBar(kIsWeb ? 'UI has auto-cleared for security' : 'Clipboard has auto-cleared for security');
      }
    });
  }

  void _calculateHash() async {
    if (_requiresSalt && saltText.isEmpty) {
      _showSnackBar('Salt is required for this algorithm!');
      return;
    }

    setState(() => _isCalculating = true);
    
    String result = await HashingLogic.hashInput(
      userText: inputText,
      algorithm: algorithm,
      salt: saltText,
      argon2Iterations: argon2Iterations,
      argon2Memory: argon2Memory,
      argon2Parallelism: argon2Parallelism,
      pbkdf2Iterations: pbkdf2Iterations,
    );

    result = HashingLogic.numberSystemConvert(numSystem, result);

    if (_character == RestrictDigit.yes) {
      result = HashingLogic.finalOutputText(result, _valueRestrictDigit);
    }

    setState(() {
      outText = result;
      _isCalculating = false;
    });
  }

  void _generateRandomSalt() {
    final random = Random();
    final length = 8 + random.nextInt(9); // Random length between 8 and 16
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    final randomHex = hex.encode(values);
    setState(() {
      saltText = randomHex;
      _saltController.text = randomHex;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildInputCard(theme),
                        const SizedBox(height: 16),
                        _buildSaltCard(theme),
                        const SizedBox(height: 16),
                        _buildSettingsCard(theme),
                        const SizedBox(height: 16),
                        if (_requiresSalt) _buildAdvancedSettingsCard(theme),
                        if (_requiresSalt) const SizedBox(height: 16),
                        _buildRestrictionCard(theme),
                        const SizedBox(height: 24),
                        _buildActionButtons(theme),
                        const SizedBox(height: 24),
                        _buildOutputCard(theme),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      endDrawer: const AppInfoDrawer(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          AppLogo(size: 32),
          SizedBox(width: 12),
          Text(AppConstants.appTitle, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 28)),
        ],
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        )
      ],
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    return PHATCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('INPUT TEXT', color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          TextFormField(
            controller: _inputController,
            obscureText: !_isInputVisible,
            decoration: InputDecoration(
              hintText: 'Type something to hash...',
              filled: true,
              fillColor: AppConstants.inputFillColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.security),
              suffixIcon: IconButton(
                icon: Icon(_isInputVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isInputVisible = !_isInputVisible),
              ),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.white),
            onChanged: (value) => setState(() => inputText = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSaltCard(ThemeData theme) {
    return PHATCard(
      color: _requiresSalt ? null : theme.disabledColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionLabel('SALT (REQUIRED FOR ADVANCED)', color: _requiresSalt ? theme.colorScheme.primary : theme.disabledColor),
              if (_requiresSalt)
                TextButton.icon(
                  onPressed: _generateRandomSalt,
                  icon: const Icon(Icons.casino, size: 16),
                  label: const Text('Random', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _saltController,
            enabled: _requiresSalt,
            obscureText: !_isSaltVisible,
            decoration: InputDecoration(
              hintText: _requiresSalt ? 'Enter site name or unique ID...' : 'Not required for this algorithm',
              filled: true,
              fillColor: AppConstants.inputFillColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.grain),
              suffixIcon: _requiresSalt
                  ? IconButton(
                      icon: Icon(_isSaltVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isSaltVisible = !_isSaltVisible),
                    )
                  : null,
            ),
            style: TextStyle(fontSize: 18, color: _requiresSalt ? Colors.white : theme.disabledColor),
            onChanged: (value) => setState(() => saltText = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme) {
    return PHATCard(
      child: Row(
        children: [
          Expanded(child: _buildDropdown('ALGORITHM', algorithm, AppConstants.algorithmOptions, (v) => setState(() => algorithm = v))),
          const SizedBox(width: 16),
          Expanded(child: _buildDropdown('SYSTEM', numSystem, AppConstants.systemOptions, (v) => setState(() => numSystem = v))),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsCard(ThemeData theme) {
    return PHATCard(
      child: ExpansionTile(
        title: const SectionLabel('ADVANCED KDF SETTINGS'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        collapsedIconColor: theme.colorScheme.primary,
        iconColor: theme.colorScheme.primary,
        shape: const Border(),
        children: [
          if (algorithm == 'Argon2id') ...[
            _buildSettingSlider('Iterations', argon2Iterations.toDouble(), 1, 10, (v) => setState(() => argon2Iterations = v.round())),
            _buildSettingSlider('Memory (MB)', argon2Memory / 1024, 8, 256, (v) => setState(() => argon2Memory = (v * 1024).round())),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Note: Parallelism (Lanes) is fixed at 4',
                style: TextStyle(fontSize: 11, color: Colors.white38, fontStyle: FontStyle.italic),
              ),
            ),
          ],
          if (algorithm == 'PBKDF2') ...[
            _buildSettingSlider('Iterations', pbkdf2Iterations.toDouble(), 10000, 500000, (v) => setState(() => pbkdf2Iterations = v.round()), divisions: 49),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingSlider(String label, double value, double min, double max, ValueChanged<double> onChanged, {int? divisions}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            Text(value.round().toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(min: min, max: max, divisions: divisions ?? (max - min).toInt(), value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppConstants.inputFillColor, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppConstants.cardColor,
              items: options.map((s) => DropdownMenuItem(value: s, child: Text(s.contains('256') || s.contains('384') || s.contains('512') ? 'SHA-$s' : s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestrictionCard(ThemeData theme) {
    return PHATCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('RESTRICT LENGTH'),
              Switch(
                value: _character == RestrictDigit.yes,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) => setState(() => _character = val ? RestrictDigit.yes : RestrictDigit.no),
              ),
            ],
          ),
          if (_character == RestrictDigit.yes) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: 1,
                    max: 128,
                    divisions: 127,
                    label: _valueRestrictDigit.round().toString(),
                    value: _valueRestrictDigit,
                    onChanged: (v) => setState(() => _valueRestrictDigit = v),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppConstants.inputFillColor, borderRadius: BorderRadius.circular(10)),
                  child: Text(_valueRestrictDigit.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _calculateHash,
            icon: _isCalculating 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.calculate),
            label: const Text('CALCULATE', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputCard(ThemeData theme) {
    bool showPlaceholder = outText == 'Output will appear here';
    bool isError = outText.startsWith('Error');
    String displayOutText = (_isOutputVisible || showPlaceholder || isError) 
        ? outText 
        : '\u2022' * (outText.length > 32 ? 32 : outText.length);

    double entropy = HashingLogic.calculateEntropy(outText, numSystem);
    
    Color strengthColor;
    String strengthLabel;
    double progress;

    if (showPlaceholder || isError) {
      strengthColor = Colors.grey;
      strengthLabel = isError ? 'ERROR' : 'NO DATA';
      progress = 0;
    } else if (entropy < 64) {
      strengthColor = Colors.red; strengthLabel = 'WEAK'; progress = 0.25;
    } else if (entropy < 80) {
      strengthColor = Colors.orange; strengthLabel = 'FAIR'; progress = 0.5;
    } else if (entropy < 112) {
      strengthColor = Colors.lightGreen; strengthLabel = 'GOOD'; progress = 0.75;
    } else {
      strengthColor = Colors.green; strengthLabel = 'EXCELLENT'; progress = 1.0;
    }

    return PHATCard(
      elevation: 8,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SectionLabel('RESULT'),
              const SizedBox(width: 8),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                iconSize: 20,
                color: theme.colorScheme.primary.withOpacity(0.7),
                icon: Icon(_isOutputVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isOutputVisible = !_isOutputVisible),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppConstants.inputFillColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SelectableText(
                displayOutText,
                key: ValueKey(displayOutText),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isError ? 14 : 20, 
                  fontWeight: FontWeight.bold, 
                  fontFamily: 'monospace', 
                  color: isError ? Colors.redAccent : theme.colorScheme.primary.withOpacity(0.9),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('STRENGTH: $strengthLabel', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: strengthColor, letterSpacing: 1.2)),
                  Text('${entropy.round()} BITS', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(strengthColor), minHeight: 6),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildResultActions(theme),
        ],
      ),
    );
  }

  Widget _buildResultActions(ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 8,
      children: [
        _buildSmallAction(theme, Icons.copy, 'Copy', () {
          if (outText != 'Output will appear here' && !outText.startsWith('Error')) {
            Clipboard.setData(ClipboardData(text: outText));
            _showSnackBar('Copied to clipboard!');
            _startAutoClearTimer();
          }
        }),
        _buildSmallAction(theme, Icons.delete_sweep, 'Clear Clipboard', () {
          Clipboard.setData(const ClipboardData(text: ''));
          _showSnackBar('Clipboard cleared');
        }),
        _buildSmallAction(theme, Icons.refresh, 'Clear All', () {
          Clipboard.setData(const ClipboardData(text: ''));
          _inputController.clear();
          _saltController.clear();
          setState(() {
            inputText = '';
            saltText = '';
            outText = 'Output will appear here';
          });
          _showSnackBar('Everything cleared');
        }),
      ],
    );
  }

  Widget _buildSmallAction(ThemeData theme, IconData icon, String label, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
    );
  }
}
