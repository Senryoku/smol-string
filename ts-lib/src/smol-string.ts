import {
	Uint16ArraytoString,
	copyToWasmBuffer,
	extractFooterU16,
	extractFooterU8,
} from "./common.js";
import init from "./module.wasm?init";

type exportsType = {
	allocUint8: (size: number) => number;
	allocUint16: (size: number) => number;
	compress: (ptr: number, length: number) => number;
	decompress: (ptr: number, length: number) => number;
	free: (ptr: number, length: number) => void;
	memory: WebAssembly.Memory;
};

const instance = await init();
const exports = instance.exports as exportsType;

export function compress(str: string) {
	const { ptr, length } = copyToWasmBuffer(str, exports);

	const ptrToFooter = exports.compress(ptr, length);

	exports.free(ptr, length);

	const { start, capacity, content } = extractFooterU16(
		exports.memory,
		ptrToFooter
	);

	const r = Uint16ArraytoString(content);

	exports.free(start, capacity);

	return r;
}

export function decompress(compressedStr: string) {
	const ptrToCompressed = exports.allocUint16(compressedStr.length);
	const compressed_buffer = new Uint16Array(
		exports.memory.buffer,
		ptrToCompressed,
		compressedStr.length
	);
	for (let i = 0; i < compressedStr.length; i++)
		compressed_buffer[i] = compressedStr.charCodeAt(i);

	const ptrToFooter = exports.decompress(
		ptrToCompressed,
		compressedStr.length
	);

	exports.free(ptrToCompressed, compressedStr.length);

	const { start, capacity, content } = extractFooterU8(
		exports.memory,
		ptrToFooter
	);

	const r = new TextDecoder().decode(content);

	exports.free(start, capacity);

	return r;
}
