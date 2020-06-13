import 'package:nodecommander/nodecommander.dart';
import 'dart:async';

final List<NodeCommand> commands = <NodeCommand>[play, stop, setRed, setGreen, setBlue, setYellow, setParty];

bool playing = false;
String currentColor = "black";

final StreamController<bool> playerStateController = StreamController<bool>();
final StreamController<String> setColorController = StreamController<String>();

final NodeCommand play = NodeCommand.define(
    name: "play",

    /// The code executed on the soldier
    executor: (cmd) async {
      playing = true;
      playerStateController.sink.add(playing);
      return cmd.copyWithPayload(<String, dynamic>{"response": playing});
    });

final NodeCommand stop = NodeCommand.define(
    name: "stop",

    /// The code executed on the soldier
    executor: (cmd) async {
      playing = false;
      playerStateController.sink.add(playing);
      return cmd.copyWithPayload(<String, dynamic>{"response": playing});
    });

final NodeCommand setRed = NodeCommand.define(
    name: "set red",

    executor: (cmd) async {
      currentColor = "red";
      setColorController.sink.add(currentColor);
      return cmd.copyWithPayload(<String, dynamic>{"response": currentColor});
    });

final NodeCommand setGreen = NodeCommand.define(
    name: "set green",

    executor: (cmd) async {
      currentColor = "green";
      setColorController.sink.add(currentColor);
      return cmd.copyWithPayload(<String, dynamic>{"response": currentColor});
    });

final NodeCommand setBlue = NodeCommand.define(
    name: "set blue",

    executor: (cmd) async {
      currentColor = "blue";
      setColorController.sink.add(currentColor);
      return cmd.copyWithPayload(<String, dynamic>{"response": currentColor});
    });

final NodeCommand setYellow = NodeCommand.define(
    name: "set yellow",

    executor: (cmd) async {
      currentColor = "yellow";
      setColorController.sink.add(currentColor);
      return cmd.copyWithPayload(<String, dynamic>{"response": currentColor});
    });

final NodeCommand setParty = NodeCommand.define(
    name: "set party",

    executor: (cmd) async {
      currentColor = "party";
      setColorController.sink.add(currentColor);
      return cmd.copyWithPayload(<String, dynamic>{"response": currentColor});
    });