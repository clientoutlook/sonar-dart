class Assignment {
	void calc() {
		_maxSize -= _initSize;
		(view as BaseView).x.y = (view as BaseView).x.y.f(1);

		List<String> collapseCompareColumns(Map columnMap) => (
			<String>[for (var list in columnMap.values) ...list] // flaten all lists into one
			.toSet() // makes unique
			.map((layoutName) => ScreenLayoutUtils.getLayoutByName(layoutName)) // screenlayout needed for sort
			.where((layout) => layout != null)
			.toList()
			..sort(_layoutCompare))
			.map((layout) => layout.name)
			.toList();
	}
}