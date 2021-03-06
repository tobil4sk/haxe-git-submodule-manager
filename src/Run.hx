import haxe.Exception;
import haxe.io.Path;
import sys.FileSystem;

using StringTools;

macro function getVersion() {
	final version:String = try {
		haxe.Json.parse(sys.io.File.getContent("haxelib.json")).version;
	} catch (e) {
		trace(e);
		Sys.print("haxelib.json for `git-submodule-manager` not found.");
		"UNKNOWN";
	}
	return macro $v{version};
}

function runCmd(cmd:String, ...args:String) {
	final process = new sys.io.Process(cmd, args.toArray());
	final exitCode = process.exitCode();
	final stderr = process.stderr.readAll().toString().trim();
	process.close();
	if (exitCode != 0)
		throw new Exception('Failed when running $cmd:\n$stderr');
}

/** Runs a git command. **/
final runGit = runCmd.bind("git");

/** Runs a haxelib command. **/
final runHaxelib = runCmd.bind("haxelib");

function init(?folder) {
	Config.initConfig(folder);

	final submoduleDir = Config.getSubmoduleDir();

	if (FileSystem.exists(submoduleDir))
		throw new Exception("This folder already contains a submodule folder.");
	FileSystem.createDirectory(submoduleDir);
	try {
		runHaxelib("newrepo");
	} catch (e) {
		// already exists
	}
	Sys.println('Haxe module directory initialised at $submoduleDir');
	Sys.println("Add `/.haxelib/` to .gitignore");
}

function delete() {
	FileSystem.deleteDirectory(Config.getSubmoduleDir());
	Config.clearConfig();
	//runHaxelib("deleterepo");
}

function install() {
	Sys.println("Updating submodules...");
	runGit("submodule", "update", "--init", "--recursive");
	try {
		runHaxelib("newrepo");
	} catch (e) {}

	final projects = FileSystem.readDirectory(Config.getSubmoduleDir());
	for (name in projects) {
		runHaxelib("dev", name, getModulePath(name));
	}
}

function getModulePath(name:String) {
	return Path.join([Config.getSubmoduleDir(), name]);
}

function add(name:String, url:String) {
	Sys.println('adding $name $url');
	final modulePath = getModulePath(name);
	try {
		runGit("submodule", "add", "--force", url, modulePath);
		runHaxelib("dev", name, modulePath);
	} catch(e) {
		try {
			runGit("rm", modulePath);
		} catch(_) {}
		throw e;
	}
}

function remove(name:String) {
	final modulePath = getModulePath(name);
	if (!FileSystem.exists(modulePath))
		throw new Exception('No project found with name $name');
	runGit("rm", "-r", getModulePath(name));
	runHaxelib("dev", name);
	try {
		runHaxelib("remove", name);
	} catch (e) {
		// only works if no other versions are installed
	}
}

function help() {
	Sys.println('Haxe Git Submodule Manager ${getVersion()}');

	Sys.println("Usage:");

	final COLUMN_SIZE = 20;

	function document(cmd:String, params:Array<String>, doc:String) {
		final usage = cmd + " " + params.join(" ");
		final padded = usage.rpad(" ", COLUMN_SIZE);
		Sys.println('  $padded : $doc');
	}

	document("init", ["[directory]"], "Initialise scope. Optionally specify a directory to use a non-default submodule directory.");
	document("add", ["<name>", "<url>"], "Add submodule `name` from `url`");
	document("install", [], "Install dependencies for existing project");
	document("remove", ["<name>"], "Remove submodule `name` from project");
}

function parseArgs(args:Array<String>) {
	switch args {
		case ["init"]: init();
		case ["init", folder]: init(folder);
		//case ["delete"]: delete();
		case ["install"]: install();
		case ["add", name, url]: add(name, url);
		case ["remove", name]: remove(name);
		case [] | ["help"] | ["--help"] | ["-h"]: help();
		default:
			Sys.println("Invalid usage");
			help();
	}
}

function main() {
	final args = Sys.args();
	Sys.setCwd(args.pop());

	try {
		parseArgs(args);
	} catch (e) {
		Sys.stderr().writeString('Error: $e\n');
		Sys.stderr().flush();
		Sys.exit(1);
	}
}
