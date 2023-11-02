export function copyToWasmBuffer(
	str: string,
	exports: { allocUint8: (size: number) => number; memory: any }
) {
	// There's also an 'encodeInto' method to avoid a copy, but by encoding first, we con allocate only exactly what we need.
	const utf8Str = new TextEncoder().encode(str);
	const ptrToStr = exports.allocUint8(utf8Str.length);
	const inBuffer = new Uint8Array(
		exports.memory.buffer,
		ptrToStr,
		utf8Str.length
	);
	inBuffer.set(utf8Str); // Copy to WASM buffer.

	return { ptr: ptrToStr, length: utf8Str.length };
}

// Horrible. Surely we can do better...
export function Uint16ArraytoString(buf: Uint16Array) {
	const strBuilder = new Array(buf.length);
	for (let i = 0; i < buf.length; i++)
		strBuilder[i] = String.fromCharCode(buf[i]);
	return strBuilder.join("");
}

export function extractFooterU8(
	memory: WebAssembly.Memory,
	ptrToFooter: number
) {
	const footer = new Uint8Array(
		memory.buffer.slice(ptrToFooter, ptrToFooter + 8)
	);
	const streamLength =
		(footer.at(0)! << 24) +
		(footer.at(1)! << 16) +
		(footer.at(2)! << 8) +
		footer.at(3)!;
	const capacity =
		(footer.at(4)! << 24) +
		(footer.at(5)! << 16) +
		(footer.at(6)! << 8) +
		footer.at(7)!;
	const start = ptrToFooter - streamLength;

	const content = new Uint8Array(memory.buffer.slice(start, ptrToFooter));

	return {
		start,
		capacity,
		content,
	};
}

export function extractFooterU16(
	memory: WebAssembly.Memory,
	ptrToFooter: number
) {
	const footer = new Uint16Array(
		memory.buffer.slice(ptrToFooter, ptrToFooter + 8)
	);
	const streamLength = (footer.at(0)! << 16) + footer.at(1)!;
	const capacity = (footer.at(2)! << 16) + footer.at(3)!;
	const start = ptrToFooter - 2 * streamLength;
	const content = new Uint16Array(memory.buffer.slice(start, ptrToFooter));

	return {
		start,
		capacity,
		content,
	};
}
