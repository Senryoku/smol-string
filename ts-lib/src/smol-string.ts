import { Uint16ArraytoString, copyToWasmBuffer } from "./common.js";
import init from "./module.wasm?init";

type exportsType = {
	allocUint8: (size: number) => number;
	allocUint16: (size: number) => number;
	compress: (ptr: number, length: number) => number;
	decompress: (ptr: number, length: number) => number;
	free: (ptr: number, length: number) => void;
	memory: any;
};

const instance = await init();
const exports = instance.exports as exportsType;

export function compress(str: string) {
	const { ptr, length } = copyToWasmBuffer(str, exports);

	const ptrToFooter = exports.compress(ptr, length);

	exports.free(ptr, length);

	const footer = new Uint16Array(
		exports.memory.buffer.slice(ptrToFooter, ptrToFooter + 8)
	);
	const streamLength = (footer.at(0)! << 16) + footer.at(1)!;
	const capacity = (footer.at(2)! << 16) + footer.at(3)!;
	const start = ptrToFooter - 2 * streamLength;

	const compressed = new Uint16Array(
		exports.memory.buffer.slice(start, ptrToFooter)
	);

	const r = Uint16ArraytoString(compressed);

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

	const footer = new Uint8Array(
		exports.memory.buffer.slice(ptrToFooter, ptrToFooter + 8)
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

	const decompressed = new Uint8Array(
		exports.memory.buffer.slice(start, ptrToFooter)
	);

	const r = new TextDecoder().decode(decompressed);

	exports.free(start, capacity);

	return r;
}
