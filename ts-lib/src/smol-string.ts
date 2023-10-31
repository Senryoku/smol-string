import { Uint16ArraytoString, copyToWasmBuffer } from "./common.js";
import init from "./module.wasm?init";

type exportsType = {
	allocUint8: (size: number) => number;
	allocUint16: (size: number) => number;
	compress: (ptr: number) => number;
	decompress: (ptr: number) => number;
	free: (ptr: number, length: number) => void;
	memory: any;
};

const instance = await init();
const exports = instance.exports as exportsType;

export function compress(str: string) {
	const { ptr, length } = copyToWasmBuffer(str, exports);

	const ptrToCompressed = exports.compress(ptr);

	exports.free(ptr, length);

	const buffer = new Uint16Array(
		exports.memory.buffer.slice(
			ptrToCompressed,
			ptrToCompressed +
				(exports.memory.buffer.byteLength - ptrToCompressed)
		)
	);
	const end = buffer.indexOf(0);
	const compressed = buffer.slice(0, end);

	const r = Uint16ArraytoString(compressed);

	exports.free(ptrToCompressed, end + 1);

	return r;
}

export function decompress(compressedStr: string) {
	const ptrToCompressedNullTerminated = exports.allocUint16(
		compressedStr.length + 1
	);
	const compressed_buffer = new Uint16Array(
		exports.memory.buffer,
		ptrToCompressedNullTerminated,
		compressedStr.length + 1
	);
	for (let i = 0; i < compressedStr.length; i++)
		compressed_buffer[i] = compressedStr.charCodeAt(i);
	compressed_buffer[compressedStr.length] = 0;

	const ptrToDecompressedNullTerminated = exports.decompress(
		ptrToCompressedNullTerminated
	);

	exports.free(ptrToCompressedNullTerminated, compressedStr.length + 1);

	const decompressed_buffer = new Uint8Array(
		exports.memory.buffer.slice(
			ptrToDecompressedNullTerminated,
			ptrToDecompressedNullTerminated +
				(exports.memory.buffer.byteLength -
					ptrToDecompressedNullTerminated)
		)
	);
	const decompressed_end = decompressed_buffer.indexOf(0);

	exports.free(ptrToDecompressedNullTerminated, decompressed_end + 1);

	const r = new TextDecoder().decode(
		decompressed_buffer.slice(0, decompressed_end)
	);

	return r;
}
