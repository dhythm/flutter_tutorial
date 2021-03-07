import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  BookRouteDelegate _routerDelegate = BookRouteDelegate();
  BookRouteInfomationParser _routeInformationParser =
      BookRouteInfomationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _routeInformationParser,
      routerDelegate: _routerDelegate,
      title: 'Books App',
    );
  }
}

class BookRouteInfomationParser extends RouteInformationParser<BookRoutePath> {
  @override
  Future<BookRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    // Handle '/'
    if (uri.pathSegments.length == 0) {
      return BookRoutePath.home();
    }

    // Handle '/book/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'book') return BookRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) return BookRoutePath.unknown();
      return BookRoutePath.details(id);
    }

    //Handle unknown routes
    return BookRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(BookRoutePath path) {
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/book/${path.id}');
    }
    return null;
  }
}

class BookRouteDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  final GlobalKey<NavigatorState> navigatroKey;

  Book _selectedBook;
  bool show404 = false;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Rovert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  BookRouteDelegate() : navigatroKey = GlobalKey<NavigatorState>();

  BookRoutePath get currentConfiguration {
    if (show404) {
      return BookRoutePath.unknown();
    }
    return _selectedBook == null
        ? BookRoutePath.home()
        : BookRoutePath.details(books.indexOf(_selectedBook));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
        pages: [
          MaterialPage(
              child: BooksListScreen(
                books: books,
                onTapped: _handleBookTapped,
              ),
              key: ValueKey('BooksListPage')),
          if (show404)
            MaterialPage(child: UnknownScreen(), key: ValueKey('UnknownPage'))
          else if (_selectedBook != null)
            BookDetailsPage(book: _selectedBook)
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          // Update the list of pages by setting _selectedBook to null
          _selectedBook = null;
          show404 = false;
          notifyListeners();

          return true;
        });
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    if (path.isUnknown) {
      _selectedBook = null;
      show404 = true;
      return;
    }

    if (path.isDetailsPage) {
      if (path.id < 0 || path.id > books.length - 1) {
        show404 = true;
        return;
      }

      _selectedBook = books[path.id];
    } else {
      _selectedBook = null;
    }

    show404 = false;
  }

  void _handleBookTapped(Book book) {
    _selectedBook = book;
    notifyListeners();
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTapped;

  BooksListScreen({@required this.books, @required this.onTapped});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            for (var book in books)
              ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () => onTapped(book),
              )
          ],
        ));
  }
}

class BookDetailsPage extends Page {
  final Book book;

  BookDetailsPage({this.book}) : super(key: ValueKey(book));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        builder: (BuildContext context) {
          return BookDetailsScreen(book: book);
        },
        settings: this);
  }
}

class BookRoutePath {
  final int id;
  final bool isUnknown;

  BookRoutePath.home()
      : id = null,
        isUnknown = false;

  BookRoutePath.details(this.id) : isUnknown = false;

  BookRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;
  bool get isDetailsPage => id != null;
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({@required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book != null) ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(
                book.author,
                style: Theme.of(context).textTheme.subtitle1,
              )
            ]
          ],
        ),
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('404!'),
        ));
  }
}
