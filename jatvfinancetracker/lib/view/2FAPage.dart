import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(TwoFactorApp());

class TwoFactorApp extends StatelessWidget {
  const TwoFactorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TwoFactorPage(),
    );
  }
}

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final int _codeLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String _message = '';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.length == 1) {
      if (index < _codeLength - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].clear();
    }
  }

  void _verifyCode() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < _codeLength) {
      setState(() {
        _message = 'Please enter all 6 digits.';
        _isError = true;
      });
      return;
    }
    setState(() {
      _message = 'Code submitted: $code';
      _isError = false;
    });
  }

  void _resendCode() {
    for (final c in _controllers) c.clear();
    FocusScope.of(context).requestFocus(_focusNodes[0]);
    setState(() {
      _message = 'A new code has been sent.';
      _isError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4F6FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              SizedBox(height: 40),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A90D9), Color(0xFF1A56C4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4A90D9).withOpacity(0.4),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              SizedBox(height: 30),

              Text(
                'Two-Factor Authentication',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),

              SizedBox(height: 12),

              Text(
                'Enter the 6-digit code sent to your registered\nemail or authenticator app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 36),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_codeLength, (i) {
                  return KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) => _onKeyEvent(i, event),
                    child: SizedBox(
                      width: 46,
                      height: 56,
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        onChanged: (val) => _onDigitEntered(i, val),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Color(0xFFDDE1EA),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Color(0xFF4A90D9),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 28),

              if (_message.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isError ? Colors.red : Colors.green,
                      fontSize: 13,
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A90D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: Color(0xFF4A90D9).withOpacity(0.4),
                  ),
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              TextButton(
                onPressed: _resendCode,
                child: Text(
                  'Resend Code',
                  style: TextStyle(
                    color: Color(0xFF4A90D9),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),

              SizedBox(height: 12),

              Text(
                "Didn't receive the code? Check your spam\nfolder or try another verification method",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}