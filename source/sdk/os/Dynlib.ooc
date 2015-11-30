use sdk-dynlib

Dynlib: abstract class {
	suffix: static String = ""
	path: String
	success := false

	// If the platform-specific file extension is missing, it will be added
	load: static func (path: String) -> This {
		dl: This = null
		version (windows) {
			dl = DynlibWin32 new(path)
		} else {
			dl = DynlibUnix new(path)
		}
		if (!dl success)
			dl = null
		dl
	}

	// The address of the symbol with a given name.
	symbol: abstract func (name: String) -> Pointer

	// This must be the last called method on a given instance.
	// If a Dynlib is not closed explicitly, it will be freed when the
	close: abstract func -> Bool
}

{
	version (windows) {
		Dynlib suffix = ".dll"
	} else {
		version (apple) {
			Dynlib suffix = ".dylib"
		} else {
			Dynlib suffix = ".so"
		}
	}
}

version (windows) {
	include windows

	HModule: cover from HMODULE
	LoadLibraryA: extern func (path: CString) -> HModule
	GetProcAddress: extern func (module: HModule, name: CString) -> Pointer
	FreeLibrary: extern func (module: HModule) -> Bool

	DynlibWin32: class extends Dynlib {
		handle: HModule
		init: func (=path) {
			handle = LoadLibraryA(path)
			if (!handle) {
				handle = LoadLibraryA(path + suffix)
			}
			success = (handle != null)
		}
		symbol: func (name: String) -> Pointer {
			GetProcAddress(handle, name)
		}
		close: func -> Bool {
			FreeLibrary(handle)
		}
	}
}

version (!windows) {
	include dlfcn
	RTLD_LAZY, RTLD_NOW, RTLD_GLOBAL, RTLD_LOCAL: extern Int

	dlopen: extern func (path: CString, flag: Int) -> Pointer
	dlsym: extern func (handle: Pointer, name: CString) -> Pointer
	dlclose: extern func (handle: Pointer) -> Int

	DynlibUnix: class extends Dynlib {
		handle: Pointer
		init: func (=path) {
			handle = dlopen(path, RTLD_LAZY)
			if (!handle) {
				fullPath := path + suffix
				handle = dlopen(fullPath, RTLD_LAZY)
				fullPath free()
			}
			success = (handle != null)
		}
		symbol: func (name: String) -> Pointer {
			dlsym(handle, name)
		}
		close: func -> Bool {
			dlclose(handle) == 0
		}
	}
}
