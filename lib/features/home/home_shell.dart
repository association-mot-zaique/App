import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/services/local_backup_service.dart';
import '../../data/services/pin_repository.dart';
import '../../data/services/pictogram_search_service.dart';
import '../../data/services/search_cache_repository.dart';
import '../../data/services/speech_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/logo_title.dart';
import '../communication/communication_screen.dart';
import '../communication/phrase_book_controller.dart';
import '../favorites/favorites_controller.dart';
import '../favorites/favorites_screen.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.searchService,
    required this.searchCacheRepository,
    required this.favoritesController,
    required this.phraseBookController,
    required this.settingsController,
    required this.pinRepository,
    required this.speechService,
    required this.localBackupService,
    super.key,
  });

  final PictogramSearchService searchService;
  final SearchCacheRepository searchCacheRepository;
  final FavoritesController favoritesController;
  final PhraseBookController phraseBookController;
  final SettingsController settingsController;
  final PinRepository pinRepository;
  final SpeechService speechService;
  final LocalBackupService localBackupService;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  bool _favoritesUnlocked = false;

  Future<void> _onDestinationSelected(int index) async {
    if (index == _selectedIndex) {
      return;
    }

    if (index == 1) {
      final canOpenFavorites = await _ensureFavoritesUnlocked();
      if (!mounted || !canOpenFavorites) {
        return;
      }
    }

    setState(() {
      if (_selectedIndex == 1 && index != 1) {
        _favoritesUnlocked = false;
      }
      _selectedIndex = index;
    });
  }

  Future<bool> _ensureFavoritesUnlocked() async {
    final l10n = AppLocalizations.of(context);

    if (_favoritesUnlocked) {
      return true;
    }

    if (!widget.pinRepository.hasPin()) {
      final pin = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _CreatePinDialog(),
      );

      if (pin == null) {
        return false;
      }

      final setupResult = await widget.pinRepository.setupPin(pin);
      if (!mounted) {
        return false;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            _RecoveryCodeDialog(recoveryCode: setupResult.recoveryCode),
      );

      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pinCreated)));

      _favoritesUnlocked = true;
      return true;
    }

    final isValid =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              _ValidatePinDialog(pinRepository: widget.pinRepository),
        ) ??
        false;

    _favoritesUnlocked = isValid;
    return isValid;
  }

  Future<void> _changePin() async {
    final l10n = AppLocalizations.of(context);
    final newPin = await showDialog<String>(
      context: context,
      builder: (_) => const _ChangePinDialog(),
    );

    if (newPin == null) {
      return;
    }

    await widget.pinRepository.changePin(newPin);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.pinChanged)));
  }

  Future<void> _refreshAfterBackupRestore() async {
    await Future.wait([
      widget.favoritesController.load(),
      widget.phraseBookController.load(),
      widget.settingsController.load(),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _favoritesUnlocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const LogoTitle(),
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              tooltip: l10n.changePinAction,
              onPressed: _changePin,
              icon: const Icon(Icons.password_rounded),
            ),
          if (_selectedIndex == 1)
            IconButton(
              tooltip: l10n.lockFavorites,
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                  _favoritesUnlocked = false;
                });
              },
              icon: const Icon(Icons.lock_outline_rounded),
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CommunicationScreen(
            searchService: widget.searchService,
            favoritesController: widget.favoritesController,
            phraseBookController: widget.phraseBookController,
            settingsController: widget.settingsController,
            speechService: widget.speechService,
          ),
          FavoritesScreen(
            favoritesController: widget.favoritesController,
            settingsController: widget.settingsController,
          ),
          SettingsScreen(
            settingsController: widget.settingsController,
            searchCacheRepository: widget.searchCacheRepository,
            localBackupService: widget.localBackupService,
            onBackupRestored: _refreshAfterBackupRestore,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.record_voice_over_rounded),
            label: l10n.communicateNav,
          ),
          NavigationDestination(
            icon: const Icon(Icons.lock_rounded),
            selectedIcon: const Icon(Icons.lock_open_rounded),
            label: l10n.favoritesNav,
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_rounded),
            label: l10n.settingsNav,
          ),
        ],
      ),
    );
  }
}

class _CreatePinDialog extends StatefulWidget {
  const _CreatePinDialog();

  @override
  State<_CreatePinDialog> createState() => _CreatePinDialogState();
}

class _CreatePinDialogState extends State<_CreatePinDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final pin = _pinController.text.trim();
    final confirmation = _confirmController.text.trim();

    final isPinValid = RegExp(r'^\d{4,6}$').hasMatch(pin);
    if (!isPinValid) {
      setState(() {
        _error = l10n.pinInvalidRule;
      });
      return;
    }

    if (pin != confirmation) {
      setState(() {
        _error = l10n.pinMismatch;
      });
      return;
    }

    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.pinCreateTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.pinNew,
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.pinConfirm,
              counterText: '',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.pinSave)),
      ],
    );
  }
}

class _RecoveryCodeDialog extends StatelessWidget {
  const _RecoveryCodeDialog({required this.recoveryCode});

  final String recoveryCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.recoveryCodeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.recoveryCodeMessage),
          const SizedBox(height: 12),
          SelectableText(
            recoveryCode,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.continueText),
        ),
      ],
    );
  }
}

class _ValidatePinDialog extends StatefulWidget {
  const _ValidatePinDialog({required this.pinRepository});

  final PinRepository pinRepository;

  @override
  State<_ValidatePinDialog> createState() => _ValidatePinDialogState();
}

class _ValidatePinDialogState extends State<_ValidatePinDialog> {
  final TextEditingController _pinController = TextEditingController();

  Timer? _timer;
  bool _isChecking = false;
  String? _error;
  int? _remainingAttempts;
  Duration? _blockedFor;

  @override
  void initState() {
    super.initState();
    _loadInitialBlockState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialBlockState() async {
    final block = await widget.pinRepository.remainingLockDuration();
    if (!mounted || block == null) {
      return;
    }
    _startBlockCountdown(block);
  }

  void _startBlockCountdown(Duration duration) {
    _timer?.cancel();
    setState(() {
      _blockedFor = duration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = _blockedFor;
      if (current == null || current.inSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _blockedFor = null;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _blockedFor = Duration(seconds: current.inSeconds - 1);
        });
      }
    });
  }

  Future<void> _unlock() async {
    if (_isChecking || _blockedFor != null) {
      return;
    }

    setState(() {
      _isChecking = true;
      _error = null;
    });

    final result = await widget.pinRepository.verifyPin(
      _pinController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (result.status == PinValidationStatus.success) {
      Navigator.of(context).pop(true);
      return;
    }

    if (result.status == PinValidationStatus.blocked) {
      _startBlockCountdown(result.blockedFor ?? PinRepository.lockDuration);
      setState(() {
        _isChecking = false;
      });
      return;
    }

    setState(() {
      _isChecking = false;
      _remainingAttempts = result.remainingAttempts;
      _error = AppLocalizations.of(context).pinIncorrect;
    });
  }

  Future<void> _recoverPin() async {
    final recovered =
        await showDialog<bool>(
          context: context,
          builder: (_) =>
              _RecoverPinDialog(pinRepository: widget.pinRepository),
        ) ??
        false;

    if (!mounted || !recovered) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).pinResetSuccess)),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.unlockFavoritesTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.pinLabel,
              counterText: '',
            ),
            onSubmitted: (_) => _unlock(),
          ),
          if (_blockedFor != null)
            Text(
              l10n.pinLockedSeconds(_blockedFor!.inSeconds),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          else if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_remainingAttempts != null && _remainingAttempts! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l10n.remainingAttempts(_remainingAttempts!)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isChecking ? null : _recoverPin,
          child: Text(l10n.recoverPin),
        ),
        TextButton(
          onPressed: _isChecking
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isChecking ? null : _unlock,
          child: _isChecking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.continueText),
        ),
      ],
    );
  }
}

class _RecoverPinDialog extends StatefulWidget {
  const _RecoverPinDialog({required this.pinRepository});

  final PinRepository pinRepository;

  @override
  State<_RecoverPinDialog> createState() => _RecoverPinDialogState();
}

class _RecoverPinDialogState extends State<_RecoverPinDialog> {
  final TextEditingController _recoveryCodeController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _recoveryCodeController.dispose();
    _newPinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _recover() async {
    final l10n = AppLocalizations.of(context);
    if (_saving) {
      return;
    }

    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmController.text.trim();
    final recoveryCode = _recoveryCodeController.text.trim().toUpperCase();

    if (!RegExp(r'^\d{4,6}$').hasMatch(newPin)) {
      setState(() {
        _error = l10n.pinInvalidRule;
      });
      return;
    }

    if (newPin != confirmPin) {
      setState(() {
        _error = l10n.pinMismatch;
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final success = await widget.pinRepository.resetPinWithRecoveryCode(
      recoveryCode: recoveryCode,
      newPin: newPin,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _saving = false;
      _error = l10n.pinIncorrect;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.recoverPinTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _recoveryCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(labelText: l10n.recoveryCodeLabel),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newPinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.newPinLabel,
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.confirmNewPinLabel,
              counterText: '',
            ),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _recover,
          child: Text(l10n.recoverAction),
        ),
      ],
    );
  }
}

class _ChangePinDialog extends StatefulWidget {
  const _ChangePinDialog();

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final pin = _newPinController.text.trim();
    final confirm = _confirmController.text.trim();

    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      setState(() {
        _error = l10n.pinInvalidRule;
      });
      return;
    }

    if (pin != confirm) {
      setState(() {
        _error = l10n.pinMismatch;
      });
      return;
    }

    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.changePinTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _newPinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.newPinLabel,
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.confirmNewPinLabel,
              counterText: '',
            ),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
