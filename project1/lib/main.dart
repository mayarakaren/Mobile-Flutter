import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

//Apenas informa ao Flutter para executar o app definido em MyApp.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 68, 75, 116)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

//Os widgets são os elementos que servem como base para a criação de apps do Flutter. Como você pode notar, até o próprio app é um widget.

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

    void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  //O novo método getNext() reatribui o widget current a um novo WordPair aleatório. 
  //Ele também chama notifyListeners() (um método de ChangeNotifier) que envia uma notificação a qualquer elemento que 
  //esteja observando MyAppState.

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

//Define o estado do APP.

// ...

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,  // ← Here.
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}


class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

@override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),

        // ↓ Make the following change.
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

/* 
Ao usar theme.textTheme,, você acessa o tema da fonte do app. Essa classe inclui membros como bodyMedium para texto 
padrão de tamanho médio, caption para legendas de imagens ou headlineLarge para títulos grandes.

A propriedade displayMedium é um estilo grande destinado a texto de exibição. A palavra exibição é usada no sentido 
tipográfico aqui, como em fonte de exibição. A documentação de displayMedium diz que "estilos de 
exibição são reservados para textos curtos e importantes", o que é exatamente nosso caso de uso.
*/

/* 
1 - Cada widget define um método build() que é chamado automaticamente
2 - O widget MyHomePage rastreia mudanças no estado atual do app usando o método watch.
3- Cada metodo build() precisa retornar um widget ou uma árvore aninhada de widgets
4- Esse widget recebe qualquer número de filhos e os coloca em um coluna de cima para baixo.
5- Você mudou o widget Text na primeira etapa.
6- Este segundo widget Text usa o appState e acessa o único membro dessa classe, current (que é um WordPair). 
O WordPair fornece vários getters úteis, como asPascalCase ou asSnakeCase
7- Observe como o código do Flutter faz um uso intenso de vírgulas à direita. Essa vírgula específica não precisa estar 
ali, porque children é o último (e também o único) membro dessa lista de parâmetros Column. No entanto, costuma ser uma 
boa ideia usar vírgulas à direita: elas facilitam adicionar mais membros e também servem como uma dica para o 
autoformatador do Dart colocar uma nova linha ali.
*/