import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dream/muyu/record_history.dart';
import 'package:uuid/uuid.dart';

import 'animate_text.dart';
import 'count_panel.dart';
import 'models/audio_option.dart';
import 'models/image_option.dart';
import 'models/merit_record.dart';
import 'muyu_app_bar.dart';
import 'muyu_image.dart';
import 'options/select_audio.dart';
import 'options/select_image.dart';

class MuyuPage extends StatefulWidget {
  const MuyuPage({Key? key}) : super(key: key);

  @override
  State<MuyuPage> createState() => _MuyuPageState();
}

class _MuyuPageState extends State<MuyuPage> {
  int _counter = 0;
  final Random _random = Random();
  AudioPool? pool;
  MeritRecord? _cruRecord;

  final List<ImageOption> imageOptions = const [
    ImageOption('基础版', 'assets/images/muyu.png', 1, 3),
    ImageOption('尊享版', 'assets/images/muyu2.png', 3, 6),
  ];
  int _activeImageIndex = 0;
  // 激活图像
  String get activeImage => imageOptions[_activeImageIndex].src;
  // 敲击是增加值
  int get knockValue {
    int min = imageOptions[_activeImageIndex].min;
    int max = imageOptions[_activeImageIndex].max;
    return min + _random.nextInt(max + 1 - min);
  }

  final List<AudioOption> audioOptions = const [
    AudioOption('音效1', 'muyu_1.mp3'),
    AudioOption('音效2', 'muyu_2.mp3'),
    AudioOption('音效3', 'muyu_3.mp3'),
  ];
  int _activeAudioIndex = 0;
  String get activeAudio => audioOptions[_activeAudioIndex].src;

  List<MeritRecord> _records = [];
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _initAudioPool();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MuyuAppBar(
        onTapHistory: _toHistory,
      ),
      body: Column(
        children: [
          Expanded(
            child: CountPanel(
              count: _counter,
              onTapSwitchAudio: _onTapSwitchAudio,
              onTapSwitchImage: _onTapSwitchImage,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                MuyuAssetsImage(
                  image: activeImage, // 使用激活图像
                  onTap: _onKnock,
                ),
                if (_cruRecord != null) AnimateText(record: _cruRecord!)
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecordHistory( records: _records.reversed.toList()),
      ),
    );
  }

  void _onTapSwitchAudio() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return AudioOptionPanel(
          audioOptions: audioOptions,
          activeIndex: _activeAudioIndex,
          onSelect: _onSelectAudio,
        );
      },
    );
  }

  void _onSelectAudio(int value) async {
    Navigator.of(context).pop();
    if (value == _activeAudioIndex) return;
    _activeAudioIndex = value;
    pool = await FlameAudio.createPool(
      activeAudio,
      maxPlayers: 1,
    );
  }

  void _onTapSwitchImage() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ImageOptionPanel(
          imageOptions: imageOptions,
          activeIndex: _activeImageIndex,
          onSelect: _onSelectImage,
        );
      },
    );
  }

  void _onSelectImage(int value) {
    Navigator.of(context).pop();
    if (value == _activeImageIndex) return;
    setState(() {
      _activeImageIndex = value;
    });
  }

  void _onKnock() {
    pool?.start();

    setState(() {
      String id = uuid.v4();
      _cruRecord = MeritRecord(
        id,
        DateTime.now().millisecondsSinceEpoch,
        knockValue,
        activeImage,
        audioOptions[_activeAudioIndex].name,
      );
      _counter += _cruRecord!.value;
      // 添加功德记录
      _records.add(_cruRecord!);
    });
  }

  void _initAudioPool() async {
    pool = await FlameAudio.createPool(
      'muyu_1.mp3',
      maxPlayers: 4,
    );
  }
}
