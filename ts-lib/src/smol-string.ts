import {
	Uint16ArraytoString,
	copyToWasmBuffer,
	extractFooter,
} from "./common.js";
import init from "./module.wasm?init";

type exportsType = {
	allocUint8: (size: number) => number;
	allocUint16: (size: number) => number;
	compress: (ptr: number, length: number) => number;
	decompress: (
		ptr: number,
		length: number,
		tokenCount: number,
		expectedOutputSize: number
	) => number;
	free: (ptr: number, length: number) => void;
	memory: WebAssembly.Memory;
};

const instance = await init();
const exports = instance.exports as exportsType;

export function compress(str: string) {
	const { ptr, length } = copyToWasmBuffer(str, exports);

	const ptrToFooter = exports.compress(ptr, length);

	exports.free(ptr, length);

	if (ptrToFooter < 0) throw new Error("Error compressing string.");

	const { start, end, capacity } = extractFooter(exports.memory, ptrToFooter);

	// Includes the tokenCount at the end of the stream (2 * u16).
	const compressed = new Uint16Array(exports.memory.buffer.slice(start, end));

	const r = Uint16ArraytoString(compressed);

	exports.free(start, capacity);

	return r;
}

export function decompress(compressedStr: string) {
	const tokenCount =
		(compressedStr.charCodeAt(compressedStr.length - 3)! << 16) +
		compressedStr.charCodeAt(compressedStr.length - 4);
	const expectedOutputSize =
		(compressedStr.charCodeAt(compressedStr.length - 1)! << 16) +
		compressedStr.charCodeAt(compressedStr.length - 2);

	const dataLength = compressedStr.length - 4;

	let ptrToCompressed = exports.allocUint16(dataLength);
	let compressed_buffer = new Uint16Array(
		exports.memory.buffer,
		ptrToCompressed,
		dataLength
	);

	for (let i = 0; i < dataLength; i++)
		compressed_buffer[i] = compressedStr.charCodeAt(i);

	const ptrToFooter = exports.decompress(
		ptrToCompressed,
		dataLength,
		tokenCount,
		expectedOutputSize
	);

	exports.free(ptrToCompressed, 2 * dataLength);

	if (ptrToFooter < 0) throw new Error("Error decompressing string.");

	const { start, end, capacity } = extractFooter(exports.memory, ptrToFooter);
	const content = new Uint8Array(exports.memory.buffer.slice(start, end));
	const r = new TextDecoder().decode(content);

	exports.free(start, capacity);

	return r;
}
