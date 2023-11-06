import {
	Uint16ArraytoString,
	copyToWasmBuffer,
	extractFooter,
} from "./common.js";
import init from "./module-packed.wasm?init";

type exportsType = {
	allocUint8: (size: number) => number;
	allocUint16: (size: number) => number;
	compressPacked: (ptr: number, length: number) => number;
	decompressPacked: (
		ptr: number,
		length: number,
		tokenCount: number
	) => number;
	free: (ptr: number, length: number) => void;
	memory: WebAssembly.Memory;
};

const instance = await init();
const exports = instance.exports as exportsType;

export function compressPacked(str: string) {
	const { ptr, length } = copyToWasmBuffer(str, exports);

	const ptrToFooter = exports.compressPacked(ptr, length);

	exports.free(ptr, length);

	//console.log(ptrToFooter);

	const { start, end, capacity } = extractFooter(exports.memory, ptrToFooter);

	//console.log(start, end, capacity / (1024 * 1024));

	// Includes the tokenCount at the end of the stream (2 * u16).
	const compressed = new Uint16Array(exports.memory.buffer.slice(start, end));

	const r = Uint16ArraytoString(compressed);

	exports.free(start, capacity);

	return r;
}

export function decompressPacked(compressedStr: string) {
	const tokenCount =
		(compressedStr.charCodeAt(compressedStr.length - 1)! << 16) +
		compressedStr.charCodeAt(compressedStr.length - 2);

	let ptrToCompressed = exports.allocUint16(compressedStr.length - 2);
	let compressed_buffer = new Uint16Array(
		exports.memory.buffer,
		ptrToCompressed,
		compressedStr.length - 2
	);

	for (let i = 0; i < compressedStr.length - 2; i++)
		compressed_buffer[i] = compressedStr.charCodeAt(i);

	const ptrToFooter = exports.decompressPacked(
		ptrToCompressed,
		compressedStr.length - 2,
		tokenCount
	);

	exports.free(ptrToCompressed, 2 * (compressedStr.length - 2));

	const { start, end, capacity } = extractFooter(exports.memory, ptrToFooter);
	const content = new Uint8Array(exports.memory.buffer.slice(start, end));
	const r = new TextDecoder().decode(content);

	exports.free(start, capacity);

	return r;
}
