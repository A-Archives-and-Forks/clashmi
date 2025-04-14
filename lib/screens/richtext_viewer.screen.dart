//import 'package:flutter/gestures.dart';
import 'package:clashmi/i18n/strings.g.dart';
import 'package:clashmi/screens/theme_config.dart';
import 'package:clashmi/screens/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RichtextViewScreen extends LasyRenderingStatefulWidget {
  static RouteSettings routSettings() {
    return const RouteSettings(name: "RichtextViewScreen");
  }

  final String title;
  final String file;
  final String content;
  const RichtextViewScreen(
      {super.key,
      required this.title,
      required this.file,
      required this.content});

  @override
  State<RichtextViewScreen> createState() => _RichtextViewScreenState();
}

class _RichtextViewScreenState extends LasyRenderingState<RichtextViewScreen> {
  String? _res;
  //final TapGestureRecognizer _tgr1 = TapGestureRecognizer();
  //final TapGestureRecognizer _tgr2 = TapGestureRecognizer();
  @override
  void initState() {
    super.initState();
    if (widget.file.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 10), () async {
        try {
          _res = await rootBundle.loadString(widget.file, cache: false);
        } catch (err) {
          _res = "load ${widget.file} failed: ${err.toString()}";
        }
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else if (widget.content.isNotEmpty) {
      _res = widget.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tcontext = Translations.of(context);
    Size windowSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 50,
                      height: 30,
                      child: Icon(
                        Icons.arrow_back_ios_outlined,
                        size: 26,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: windowSize.width - 50 * 2,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: ThemeConfig.kFontWeightTitle,
                          fontSize: ThemeConfig.kFontSizeTitle),
                    ),
                  ),
                  widget.content.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            try {
                              Clipboard.setData(
                                  ClipboardData(text: widget.content));
                            } catch (e) {}
                          },
                          child: Tooltip(
                              message: tcontext.meta.copy,
                              child: const SizedBox(
                                width: 50,
                                height: 30,
                                child: Icon(
                                  Icons.copy,
                                  size: 26,
                                ),
                              )),
                        )
                      : const SizedBox(width: 50),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text.rich(
                            TextSpan(
                              text: _res ?? "",
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
