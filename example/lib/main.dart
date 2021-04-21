import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menus/menus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.grey[300],
        ),
        accentColor: Colors.amber,

        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.grey,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RichTextEditor(),
    );
  }
}

class RichTextEditor extends StatefulWidget {
  RichTextEditor({Key? key}) : super(key: key);

  @override
  _RichTextEditorState createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Context Menus'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ContextMenuButton(
                originAligment: Alignment.topCenter,
                aligment: Alignment.bottomCenter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu),
                    SizedBox(width: 20),
                    Text('Cascade Menu'),
                  ],
                ),
                tooltip: 'This is tooltip',
                menu: CascadeContextMenu(
                  width: 200,
                  elevation: 2,
                  actions: actions,
                ),
              ),
              ContextMenuButton(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu),
                    SizedBox(width: 20),
                    Text('Menu 2'),
                  ],
                ),
                menu: CupertinoPullDownMenu(
                  width: 200,
                  elevation: 2,
                  actions: actions,
                ),
              ),
             
              ContextMenuButton(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu),
                    SizedBox(width: 20),
                    Text('Material'),
                  ],
                ),
                menu: MaterialSelectionToolbar(
                  actions: actions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> actions(BuildContext context) {
    return [
      ContextMenuItem(
        title: Row(
          children: [
            Icon(Icons.brush, size: 16),
            SizedBox(width: 10),
            Text('Highlight'),
          ],
        ),
        onPressed: () {
          return true;
        },
      ),
      ContextMenuItem(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          //mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.format_bold_rounded,
              size: 16,
            ),
            SizedBox(
              width: 10,
            ),
            Text('Bold'),
          ],
        ),
        onPressed: () {
          return true;
        },
      ),
      ContextMenuItem(
        title: Row(
          children: [
            Icon(Icons.format_italic, size: 16),
            SizedBox(width: 10),
            Text('Italic'),
          ],
        ),
        onPressed: () {
          return true;
        },
      ),
      Divider(height: 1),
      ContextMenuItem(
        title: Row(
          children: [
            Icon(Icons.copy, size: 16),
            SizedBox(width: 10),
            Text('Copy'),
          ],
        ),
        onPressed: () {
          return true;
        },
      ),
      ContextMenuItem(
        title: Row(
          children: [
            Icon(Icons.paste, size: 16),
            SizedBox(width: 10),
            Text('Paste'),
          ],
        ),
        onPressed: () {
          return true;
        },
      ),
      Divider(height: 1),
      ContextMenuItem(
        title: Row(
          children: [
            Icon(Icons.edit, size: 16),
            SizedBox(width: 10),
            Text('Rename'),
          ],
        ),
        onPressed: () {
          return true;
        },
      ),
      ContextMenuItem.sublist(
          title: Row(
            children: [
              Icon(Icons.more_vert, size: 16),
              SizedBox(width: 10),
              Text('More'),
              Spacer(),
              Icon(Icons.arrow_right_rounded, size: 16),
            ],
          ),
          children: [
            ContextMenuItem(
              title: Row(
                children: [
                  Icon(Icons.arrow_left_rounded, size: 16),
                  SizedBox(width: 10),
                  Text(
                    'More',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
              onPressed: () {
                final menuController = DefaultContextMenuController.of(context);
                menuController.pop();
                return false;
              },
            ),
            ContextMenuItem(
              title: Row(
                children: [
                  Icon(Icons.brush, size: 16),
                  SizedBox(width: 10),
                  Text('Highlight'),
                ],
              ),
              onPressed: () {
                return true;
              },
            ),
            ContextMenuItem(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.ideographic,
                //mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.format_bold_rounded,
                    size: 16,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Bold'),
                ],
              ),
              onPressed: () {
                return true;
              },
            ),
            ContextMenuItem(
              title: Row(
                children: [
                  Icon(Icons.format_italic, size: 16),
                  SizedBox(width: 10),
                  Text('Italic'),
                ],
              ),
              onPressed: () {
                return true;
              },
            ),
          ]),
    ];
  }
}
