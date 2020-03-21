var _visited = false;

class Initialization {
	InitProxy proxy = new ClassConstructionProxy("Request", () => new Request(), Request.from, Request.to);

	void f() {
		_zone.run(() => _cdr.markForCheck());
		keys.firstWhere((k) => keys[k] == mode, orElse: () => 1);
	}
}
