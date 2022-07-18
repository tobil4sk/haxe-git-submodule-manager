# Haxe Git Submodule Manager

Tool for managing [Haxe](https://github.com/HaxeFoundation) dependencies as git submodules.

This tool allows for the confidence of knowing that your dependencies will stay locked in place without the hassle of having to manually specify `-cp` arguments to the haxe compiler.

## About

Haxe has a long standing issue with not having a standard way of locking down dependencies. Along with [lix](https://github.com/lix-pm/lix.client) and [hmm](https://github.com/andywhite37/hmm), a solution some people like to use is locking down dependencies using git submodules. However, this quickly becomes a laborious task, as submodules have to be managed manually. Additionally, various extra library-specific arguments have to be manually added for each dependency, as haxe can no longer resolve `-lib` arguments because the libraries are no longer in the standard location.

This tool addresses the problem by managing these submodules in a way that is compatible with haxe and haxelib, such that the libraries can be added to the project via regular `-lib` arguments to the compiler. In practice, this means that using this tool in an existing project requires no modifications to existing build files.

Additionally, developers who clone a project making use of this tool only have to run one command to reproduce a compilable state (à la `npm install`), thanks to the locked down nature of git submodules.

## Limitations

Although this tool ensures that all haxe library dependencies are locked down (assuming they have been added as submodules), it does not take care of the haxe compiler version. This means builds aren't fully reproducible, as updates to the compiler may sometimes break code. Other tools such as [lix](https://github.com/lix-pm/lix.client) may be a better choice if this is a concern.

## Installation

Firstly, both `haxelib` and `git` must be available via the system `PATH`.

For global use:

```bash
haxelib git gsm https://github.com/tobil4sk/haxe-git-submodule-manager.git

haxelib --global run gsm ... # the --global flag is always required
```

For local use:

```bash
haxelib newrepo
haxelib git gsm https://github.com/tobil4sk/haxe-git-submodule-manager.git

haxelib run gsm ...
```

## Usage

### Adding to a Project

To use this tool with a new/existing git project, run:

```bash
haxelib run gsm init
```

This creates and sets up a directory for submodules, which is `haxe_modules` by default. To specify a custom submodule directory, add the directory to the command:

```bash
haxelib run gsm init other-directory
```

After initialising, the hidden `.haxelib` folder must be added to `.gitignore`. Everything else should be checked into version control.

Then, to add git dependencies as submodules, run:

```bash
haxelib run gsm add [name] [url]

# for example:
haxelib run gsm add heaps https://github.com/HeapsIO/heaps.git
haxelib run gsm add format https://github.com/HaxeFoundation/format.git
...

git commit -m "Add dependencies"
```

NOTE: You must repeat this for all your dependencies and the dependencies of your dependencies. Haxe will tell you if a library is missing.

Now you can carry on using your libraries as normal (by passing the `-lib` argument to haxe).

To remove a dependency, run:

```bash
haxelib run gsm remove [name]

# for example:
haxelib run gsm remove heaps
git commit -m "Remove dependency"
```

### Cloning a Project

If you clone a project which uses this tool, to get and setup the dependencies, run:

```bash
haxelib run gsm install
```

This clones the submodules (if they haven't been cloned already) and sets them up for use by haxe.

## Future plans

- Command for updating dependencies?
- Set up alias for easier usage
