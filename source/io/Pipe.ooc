import native/[PipeUnix, PipeWin32]
import io/[Reader, Writer]

Pipe: abstract class {
	eof := false
	read: func ~char -> Char {
		c: Char
		howmuch := read(c& as CString, 1)
		if (howmuch == -1)
			c = '\0'
		c
	}
	read: func ~string (len: Int) -> String {
		buf := gc_malloc(len + 1) as CString
		howmuch := read(buf, len)
		if (howmuch == -1)
			return null
		buf[howmuch] = '\0'
		buf toString()
	}
	read: func ~buffer (buf: CharBuffer) -> Int {
		bytesRead := read(buf data, buf capacity)
		if (bytesRead >= 0) {
			buf setLength(bytesRead)
		}
		bytesRead
	}
	read: abstract func ~cstring (buf: CString, len: Int) -> Int
	write: func ~string (str: String) -> Int {
		write(str _buffer data, str length())
	}
	write: abstract func (data: CString, len: Int) -> Int
	close: abstract func (mode: Char) -> Int
	close: abstract func ~both
	setNonBlocking: func ~both {
		this setNonBlocking('r')
		this setNonBlocking('w')
	}
	setNonBlocking: func (end: Char) {
		raise("This platform doesn't support non-blocking pipe I/O.")
	}
	SetBlocking: func ~both {
		this setBlocking('r')
		this setBlocking('w')
	}
	setBlocking: func (end: Char) {
		raise("This platform doesn't support blocking pipe I/O.")
	}
	eof: func -> Bool {
		this eof
	}
	reader: func -> PipeReader {
		PipeReader new(this)
	}
	writer: func -> PipeWriter {
		PipeWriter new(this)
	}
	new: static func -> This {
		version(unix || apple) {
			return PipeUnix new() as This
		}
		version(windows) {
			return PipeWin32 new() as This
		}
		Exception new(This, "Unsupported platform!\n") throw()
		null
	}
}

PipeReader: class extends Reader {
	pipe: Pipe
	init: func (=pipe)
	read: override func (chars: CString, offset: Int, count: Int) -> SizeT {
		bytesRead := pipe read(chars + offset, count)
		// the semantics of Reader read() don't specify negative return values
		bytesRead >= 0 ? bytesRead : 0
	}
	read: override func ~char -> Char {
		bytesRead := pipe read()
		// the semantics of Reader read() don't specify negative return values
		bytesRead >= 0 ? bytesRead : 0
	}
	hasNext?: override func -> Bool {
		!pipe eof()
	}
	mark: override func -> Long {
		raise("Seeking is not supported for this source")
		-1
	}
	seek: override func (offset: Long, mode: SeekMode) -> Bool {
		raise("Seeking is not supported for this source")
		false
	}
	close: override func {
		pipe close('r')
	}
}

PipeWriter: class extends Writer {
	pipe: Pipe
	init: func (=pipe)
	write: override func ~chr (chr: Char) {
		pipe write(chr&, 1)
	}
	write: override func (bytes: CString, length: SizeT) -> SizeT {
		pipe write(bytes, length)
	}
	close: override func {
		pipe close('w')
	}
}
