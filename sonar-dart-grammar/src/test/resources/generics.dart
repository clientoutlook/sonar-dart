import 'dart:core';

class Generics {
	List<int> _list;
	List<int,int> _list2;
	List<List<int>> _listOfLists;

	List<List<int>> get listOfLists {
		return _listOfLists;
	}
}