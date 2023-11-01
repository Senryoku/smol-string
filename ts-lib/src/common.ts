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
