import 'package:flutter/material.dart';
import 'package:flutter_tutorial/navigator_1.dart';

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
  void initState() {
    super.initState();
  }

  Book _selectedBook;
  bool show404 = false;
  List<Book> books = [
    Book('Stranger in a Strange Land', 'Rovert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Books App',
        home: Navigator(
          pages: [
            MaterialPage(
                child:
                    BooksListScreen(books: books, onTapped: _handleBookTapped),
                key: ValueKey('BooksListPage')),
            if (show404)
              MaterialPage(key: ValueKey('UnknownPage'), child: UnknownScreen())
            else if (_selectedBook != null)
              MaterialPage(
                  child: BookDetailsScreen(book: _selectedBook),
                  key: ValueKey(_selectedBook))
          ],
          // onPopPage: (route, result) => route.didPop(result),
        ));
  }

  void _handleBookTapped(Book book) {
    setState(() {
      _selectedBook = book;
    });
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
    return PageRouteBuilder(
        settings: this,
        pageBuilder: (context, animation, animation2) {
          final tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero);
          final curveTween = CurveTween(curve: Curves.easeInOut);
          return SlideTransition(
            position: animation.drive(curveTween).drive(tween),
            child: BookDetailsScreen(key: ValueKey(book), book: book),
          );
        });
  }
}
