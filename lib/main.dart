import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity/connectivity.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:nodecommander/nodecommander.dart';
import 'commands.dart' as cmds;

void main() {
  runApp(VideoApp());
  Wakelock.enable();
  initNode();
}

CommanderNode _commanderNode;
SoldierNode _soldierNode;

Future<void> initNode() async {
  var host = await (Connectivity().getWifiIP());
  _soldierNode = SoldierNode(
      name: "deskovka", commands: cmds.commands, host: host, verbose: true);
  // initialize the node
  await _soldierNode.init();
  // print some info about the node
  _soldierNode.info();
  // idle
  await Completer<void>().future;
}

void initCommander() async {
  var host = await (Connectivity().getWifiIP());
  _soldierNode?.dispose();
  _commanderNode?.dispose();
  _commanderNode = CommanderNode(
      name: "commander",
      commands: cmds.commands,
      host: host,
      port: 8085,
      verbose: true);
  // initialize the node
  await _commanderNode.init();
  // print some info about the node
  _commanderNode.info();
  // Wait for the node to be ready to operate
  await _commanderNode.onReady;

  discoverNodes();
}

void discoverNodes() async {
  _commanderNode.discoverNodes();
  await Future<dynamic>.delayed(const Duration(seconds: 2));
  for (final s in _commanderNode.soldiers) {
    print("Soldier ${s.name} at ${s.address}");
  }
}

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Control page"),
      ),
      body: Column(children: [
        RaisedButton(
          onPressed: () {
            initCommander();
          },
          child: Text('Master node'),
        ),
        RaisedButton(
          onPressed: () {
            _commanderNode.sendCommand(
                cmds.play, _commanderNode.soldierUri("deskovka"));
          },
          child: Text('Play'),
        ),
        RaisedButton(
          onPressed: () {
            _commanderNode.sendCommand(
                cmds.stop, _commanderNode.soldierUri("deskovka"));
          },
          child: Text('Pause'),
        ),
        RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ColorPage()),
            );
          },
          child: Text('Color page'),
        ),
        RaisedButton(
          onPressed: () {
            _commanderNode.sendCommand(cmds.setGreen, _commanderNode.soldierUri("deskovka"));
          },
          color: Colors.green,
        ),
        RaisedButton(
          onPressed: () {
            _commanderNode.sendCommand(cmds.setBlue, _commanderNode.soldierUri("deskovka"));
          },
          color: Colors.blue,
        ),
        RaisedButton(
          onPressed: () {
            _commanderNode.sendCommand(cmds.setRed, _commanderNode.soldierUri("deskovka"));
          },
          color: Colors.red,
        ),
        RaisedButton(
          onPressed: () {
            _commanderNode.sendCommand(cmds.setYellow, _commanderNode.soldierUri("deskovka"));
          },
          color: Colors.yellow,
        ),
        GradientButton(
          child: Text('Party!'),
          callback: () {
            _commanderNode.sendCommand(cmds.setParty, _commanderNode.soldierUri("deskovka"));
          },
          gradient: Gradients.jShine,
          shapeRadius: BorderRadius.all(Radius.circular(3)),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,),
    );
  }
}

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller = VideoPlayerController.file(File('/storage/emulated/0/jumanji.mkv'));
  Future<void> _initializeVideoPlayerFuture;
  StreamSubscription<bool> _sub;

  @override
  void initState() {
    Permission.storage.request();
    _initializeVideoPlayerFuture = _controller.initialize();
    _initializeVideoPlayerFuture.then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller.setLooping(false);
        _sub = cmds.playerStateController.stream.listen((p) => setState(() {
          p ? _controller.play() : _controller.pause();
        }));
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
        title: 'Video',
        home: Builder(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              // ignore: null_aware_in_condition
              child: _controller.value.initialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ControlPage()),
                );
              },
              child: Icon(
                Icons.arrow_forward_ios,
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _commanderNode.dispose();
    _sub.cancel();
  }
}


class ColorPage extends StatefulWidget {
  ColorPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ColorPageState createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  StreamSubscription<String> _sub;
  String _color = "party";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _controller.addListener(() {
      switch(_color) {
        case "red": if(_controller.value > 0 && _controller.value < 0.02) {_controller.stop();} break;
        case "yellow": if(_controller.value > 0.24 && _controller.value < 0.26) {_controller.stop();} break;
        case "green": if(_controller.value > 0.49 && _controller.value < 0.51) {_controller.stop();} break;
        case "blue": if(_controller.value > 0.74 && _controller.value < 0.76) {_controller.stop();} break;
      }
      //if (_color == Colors.yellow &&_controller.value > 0.24 && _controller.value < 0.26) {_controller.stop();}
    });
    _sub = cmds.setColorController.stream.listen((c) => setState(() {
      switch(c) {
        case "red":
        case "green":
        case "blue":
        case "yellow":
          _color = c;
          break;
        case "party":
          _color = "party";
          _controller.repeat();
          break;
        default:
          _color = "party";
          _controller.repeat();
          break;
      }

    }));
  }

  Animatable<Color> background = TweenSequence<Color>([
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.red,
        end: Colors.yellow,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.yellow,
        end: Colors.green,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.green,
        end: Colors.blue,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.blue,
        end: Colors.pink,
      ),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Scaffold(
            body: Container(
              color: background
                  .evaluate(AlwaysStoppedAnimation(_controller.value)),
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}