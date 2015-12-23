class TestCommandBase extends haxe.unit.TestCase {
	function run(cmd:String, ?args:Array<String>):Int {
		throw "should be overridden";
	}

	#if !php //FIXME https://github.com/HaxeFoundation/haxe/issues/3603#issuecomment-86437474
	function testCommand() {
		var bin = sys.FileSystem.absolutePath(TestArguments.bin);
		var args = TestArguments.expectedArgs;

		#if !(cs || cpp)
		var exitCode = run("haxe", ["compile-each.hxml", "--run", "TestArguments"].concat(args));
		if (exitCode != 0)
			trace(sys.io.File.getContent(TestArguments.log));
		assertEquals(0, exitCode);
		#end

		var exitCode =
			#if (macro || interp)
				run("haxe", ["compile-each.hxml", "--run", "TestArguments"].concat(args));
			#elseif cpp
				run(bin, args);
			#elseif cs
				switch (Sys.systemName()) {
					case "Windows":
						run(bin, args);
					case _:
						run("mono", [bin].concat(args));
				}
			#elseif java
				run("java", ["-jar", bin].concat(args));
			#elseif python
				run("python3", [bin].concat(args));
			#elseif neko
				run("neko", [bin].concat(args));
			#elseif php
				run("php", [bin].concat(args));
			#else
				-1;
			#end
		if (exitCode != 0)
			trace(sys.io.File.getContent(TestArguments.log));
		assertEquals(0, exitCode);
	}

	#if !cs //FIXME
	function testCommandName() {
		// This is just a script that behaves like ExitCode.hx, 
		// which exits with the code same as the first given argument. 
		// var scriptContent = switch (Sys.systemName()) {
		// 	case "Windows":
		// 		'@echo off\nexit /b %1';
		// 	case "Mac", "Linux", _:
		// 		'#!/bin/sh\nexit $1';
		// }
		// var scriptExt = switch (Sys.systemName()) {
		// 	case "Windows":
		// 		".bat";
		// 	case "Mac", "Linux", _:
		// 		".sh";
		// }

		switch (Sys.systemName()) {
			case "Windows":
				var gcc = Sys.command("cl", ["src/ExitCode.c", "/Fobin", "/link", "/out:bin/ExitCode.exe"]);
				if (gcc != 0)
					throw "cannot compile ExitCode";
			case "Mac", "Linux", _:
				var gcc = Sys.command("gcc", ["src/ExitCode.c", "-o", "bin/ExitCode"]);
				if (gcc != 0)
					throw "cannot compile ExitCode";
		}
		
		var binExt = switch (Sys.systemName()) {
			case "Windows":
				".exe";
			case "Mac", "Linux", _:
				"";
		}

		for (name in FileNames.names) {
			if ((name + binExt).length < 256) {
				var path = sys.FileSystem.absolutePath("temp/" + name + binExt);
				// sys.io.File.saveContent(path, scriptContent);
				sys.io.File.copy("bin/ExitCode" + binExt, path);
				switch (Sys.systemName()) {
					case "Mac", "Linux":
						var exitCode = run("chmod", ["a+x", path]);
						assertEquals(0, exitCode);
					case "Windows":
						//pass
				}

				Sys.sleep(0.1);

				var random = Std.random(256);
				var exitCode = try {
					run(path, [Std.string(random)]);
				} catch (e:Dynamic) {
					trace(e);
					trace(name);
					throw e;
				}
				if (exitCode != random)
					trace(name);
				assertEquals(random, exitCode);
				sys.FileSystem.deleteFile(path);
			}
		}
	}
	#end //!cs

	function testExitCode() {
		var bin = sys.FileSystem.absolutePath(ExitCode.bin);

		// Just test only a few to save time.
		// They have special meanings: http://tldp.org/LDP/abs/html/exitcodes.html
		var codes = [0, 1, 2, 126, 127, 128, 130, 255];

		for (code in codes) {
			var args = [Std.string(code)];
			var exitCode = run("haxe", ["compile-each.hxml", "--run", "ExitCode"].concat(args));
			assertEquals(code, exitCode);
		}

		for (code in codes) {
			var args = [Std.string(code)];
			var exitCode =
				#if (macro || interp)
					run("haxe", ["compile-each.hxml", "--run", "ExitCode"].concat(args));
				#elseif cpp
					run(bin, args);
				#elseif cs
					switch (Sys.systemName()) {
						case "Windows":
							run(bin, args);
						case _:
							run("mono", [bin].concat(args));
					}
				#elseif java
					run("java", ["-jar", bin].concat(args));
				#elseif python
					run("python3", [bin].concat(args));
				#elseif neko
					run("neko", [bin].concat(args));
				#elseif php
					run("php", [bin].concat(args));
				#else
					-1;
				#end
			assertEquals(code, exitCode);
		}
	}
	#end
}