// Copyright (C) 2026 Lorne Cammack
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:convert/convert.dart';
import 'constants.dart';
import 'logic/hashing_logic.dart';
import 'widgets/custom_cards.dart';
import 'widgets/app_logo.dart';
import 'widgets/info_drawer.dart';

/// Global notifier for theme mode to allow switching from anywhere in the app.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() => runApp(const PhatApp());

/// Root widget of the application.
class PhatApp extends StatelessWidget {
  const PhatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: AppConstants.appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          // Light Theme Definition
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.light,
              primary: AppConstants.primaryAccent,
              surface: AppConstants.lightCardColor,
            ),
            scaffoldBackgroundColor: AppConstants.lightScaffoldBgColor,
            fontFamily: 'sans-serif',
            splashFactory: InkRipple.splashFactory,
          ),
          // Dark Theme Definition
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
              primary: AppConstants.primaryAccent,
              surface: AppConstants.cardColor,
            ),
            scaffoldBackgroundColor: AppConstants.scaffoldBgColor,
            fontFamily: 'sans-serif',
            splashFactory: InkRipple.splashFactory,
          ),
          home: const PHATHome(),
        );
      },
    );
  }
}

/// Enum to toggle length restriction.
enum RestrictDigit { yes, no }

/// The main home screen of the PHAT application.
class PHATHome extends StatefulWidget {
  const PHATHome({super.key});

  @override
  State<PHATHome> createState() => _PHATHomeState();
}

/// The state logic for the PHAT application, handling UI interactions and hashing orchestration.
class _PHATHomeState extends State<PHATHome> with WidgetsBindingObserver {
  final _inputController = TextEditingController();
  final _saltController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Timer? _clipboardTimer;
  String inputText = '';
  String saltText = '';
  HashAlgorithm algorithm = HashAlgorithm.sha256;
  NumberSystem numSystem = NumberSystem.hex;
  RestrictDigit? _character = RestrictDigit.no;
  double _valueRestrictDigit = 128;
  String outText = 'Output will appear here';
  
  /// Cached bytes of the last calculation to allow fast re-formatting.
  /// Using [Uint8List] to allow explicit memory wiping.
  Uint8List? _cachedRawBytes;
  
  bool _isCalculating = false;
  bool _isInputVisible = false;
  bool _isSaltVisible = false;
  bool _isOutputVisible = false;

  int argon2Iterations = AppConstants.argon2Iterations;
  int argon2Memory = AppConstants.argon2Memory;
  int argon2Parallelism = AppConstants.argon2Parallelism;
  int pbkdf2Iterations = AppConstants.pbkdf2Iterations;

  bool get _requiresSalt => algorithm == HashAlgorithm.argon2id || algorithm == HashAlgorithm.pbkdf2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inputController.dispose();
    _saltController.dispose();
    _clipboardTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _clearAllSensitiveData();
    }
  }

  void _clearAllSensitiveData() {
    if (!kIsWeb) {
      Clipboard.setData(const ClipboardData(text: ''));
    }
    _inputController.clear();
    _saltController.clear();
    
    // Explicitly wipe the cached result bytes before nullifying
    if (_cachedRawBytes != null) {
      _cachedRawBytes!.fillRange(0, _cachedRawBytes!.length, 0);
    }
    
    if (mounted) {
      setState(() {
        inputText = '';
        saltText = '';
        outText = 'Output will appear here';
        _cachedRawBytes = null;
      });
    }
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
    if (inputText.isEmpty) {
      _showSnackBar('Input text is empty');
      return;
    }

    if (_requiresSalt && saltText.length < AppConstants.minSaltLength) {
      _showSnackBar('Salt must be at least ${AppConstants.minSaltLength} characters!');
      return;
    }

    setState(() {
      _isCalculating = true;
      // Wipe old cache before creating a new one
      if (_cachedRawBytes != null) {
        _cachedRawBytes!.fillRange(0, _cachedRawBytes!.length, 0);
      }
      _cachedRawBytes = null;
    });

    // Convert sensitive strings to Uint8List as late as possible
    final userTextBytes = Uint8List.fromList(utf8.encode(inputText.trim()));
    final saltBytes = Uint8List.fromList(utf8.encode(saltText));

    try {
      final params = HashParams(
        userText: userTextBytes,
        algorithm: algorithm,
        salt: saltBytes,
        argon2Iterations: argon2Iterations,
        argon2Memory: argon2Memory,
        argon2Parallelism: argon2Parallelism,
        pbkdf2Iterations: pbkdf2Iterations,
      );

      // compute() copies data to the new isolate. HashingLogic.hashInput
      // will wipe its copies in the worker isolate.
      final resultBytes = await compute(HashingLogic.hashInput, params);
      _cachedRawBytes = resultBytes;
      _updateOutput();
    } catch (e) {
      setState(() {
        outText = "Error: ${e.toString().replaceAll('Exception: ', '')}";
      });
    } finally {
      // Wipe our local byte array copies in the main isolate
      userTextBytes.fillRange(0, userTextBytes.length, 0);
      saltBytes.fillRange(0, saltBytes.length, 0);
      setState(() => _isCalculating = false);
    }
  }

  void _updateOutput() {
    if (_cachedRawBytes == null) return;
    String result = HashingLogic.formatBytes(_cachedRawBytes!, numSystem);
    if (_character == RestrictDigit.yes) {
      result = HashingLogic.truncateOutput(result, _valueRestrictDigit);
    }
    setState(() => outText = result);
  }

  void _generateRandomSalt() {
    final random = Random();
    final length = 8 + random.nextInt(9); 
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    final randomHex = hex.encode(values);
    setState(() {
      saltText = randomHex;
      _saltController.text = randomHex;
      _cachedRawBytes = null;
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(isDark),
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

  Widget _buildAppBar(bool isDark) {
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
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () {
            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
          tooltip: 'Toggle Light/Dark Mode',
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: 'Information',
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
            enabled: !_isCalculating,
            decoration: InputDecoration(
              hintText: 'Type something to hash...',
              filled: true,
              fillColor: theme.brightness == Brightness.dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.security),
              suffixIcon: IconButton(
                icon: Icon(_isInputVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isInputVisible = !_isInputVisible),
              ),
            ),
            style: TextStyle(fontSize: 18, color: theme.textTheme.bodyLarge?.color),
            onChanged: (value) => setState(() {
              inputText = value;
              _cachedRawBytes = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSaltCard(ThemeData theme) {
    final bool isEnabled = _requiresSalt;
    return PHATCard(
      color: isEnabled ? null : theme.disabledColor.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionLabel('SALT (REQUIRED FOR ADVANCED)', color: isEnabled ? theme.colorScheme.primary : theme.disabledColor),
              if (isEnabled)
                TextButton.icon(
                  onPressed: _isCalculating ? null : _generateRandomSalt,
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
            enabled: isEnabled && !_isCalculating,
            obscureText: !_isSaltVisible,
            decoration: InputDecoration(
              hintText: isEnabled ? 'Enter site name or unique ID...' : 'Not required for this algorithm',
              filled: true,
              fillColor: theme.brightness == Brightness.dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.grain),
              suffixIcon: isEnabled
                  ? IconButton(
                      icon: Icon(_isSaltVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isSaltVisible = !_isSaltVisible),
                    )
                  : null,
            ),
            style: TextStyle(fontSize: 18, color: isEnabled ? theme.textTheme.bodyLarge?.color : theme.disabledColor),
            onChanged: (value) => setState(() {
              saltText = value;
              _cachedRawBytes = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme) {
    return PHATCard(
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown<HashAlgorithm>(
              'ALGORITHM',
              algorithm,
              HashAlgorithm.values,
              _isCalculating
                  ? null
                  : (v) => setState(() {
                        algorithm = v!;
                        _cachedRawBytes = null;
                      }),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown<NumberSystem>(
              'SYSTEM',
              numSystem,
              NumberSystem.values,
              _isCalculating
                  ? null
                  : (v) => setState(() {
                        numSystem = v!;
                        _updateOutput();
                      }),
            ),
          ),
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
          if (algorithm == HashAlgorithm.argon2id) ...[
            _buildSettingSlider(
              'Iterations',
              argon2Iterations.toDouble(),
              1,
              10,
              _isCalculating
                  ? null
                  : (v) => setState(() {
                        argon2Iterations = v.round();
                        _cachedRawBytes = null;
                      }),
            ),
            _buildSettingSlider(
              'Memory (MB)',
              argon2Memory / 1024,
              8,
              256,
              _isCalculating
                  ? null
                  : (v) => setState(() {
                        argon2Memory = (v * 1024).round();
                        _cachedRawBytes = null;
                      }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Note: Parallelism (Lanes) is fixed at 4',
                style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontStyle: FontStyle.italic),
              ),
            ),
          ],
          if (algorithm == HashAlgorithm.pbkdf2) ...[
            _buildSettingSlider(
              'Iterations',
              pbkdf2Iterations.toDouble(),
              10000,
              1000000,
              _isCalculating
                  ? null
                  : (v) => setState(() {
                        pbkdf2Iterations = v.round();
                        _cachedRawBytes = null;
                      }),
              divisions: 99,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingSlider(String label, double value, double min, double max, ValueChanged<double>? onChanged, {int? divisions}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
            Text(value.round().toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          min: min,
          max: max,
          divisions: divisions ?? (max - min).toInt(),
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(String label, T value, List<T> options, ValueChanged<T?>? onChanged) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: theme.cardColor,
              items: options.map((s) {
                String text = s.toString().split('.').last;
                if (s is HashAlgorithm) text = s.label;
                if (s is NumberSystem) text = s.label;
                return DropdownMenuItem(value: s, child: Text(text));
              }).toList(),
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
                activeTrackColor: theme.colorScheme.primary.withOpacity(0.5),
                activeColor: theme.colorScheme.primary,
                onChanged: _isCalculating
                    ? null
                    : (val) => setState(() {
                          _character = val ? RestrictDigit.yes : RestrictDigit.no;
                          _updateOutput();
                        }),
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
                    onChanged: _isCalculating
                        ? null
                        : (v) => setState(() {
                              _valueRestrictDigit = v;
                              _updateOutput();
                            }),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_valueRestrictDigit.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
            onPressed: _isCalculating ? null : _calculateHash,
            icon: _isCalculating 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.calculate),
            label: const Text('CALCULATE', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
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
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.black26 : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
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
                  Text('${entropy.round()} BITS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, backgroundColor: theme.dividerColor.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(strengthColor), minHeight: 6),
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
        _buildSmallAction(theme, Icons.copy, 'Copy', _isCalculating ? null : () {
          if (outText != 'Output will appear here' && !outText.startsWith('Error')) {
            Clipboard.setData(ClipboardData(text: outText));
            _showSnackBar('Copied to clipboard!');
            _startAutoClearTimer();
          }
        }),
        _buildSmallAction(theme, Icons.delete_sweep, 'Clear Clipboard', _isCalculating ? null : () {
          Clipboard.setData(const ClipboardData(text: ''));
          _showSnackBar('Clipboard cleared');
        }),
        _buildSmallAction(theme, Icons.refresh, 'Clear All', _isCalculating ? null : () {
          _clearAllSensitiveData();
          _showSnackBar('Everything cleared');
        }),
      ],
    );
  }

  Widget _buildSmallAction(ThemeData theme, IconData icon, String label, VoidCallback? onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
    );
  }
}
