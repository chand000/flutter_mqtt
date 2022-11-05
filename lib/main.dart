/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
final client = MqttServerClient('test.mosquitto.org', '');





var pongCount = 0; // Pong counter

Future<int> main() async {
  runApp(HomeApp());
  client.logging(on: true);
  client.setProtocolV311();
  client.keepAlivePeriod = 20;
  client.connectTimeoutPeriod = 2000; // milliseconds
  // client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;
  client.onSubscribed = onSubscribed;
  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      .withWillTopic('esp32/humidity') // If you set this you must set a will message
      .withWillMessage('button1')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  print('EXAMPLE::Mosquitto client connecting....');
  client.connectionMessage = connMess;


  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    // Raised by the client when connection fails.
    print('EXAMPLE::client exception - $e');
    client.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    print('EXAMPLE::socket exception - $e');
    client.disconnect();
  }

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('EXAMPLE::Mosquitto client connected');
  } else {
    print(
        'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
  }

  print('EXAMPLE::Subscribing to the test/lol topic');
  const topic = 'esp32/humidity'; // Not a wildcard topic
  client.subscribe(topic, MqttQos.atMostOnce);

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    print(
        'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    print('');
  });

  client.published!.listen((MqttPublishMessage message) {
    print(
        'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
  });

  const pubTopic = 'Dart/Mqtt_client/testtopic';
  final builder = MqttClientPayloadBuilder();
  builder.addString('Hello from mqtt_client');

  print('EXAMPLE::Subscribing to the Dart/Mqtt_client/testtopic topic');
  client.subscribe(pubTopic, MqttQos.exactlyOnce);

  print('EXAMPLE::Publishing our topic');
  client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);

  return 0;
}

void onSubscribed(String topic) {
  print('EXAMPLE::Subscription confirmed for topic $topic');
}

void onConnected() {
  print(
      'EXAMPLE::OnConnected client callback - Client connection was successful');
}

void pong() {
  print('EXAMPLE::Ping response client callback invoked');
  pongCount++;
}

//----------------------------------------------------------
Future<int> main1() async {
  runApp(HomeApp());
  client.logging(on: true);
  client.setProtocolV311();
  client.keepAlivePeriod = 20;
  client.connectTimeoutPeriod = 2000; // milliseconds
  // client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;
  client.onSubscribed = onSubscribed;
  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      .withWillTopic('esp32/humidity') // If you set this you must set a will message
      .withWillMessage('button2')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  print('EXAMPLE::Mosquitto client connecting....');
  client.connectionMessage = connMess;


  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    // Raised by the client when connection fails.
    print('EXAMPLE::client exception - $e');
    client.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    print('EXAMPLE::socket exception - $e');
    client.disconnect();
  }

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('EXAMPLE::Mosquitto client connected');
  } else {
    print(
        'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
  }


  print('EXAMPLE::Subscribing to the test/lol topic');
  const topic = 'esp32/humidity'; // Not a wildcard topic
  client.subscribe(topic, MqttQos.atMostOnce);

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    print(
        'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    print('');
  });

  client.published!.listen((MqttPublishMessage message) {
    print(
        'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
  });

  const pubTopic = 'Dart/Mqtt_client/testtopic';
  final builder = MqttClientPayloadBuilder();
  builder.addString('Hello from mqtt_client');

  print('EXAMPLE::Subscribing to the Dart/Mqtt_client/testtopic topic');
  client.subscribe(pubTopic, MqttQos.exactlyOnce);

  print('EXAMPLE::Publishing our topic');
  client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);

  return 0;
}


// ----------------from here UI start---------------------------------------------------------

class HomeApp extends StatefulWidget {
  HomeApp({Key? key}) : super(key: key);

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('MQTT'),

            ),
            body: Center (

                child: Column (
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton (
                      child: Text("button1"),
                        onPressed: () => {
                          main()
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.greenAccent),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        )
                    ),
                    TextButton (
                        child: Text("button2"),
                        onPressed: () => {
                          main1()
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.greenAccent),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        )
                    ),

                    Text('subscribe message'),

                  ],
                )
            )
            ));
  }
}


