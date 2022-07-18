import sys.FileSystem;
import sys.io.File;

final DEFAULT_SUBMODULE_DIR = "haxe_modules";
final CONFIG_FILE = ".haxe_gsm_config";

typedef Config = {
	submoduleDir:String
}

private var configData:Null<Config>;

private function getConfig() {
	if (configData == null) {
		configData =
			if (FileSystem.exists(CONFIG_FILE) && !FileSystem.isDirectory(CONFIG_FILE))
				haxe.Json.parse(File.getContent(CONFIG_FILE));
			else
				{submoduleDir: DEFAULT_SUBMODULE_DIR};
	}
	return configData;
}

function getSubmoduleDir() {
	return getConfig().submoduleDir;
}

function initConfig(?folder:String) {
	configData = {submoduleDir: folder ?? DEFAULT_SUBMODULE_DIR};
	if (folder != null) {
		File.saveContent(CONFIG_FILE, haxe.Json.stringify(configData, "\t"));
	}
}

function clearConfig() {
	configData = {submoduleDir: DEFAULT_SUBMODULE_DIR};
	if (FileSystem.exists(CONFIG_FILE) && !FileSystem.isDirectory(CONFIG_FILE))
		FileSystem.deleteFile(CONFIG_FILE);
}
