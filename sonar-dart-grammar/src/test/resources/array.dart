class Array {
	final List params = [];

	static Request createRequest() {
		Request r = new Request();
		r.params["secure"] = true;
		r.params["x"][1] = 36.0;
		r.params["context"].x = 36.0;
		this.params["tags"] = new ArrayCollection();
		return r;
	}

	static void process() {
		final List keys = [];
	}
}
