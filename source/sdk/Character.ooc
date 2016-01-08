include stdlib

__LINE__: extern Int
__FILE__: extern CString
__FUNCTION__: extern CString

strrchr: extern func (Char*, Int) -> Char*
strcmp: extern func (Char*, Char*) -> Int
strncmp: extern func (Char*, Char*, Int) -> Int
strstr: extern func (Char*, Char*) -> Char*
strlen: extern func (Char*) -> Int
strtol: extern func (Char*, Pointer, Int) -> Long
strtoll: extern func (Char*, Pointer, Int) -> LLong
strtoul: extern func (Char*, Pointer, Int) -> ULong
strtof: extern func (Char*, Pointer) -> Float
strtod: extern func (Char*, Pointer) -> Double

version (!cygwin) {
	strtold: extern func (Char*, Pointer) -> LDouble
} else {
	strtold: func (str: Char*, p: Pointer) -> LDouble {
		strtod(str, p) as LDouble
	}
}

Char: cover from char {
	alphaNumeric: func -> Bool {
		alpha() || digit()
	}
	alpha: func -> Bool {
		lower() || upper()
	}
	lower: func -> Bool {
		this >= 'a' && this <= 'z'
	}
	upper: func -> Bool {
		this >= 'A' && this <= 'Z'
	}
	digit: func -> Bool {
		this >= '0' && this <= '9'
	}
	octalDigit: func -> Bool {
		this >= '0' && this <= '7'
	}
	hexDigit: func -> Bool {
		digit() ||
		(this >= 'A' && this <= 'F') ||
		(this >= 'a' && this <= 'f')
	}
	control: func -> Bool {
		(this >= 0 && this <= 31) || this == 127
	}
	graph: func -> Bool {
		printable() && this != ' '
	}
	printable: func -> Bool {
		this >= 32 && this <= 126
	}
	punctuation: func -> Bool {
		printable() && !alphaNumeric() && this != ' '
	}
	whitespace: func -> Bool {
		this == ' ' ||
		this == '\f' ||
		this == '\n' ||
		this == '\r' ||
		this == '\t' ||
		this == '\v'
	}
	blank: func -> Bool {
		this == ' ' || this == '\t'
	}
	toInt: func -> Int {
		if (digit()) {
			return (this - '0') as Int
		}
		return -1
	}
	toLower: extern (tolower) func -> This
	toUpper: extern (toupper) func -> This
	toString: func -> String {
		String new(this& as CString, 1)
	}
	print: func {
		fputc(this, stdout)
	}
	print: func ~withStream (stream: FStream) {
		fputc(this, stream)
	}
	println: func {
		fputc(this, stdout)
		fputc('\n', stdout)
	}
	println: func ~withStream (stream: FStream) {
		fputc(this, stream)
		fputc('\n', stream)
	}
	containedIn: func (s : String) -> Bool {
		containedIn(s _buffer data, s size)
	}
	containedIn: func ~charWithLength (s : Char*, sLength: SizeT) -> Bool {
		for (i in 0 .. sLength) {
			if ((s + i)@ == this) return true
		}
		return false
	}
	compareWith: func (compareFunc: Func (Char, Char*, SizeT) -> SSizeT, target: Char*, targetSize: SizeT) -> SSizeT {
		compareFunc(this, target, targetSize)
	}
}

SChar: cover from signed char extends Char
UChar: cover from unsigned char extends Char
WChar: cover from wchar_t

operator as (value: Char) -> String { value toString() }
operator as (value: Char*) -> String { value ? value as CString toString() : null }
operator as (value: CString) -> String { value ? value toString() : null }

CString: cover from Char* {
	clone: func -> This {
		length := length()
		copy := This new(length)
		memcpy(copy, this, length + 1)
		return copy as This
	}
	equals: func ( other: This) -> Bool {
		if (other == null) return false
		l := length()
		l2 := length()
		if (l != l2) return false

		for (i in 0 .. l) {
			if (this[i] != other[i]) return false
		}
		return true
	}
	toString: func -> String {
		if (this == null) return null
		String new(this, length())
	}
	length: extern (strlen) func -> Int
	print: func {
		stdout write(this, 0, length())
	}
	println: func {
		stdout write(this, 0, length()). write('\n')
	}
	new: static func ~withLength (length: Int) -> This {
		result := gc_malloc(length + 1) as Char*
		result[length] = '\0'
		result as This
	}
}

operator == (str1: CString, str2: CString) -> Bool {
	if ((str1 == null) || (str2 == null))
		return false
	str1 equals(str2)
}

operator != (str1: CString, str2: CString) -> Bool {
	!(str1 == str2)
}
