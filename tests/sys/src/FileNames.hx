class FileNames {
	static public var names(default, never) = [
		"ok",

		// a space inside
		"two words",

		// Chinese, Japanese
		#if !(cs || python || php || neko || cpp)
		"中文，にほんご",
		#end

		// "aaa...a"
		[for (i in 0...100) "a"].join(""),
	].concat(switch (Sys.systemName()) {
		case "Windows":
			// http://stackoverflow.com/a/265782/267998
			[];
		case _:
		[
			// 255 bytes is the max filename length according to http://en.wikipedia.org/wiki/Comparison_of_file_systems
			#if !(python || neko || cpp || java)
			[for (i in 0...255) "a"].join(""),
			#end
		];
	});
}