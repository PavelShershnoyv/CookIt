import 'package:cookit/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'pages/recipes_page.dart';
import 'pages/scanner_page.dart';
import 'pages/fridge_page.dart';
import 'pages/validation_page.dart';
import 'pages/recipe_info_page.dart';
import 'pages/cooking_steps_page.dart';

void main() {
  // Прячем системные панели (статус-бар и навигацию) и оставляем жест для показа
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Делаем статус-бар прозрачным, чтобы контент мог идти под него
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const StartPage()),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
            path: '/recipes', builder: (context, state) => const RecipesPage()),
        GoRoute(
            path: '/scanner', builder: (context, state) => const ScannerPage()),
        GoRoute(
            path: '/fridge', builder: (context, state) => const FridgePage()),
        GoRoute(
            path: '/validation', builder: (context, state) => const ValidationPage()),
        GoRoute(
            path: '/recipe',
            builder: (context, state) => RecipeInfoPage.fromState(state)),
        GoRoute(
            path: '/recipe/steps',
            builder: (context, state) => CookingStepsPage.fromState(state)),
      ],
      initialLocation: '/',
    );

    return MaterialApp.router(
      title: 'Cooking App',
      debugShowCheckedModeBanner: false,
      // Базовая тема + Montserrat для всего проекта
      theme: (() {
        final base = ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          useMaterial3: true,
        );
        return base.copyWith(
          textTheme: GoogleFonts.montserratTextTheme(base.textTheme),
          primaryTextTheme:
              GoogleFonts.montserratTextTheme(base.primaryTextTheme),
        );
      })(),
      routerConfig: router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
